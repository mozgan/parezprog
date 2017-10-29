--
--     Author: Mehmet Ozgan
--    Matr.Nr: 0526530
--       Date: 23.03.2016
--    Version: 0.1
--   Compiler: GNAT GPL 2015 (20150428-49) (Mac)
--             GNAT 4.4.7 (Gentoo Linux)
--             GNAT 5.3.0 (20150118-release) (FreeBSD 64)
--
--
--      @(#) primes.ads          TU Wien 23.03.2016
-- $Id: primes.ads,v 0.1 23.03.2016 10:25 mozgan Exp $
------------------------------------------------------------------------------

package Primes is
	function FindPrimes(First, Last : Positive) return Integer;
	function Is_Prime(Number : Positive) return Boolean;
end Primes;
