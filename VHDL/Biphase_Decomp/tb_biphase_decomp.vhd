----------------------------------------------------------------------------------------------------
--        Bi-Phase Decomposition Testbench
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
   use work.biphase_decomp_pkg.all;
   
--This module is a test-bench for simulating the bi-phase decomposition module
entity tb_biphase_decomp is
end tb_biphase_decomp;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_biphase_decomp is
   signal rst              : std_logic;
   signal clk              : std_logic;
   signal count_data       : std_logic_vector(15 downto 0);
   signal x0               : std_logic_vector(15 downto 0);
   signal x1               : std_logic_vector(15 downto 0);

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
   uut : biphase_decomp
   port map(   clk   => clk,
               rst   => rst,
               x     => count_data,
               x0    => x0,
               x1    => x1);        

   --Main Process
   main: process
   begin
      rst <= '1';
      wait for 50ns;
      rst <= '0';
      wait;
   end process;

end sim;
