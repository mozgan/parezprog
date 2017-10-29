--
-- Find all primes numbers between two given positive integer numbers
-- and count them.
--
--     Author: Mehmet Ozgan
--    Matr.Nr: 0526530
--       Date: 23.03.2016
--    Version: 0.2
--   Compiler: GNAT GPL 2015 (20150428-49) (Mac)
--             GNAT 4.4.7 (Gentoo Linux)
--             GNAT 5.3.0 (20150118-release) (FreeBSD 64)
--
--
--      @(#) primes.adb          TU Wien 23.03.2016
-- $Id: primes.adb,v 0.2 23.03.2016 10:25 mozgan Exp $
------------------------------------------------------------------------------

with Ada.Numerics.Elementary_Functions; -- math functions

use Ada.Numerics.Elementary_Functions;
	
package body Primes is
    function FindPrimes(First, Last : Positive) return Integer is
        -- Find all prime numbers between First and Last numbers and
        -- returns the number of all founded prime numbers
        Counter: Positive;
        Found : Integer := 0;
    begin
        if Last < 2 then        -- 1 is not prime!
            return Found;
        elsif First = 2 then    -- 2 is prime!
            Counter := 3;
            Found := 1;
        elsif (First mod 2) = 0 then -- take only odd numbers to check!
            Counter := First + 1;
        else
            Counter := First;
        end if;

        while Counter <= Last loop
            if Is_Prime(Counter) = True then
                Found := Found + 1;
            end if;
            Counter := Counter + 2; -- check only odd numbers!
        end loop;

        return Found;
    end FindPrimes;
	
    function Is_Prime(Number : Positive) return Boolean is
        -- Check it out if the number is prime or not.
        -- Return : True - If the number is prime
        -- Return : False - If the number is not prime
        Root : Positive;
    begin
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
end Primes;
