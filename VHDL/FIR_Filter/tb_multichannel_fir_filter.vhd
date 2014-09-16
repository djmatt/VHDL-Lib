----------------------------------------------------------------------------------------------------
--        Multi-channel FIR Filter Testbench
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
   use work.dsp_pkg.all;
   use work.tb_write_csv_pkg.all;
   use work.multichannel_fir_filter_pkg.all;
--   use work.muxer_pkg.all;
--   use work.demuxer_pkg.all;

--This module is a test-bench for simulating the fir filter
entity tb_multichannel_fir_filter is
end tb_multichannel_fir_filter;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_multichannel_fir_filter is
--   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs.csv";
--   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs_filtered.csv";  
   constant INPUT_FILE1 : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp.csv";
   constant INPUT_FILE2 : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp2.csv";
   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_filtered.csv";  
  
   signal rst        : std_logic := '0';
   signal clk        : std_logic := '0';
   signal clk_2x     : std_logic := '0';
   signal sig1       : std_logic_vector(NUM_SIG_BITS-1 downto 0) := (others => '0');
   signal sig2       : std_logic_vector(NUM_SIG_BITS-1 downto 0) := (others => '0');
--   signal sigs       : std_logic_vector(NUM_SIG_BITS-1 downto 0) := (others => '0');
--   signal rsig1      : std_logic_vector(NUM_SIG_BITS-1 downto 0) := (others => '0');
--   signal rsig2      : std_logic_vector(NUM_SIG_BITS-1 downto 0) := (others => '0');
   signal filtered1  : fir_sig := (others => '0');
   signal filtered2  : fir_sig := (others => '0');
   
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
                  
--   mux_sigs : muxer
--      port map(clk      => clk,
--               clk_2x   => clk_2x,
--               rst      => rst,
--               sig_1    => sig1,
--               sig_2    => sig2,
--               sigs     => sigs);
--               
--   demux_sigs : demuxer
--      port map(clk      => clk, 
--               clk_2x   => clk_2x, 
--               rst      => rst, 
--               sigs     => sigs,
--               sig_1    => rsig1, 
--               sig_2    => rsig2);                
--
   --Instantiate unit under test
   uut : entity work.multichannel_fir_filter(behave)
      generic map(h        => LOW_PASS)
      port map(   clk      => clk,
                  clk_2x   => clk_2x,
                  rst      => rst,
                  x1       => signed(sig1),
                  x2       => signed(sig2),
                  y1       => filtered1,
                  y2       => filtered2);
                                  
   --Instantiate a file writer
   writer : tb_write_csv
      generic map(FILENAME => OUTPUT_FILE)
      port map(   clk      => clk,
                  data     => std_logic_vector(filtered1(30 downto 15)));

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