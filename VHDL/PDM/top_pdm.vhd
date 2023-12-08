--------------------------------------------------------------------------------------------------
--        pdm Testbench
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.pdm_pkg.all;

--This module is a test-bench for simulating the pulse density modulator
entity top_pdm is
   port( clk      : in  std_logic;
         rst      : in  std_logic;
         sig      : in  std_logic_vector(16-1 downto 0) := (others => '0');
         pulse    : out std_logic);
end top_pdm;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture rtl of top_pdm is

begin
   --Instantiate unit under test
   uut : pdm
   port map(clk         => clk,
            rst         => rst,
            data        => signed(sig),
            pdm_pulses  => pulse);
end rtl;
