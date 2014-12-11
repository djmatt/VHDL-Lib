--------------------------------------------------------------------------------------------------
--        Multi-channel FIR Filter Testbench
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
   use work.dsp_pkg.all;
   use work.tb_write_csv_pkg.all;
   use work.multichannel_fir_filter_pkg.all;

--This module is a test-bench for simulating the multichannel fir filter
entity tb_multichannel_fir_filter is
end tb_multichannel_fir_filter;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture sim of tb_multichannel_fir_filter is
   constant INPUT_FILE1    : string 
      := "X:\Education\Masters Thesis\matlab\multichannel\chirp_s2f.csv";
   constant TEST_FILTER1   : coefficient_array  := LOW_PASS_101;
   constant OUTPUT_FILE1   : string 
      := "X:\Education\Masters Thesis\matlab\multichannel\chirp_lowpass101.csv";  
   
   constant INPUT_FILE2    : string 
      := "X:\Education\Masters Thesis\matlab\multichannel\chirp_f2s.csv";
   constant TEST_FILTER2   : coefficient_array  := HIGH_PASS_101;
   constant OUTPUT_FILE2   : string 
      := "X:\Education\Masters Thesis\matlab\multichannel\chirp_highpass101.csv";  
  
   signal rst        : std_logic                                  := '0';
   signal clk        : std_logic                                  := '0';
   signal clk_2x     : std_logic                                  := '0';
   signal sig1       : std_logic_vector(NUM_SIG_BITS-1 downto 0)  := (others => '0');
   signal sig2       : std_logic_vector(NUM_SIG_BITS-1 downto 0)  := (others => '0');
   signal filtered1  : fir_sig                                    := (others => '0');
   signal filtered2  : fir_sig                                    := (others => '0');
   
begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 10ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk);
      
   --Instantiate 2x clock generator
   clk2 : tb_clockgen
      generic map(PERIOD      => 5ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk_2x);
   
   --Instantiate file reader
   reader1 : tb_read_csv
      generic map(FILENAME => INPUT_FILE1)
      port map(   clk      => clk,
                  data     => sig1);
   
   --Instantiate file reader              
   reader2  : tb_read_csv
      generic map(FILENAME => INPUT_FILE2)
      port map(   clk      => clk,
                  data     => sig2);
                  
   --Instantiate unit under test
   uut : entity work.multichannel_fir_filter(behave)
      generic map(h0       => TEST_FILTER1,
                  h1       => TEST_FILTER2)
      port map(   clk      => clk,
                  clk_2x   => clk_2x,
                  rst      => rst,
                  x1       => signed(sig1),
                  x2       => signed(sig2),
                  y1       => filtered1,
                  y2       => filtered2);
                                  
   --Instantiate a file writer
   writer1 : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE1)
      port map(   clk      => clk,
                  data     => std_logic_vector(filtered1(30 downto 15)));

   --Instantiate a file writer
   writer2 : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE2)
      port map(   clk      => clk,
                  data     => std_logic_vector(filtered2(30 downto 15)));

   --Main Process
   --TODO: Add a check for end of file, once reached terminate simulation.
   main: process
   begin
      rst <= '1';
      wait for 12ns;
      rst <= '0';
      wait;
   end process;
end sim;
