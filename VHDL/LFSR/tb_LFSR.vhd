----------------------------------------------------------------------------------------------------
--        LFSR Test-bench Top Level
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.tb_clockgen_pkg.all;
   use work.tb_write_csv_pkg.all;
   use work.lfsr_pkg.all;

--This module is a test-bench for simulating the LFSR
entity tb_lfsr is
end tb_lfsr;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_lfsr is
   signal rst        : std_logic := '0';
   signal clk        : std_logic := '0';
   signal feedback   : std_logic_vector(0 downto 0) := (others => '0');

   signal polynomial : std_logic_vector(15 downto 0) := (others => '0');
   signal seed       : std_logic_vector(15 downto 0) := (others => '0');
   signal pr_num     : std_logic_vector(15 downto 0) := (others => '0');
   
begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 10ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk);

   --Instantiate unit under test
   uut : entity work.lfsr(structural)
      port map(   clk         => clk,
                  rst         => rst,
                  poly_mask   => polynomial,
                  seed        => seed,
                  feedin      => feedback,
                  feedout     => feedback,
                  history     => pr_num);
                  
   writer : tb_write_csv
      generic map(FILENAME => "prng.csv")
      port map(   clk      => clk,
                  data     => pr_num);

   --Main Process
   main: process
   begin
      polynomial <= (15 => '1', 14 => '1', 12 => '1', 3 =>'1', others => '0'); 
      seed       <= (others => '1');  
      rst <= '1';
      wait for 11ns;
      rst <= '0';
      wait;
   end process;
end sim;
