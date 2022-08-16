
with Ada.Text_IO,
     Ada.Real_Time,
     Ada.Numerics.Elementary_Functions,
     Master;

use Ada.Text_IO, Ada.Real_Time, Ada.Numerics.Elementary_Functions;

package body Worker is
    task body Worker_Task is
        My_ID : Positive;

        Start_Time, Stop_Time : Time;
        Runtime : Duration;

        Timeout : Duration;

        First, Last : Integer;
        Working : Boolean;
        Counter, Last_Checked : Positive;
        Found : Integer := 0;
        Reported : Boolean := False;

        Approx_Algorithm : Boolean := False;

        Master_P : Master.Pointer;

        function Is_Prime(Number : Positive) return Boolean is
            -- Check it out if the number is prime or not.
            -- Return : True - If the number is prime
            -- Return : False - If the number is not prime
            Root : Positive;
        begin
            if Number = 2 then
                return True;
            end if;

            Root := Positive(Float'Ceiling(Sqrt(Float(Number))));

            -- If modulo of the given number from 3 to sqrt(number) is zero,
            -- that means the number is not a prime, return False.
            -- Otherwise, the number is prime and return True.
            For i in 3 .. Root loop
                if (Number mod i) = 0 then
                    return False;
                end if;
            end loop;

            return True;
        end Is_Prime;

        function Calculate_Estimate_Primes(First, Last : in Integer)
            return Integer is

            Differenz : Integer := Last - First;
            Result : Float := 0.0;
        begin
            Result := Float(Differenz)/6.0*(1.0/Log(Float(First)) + 4.0*1.0/Log(Float(First+Last)/2.0) + 1.0/Log(Float(Last)));

            return Integer(Result);
        end Calculate_Estimate_Primes;

        procedure Find_Primes is
        begin
            loop
                Master_P.Request(First, Last, Working);

                if Working = True then
                    Put_Line("Worker" & Integer'Image(My_ID) &
                        ": Starting Computation for" &
                        Integer'Image(First) & " .." &
                        Integer'Image(Last));

                    Start_Time := Clock;
                    Reported := False;
                    Counter := First;

                    if Approx_Algorithm = False then
                        Put_Line("Using exact Algorithm at position" &
                            Integer'Image(First));
                        if (First mod 2) = 0 then   -- take only odd numbers to check!
                            Counter := First + 1;
                        end if;

                        while Counter <= Last loop
                            if Is_Prime(Counter) = True then
                                Found := Found + 1;
                            end if;
                            Last_Checked := Counter;
                            Counter := Counter + 2;     -- check only odd numbers!
                            delay 0.0;
                        end loop;
                    else
                        Put_Line("Using approx. Algorithm at position" &
                            Integer'Image(First));
                        Found := Calculate_Estimate_Primes(First, Last);
                    end if;
                    
                    Stop_Time := Clock;
                    Runtime := To_Duration(Stop_Time - Start_Time);

                    Master_P.Report(My_ID, First, Last, Found, Runtime);
                    Reported := True;
                else
                    -- Working is False, that means that there is no more 
                    -- slice to compute. And the Worker should be terminate!
                    Put_Line("Worker" & Integer'Image(My_ID) & ": Terminating");

                    -- Tell to Master: I am going to terminate!
                    Master_P.Finished(My_ID);
                    exit; -- Terminate!
                end if;
            end loop;
        end Find_Primes;

    begin
        Put_Line("Another Worker Created");

        accept Ready(ID : in Positive; P : Master.Pointer; T : Duration) do
            My_Id := ID;
            Master_P := P;
            Timeout := T;
            Put_Line("Worker" & Integer'Image(ID) & ": Ready for Service");
        end Ready;

        select
            delay Timeout;
            
            Put_Line("Worker" & Integer'Image(My_ID) &
                ": Switching to approx. Algorithm at position" &
                Integer'Image(Last_Checked));

            Approx_Algorithm := True;
            Master_P.Switch_Algorithm(Approx_Algorithm);

            if Reported = False then
                Stop_Time := Clock;
                Runtime := To_Duration(Stop_Time - Start_Time);
                Found := Found + Calculate_Estimate_Primes(Last_Checked+1, Last);
                Master_P.Report(My_ID, First, Last, Found, Runtime);
            end if;

            Find_Primes;
        then abort
            Find_Primes;
        end select;
    end Worker_Task;
end Worker;

