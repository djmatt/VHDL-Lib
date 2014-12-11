--------------------------------------------------------------------------------------------------
--        Digital Signal Processing package
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
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
   constant ZERO_COEF         : coefficient       := x"0000";

   constant PASS_THRU         : coefficient_array := (x"0000", x"0000", x"0000",
         x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"7FFF",
         x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
         x"0000", x"0000");

   constant LOW_PASS_21       : coefficient_array := (x"0000", x"0070", x"0000",
         x"fe7b", x"0000", x"0453", x"0000", x"f512", x"0000", x"27c2", x"4010",
         x"27c2", x"0000", x"f512", x"0000", x"0453", x"0000", x"fe7b", x"0000",
         x"0070", x"0000");

   constant HIGH_PASS_21      : coefficient_array := (x"0000", x"ff90", x"0000",
         x"0185", x"0000", x"fbad", x"0000", x"0aee", x"0000", x"d83e", x"4010",
         x"d83e", x"0000", x"0aee", x"0000", x"fbad", x"0000", x"0185", x"0000",
         x"ff90", x"0000");
         
   constant LOW_PASS_41       : coefficient_array := (x"0000", x"ffdb", x"0000",
         x"0042", x"0000", x"ff7f", x"0000", x"00ee", x"0000", x"fe66", x"0000",
         x"02a1", x"0000", x"fbc8", x"0000", x"06ef", x"0000", x"f330", x"0000",
         x"2872", x"4010", x"2872", x"0000", x"f330", x"0000", x"06ef", x"0000",
         x"fbc8", x"0000", x"02a1", x"0000", x"fe66", x"0000", x"00ee", x"0000",
         x"ff7f", x"0000", x"0042", x"0000", x"ffdb", x"0000");

   constant HIGH_PASS_41      : coefficient_array := (x"0000", x"0025", x"0000",
         x"ffbe", x"0000", x"0081", x"0000", x"ff12", x"0000", x"019a", x"0000",
         x"fd5f", x"0000", x"0438", x"0000", x"f911", x"0000", x"0cd0", x"0000",
         x"d78e", x"4010", x"d78e", x"0000", x"0cd0", x"0000", x"f911", x"0000",
         x"0438", x"0000", x"fd5f", x"0000", x"019a", x"0000", x"ff12", x"0000",
         x"0081", x"0000", x"ffbe", x"0000", x"0025", x"0000");
         
   constant LOW_PASS_101      : coefficient_array := (x"0000", x"0000", x"0000",
         x"ffff", x"0000", x"0003", x"0000", x"fffb", x"0000", x"0009", x"0000",
         x"fff2", x"0000", x"0015", x"0000", x"ffe1", x"0000", x"002c", x"0000",
         x"ffc2", x"0000", x"0054", x"0000", x"ff90", x"0000", x"0092", x"0000",
         x"ff43", x"0000", x"00f2", x"0000", x"fecd", x"0000", x"0183", x"0000",
         x"fe19", x"0000", x"0267", x"0000", x"fcf0", x"0000", x"03fd", x"0000",
         x"fa9c", x"0000", x"07d5", x"0000", x"f29f", x"0000", x"28a3", x"4010",
         x"28a3", x"0000", x"f29f", x"0000", x"07d5", x"0000", x"fa9c", x"0000",
         x"03fd", x"0000", x"fcf0", x"0000", x"0267", x"0000", x"fe19", x"0000",
         x"0183", x"0000", x"fecd", x"0000", x"00f2", x"0000", x"ff43", x"0000",
         x"0092", x"0000", x"ff90", x"0000", x"0054", x"0000", x"ffc2", x"0000",
         x"002c", x"0000", x"ffe1", x"0000", x"0015", x"0000", x"fff2", x"0000",
         x"0009", x"0000", x"fffb", x"0000", x"0003", x"0000", x"ffff", x"0000",
         x"0000", x"0000");
         
   constant HIGH_PASS_101     : coefficient_array := (x"0000", x"0000", x"0000",
         x"0001", x"0000", x"fffd", x"0000", x"0005", x"0000", x"fff7", x"0000",
         x"000e", x"0000", x"ffeb", x"0000", x"001f", x"0000", x"ffd4", x"0000",
         x"003e", x"0000", x"ffac", x"0000", x"0070", x"0000", x"ff6e", x"0000",
         x"00bd", x"0000", x"ff0e", x"0000", x"0133", x"0000", x"fe7d", x"0000",
         x"01e7", x"0000", x"fd99", x"0000", x"0310", x"0000", x"fc03", x"0000",
         x"0564", x"0000", x"f82b", x"0000", x"0d61", x"0000", x"d75d", x"4010",
         x"d75d", x"0000", x"0d61", x"0000", x"f82b", x"0000", x"0564", x"0000",
         x"fc03", x"0000", x"0310", x"0000", x"fd99", x"0000", x"01e7", x"0000",
         x"fe7d", x"0000", x"0133", x"0000", x"ff0e", x"0000", x"00bd", x"0000",
         x"ff6e", x"0000", x"0070", x"0000", x"ffac", x"0000", x"003e", x"0000",
         x"ffd4", x"0000", x"001f", x"0000", x"ffeb", x"0000", x"000e", x"0000",
         x"fff7", x"0000", x"0005", x"0000", x"fffd", x"0000", x"0001", x"0000",
         x"0000", x"0000");
                                                                                                
   constant PR_ANALYSIS_LOW   : coefficient_array := (x"0a71", x"2378", x"3882",
         x"2c62", x"02c3", x"e702", x"f433", x"0de2", x"0c3f", x"f7f0", x"f50c",
         x"04e9", x"096d", x"fcde", x"f7f6", x"021f", x"06d3", x"fe78", x"fa36",
         x"012f", x"04e8", x"ff05", x"fbdc", x"00dd", x"037a", x"ff35", x"fd1a",
         x"00bf", x"0263", x"ff4b", x"fe0f", x"00aa", x"018e", x"ff61", x"fec6",
         x"0095", x"00ef", x"ff7b", x"ff4d", x"0077", x"0080", x"ff99", x"ffaa",
         x"0055", x"0039", x"ffb9", x"ffdc", x"003e", x"0018", x"ffa9", x"0041",
         x"ffed");

   constant PR_ANALYSIS_HIGH  : coefficient_array := (x"0013", x"0041", x"0057",
         x"0018", x"ffc2", x"ffdc", x"0047", x"0039", x"ffab", x"ffaa", x"0067",
         x"0080", x"ff89", x"ff4d", x"0085", x"00ef", x"ff6b", x"fec6", x"009f",
         x"018e", x"ff56", x"fe0f", x"00b5", x"0263", x"ff41", x"fd1a", x"00cb",
         x"037a", x"ff23", x"fbdc", x"00fb", x"04e8", x"fed1", x"fa36", x"0188",
         x"06d3", x"fde1", x"f7f6", x"0322", x"096d", x"fb17", x"f50c", x"0810",
         x"0c3f", x"f21e", x"f433", x"18fe", x"02c3", x"d39e", x"3882", x"dc88",
         x"0a71");

   constant PR_SYNTHESIS_LOW  : coefficient_array := (x"ffda", x"0083", x"ff51",
         x"0030", x"007d", x"ffb7", x"ff72", x"0072", x"00ab", x"ff53", x"ff32",
         x"0100", x"00ef", x"fe99", x"fef6", x"01de", x"012a", x"fd8b", x"fec2",
         x"031d", x"0155", x"fc1e", x"fe96", x"04c7", x"017e", x"fa34", x"fe6a",
         x"06f5", x"01bb", x"f7b7", x"fe09", x"09d0", x"025e", x"f46b", x"fcf0",
         x"0da7", x"043f", x"efec", x"f9bc", x"12da", x"09d3", x"ea17", x"efe0",
         x"187e", x"1bc5", x"e865", x"ce04", x"0587", x"58c4", x"7105", x"46f0",
         x"14e3");

   constant PR_SYNTHESIS_HIGH : coefficient_array := (x"14e3", x"b910", x"7105",
         x"a73c", x"0587", x"31fc", x"e865", x"e43b", x"187e", x"1020", x"ea17",
         x"f62d", x"12da", x"0644", x"efec", x"fbc1", x"0da7", x"0310", x"f46b",
         x"fda2", x"09d0", x"01f7", x"f7b7", x"fe45", x"06f5", x"0196", x"fa34",
         x"fe82", x"04c7", x"016a", x"fc1e", x"feab", x"031d", x"013e", x"fd8b",
         x"fed6", x"01de", x"010a", x"fe99", x"ff11", x"0100", x"00ce", x"ff53",
         x"ff55", x"0072", x"008e", x"ffb7", x"ff83", x"0030", x"00af", x"0083",
         x"0026");                                           

                                                
   --Function declarations
--   type slice_type is array(natural range <>) of integer;
   function slice_coefficient_array (  original_array : coefficient_array; 
                                       num_cuts       : integer;
                                       cut            : integer;
                                       front_load     : integer) return coefficient_array;
   
end package;
 
--------------------------------------------------------------------------------------------------
--        PACKAGE BODY
--------------------------------------------------------------------------------------------------
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
      variable result         : coefficient_array(1 to result_len)  
                                        := (others => (others => '0'));
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