----------------------------------------------------------------------------------------------------
--        Interpolator Testbench
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
   use work.interpolator_pkg.all;

--This module is a test-bench for simulating the fir filter
entity tb_interpolator is
end tb_interpolator;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_interpolator is
--   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\singleSig_decimated.csv";  
--   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\singleSig_interpolated.csv";
--   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs_decimated.csv";  
--   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs_interpolated.csv";
   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_decimated.csv";  
   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_interpolated.csv";
  
   signal rst        : std_logic := '0';
   signal clk_10ns   : std_logic := '0';
   signal clk_20ns   : std_logic := '0';
   signal sig_in     : sig       := (others => '0');
   signal sig_out    : sig       := (others => '0');
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
   
   --Instantiate file reader
   reader : tb_read_csv
      generic map(FILENAME    => INPUT_FILE)
      port map(   clk         => clk_20ns,
                  sig(data)   => sig_in);

   --Instantiate unit under test
   uut : entity work.interpolator(behave)
--      generic map(h        => LOW_PASS)
      generic map(h        => PR_SYNTHESIS_LOW)
      port map(   clk_high => clk_10ns,
                  clk_low  => clk_20ns,
                  rst      => rst,
                  sig_low  => sig_in,
                  sig_high => sig_out);
                                    
   --Instantiate a file writer
   writer : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE)
      port map(   clk      => clk_10ns,
                  data     => std_logic_vector(sig_out));

   --Main Process
   --TODO: Add a check for end of file, once reached terminate simulation.
   main: process
   begin
      rst <= '1';
      wait for 36ns;
      rst <= '0';
      wait;
   end process;
end sim;
