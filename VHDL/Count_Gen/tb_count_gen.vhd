--------------------------------------------------------------------------------------------------
--        Count Generator Testbench
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
   use work.count_gen_pkg.all;

entity tb_count_gen is
end tb_count_gen;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture rtl of tb_count_gen is

   signal clk     : std_logic;
   signal rst     : std_logic;
   signal en      : std_logic;
   signal count   : integer;

begin
   --Instantiate clock generator
   clk_gen : tb_clockgen
   generic map(PERIOD      => 10ns,
               DUTY_CYCLE  => 0.50)
   port map(   clk         => clk);

   --Unit under test
   uut : count_gen
   generic map(INIT_VAL    => 17,
               STEP_VAL    => 2)
   port map(   clk         => clk,
               rst         => rst,
               en          => en,
               count       => count);

   --main process
   main : process
   begin
      rst   <= '1';
      en    <= '0';
      wait until falling_edge(clk);
      rst   <= '0';
      wait for 50ns;
      wait until falling_edge(clk);
      en    <= '1';
      wait for 100ns;
      wait until falling_edge(clk);
      en    <= '0';
      wait;
   end process;

end rtl;
