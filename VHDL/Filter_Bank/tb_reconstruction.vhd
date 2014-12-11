--------------------------------------------------------------------------------------------------
--        Reconstruction Testbench
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.tb_clockgen_pkg.all;
   use work.tb_read_csv_pkg.all;
   use work.tb_write_csv_pkg.all;
   use work.dsp_pkg.all;
   use work.reconstruction_pkg.all;

--This module is a test-bench for simulating the fir filter
entity tb_reconstruction is
end tb_reconstruction;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture sim of tb_reconstruction is
   constant INPUT_FILE1 : string 
      := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_decomp_low.csv";  
   constant INPUT_FILE2 : string 
      := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_decomp_high.csv";
   constant OUTPUT_FILE : string 
      := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_reconstructed.csv";
  
   signal rst           : std_logic := '0';
   signal clk_10ns      : std_logic := '0';
   signal clk_20ns      : std_logic := '0';
   signal sig_in1       : sig       := (others => '0');
   signal sig_in2       : sig       := (others => '0');
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
      
   --Instantiate file reader
   reader1 : tb_read_csv
      generic map(FILENAME    => INPUT_FILE1)
      port map(   clk         => clk_20ns,
                  sig(data)   => sig_in1);
                  
   --Instantiate file reader
   reader2 : tb_read_csv
      generic map(FILENAME    => INPUT_FILE2)
      port map(   clk         => clk_20ns,
                  sig(data)   => sig_in2);                  

   --Instantiate unit under test
   uut : entity work.reconstruction(behave)
      generic map(low_pass    => NYQUIST_LOW_BANK,
                  high_pass   => NYQUIST_HIGH_BANK)
      port map(   clk_low     => clk_20ns,
                  clk_high    => clk_10ns,
                  rst         => rst,
                  x_low       => sig_in1,
                  x_high      => sig_in2,
                  y           => sig_out);
                                    
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
