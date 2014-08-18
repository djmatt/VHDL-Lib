----------------------------------------------------------------------------------------------------
--        Pulse Extender Test-bench
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.tb_clockgen_pkg.all;
   use work.pulse_extender_pkg.all;

--This module is a test-bench for simulating the pulse_extender module
entity tb_pulse_extender is
end tb_pulse_extender;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_pulse_extender is
   signal rst           : std_logic;
   signal clk           : std_logic;
   signal stimulus      : std_logic;
   signal result_e0a0r0 : std_logic;
   signal result_e0a0r1 : std_logic;
   signal result_e0a1r0 : std_logic;
   signal result_e0a1r1 : std_logic;
   signal result_e1a0r0 : std_logic;
   signal result_e1a0r1 : std_logic;
   signal result_e1a1r0 : std_logic;
   signal result_e1a1r1 : std_logic;
   signal result_e4a0r0 : std_logic;
   signal result_e4a0r1 : std_logic;
   signal result_e4a1r0 : std_logic;
   signal result_e4a1r1 : std_logic;


begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 10ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk);

   --UUT
   e0a0r0 : pulse_extender
   generic map(EXTEND_COUNT   => 0,
               ACTIVE_LEVEL   => '0',
               RESET_LEVEL    => '0')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e0a0r0);

   e0a0r1 : pulse_extender
   generic map(EXTEND_COUNT   => 0,
               ACTIVE_LEVEL   => '0',
               RESET_LEVEL    => '1')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e0a0r1);

   e0a1r0 : pulse_extender
   generic map(EXTEND_COUNT   => 0,
               ACTIVE_LEVEL   => '1',
               RESET_LEVEL    => '0')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e0a1r0);

   e0a1r1 : pulse_extender
   generic map(EXTEND_COUNT   => 0,
               ACTIVE_LEVEL   => '1',
               RESET_LEVEL    => '1')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e0a1r1);

   e1a0r0 : pulse_extender
   generic map(EXTEND_COUNT   => 1,
               ACTIVE_LEVEL   => '0',
               RESET_LEVEL    => '0')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e1a0r0);

   e1a0r1 : pulse_extender
   generic map(EXTEND_COUNT   => 1,
               ACTIVE_LEVEL   => '0',
               RESET_LEVEL    => '1')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e1a0r1);

   e1a1r0 : pulse_extender
   generic map(EXTEND_COUNT   => 1,
               ACTIVE_LEVEL   => '1',
               RESET_LEVEL    => '0')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e1a1r0);

   e1a1r1 : pulse_extender
   generic map(EXTEND_COUNT   => 1,
               ACTIVE_LEVEL   => '1',
               RESET_LEVEL    => '1')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e1a1r1);
   
   e4a0r0 : pulse_extender
   generic map(EXTEND_COUNT   => 4,
               ACTIVE_LEVEL   => '0',
               RESET_LEVEL    => '0')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e4a0r0);

   e4a0r1 : pulse_extender
   generic map(EXTEND_COUNT   => 4,
               ACTIVE_LEVEL   => '0',
               RESET_LEVEL    => '1')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e4a0r1);

   e4a1r0 : pulse_extender
   generic map(EXTEND_COUNT   => 4,
               ACTIVE_LEVEL   => '1',
               RESET_LEVEL    => '0')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e4a1r0);

   e4a1r1 : pulse_extender
   generic map(EXTEND_COUNT   => 4,
               ACTIVE_LEVEL   => '1',
               RESET_LEVEL    => '1')
   port map(   clk            => clk,
               rst            => rst,
               pulse          => stimulus,
               extended_pulse => result_e4a1r1);
   
   
   --Main Process
   main: process
   begin
      --Initializing
      stimulus <= '0';
      rst <= '1';
      wait for 55ns;
      rst <= '0';
      
      --Wait for max (5) clock cycles
      wait for 50ns;
      
      --pulse for 1 clock cycle then wait for 5
      stimulus <= '1';
      wait for 10ns;
      stimulus <= '0';
      wait for 50ns;
      
      --pulse for 2 clock cycles then wait for 5
      stimulus <= '1';
      wait for 20ns;
      stimulus <= '0';
      wait for 50ns;
      
      --pulse for 4 clock cycles then wait for 5
      stimulus <= '1';
      wait for 40ns;
      stimulus <= '0';
      wait for 50ns;
      
      wait;
   end process;

end sim;