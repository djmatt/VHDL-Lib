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
                                                x"0070",
                                                x"0000",
                                                x"fe7b",
                                                x"0000",
                                                x"0453",
                                                x"0000",
                                                x"f512",
                                                x"0000",
                                                x"27c2",
                                                x"4010",
                                                x"27c2",
                                                x"0000",
                                                x"f512",
                                                x"0000",
                                                x"0453",
                                                x"0000",
                                                x"fe7b",
                                                x"0000",
                                                x"0070",
                                                x"0000");
                                                
   constant HIGH_PASS   : coefficient_array := (x"0000",
                                                x"ff90",
                                                x"0000",
                                                x"0185",
                                                x"0000",
                                                x"fbad",
                                                x"0000",
                                                x"0aee",
                                                x"0000",
                                                x"d83e",
                                                x"4010",
                                                x"d83e",
                                                x"0000",
                                                x"0aee",
                                                x"0000",
                                                x"fbad",
                                                x"0000",
                                                x"0185",
                                                x"0000",
                                                x"ff90",
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
                                                x"7FFF",
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
   
   constant LOW_BANK    : coefficient_array := (x"0000",
                                                x"000e",
                                                x"ffff",
                                                x"ff68",
                                                x"0006",
                                                x"02d6",
                                                x"fff0",
                                                x"f686",
                                                x"001b",
                                                x"2727",
                                                x"3ff0",
                                                x"2727",
                                                x"001b",
                                                x"f686",
                                                x"fff0",
                                                x"02d6",
                                                x"0006",
                                                x"ff68",
                                                x"ffff",
                                                x"000e",
                                                x"0000");
                                                
   constant HIGH_BANK   : coefficient_array := (x"0000",
                                                x"fff2",
                                                x"0001",
                                                x"0098",
                                                x"fffa",
                                                x"fd2a",
                                                x"0010",
                                                x"097a",
                                                x"ffe5",
                                                x"d8d9",
                                                x"4030",
                                                x"d8d9",
                                                x"ffe5",
                                                x"097a",
                                                x"0010",
                                                x"fd2a",
                                                x"fffa",
                                                x"0098",
                                                x"0001",
                                                x"fff2",
                                                x"0000");

   constant NYQUIST_LOW_BANK  : coefficient_array := (x"0be0",
                                                      x"2637",
                                                      x"398f",
                                                      x"2946",
                                                      x"fe69",
                                                      x"e6ac",
                                                      x"f791",
                                                      x"0f5a",
                                                      x"09dc",
                                                      x"f631",
                                                      x"f6c1",
                                                      x"06a1",
                                                      x"082b",
                                                      x"fb46",
                                                      x"f8f0",
                                                      x"038a",
                                                      x"060c",
                                                      x"fd3a",
                                                      x"fadb",
                                                      x"0242",
                                                      x"0459",
                                                      x"fe1a",
                                                      x"fc5a",
                                                      x"01a3",
                                                      x"0309",
                                                      x"fe91",
                                                      x"fd81",
                                                      x"0144",
                                                      x"0207",
                                                      x"fee1",
                                                      x"fe61",
                                                      x"00fd",
                                                      x"0145",
                                                      x"ff23",
                                                      x"ff07",
                                                      x"00c0",
                                                      x"00b9",
                                                      x"ff5d",
                                                      x"ff7c",
                                                      x"0088",
                                                      x"005a",
                                                      x"ff91",
                                                      x"ffc6",
                                                      x"0059",
                                                      x"0021",
                                                      x"ffba",
                                                      x"ffef",
                                                      x"0038",
                                                      x"0007",
                                                      x"ffbe",
                                                      x"0036",
                                                      x"ffef");

   constant NYQUIST_HIGH_BANK : coefficient_array := (x"0be0",
                                                      x"d9c9",
                                                      x"398f",
                                                      x"d6ba",
                                                      x"fe69",
                                                      x"1954",
                                                      x"f791",
                                                      x"f0a6",
                                                      x"09dc",
                                                      x"09cf",
                                                      x"f6c1",
                                                      x"f95f",
                                                      x"082b",
                                                      x"04ba",
                                                      x"f8f0",
                                                      x"fc76",
                                                      x"060c",
                                                      x"02c6",
                                                      x"fadb",
                                                      x"fdbe",
                                                      x"0459",
                                                      x"01e6",
                                                      x"fc5a",
                                                      x"fe5d",
                                                      x"0309",
                                                      x"016f",
                                                      x"fd81",
                                                      x"febc",
                                                      x"0207",
                                                      x"011f",
                                                      x"fe61",
                                                      x"ff03",
                                                      x"0145",
                                                      x"00dd",
                                                      x"ff07",
                                                      x"ff40",
                                                      x"00b9",
                                                      x"00a3",
                                                      x"ff7c",
                                                      x"ff78",
                                                      x"005a",
                                                      x"006f",
                                                      x"ffc6",
                                                      x"ffa7",
                                                      x"0021",
                                                      x"0046",
                                                      x"ffef",
                                                      x"ffc8",
                                                      x"0007",
                                                      x"0042",
                                                      x"0036",
                                                      x"0011");                                             
                                                
   --Function declarations
--   type slice_type is array(natural range <>) of integer;
   function slice_coefficient_array (  original_array : coefficient_array; 
                                       num_cuts       : integer;
                                       cut            : integer;
                                       front_load     : integer) return coefficient_array;
   
end package;
 
----------------------------------------------------------------------------------------------------
--        PACKAGE BODY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

   
package body dsp_pkg is
   
   --This function slices a coefficient array into the polyphase slice of that array.
   --The original array is the coefficient array to be sliced
   --num_cuts is the number of sub-arrays that can be created
   --cut is the 1-based identifier of the cut desired (e.g. when num_cuts is 2, cut can be 1 or 2)
   --front_load can be 0 or 1.  0 indicates that the coeffs will be back loaded (padded 0's in the
   --  front.  1 indicates that coefs will be front loaded (padded 0's in the back)
   function slice_coefficient_array (  original_array : coefficient_array; 
                                       num_cuts       : integer;
                                       cut            : integer;
                                       front_load     : integer) return coefficient_array is
      
      constant slice_len      : integer := (original_array'length - cut + num_cuts) / num_cuts;
      constant result_len     : integer := (original_array'length - 1 + num_cuts) / num_cuts;
      constant slice_starter  : integer := result_len-slice_len;
      variable result         : coefficient_array(1 to result_len)  := (others => (others => '0'));
   begin
      for index in 1 to slice_len loop
         if(front_load = 1) then
            result(index) := original_array(cut-1 + ((index-1)*num_cuts));
         else
            result(index+slice_starter) := original_array(cut-1 + ((index-1)*num_cuts));
         end if;
      end loop;
      return result;
   end function;
   
end package body;