--------------------------------------------------------------------------------------------------
--        Pulse Generator
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package pulse_gen_pkg is
   component pulse_gen is
      generic( CLKS_PER_PULSE : positive  := 1);
      port(    clk            : in  std_logic;
               rst            : in  std_logic;
               pulse          : out std_logic);
   end component;
end package;

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.count_gen_pkg.all;

entity pulse_gen is
      generic( CLKS_PER_PULSE : positive  := 1);
      port(    clk            : in  std_logic;
               rst            : in  std_logic;
               pulse          : out std_logic);
end pulse_gen;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture rtl of pulse_gen is
   constant MAX_COUNT         : positive := CLKS_PER_PULSE-1;
   signal   count             : integer;
   signal   end_count         : std_logic;
   signal   rst_clock_counter : std_logic;

begin

   --This counter counts the number of clocks since last pulse
   --This counter resets when the count reaches CLKS_PER_PULSE
   --This counter counts every clock cycle
   clock_counter : count_gen
   port map(   clk         => clk,
               rst         => rst_clock_counter,
               en          => '1',
               count       => count);

   end_count         <= '1' when count = MAX_COUNT else '0';
   rst_clock_counter <= end_count or rst;
   pulse             <= end_count;
end rtl;
