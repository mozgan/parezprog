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
--      @(#) multitasking.ads         TU Wien 23.03.2016
-- $Id: multitasking.ads,v 0.1 23.03.2016 10:20 mozgan Exp $
------------------------------------------------------------------------------

package Multitasking is
	procedure Multitasking_Start (RangeMax, TaskCnt, SliceSize : in Positive);
end Multitasking;
