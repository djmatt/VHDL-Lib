----------------------------------------------------------------------------------------------------
--        FIR Filter Testbench
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
   use work.fir_filter_pkg.all;

--This module is a test-bench for simulating the LFSR
entity tb_fir_filter is
end tb_fir_filter;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_fir_filter is
--   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs.csv";
--   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs_filtered.csv";  
   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp.csv";
   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_filtered.csv";  
  
   signal rst        : std_logic := '0';
   signal clk        : std_logic := '0';
   signal sig        : std_logic_vector(NUM_SIG_BITS-1 downto 0) := (others => '0');
   signal filtered   : fir_sig := (others => '0');
begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 10ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk);
      
   
   --Instantiate file reader
   reader : tb_read_csv
      generic map(FILENAME => INPUT_FILE)
      port map(   clk      => clk,
                  data     => sig);
   

   --Instantiate unit under test
   uut : entity work.fir_filter(behave)
      generic map(h    => LOW_PASS)
      port map(   clk  => clk,
                  rst  => rst,
                  x    => signed(sig),
                  y    => filtered);
                                    
   --Instantiate a file writer
   writer : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE)
      port map(   clk      => clk,
                  data     => std_logic_vector(filtered(30 downto 15)));

   --Main Process
   --TODO: Add a check for end of file, once reached terminate simulation.
   main: process
   begin
      rst <= '1';
      wait for 10ns;
      rst <= '0';
      wait;
   end process;
end sim;
