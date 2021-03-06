--------------------------------------------------------------------------------------------------
--        FIR Filter
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;

package fir_filter_pkg is
   --FIR filter component declaration
   component fir_filter is
      generic( h                    : coefficient_array);
      port(    clk                  : in  std_logic;
               rst                  : in  std_logic;
               x                    : in  sig;
               y                    : out fir_sig);
   end component;
end package;

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.dsp_pkg.all;
   use work.fir_tap_pkg.all;

entity fir_filter is
   generic( h                    : coefficient_array);
   port(    clk                  : in  std_logic;
            rst                  : in  std_logic;
            x                    : in  sig;
            y                    : out fir_sig);
end fir_filter;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture behave of fir_filter is
   signal x_chain       : sig_array(h'range)       := (others  => (others => '0'));
   signal running_sum   : fir_sig_array(h'range)   := (others  => (others => '0'));
begin
   
   filter_loop : for tap in h'low to h'high generate
   begin

      head_tap_gen : if tap = h'low generate
         head_tap : fir_tap
         port map(clk      => clk,
                  rst      => rst,
                  coef     => h(tap),
                  sig_in   => x,
                  sig_out  => x_chain(tap),
                  sum_in   => (others => '0'),
                  sum_out  => running_sum(tap));
      end generate; --if head tap
      
      tail_taps_gen : if tap /= h'low generate
         tail_tap : fir_tap
         port map(clk      => clk,
                  rst      => rst,
                  coef     => h(tap),
                  sig_in   => x_chain(tap-1),
                  sig_out  => x_chain(tap),
                  sum_in   => running_sum(tap-1),
                  sum_out  => running_sum(tap));
      end generate; --if tail taps
      
   end generate;
   
   --output end of the running sum
   y <= running_sum(h'high);
   
end behave;
