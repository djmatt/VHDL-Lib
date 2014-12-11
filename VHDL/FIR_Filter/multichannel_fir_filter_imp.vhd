--------------------------------------------------------------------------------------------------
--        Multichannel FIR Filter Implementation
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
   use work.multichannel_fir_filter_pkg.all;

--This module is a top-level for implementing the fir filter
entity multichannel_fir_filter_imp is
   port(    clk                  : in  std_logic;
            clk_2x               : in  std_logic;
            rst                  : in  std_logic;
            x1                   : in  sig;
            x2                   : in  sig;
            y1                   : out fir_sig;
            y2                   : out fir_sig);
end multichannel_fir_filter_imp;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture imp of multichannel_fir_filter_imp is
begin
   uut : entity work.multichannel_fir_filter(behave)
      generic map(h0       => LOW_PASS_41,
                  h1       => HIGH_PASS_41)
      port map(   clk      => clk,
                  clk_2x   => clk_2x,
                  rst      => rst,
                  x1       => x1,
                  x2       => x2,
                  y1       => y1,
                  y2       => y2);
end imp;
