with Ada.Text_IO,                       -- string output
     Ada.Integer_Text_IO,               -- integer output
     Ada.Command_Line,                  -- arguments from command line
     Ada.Real_Time,                     -- clock, time, etc.
     Ada.Exceptions,                    -- exceptions
     Ada.Numerics.Discrete_Random;

use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Command_Line, Ada.Real_Time,
	Ada.Exceptions;

procedure Workplace is

    -- N : Number of workers
    -- K : Number of gloves
    -- L : Left hand
    -- R : Right hand
    N, K, L, R : Natural;

    -- Type of hand (LEFT, RIGHT)
    type Hand is (LEFT, RIGHT);

    -- Transport direction
    -- AB : from A to B
    -- BA : from B to A
    type Direction is (AB, BA);

    DRESS_TIME : Duration := 0.2;
    TRANSPORT_TIME : Duration := 5.0;
    PAUSE_TIME : Duration := 2.0;
    PERIOD_TIME : Duration := 1.0;

------------------------------------------------------------------------------
    -- Semaphore for gloves
    protected type SemGlove (Init_Value : Natural) is
        entry P(My_Hand : in Hand);
        entry OtherL;
        entry OtherR;
        procedure V(My_Hand : in Hand);
        function Status(H : in Hand) return Integer;
    private
        CL : Integer := Init_Value;	-- Left
        CR : Integer := Init_Value;	-- Right
    end SemGlove;

    protected body SemGlove is
        -- take glove for My_Hand
        entry P(My_Hand : in Hand) when CR = CL and CR > 0 and CL > 0 is
        begin
            if My_Hand = RIGHT then
                CR := CR - 1;
            else
                CL := CL - 1;
            end if;
        end P;

        -- take glove for Other_Hand
        entry OtherL when CL > 0 is
        begin
            CL := CL - 1;
        end OtherL;

        entry OtherR when CR > 0 is
        begin
            CR := CR - 1;
        end OtherR;

        -- give glove
        procedure V(My_Hand : in Hand) is
        begin
            if My_Hand = RIGHT then
                CR := CR + 1;
            else
                CL := CL + 1;
            end if;
        end V;

        function Status(H : in Hand) return Integer is
        begin
            if H = RIGHT then
                return CR;
            else
                return CL;
            end if;
        end Status;
    end SemGlove;

    type Gloves_Ptr is access all SemGlove;
    Gloves : Gloves_Ptr;

    -- Semaphore for places
    protected type SemPlace(Init_Value : Integer) is
        entry P;
        procedure V;
        procedure Update(Val : in Integer);
        function Status return Integer;
    private
        Material : Integer := Init_Value;
    end SemPlace;

    protected body SemPlace is
        entry P when Material > 0 is
        begin
            Material := Material - 1;
        end P;

        procedure V is
        begin
            Material := Material + 1;
        end V;

        procedure Update(Val : in Integer) is
        begin
            Material := Val;
        end Update;

        function Status return Integer is
        begin
            return Material;
        end Status;
    end SemPlace;

    PlaceA : SemPlace(0);
    PlaceB : SemPlace(0);

------------------------------------------------------------------------------
    -- Usage: workplace <workers> <left> <right> <gloves>
    procedure Usage is
    begin
        Put_Line("Usage:");
        Put_Line("      " & Command_Name &
            " <workers> <left> <right> <gloves>");
        New_Line;
        Put_Line("Left plus Right whould be equal to Workers!");
    end Usage;

    -- Parse command line
    function Parse_Command_Line return Boolean is
    begin
        if Argument_Count /= 4 then
            Usage;
            return False;
        end if;

        N := Positive'Value(Argument(1));
        L := Natural'Value(Argument(2));
        R := Natural'Value(Argument(3));
        K := Positive'Value(Argument(4));

        if (L + R) /= N then
            Usage;
            return False;
        end if;

        Put_Line("Workers:" & Integer'Image(N));
        Put_Line("Left:" & Integer'Image(L));
        Put_Line("Right:" & Integer'Image(R));
        Put_Line("Gloves:" & Integer'Image(K));

        return True;
    end Parse_Command_Line;

------------------------------------------------------------------------------
    -- Find a random number
    function Random (Max : in Positive) return Natural is
        subtype Rand_Range is Natural;
        package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);

        seed : Rand_Int.Generator;
        Num : Rand_Range;
    begin
        Rand_Int.Reset(seed);
        Num := Rand_Int.Random(seed) mod Max;

        return Num;
    end Random;

------------------------------------------------------------------------------
    -- Workers
    task type Worker is
        entry Ready (ID : in Positive; H : in Hand);
    end Worker;

    -- Define Worker Array
    type Worker_Array is array(Integer range <>) of Worker;
    type Worker_Array_Ptr is access all Worker_Array;
    Workers : Worker_Array_Ptr;

    task body Worker is
        My_ID : Natural;
        My_Hand, Other_Hand : Hand;
        My_Direction : Direction;
    begin
        accept Ready(ID : in Positive; H : in Hand) do
            My_ID := ID;

            if H = RIGHT then
                My_Hand := RIGHT;
                Other_Hand := LEFT;
            else
                My_Hand := LEFT;
                Other_Hand := RIGHT;
            end if;

            if Random(2) = 0 then
                My_Direction := AB;
            else
                My_Direction := BA;
            end if;

            Put_Line("Worker" & Integer'Image(ID) & " - " &
                Hand'Image(My_Hand) & " - " & Direction'Image(My_Direction));
        end Ready;

        loop
            -- reserve a material
            if My_Direction = AB then
                PlaceA.P;
                Put_Line("Worker " & Integer'Image(My_ID) &
                    " has a material to transport " & Direction'Image(My_Direction));
            else
                PlaceB.P;
                Put_Line("Worker " & Integer'Image(My_ID) &
                    " has a material to transport " & Direction'Image(My_Direction));
            end if;

            Put_Line("Worker " & Integer'Image(My_ID) &
                " waits " & Hand'Image(My_Hand));

            -- reserve a glove
            Gloves.P(My_Hand);
            Put_Line("-> Worker " & Integer'Image(My_ID) &
                " takes " & Hand'Image(My_Hand));
            delay DRESS_TIME;

            if Other_Hand = RIGHT then
                Gloves.OtherR;
            else
                Gloves.OtherL;
            end if;
            Put_Line("--> Worker " & Integer'Image(My_ID) &
                " takes " & Hand'Image(Other_Hand));
            delay DRESS_TIME;

            Put_Line("### Transport: Worker " & Integer'Image(My_ID) &
                " to " & Direction'Image(My_Direction) & " ###");

            delay TRANSPORT_TIME;

            -- give material
            if My_Direction = AB then
                PlaceB.V;
            else
                PlaceA.V;
            end if;

            -- give back glove
            Gloves.V(My_Hand);
            Put_Line("<-- Worker " & Integer'Image(My_ID) &
                " gives " & Hand'Image(My_Hand));
            delay DRESS_TIME;
            Gloves.V(Other_Hand);
            Put_Line("<- Worker " & Integer'Image(My_ID) &
                " gives " & Hand'Image(Other_Hand));
            delay DRESS_TIME;

            Put_Line("Worker " & Integer'Image(My_ID) & " in pause!");
            delay PAUSE_TIME;

        end loop;
    end Worker;

------------------------------------------------------------------------------

begin
    if Parse_Command_Line = False then
        return;
    end if;

    -- init gloves
    Gloves := new SemGlove(K);

    -- Create Workers
    Workers := new Worker_Array (1 .. N);

    for ID in 1 .. N loop
        if ID <= R then
            Workers(ID).Ready(ID, RIGHT);
        else
            Workers(ID).Ready(ID, LEFT);
        end if;
    end loop;

    PlaceA.Update(5);
    PlaceB.Update(2);

    loop
        Put_Line("Place A: " & Integer'Image(PlaceA.Status));
        Put_Line("Place B: " & Integer'Image(PlaceB.Status));
        Put_Line("Right: " & Integer'Image(Gloves.Status(RIGHT)) & 
            " Left : " & Integer'Image(Gloves.Status(LEFT)));

        delay PERIOD_TIME;
    end loop;
    
    -- Exceptions
	exception
        when E : Storage_Error =>
            Put_Line("Out of memory!");
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));

        when E : Tasking_Error =>
            Put_Line("Task cannot be activated because the operating system" &
                " has not enough resources");
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));

        when E : others =>
            Usage;
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));
end Workplace;

