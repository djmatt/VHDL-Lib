----------------------------------------------------------------------------------------------------
--        FIR Tap
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.dsp_pkg.all;
   
package fir_tap_pkg is

   --FIR tap component declaration
   component fir_tap is
      port(    clk                  : in  std_logic;
               rst                  : in  std_logic;
               coef                 : in  coefficient;
               sig_in               : in  sig;
               sig_out              : out sig;
               sum_in               : in  fir_sig;
               sum_out              : out fir_sig);
   end component;
   
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
library work;
   use work.dsp_pkg.all;

--This entity represents a single tap in a FIR filter.  The taps are designed to implement a cascade 
--adder allowing for chaining an indefinite (tho definitely finite) number of taps.
entity fir_tap is
   port(    clk                  : in  std_logic;
            rst                  : in  std_logic;
            coef                 : in  coefficient;
            sig_in               : in  sig;
            sig_out              : out sig;
            sum_in               : in  fir_sig;
            sum_out              : out fir_sig);
end fir_tap;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE (behavioral)
----------------------------------------------------------------------------------------------------
architecture behave of fir_tap is
   signal intermediate  : sig := (others => '0');
begin  

   --delay the signal 2 clocks (one more than the running sum)
   delay_sig : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then   
            sig_out        <= (others => '0');
            intermediate   <= (others => '0');
         else
            sig_out        <= intermediate;
            intermediate   <= sig_in;
         end if;
      end if;
   end process;
   
   --update the sum (includes 1 clock delay)
   update_sum : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            sum_out <= (others => '0');
         else 
            sum_out <= sum_in + resize(sig_in * coef, NUM_FIR_BITS);
         end if;
      end if;
   end process;

end behave;
