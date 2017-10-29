with Ada.Real_Time, Master;
use Ada.Real_Time, Master;

package Worker is
    task type Worker_Task is
        entry Ready(ID : in Positive; P : Master.Pointer; T : Duration);
    end Worker_Task;
end Worker;

