----------------------------------------------------------------------------------------------------
--        Digital Signal Processing package
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

package dsp_pkg is
   --Definitions for coefficients
   constant NUM_COEF_BITS : positive := 16;
   subtype coefficient is signed(NUM_COEF_BITS-1 downto 0);
   type coefficient_array is array (natural range <>) of coefficient;

   --Definitions for signal data
   constant NUM_SIG_BITS : positive := 16;
   subtype sig is signed(NUM_SIG_BITS-1 downto 0);
   subtype summed_sig is signed(NUM_SIG_BITS downto 0); --for when 2 sigs are added together
   constant NUM_SUMMED_SIG_BITS : positive := NUM_SIG_BITS+1;
   type sig_array is array (natural range <>) of sig;
   
   --Types for fir signal data - for use for internal FIR calculations
   --The size is based on the number of bits needed for calculation.  The multiplication of 
   --coefficient and signal is 16-bits + 16-bits.  The cumulative addtion of N taps will need 
   --require a log2(N) addtional bits.  Allowing for up to 256 taps, the full size will be 
   --16 + 16 + log2(256) or 40 bits
   constant MAX_TAPS : positive := 256;
   constant NUM_ADDED_TAPS_BITS : positive := 8; --log2(256)
   constant NUM_FIR_BITS : positive := NUM_COEF_BITS + NUM_SIG_BITS + NUM_ADDED_TAPS_BITS;
   subtype fir_sig is signed(NUM_FIR_BITS-1 downto 0);
   type fir_sig_array is array (natural range <>) of fir_sig;
   
   --Coefficients for FIR filters
   constant ZERO_COEF   : coefficient       := x"0000";
   constant LOW_PASS    : coefficient_array := (x"0000",
                                                x"02e4",
                                                x"0000",
                                                x"fc21",
                                                x"0000",
                                                x"0595",
                                                x"0000",
                                                x"f682",
                                                x"0000",
                                                x"1cc4",
                                                x"2d5f",
                                                x"1cc4",
                                                x"0000",
                                                x"f682",
                                                x"0000",
                                                x"0595",
                                                x"0000",
                                                x"fc21",
                                                x"0000",
                                                x"02e4",
                                                x"0000");
                                                
   constant PASS_THRU   : coefficient_array := (x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"3FFF",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000",
                                                x"0000");
   
   
end package;

----------------------------------------------------------------------------------------------------
--        PACKAGE BODY
----------------------------------------------------------------------------------------------------
--library ieee;
--   use ieee.std_logic_1164.all;
--
--package body lfsr_pkg is
--end package body;