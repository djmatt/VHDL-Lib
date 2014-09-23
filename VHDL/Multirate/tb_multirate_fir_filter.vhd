----------------------------------------------------------------------------------------------------
--        Multirate Fir Filter Testbench
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
   use work.multirate_fir_filter_pkg.all;

--This module is a test-bench for simulating the fir filter
entity tb_multirate_fir_filter is
end tb_multirate_fir_filter;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_multirate_fir_filter is
--   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\singleSig.csv";  
--   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\singleSig_multirated.csv";
   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs2.csv";  
   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\mixedSigs2_multirated.csv";
--   constant INPUT_FILE  : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_half.csv";  
--   constant OUTPUT_FILE : string := "X:\Education\Masters Thesis\matlab\fir_filters\chirp_half_multirated.csv";
  
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
      port map(   clk         => clk_10ns,
                  sig(data)   => sig_in);
                  
   uut : multirate_fir_filter
   generic map(h        => LOW_PASS)
   port map(   clk_low  => clk_20ns,
               clk_high => clk_10ns,
               rst      => rst,
               x        => sig_in,
               y        => sig_out);
                                    
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
      wait for 12ns;
      rst <= '0';
      wait;
   end process;
end sim;
