----------------------------------------------------------------------------------------------------
--        FIR Filter
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;

package lp_fir_filter_pkg is
   --linear phase FIR filter component declaration
   component lp_fir_filter is
      generic( h                    : coefficient_array);
      port(    clk                  : in  std_logic;
               rst                  : in  std_logic;
               x                    : in  sig;
               y                    : out fir_sig);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.dsp_pkg.all;
   use work.lp_fir_tap_pkg.all;

entity lp_fir_filter is
   generic( h                    : coefficient_array);
   port(    clk                  : in  std_logic;
            rst                  : in  std_logic;
            x                    : in  sig;
            y                    : out fir_sig);
end lp_fir_filter;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of lp_fir_filter is
   constant N              : natural := h'length;
   constant NTAPS          : natural := N - N/2;
   constant RETURN_DELAY   : natural := NTAPS*2-1;
   constant FIRST_TAP      : natural := h'low;
   constant LAST_TAP       : natural := h'low + NTAPS-1;
   
   signal x_chain          : sig_array(0 to NTAPS-1);
   signal x_return_delay   : sig_array(0 to RETURN_DELAY-1);
   signal running_sum      : fir_sig_array(0 to NTAPS-1);
begin
   
   --The return path can be replicated useing a fifo of an appropriate delay
   x_return_fifo : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then   
            x_return_delay <= (others => (others => '0'));
         else
            x_return_delay(0) <= x;
            for xn in 1 to RETURN_DELAY-1 loop
               x_return_delay(xn) <= x_return_delay(xn-1);
            end loop;
         end if;
      end if;
   end process;

   --This chain links the taps together
   filter_chain : for tap in FIRST_TAP to LAST_TAP generate
   begin

      head_tap_gen : if tap = FIRST_TAP generate
         head_tap : lp_fir_tap
         port map(clk            => clk,
                  rst            => rst,
                  coef           => h(tap),
                  sig_in         => x,
                  return_sig_in  => x_return_delay(x_return_delay'high),
                  sig_out        => x_chain(tap),
                  sum_in         => (others => '0'),
                  sum_out        => running_sum(tap));
      end generate; --if head tap
      
      mid_taps_gen : if tap /= FIRST_TAP and tap /= LAST_TAP generate
         mid_tap : lp_fir_tap
         port map(clk            => clk,
                  rst            => rst,
                  coef           => h(tap),
                  sig_in         => x_chain(tap-1),
                  return_sig_in  => x_return_delay(x_return_delay'high),
                  sig_out        => x_chain(tap),
                  sum_in         => running_sum(tap-1),
                  sum_out        => running_sum(tap));
      end generate; --if mid taps
      
      last_tap_even_gen : if tap = LAST_TAP and (NTAPS mod 2) = 0 generate
         last_tap_even_tap : lp_fir_tap
         port map(clk            => clk,
                  rst            => rst,
                  coef           => h(tap),
                  sig_in         => x_chain(tap-1),
                  return_sig_in  => x_return_delay(x_return_delay'high),
                  sig_out        => x_chain(tap),
                  sum_in         => running_sum(tap-1),
                  sum_out        => running_sum(tap));
      end generate; --if last even tap
      
      last_tap_odd_gen : if tap = LAST_TAP and (NTAPS mod 2) = 1 generate
         last_tap_odd_tap : lp_fir_tap
         port map(clk            => clk,
                  rst            => rst,
                  coef           => h(tap),
                  sig_in         => x_chain(tap-1),
                  return_sig_in  => (others => '0'),
                  sig_out        => x_chain(tap),
                  sum_in         => running_sum(tap-1),
                  sum_out        => running_sum(tap));
      end generate; --if last odd tap

   end generate;
   
   --output end of the running sum
   y <= running_sum(NTAPS-1);
   
end behave;
