----------------------------------------------------------------------------------------------------
--        Filter Bank Testbench
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.tb_clockgen_pkg.all;
   use work.tb_read_csv_pkg.all;
   use work.tb_write_csv_pkg.all;
   use work.dsp_pkg.all;
   use work.filter_bank_pkg.all;

--This module is a test-bench for simulating the fir filter
entity tb_filter_bank is
end tb_filter_bank;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_filter_bank is
   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_long.csv";
   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_filter_bank.csv";  
  
   signal rst           : std_logic := '0';
   signal clk_10ns      : std_logic := '0';
   signal clk_20ns      : std_logic := '0';
   signal clk_40ns      : std_logic := '0';
   signal clk_80ns      : std_logic := '0';
   signal sig_in        : sig       := (others => '0');
   signal sig_out       : sig       := (others => '0');
begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 10ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk_10ns);
      
   clk2 : tb_clockgen
      generic map(PERIOD      => 20ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk_20ns);

   clk3 : tb_clockgen
      generic map(PERIOD      => 40ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk_40ns);

   clk4 : tb_clockgen
      generic map(PERIOD      => 80ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk_80ns);

   --Instantiate file reader
   reader : tb_read_csv
      generic map(FILENAME    => INPUT_FILE)
      port map(   clk         => clk_10ns,
                  sig(data)   => sig_in);

   --Instantiate unit under test
   uut : entity work.filter_bank(behave)
      generic map(analysis_low   => PR_ANALYSIS_LOW,
                  analysis_high  => PR_ANALYSIS_HIGH,
                  synthesis_low  => PR_SYNTHESIS_LOW,
                  synthesis_high => PR_SYNTHESIS_HIGH)
      port map(   clk0           => clk_10ns,
                  clk1           => clk_20ns,
                  clk2           => clk_40ns,
                  clk3           => clk_80ns,
                  rst            => rst,
                  x              => sig_in,
                  y              => sig_out);
                                    
   --Instantiate a file writer
   writer1 : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE)
      port map(   clk      => clk_10ns,
                  data     => std_logic_vector(sig_out));


   --Main Process
   --TODO: Add a check for end of file, once reached terminate simulation.
   main: process
   begin
      rst <= '1';
      wait for 76ns;
      rst <= '0';
      wait;
   end process;
end sim;
