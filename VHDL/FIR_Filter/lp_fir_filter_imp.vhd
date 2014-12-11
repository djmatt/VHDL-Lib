--------------------------------------------------------------------------------------------------
--        Linear Phase FIR Filter Implementation
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
   use work.lp_fir_filter_pkg.all;

--This module is a top-level for implementing the fir filter
entity lp_fir_filter_imp is
   port(    clk                  : in  std_logic;
            rst                  : in  std_logic;
            x                    : in  sig;
            y                    : out fir_sig);
end lp_fir_filter_imp;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture imp of lp_fir_filter_imp is
begin
   --Instantiate unit under test
   uut : entity work.lp_fir_filter(behave)
      generic map(h    => HIGH_PASS_101)
      port map(   clk  => clk,
                  rst  => rst,
                  x    => x,
                  y    => y);
end imp;
