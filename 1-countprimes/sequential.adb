
with Ada.Text_IO,                       -- string output
     Ada.Integer_Text_IO,               -- integer output
     Ada.Command_Line,                  -- arguments from command line
     Ada.Real_Time,                     -- clock, time, etc.
     Ada.Exceptions,                    -- exceptions
     Ada.Numerics.Elementary_Functions, -- math functions
	 Primes,							-- prime numbers
     Multitasking;                      -- multitasking

use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Command_Line, Ada.Real_Time,
	Ada.Exceptions, Ada.Numerics.Elementary_Functions, Primes;

procedure sequential is

    -- N : Max. Number
    N : Positive;

    Found : Integer := 0;

    Start_Time, Stop_Time : Time;
    Runtime : Duration;         -- in seconds

    -- Usage: countprimes <max. number>
    procedure Usage is
    begin
        Put_Line("Usage:");
        Put_Line("      " & Command_Name & " <max. number>");
        New_Line;
    end Usage;

    -- Parse command line
    function Parse_Command_Line return Boolean is
    begin
        -- it takes only one argument (max. number)
        if Argument_Count /= 1 then
            Put_Line("The program should take only one argument i.e. max. number");
            Usage;
            return False;
        end if;

        N := Positive'Value(Argument(1));

        Put("Count Primes [1 .." & Integer'Image(N) & "] - ");
        Put("TaskCnt: 1 (Sequential) - ");
        Put_Line("SliceSize:" & Integer'Image(N));

        return True;
    end Parse_Command_Line;
begin
    if Parse_Command_Line = True then
        Start_Time := Clock;

        Found := FindPrimes(1, N);
        Put_Line("PrimeCnt =" & Integer'Image(Found));

        Stop_Time := Clock;
        Runtime := To_Duration(Stop_Time - Start_Time);
        Put_Line("RunTime =" & Duration'Image (Runtime) &
            " seconds");
    end if;

    -- Exceptions
    exception
        when E : Storage_Error =>
            Put_Line("Out of memory!");
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));

        when E : others =>
            Usage;
            Put("Exception Message: ");
            Put_Line(Exception_Message(E));

end sequential;


