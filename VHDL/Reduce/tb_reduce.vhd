----------------------------------------------------------------------------------------------------
--        Reduce Test-bench
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
   use work.reduce_pkg.all;

--This module is a test-bench for simulating the reduce operation
entity tb_reduce is
end tb_reduce;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture sim of tb_reduce is
   signal rst           : std_logic;
   signal clk           : std_logic;
   signal count_data    : std_logic_vector(2 downto 0);
   signal result_and    : std_logic;
   signal result_or     : std_logic;
   signal result_xor    : std_logic;
   signal result_nand   : std_logic;
   signal result_nor    : std_logic;
   signal result_xnor   : std_logic;

begin

   --Instantiate clock generator
   clk1 : tb_clockgen
      generic map(PERIOD      => 30ns,
                  DUTY_CYCLE  => 0.50)
      port map(   clk         => clk);

   --count_process
   counter: process(clk, rst)
      variable counter : unsigned(count_data'range) := (others => '0');
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
   reduce_and_test : reduce_and
      port map(data     => count_data,
               result   => result_and);
   reduce_or_test  : reduce_or
      port map(data     => count_data,
               result   => result_or);
   reduce_xor_test : reduce_xor
      port map(data     => count_data,
               result   => result_xor);
   reduce_nand_test : reduce_nand
      port map(data     => count_data,
               result   => result_nand);
   reduce_nor_test  : reduce_nor
      port map(data     => count_data,
               result   => result_nor);
   reduce_xnor_test : reduce_xnor
      port map(data     => count_data,
               result   => result_xnor);
                  
   --Main Process
   main: process
   begin
      rst <= '1';
      wait for 50ns;
      rst <= '0';
      wait;
   end process;

end sim;
