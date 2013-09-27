library ieee;
   use ieee.std_logic_1164.all;

package tb_clockgen_pkg is
   component tb_clockgen is
      generic( PERIOD      : time := 30ns;
               DUTY_CYCLE  : real := 0.50);
      port(    clk         : out  std_logic);
   end component;
end package;


library ieee;
   use ieee.std_logic_1164.all;

--This is a clock generator module for simulations
entity tb_clockgen is
   generic( PERIOD      : time := 30ns;
            DUTY_CYCLE  : real := 0.50);
   port(    clk         : out  std_logic);
end tb_clockgen;

architecture behave of tb_clockgen is
   signal clock   : std_logic;
begin

   clk <= clock;

   process
   begin
      clock <= '0';
      wait for (PERIOD - (PERIOD * DUTY_CYCLE));
      clock <= '1';
      wait for (PERIOD * DUTY_CYCLE);
   end process;
end behave;