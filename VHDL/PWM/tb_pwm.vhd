--------------------------------------------------------------------------------------------------
--        PWM Testbench
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
--   use work.tb_write_csv_pkg.all;
   use work.pwm_pkg.all;

--This module is a test-bench for simulating the fir filter
entity tb_pwm is
end tb_pwm;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture sim of tb_pwm is
   constant INPUT_FILE  : string
      := "C:\Users\Matt\Documents\MATLAB\pwm_chirp.csv";
--
--   constant OUTPUT_FILE : string
--      := "C:\Users\Matt\Documents\MATLAB\pwm_result.csv";

   constant NUM_SIG_BITS   : natural   := 16;

   signal rst        : std_logic := '0';
   signal clk        : std_logic := '0';
   signal sig        : std_logic_vector(NUM_SIG_BITS-1 downto 0) := (others => '0');
   signal pulse      : std_logic;

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
   uut : pwm
   port map(clk         => clk,
            rst         => rst,
            data        => signed(sig),
            pwm_pulses  => pulse);


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
