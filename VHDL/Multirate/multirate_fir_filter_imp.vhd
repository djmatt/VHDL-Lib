--------------------------------------------------------------------------------------------------
--        Multirate Filter Implementation
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.dsp_pkg.all;
   use work.multirate_fir_filter_pkg.all;

--This module is a top-level for implementing the fir filter
entity multirate_fir_filter_imp is
   port(    clk_low              : in  std_logic;
            clk_high             : in  std_logic;
            rst                  : in  std_logic;
            x                    : in  sig;
            y                    : out sig);
end multirate_fir_filter_imp;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture imp of multirate_fir_filter_imp is
begin
   --Instantiate unit under test
   uut : entity work.multirate_fir_filter(behave)
   generic map(h        => LOW_PASS_41)
   port map(   clk_low  => clk_low,
               clk_high => clk_high,
               rst      => rst,
               x        => x,
               y        => y);
end imp;
