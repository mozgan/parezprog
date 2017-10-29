
with Ada.Text_IO,                       -- string output
     Ada.Integer_Text_IO,               -- integer output
     Ada.Command_Line,                  -- arguments from command line
     Ada.Real_Time,                     -- clock, time, etc.
     Ada.Exceptions,                    -- exceptions
     Ada.Numerics.Elementary_Functions, -- math functions
     Master;

use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Command_Line, Ada.Real_Time,
	Ada.Exceptions, Ada.Numerics.Elementary_Functions, Master;

procedure countprimes is
    -- N : Max. Number
    -- T : Task Number
    -- S : Slice Size
    -- D : Execution Timeout
    N, T, S : Positive;
    D : Duration;

    Master_P : Master.Pointer;

    -- Usage: countprimes <max. number> <task number> <slice size> <Ex. timeout>
    procedure Usage is
    begin
        Put_Line("All arguments must be positive integer.");
        Put_Line("Usage:");
        Put_Line("      " & Command_Name &
            " <max. number> <task number> <slice size>");
        New_Line;
    end Usage;

    -- Parse command line
    function Parse_Command_Line return Boolean is
    begin
        -- the program takes exactly four arguments!
        if Argument_Count /= 4 then
            Put_Line("The program should take exactly three arguments.");
            Usage;
            return False;
        end if;

        N := Positive'Value(Argument(1));
        T := Positive'Value(Argument(2));
        S := Positive'Value(Argument(3));
        D := To_Duration(Milliseconds(Integer'Value(Argument(4))));

        Put("Count Primes [1 .." & Integer'Image(N) & "] - ");
        Put("TaskCnt:" & Integer'Image(T) & " - ");
        Put_Line("SliceSize:" & Integer'Image(S));

        return True;
    end Parse_Command_Line;

begin
    if Parse_Command_Line then
        Master_P := new Master_Task;
        Master_P.Start(N, T, S, D);
    end if;

    -- Exceptions
    exception
        when E : Storage_Error =>
            Put_Line("Out of memory!");
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));

        when E : Tasking_Error =>
            Put_Line("Task cannot be activated because the operating system" &
                "has not enough resources");
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));

        when E : others =>
            Usage;
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));
end countprimes;


