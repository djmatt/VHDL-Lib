----------------------------------------------------------------------------------------------------
--        Linear Feedback Shift Register
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package lfsr_pkg is
   component lfsr is
      port( clk         : in  std_logic;
            rst         : in  std_logic;
            poly_mask   : in  std_logic_vector;
            seed        : in  std_logic_vector;
            feedin      : in  std_logic_vector;
            feedout     : out std_logic_vector;
            history     : out std_logic_vector);
   end component;

   function xor_Reduce(bits: std_logic_vector) return std_logic;
end package;

----------------------------------------------------------------------------------------------------
--        PACKAGE BODY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package body lfsr_pkg is
   -- XOR's all the bits in a vector.  Useful for checking the parity of a vector.
   -- bits:    Logic vector
   -- returns: result of all the bits XOR'd together
   function xor_Reduce(bits: std_logic_vector) return std_logic is
   begin
      if(bits'low = bits'high) then
         return bits(bits'low);
      else
         if(bits'ascending) then
            return bits(bits'low) xor xor_Reduce(bits(bits'low+1 to bits'high));
         else
            return bits(bits'low) xor xor_Reduce(bits(bits'high downto bits'low+1));
         end if;
      end if;
   end function;
end package body;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.lfsr_pkg.all;
   use work.reduce_pkg.reduce_xor;

--Linear feedback shift register
--Using this module requires that the feedout be fed-back into feedin at some point.  The feedback
--would normally be done internally, except some designs require modifying the feedback before
--returning it to the shift register.  To support such robust designs the feedback is always
--expected to be performed at a higher level, even when simple feedback is all that is required
--(e.g. feedin<=feedout;)
entity lfsr is
   port( --Process clock, on every rising edge the LFSR updates the feedback with a new value and 
         --shifts previous values into the history.
         clk         : in  std_logic;
         --Asynchronous reset. While high: resets the LFSR to the seed value and sets the poly_mask
         --used for the feedback polynomial
         rst         : in  std_logic;
         --Place '1's in the bits where the polynomial calls for taps.  Read up on LFSR's before
         --selecting a polynomial, not all choices will yield "good" random numbers.
         --(e.g. X^5 + X^3 + 1 would be poly_mask(4 downto 0) <= "10100";)
         poly_mask   : in  std_logic_vector;
         --Must be identical in length to poly_mask. Initial value of the shift register.  Is only
         --set during rst = '1'.  DO NOT SET TO ALL '0's
         seed        : in  std_logic_vector;
         --Return path for the feedback.  Feeds directly into the shift register.
         feedin      : in  std_logic_vector;
         --Outbound path of the feedback.  This value is the result of the polynomial.  Feedback
         --this value to this module using feedin port.  Some designs call for xor'ing this value
         --with another value before returning to feedin.  Wider feedback signal generate multiple 
         --feedback bits per clock cycle, but can be difficult for timing.
         feedout     : out std_logic_vector;
         --This output contains the history of the feedback which is also used to calculate the 
         --subsequent feedback.  The history has to be seeded, hence the seed input.  It can also
         --be used to source pseudorandom values.
         history     : out std_logic_vector);
end lfsr;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE (structural)
----------------------------------------------------------------------------------------------------
architecture structural of lfsr is
   signal poly_mask_reg : std_logic_vector(poly_mask'range) := (others => '0');
   --All of these internal signals need to be defined in the same 0-to-'length range-order to make
   --optimal use of the 'range attribute
   signal shift_reg     : std_logic_vector(0 to (feedin'length + poly_mask'length-1)) := (others => '0');
      alias data_in     : std_logic_vector(0 to (feedin'length-1)) is shift_reg(0 to (feedin'length-1));
      alias polynomial  : std_logic_vector(0 to (poly_mask'length-1)) is shift_reg(feedin'length to (feedin'length + poly_mask'length-1));
   signal result        : std_logic_vector(0 to (feedout'length-1)) := (others => '0');
begin

   --load the left-most bits of shift_reg with the feedin
   data_in <= feedin;

   --Process to shift the feedback through a shift-register
   shifter: process(clk, rst)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            --Typical vector assignments preserve the left-to-right bit order.  We need to preserve the
            --0 to n order for this assignment.  The seed may not always be defined 0-to-n, but at
            --least we know polynomial is 0-to-n.
            for n in seed'low to seed'high loop
               polynomial(n-seed'low) <= seed(n);
            end loop;
            
            --Set the polynomial mask when only while reset is asserted.
            poly_mask_reg <= poly_mask;
         else   
            --shift_reg is a concatenation of data_in and polynomial. By assigning the left-most
            --bits of shift_reg to polynomial(the right-most bits), we achieve a right shift.
            polynomial <= shift_reg(polynomial'range);
         end if;
      end if;
   end process;

   --The shift register updates every clock cycle, when it does, this generate loop calculates the
   --feedback result.  The result is the modulus-2 summation of specified polynomial taps.
   --Modulus-2 addition is simply an xor operation.
   calc_feedback: for outbit in result'reverse_range generate
      signal polynomial_window   : std_logic_vector(polynomial'range);
      signal final_polynomial    : std_logic_vector(polynomial'range);
      signal iResult             : std_logic := '0';
   begin
      --Lines up the polynomial with the current outbit
      polynomial_window <= shift_reg(outbit + polynomial'low + 1 to outbit + polynomial'high + 1);

      --This loop will handle situations when the poly_mask is not a 0-based ascending ranged vector
      loop_taps: for tap in poly_mask_reg'range generate
         final_polynomial(tap-poly_mask'low)  <= poly_mask_reg(tap-poly_mask'low) and polynomial_window(tap-poly_mask'low);
      end generate;

      --Finally we need to find the modulus-2 summation of the final polynomial for this outbit
      reducer: reduce_xor
      port map(data     => final_polynomial,
               result   => iResult);
      result(outbit) <= iResult;
      
   end generate;

   --Before feeding the result back to the shift register, pass it to the higher level first.
   feedout <= result;
   
   --Output the polynomial portion of the shift register.
   history <= polynomial;
end structural;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE (behavioral)
----------------------------------------------------------------------------------------------------
architecture behave of lfsr is
   signal poly_mask_reg : std_logic_vector(poly_mask'range) := (others => '0');
   --All of these internal signals need to be defined in the same 0-to-'length range order to make optimal use of the 'range attribute
   signal shift_reg     : std_logic_vector(0 to (feedin'length + poly_mask'length-1)) := (others => '0');
      alias data_in     : std_logic_vector(0 to (feedin'length-1)) is shift_reg(0 to (feedin'length-1));
      alias polynomial  : std_logic_vector(0 to (poly_mask'length-1)) is shift_reg(feedin'length to (feedin'length + poly_mask'length-1));
   signal result        : std_logic_vector(0 to (feedout'length-1));
begin

   --load the left-most bits of shift_reg with the feedin
   data_in <= feedin;

   --Process to shift the feedback through a shift-register
   shifter: process(clk, rst)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            --Typical vector assignments preserve the left-to-right bit order.  We need to preserve the
            --0 to n order for this assignment.  The seed may not always be defined 0-to-n, but at
            --least we know polynomial is 0-to-n.
            for n in seed'low to seed'high loop
               polynomial(n-seed'low) <= seed(n);
            end loop;
            
            --Set the polynomial mask when only while reset is asserted.
            poly_mask_reg <= poly_mask;
         else   
            --shift_reg is a concatenation of data_in and polynomial. By assigning the left-most
            --bits of shift_reg to polynomial(the right-most bits), we achieve a right shift.
            polynomial <= shift_reg(polynomial'range);
         end if;
      end if;
   end process;

   --The shift register updates every clock cycle, when it does, this process calculates the feedback result
   --The result is the modulus-2 summation of specified polynomial taps.
   --Modulus-2 addition is simply an xor operation.
   process(polynomial)
      variable tmp : std_logic_vector(0 to (result'length + polynomial'length-1));
   begin
      tmp := (others => '0');
      tmp(result'length to (result'length + polynomial'length-1)) := polynomial;--way to say polynomial'(range + scalar)?
      for outbit in result'reverse_range loop --It is critical that the result is calculated from right to left.  This ensures the feedback history is preserved
         for tap in poly_mask_reg'range loop
            if(poly_mask_reg(tap) = '1') then
               tmp(outbit) := tmp(outbit) xor tmp(tap-poly_mask_reg'low+outbit+1); --subtracting poly_mask_reg'low is to handle situations where the poly_mask_reg'range is not 0-based (e.g. 1 to 15)
            end if;
         end loop;
      end loop;
      --left-most bits of the temporary variable contains the result.
      result <= tmp(result'range);
   end process;

   --Before feeding the result back to the shift register, pass it to the higher level first.
   feedout(feedout'range) <= result(result'range);
   
   --Output the polynomial portion of the shift register.
   history <= polynomial;

end behave;
