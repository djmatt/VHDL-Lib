----------------------------------------------------------------------------------------------------
--        Scrambler/Descramber Testbench
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
   use work.scrambler_pkg.all;
   use work.descrambler_pkg.all;

--This module is a testbench for simulating the LFSR
entity tb_lfsr is
end tb_lfsr;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_lfsr is
   signal rst : std_logic;
   signal clk : std_logic;
   signal count_data       : std_logic_vector(15 downto 0);
   signal scrambled_data   : std_logic_vector(15 downto 0);
   signal unscrambled_data : std_logic_vector(15 downto 0);

   constant polynomial     : std_logic_vector(14 downto 0) := "110000000000000";
   constant seed1          : std_logic_vector(14 downto 0) := "010101010101010";
   constant seed2          : std_logic_vector(14 downto 0) := "101010101010101";
begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 30ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk);

   --count_process
   counter: process(clk, rst)
      variable counter : unsigned (15 downto 0) := (others => '0');
   begin
      if(rst = '1') then
         counter := (others => '0');
      else
         if(rising_edge(clk)) then
            counter := counter + 1;
         end if;
      end if;
      count_data <= std_logic_vector(counter);
   end process;

   --UUT
   count_scrambler : scrambler
      port map(   clk                  => clk,
                  rst                  => rst,
                  poly_mask            => polynomial,
                  seed                 => seed1,
                  unscrambled_datain   => count_data,
                  scrambled_dataout    => scrambled_data);

   count_descrambler : descrambler
      port map(   clk                  => clk,
                  rst                  => rst,
                  poly_mask            => polynomial,
                  seed                 => seed2,
                  scrambled_datain     => scrambled_data,
                  unscrambled_dataout  => unscrambled_data);

   --Main Process
   main: process
   begin
      rst <= '1';
      wait for 50ns;
      rst <= '0';
      wait;
   end process;

end sim;
