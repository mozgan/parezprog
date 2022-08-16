--
-- Find primes numbers between 2 and N in T workers
-- and give the number of primes between 2 and N.
--
--     Author: Mehmet Ozgan
--    Matr.Nr: 0526530
--       Date: 23.03.2016
--    Version: 0.5
--   Compiler: GNAT GPL 2015 (20150428-49) (Mac)
--             GNAT 4.4.7 (Gentoo Linux)
--             GNAT 5.3.0 (20150118-release) (FreeBSD 64)
--
-- Usage: countprimes <max. number> <task number> <slice size>
--
--      @(#) countprimes.adb         TU Wien 23.03.2016
-- $Id: countprimes.adb,v 0.5 23.03.2016 10:03 mozgan Exp $
------------------------------------------------------------------------------

with Ada.Text_IO,                       -- string output
     Ada.Integer_Text_IO,               -- integer output
     Ada.Command_Line,                  -- arguments from command line
     Ada.Real_Time,                     -- clock, time, etc.
     Ada.Exceptions,                    -- exceptions
     Ada.Numerics.Elementary_Functions, -- math functions
	 Primes,							-- prime numbers
     Multitasking;                      -- multitasking

use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Command_Line, Ada.Real_Time,
	Ada.Exceptions, Ada.Numerics.Elementary_Functions, Primes, Multitasking;

procedure countprimes is

    -- N : Max. Number
    -- T : Task Number
    -- S : Slice Size
    N, T, S : Positive;

    Start_Time, Stop_Time : Time;
    Runtime : Duration;             -- in seconds

    -- Usage: countprimes <max. number> <task number> <slice size>
    procedure Usage is
    begin
        Put_Line("All arguments must be positive integer.");
        Put_Line("Usage:");
        Put_Line("      " & Command_Name &
            "<max. number> <task number> <slice size>");
        New_Line;
            
    end Usage;

    -- Parse command line
    function Parse_Command_Line return Boolean is
    begin
        -- it takes exactly three arguments!
        if Argument_Count /= 3 then
            Put_Line("The program should take exactly three arguments.");
            Usage;
            return False;
        end if;

        N := Positive'Value(Argument(1));
        T := Positive'Value(Argument(2));
        S := Positive'Value(Argument(3));

        Put("Count Primes [1 .." & Integer'Image(N) & "] - ");
        Put("TaskCnt:" & Integer'Image(T) & " - ");
        Put_Line("SliceSize:" & Integer'Image(S));

        return True;
    end Parse_Command_Line;

begin
    if Parse_Command_Line = True then
        Start_Time := Clock;            -- Start the time

        Multitasking_Start(N, T, S);    -- Let's start!

        Stop_Time := Clock;             -- Stop the time
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

