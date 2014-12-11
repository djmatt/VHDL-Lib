--------------------------------------------------------------------------------------------------
--        Filter Bank Implementation
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
   use work.filter_bank_pkg.all;

--This module is a test-bench for simulating the fir filter
entity filter_bank_imp is
   port(    clk0           : in  std_logic;
            clk1           : in  std_logic;
            clk2           : in  std_logic;
            clk3           : in  std_logic;
            rst            : in  std_logic;
            x              : in  sig;
            y              : out sig);
end filter_bank_imp;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture imp of filter_bank_imp is
begin
   --Instantiate unit under test
   uut : entity work.filter_bank(behave)
      generic map(analysis_low   => PR_ANALYSIS_LOW,
                  analysis_high  => PR_ANALYSIS_HIGH,
                  synthesis_low  => PR_SYNTHESIS_LOW,
                  synthesis_high => PR_SYNTHESIS_HIGH)
      port map(   clk0           => clk0,
                  clk1           => clk1,
                  clk2           => clk2,
                  clk3           => clk3,
                  rst            => rst,
                  x              => x,
                  y              => y);
end imp;
