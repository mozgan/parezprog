
with Ada.Text_IO,
     Ada.Real_Time,
     Ada.Calendar,
     Worker;

use Ada.Text_IO, Ada.Real_Time, Worker;

package body Master is
    task body Master_Task is
        Start_Time, Stop_Time : Time;
        Runtime : Duration;

        RangeMax, TaskCnt, Slicesize : Positive;
        Timeout : Duration;

        SliceCnt : Integer := 0;
        RangeMin : Integer := 1;
        PrimeCnt, TaskCounter, FinishedCnt : Integer := 0;

        Approx_Algorithm : Boolean := False;

        -- Define Worker Array
        type Worker_Array is array(Integer range <>) of Worker_Task;
        type Worker_Array_Ptr is access all Worker_Array;
        Workers : Worker_Array_Ptr;

    begin
        accept Start(N, T, S : in Positive; D : in Duration) do
            Start_Time := Clock;        -- Start the time
            
            Put_Line("Starting Master:");

            RangeMax := N;
            TaskCnt := T;
            SliceSize := S;
            Timeout := D;

            SliceCnt := Integer(Float'Ceiling((Float((RangeMax - 1)) /
                Float(SliceSize))));

            Put_Line("RangeMin =" & Integer'Image(RangeMin));
            Put_Line("RangeMax =" & Integer'Image(RangeMax));
            Put_Line("TaskCnt =" & Integer'Image(TaskCnt));
            Put_Line("SliceSize =" & Integer'Image(SliceSize));
            Put_Line("SliceCnt =" & Integer'Image(SliceCnt));
        end Start;

        -- Create the Workers and add into Worker_Array
        Workers := new Worker_Array(1 .. TaskCnt);

        -- Set all created Workers in "Ready" state
        for Worker_ID in 1 .. TaskCnt loop
            Workers(Worker_ID).Ready(Worker_ID, Master_Task'Unchecked_Access,
                Timeout);
        end loop;

        loop
            select
                accept Request(First, Last : out Integer; Working : out Boolean) do
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
                accept Report(Worker_Id, First, Last : in Positive;
                        Found : in Integer; Runtime : in Duration) do 
                    --Report(Found : in Integer) do
                    Put_Line("Worker" & Integer'Image(Worker_Id) & 
                        ": Completed Computation for" & Integer'Image(First)
                        & " .." & Integer'Image(Last) & " - Found" &
                        Integer'Image(Found) & " Primes in " &
                        Duration'Image (Runtime) & " seconds");

                    PrimeCnt := PrimeCnt + Found;
                end Report;
            or
                accept Switch_Algorithm(A : in Boolean) do
                    if Approx_Algorithm = False then
                        Put_Line("*********** Timeout Expired ***********");
                        Approx_Algorithm := True;
                    end if;
                end Switch_Algorithm;
            or
                accept Finished(Worker_ID : in Positive) do
                    -- Count how many Workers have terminated
                    FinishedCnt := FinishedCnt + 1;
                end Finished;

                if FinishedCnt = TaskCnt then
                    Put_Line("PrimeCnt =" & Integer'Image(PrimeCnt));
                    Put_Line("Master Terminating");
                    exit;
                end if;
            end select;
        end loop;

        Stop_Time := Clock;             -- Stop the time
        Runtime := To_Duration(Stop_Time - Start_Time);
        Put_Line("RunTime =" & Duration'Image (Runtime) &
            " seconds");
    end Master_Task;
end Master;
