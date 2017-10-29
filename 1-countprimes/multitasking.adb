--
-- Create a Master and T Workers for parallel computation.
--
--     Author: Mehmet Ozgan
--    Matr.Nr: 0526530
--       Date: 23.03.2016
--    Version: 0.3
--   Compiler: GNAT GPL 2015 (20150428-49) (Mac)
--             GNAT 4.4.7 (Gentoo Linux)
--             GNAT 5.3.0 (20150118-release) (FreeBSD 64)
--
--
--      @(#) multitasking.adb         TU Wien 23.03.2016
-- $Id: multitasking.adb,v 0.3 23.03.2016 10:20 mozgan Exp $
------------------------------------------------------------------------------

with Ada.Text_IO,                       -- string output
	 Primes;							-- prime numbers

use Ada.Text_IO, Primes;
	
package body Multitasking is
	procedure Multitasking_Start (RangeMax, TaskCnt, SliceSize : in Positive) is
        -- Definition: Master Task
        task type Master is
            entry Request(Worker_ID : in Positive; Working : out Boolean;
                First, Last : out Positive; Found : in Integer);
            entry Finished(Worker_ID : in Positive);
        end Master;

        Master_P : Master;              -- create and start Master Task
        
        -- Definition: Worker Task
        task type Worker is
            entry Ready(ID : in Positive);
        end Worker;

        -- Define Worker Array
        type Worker_Array is array(Integer range <>) of Worker;
        type Worker_Array_Ptr is access all Worker_Array;
        Workers : Worker_Array_Ptr;

------------------------------------------------------------------------------
        -- Body: Master Task
        task body Master is
            SliceCnt : Integer := 0;
            RangeMin : Integer := 1;
            PrimeCnt, TaskCounter, FinishedCnt : Integer := 0;
        begin
            Put_Line("Starting Master:");

            SliceCnt := Integer(Float'Ceiling((Float((RangeMax - 1)) /
                        Float(SliceSize))));

            Put_Line("RangeMin =" & Integer'Image(RangeMin));
            Put_Line("RangeMax =" & Integer'Image(RangeMax));
            Put_Line("TaskCnt =" & Integer'Image(TaskCnt));
            Put_Line("SliceSize =" & Integer'Image(SliceSize));
            Put_Line("SliceCnt =" & Integer'Image(SliceCnt));

            -- Create the Workers and add into Worker_Array
            Workers := new Worker_Array(1 .. TaskCnt);

            -- Set all created Workers in "Ready" state
            for Worker_ID in 1 .. TaskCnt loop
                Workers(Worker_ID).Ready(ID => Worker_ID);
            end loop;

            loop    -- infinite loop
            select
                accept Request(Worker_ID : in Positive; Working : out Boolean;
                    First, Last : out Positive; Found : in Integer) do

                    -- If Master receives a request from a Worker then
                    -- take found primes and add to the PrimeCnt.
                    PrimeCnt := PrimeCnt + Found;

                    -- If there are some slice to compute then send
                    -- the first and the last numbers of slice to Worker,
                    -- which has send requesting.
                    if TaskCounter < SliceCnt then
                        First := TaskCounter * SliceSize + 1;
                        Last := (TaskCounter + 1) * SliceSize;

                        -- Ex: RangeMax= 100, SliceSize=75
                        if (Last > RangeMax) then
                            Working := False;
                        else
                            Working := True;
                            TaskCounter := TaskCounter + 1;
                        end if;
                    else
                        -- If there is no more slice to compute then send
                        -- False to terminate the created Workers.
                        Working := False;
                    end if;
                end Request;
            or
                accept Finished(Worker_ID : in Positive) do
                    -- Count how many Workers have terminated
                    FinishedCnt := FinishedCnt + 1;
                end Finished;

                if FinishedCnt = TaskCnt then
                    -- If all Workers are finished then check that are there
                    -- some numbers to compute.
                    if (TaskCounter * SliceSize) < RangeMax then
                        PrimeCnt := PrimeCnt +
                            FindPrimes(TaskCounter * SliceSize + 1, RangeMax);
                    end if;

                    Put_Line("PrimeCnt =" & Integer'Image(PrimeCnt));
                    Put_Line("Master Terminating");
                    exit;
                end if;
            end select;
            end loop;

        end Master;

------------------------------------------------------------------------------
        -- Body: Worker Task
        task body Worker is
            My_ID : Positive;
            Working : Boolean := False;
            First, Last : Positive;
            Found : Integer := 0;
        begin
            Put_Line("Another Worker Created");

            -- If a Worker task takes an ID then it is ready for computation
            accept Ready(ID : in Positive) do
                My_ID := ID;
                Put_Line("Worker" & Integer'Image(ID) & ": Ready for Service");
            end Ready;

            loop
                -- First, send a request to Master.
                -- If there are some slice to compute then (Working = True),
                -- Worker receives the first and the last numbers of slice
                Master_P.Request(My_ID, Working, First, Last, Found);

                if Working = True then
                    Put_Line("Worker" & Integer'Image(My_ID) &
                        ": Starting Computation for" &
                        Integer'Image(First) & " .." &
                        Integer'Image(Last));

                    Found := FindPrimes(First, Last);

                    Put_Line("Worker" & Integer'Image(My_ID) & 
                        ": Completed Computation for" & Integer'Image(First)
                        & " .." & Integer'Image(Last) & " - Found" &
                        Integer'Image(Found) & " Primes");
                else
                    -- Working is False, that means that there is no more 
                    -- slice to compute. And the Worker should be terminate!
                    Put_Line("Worker" & Integer'Image(My_ID) & ": Terminating");

                    -- Tell to Master: I am going to terminate!
                    Master_P.Finished(My_ID);
                    exit;
                end if;
            end loop;
        end Worker;

------------------------------------------------------------------------------
	begin
        NULL;
	end Multitasking_Start;
end Multitasking;
