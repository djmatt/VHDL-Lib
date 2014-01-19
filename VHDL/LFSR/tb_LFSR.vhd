----------------------------------------------------------------------------------------------------
--        LFSR Testbench Top Level
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com
-- Copyright 2013

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.tb_clockgen_pkg.all;
   use work.lfsr_pkg.all;

--This module is a testbench for simulating the LFSR
entity tb_lfsr is
end tb_lfsr;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_lfsr is
   signal rst        : std_logic := '0';
   signal clk        : std_logic := '0';
   signal feedback   : std_logic_vector(3 downto 0);

   signal polynomial : std_logic_vector(6 downto 0) := "0000000";
   signal seed       : std_logic_vector(6 downto 0) := "0000000";
begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 30ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk);

   --Instantiate unit under test
   uut : lfsr
      port map(   clk         => clk,
                  rst         => rst,
                  poly_mask   => polynomial,
                  seed        => seed,
                  feedin      => feedback,
                  feedout     => feedback);

   --Main Process
   main: process
   begin
      polynomial <= "1100000";
      seed       <= "1111111";
      rst <= '1';
      wait for 50ns;
      rst <= '0';
      wait;
   end process;
end sim;
