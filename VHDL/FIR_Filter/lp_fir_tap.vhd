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
   
package lp_fir_tap_pkg is

   --Linear Phase FIR tap component declaration
   component lp_fir_tap is
      port(    clk                  : in  std_logic;
               rst                  : in  std_logic;
               coef                 : in  coefficient;
               sig_in               : in  sig;
               sig_out              : out sig;
               return_sig_in        : in  sig;
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

--This entity represents a single tap in a even-symmetry linear phase FIR filter.  The taps are 
--designed to implement a cascade adder allowing for chaining an indefinite (tho definitely finite) 
--number of taps.
entity lp_fir_tap is
   port(    clk                  : in  std_logic;
            rst                  : in  std_logic;
            coef                 : in  coefficient;
            sig_in               : in  sig;
            sig_out              : out sig;
            return_sig_in        : in  sig;
            sum_in               : in  fir_sig;
            sum_out              : out fir_sig);
end lp_fir_tap;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE (behavioral)
----------------------------------------------------------------------------------------------------
architecture behave of lp_fir_tap is
   signal sig_delay        : sig_array(1 to 2)     := (others => (others => '0'));
   signal return_sig_delay : sig                   := (others => '0');
   signal pre_add_sum      : summed_sig            := (others => '0');
   signal product          : fir_sig               := (others => '0');
begin  

   --delay the input signals 
   delay_sig : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then   
            sig_delay         <= (others => (others => '0'));
            return_sig_delay  <= (others => '0');
         else
            sig_delay(1)      <= sig_in;
            sig_delay(2)      <= sig_delay(1);
            return_sig_delay  <= return_sig_in;
         end if;
      end if;
   end process;   
   sig_out <= sig_delay(2);
      
   --pre add the signal and returning signal; register the result
   pre_add : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then   
            pre_add_sum <= (others => '0');
         else
            pre_add_sum <= resize(sig_delay(2), NUM_SUMMED_SIG_BITS) + resize(return_sig_delay, NUM_SUMMED_SIG_BITS);
         end if;
      end if;
   end process;
   
   --multiply the pre-add sum to the tap coefficient
   multiply : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then   
            product <= (others => '0');
         else
            product <= resize(pre_add_sum * coef, NUM_FIR_BITS);
         end if;
      end if;
   end process;
   
   --update the running sum 
   update_sum : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            sum_out <= (others => '0');
         else 
            sum_out <= sum_in + product;
         end if;
      end if;
   end process;

end behave;
