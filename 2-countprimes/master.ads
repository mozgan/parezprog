with Ada.Real_Time;
use Ada.Real_Time;

package Master is
    task type Master_Task is
        entry Start(N, T, S : in Positive; D : in Duration);
        entry Request(First, Last : out Integer; Working : out Boolean);
        entry Report(Worker_Id, First, Last : in Positive; Found : in Integer;
            Runtime : in Duration);
        entry Finished(Worker_ID : in Positive);
        entry Switch_Algorithm(A : in Boolean);
    end Master_Task;

    type Pointer is access all Master_Task;
end master;

