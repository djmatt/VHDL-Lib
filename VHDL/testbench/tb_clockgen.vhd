----------------------------------------------------------------------------------------------------
--        Clock generator for testbenches
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com
-- Copyright 2013

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package tb_clockgen_pkg is
   component tb_clockgen is
      generic( PERIOD      : time := 30ns;
               DUTY_CYCLE  : real := 0.50);
      port(    clk         : out  std_logic);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

-- Clock generator for testbenches/simulations.  Do not use for synthesis designs.
entity tb_clockgen is
   generic( --Duration of one clock cycle in seconds.  Cycle starts at low logic.
            PERIOD      : time := 30ns;
            --Percentage of the cycle spent at high logic.  Valid Values between 0 and 1.
            DUTY_CYCLE  : real := 0.50);
   port(    --The generated clock signal
            clk         : out  std_logic);
end tb_clockgen;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of tb_clockgen is
   signal clock   : std_logic;
begin

   clk <= clock;

   tictoc: process
   begin
      clock <= '0';
      wait for (PERIOD - (PERIOD * DUTY_CYCLE));
      clock <= '1';
      wait for (PERIOD * DUTY_CYCLE);
   end process;
end behave;