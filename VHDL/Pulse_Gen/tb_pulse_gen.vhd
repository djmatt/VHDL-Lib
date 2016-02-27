--------------------------------------------------------------------------------------------------
--        Pulse Generator Testbench
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
   use work.pulse_gen_pkg.all;

entity tb_pulse_gen is
end tb_pulse_gen;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture rtl of tb_pulse_gen is

   signal clk     : std_logic;
   signal rst     : std_logic;
   signal pulse   : std_logic;

begin
   --Instantiate clock generator
   clk_gen : tb_clockgen
   generic map(PERIOD      => 10ns,
               DUTY_CYCLE  => 0.50)
   port map(   clk         => clk);   
   
   --Unit under test
   uut : pulse_gen
   generic map(CLKS_PER_PULSE => 20)
   port map(   clk            => clk,
               rst            => rst,
               pulse          => pulse);

   --main process
   main : process
   begin
      rst   <= '1';
      wait until rising_edge(clk);
      wait until falling_edge(clk);
      rst   <= '0';
      wait;
   end process;

end rtl;
