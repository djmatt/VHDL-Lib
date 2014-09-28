----------------------------------------------------------------------------------------------------
--        Decimator Testbench
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
   use work.decomposition_pkg.all;

--This module is a test-bench for simulating the fir filter
entity tb_decomposition is
end tb_decomposition;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_decomposition is
   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp.csv";
   constant OUTPUT_FILE1: string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_decomp_low.csv";  
   constant OUTPUT_FILE2: string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_decomp_high.csv";  
  
   signal rst           : std_logic := '0';
   signal clk_10ns      : std_logic := '0';
   signal clk_20ns      : std_logic := '0';
   signal sig_in        : sig       := (others => '0');
   signal sig_out_low   : sig       := (others => '0');
   signal sig_out_high  : sig       := (others => '0');
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
      port map(   clk         => clk_10ns,
                  sig(data)   => sig_in);

   --Instantiate unit under test
   uut : entity work.decomposition(behave)
      generic map(low_pass    => NYQUIST_LOW_BANK,
                  high_pass   => NYQUIST_HIGH_BANK)
      port map(   clk_low     => clk_20ns,
                  clk_high    => clk_10ns,
                  rst         => rst,
                  x           => sig_in,
                  y_low       => sig_out_low,
                  y_high      => sig_out_high);
                                    
   --Instantiate a file writer
   writer1 : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE1)
      port map(   clk      => clk_20ns,
                  data     => std_logic_vector(sig_out_low));

   --Instantiate a file writer
   writer2 : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE2)
      port map(   clk      => clk_20ns,
                  data     => std_logic_vector(sig_out_high));

   --Main Process
   --TODO: Add a check for end of file, once reached terminate simulation.
   main: process
   begin
      rst <= '1';
      wait for 16ns;
      rst <= '0';
      wait;
   end process;
end sim;
