--------------------------------------------------------------------------------------------------
--        Count Generator
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
package count_gen_pkg is
   component count_gen is
      generic( VECTOR_LEN  : positive  := 32;
               INIT_VAL    : integer   := 0);
      port(    clk         : in  std_logic;
               rst         : in  std_logic;
               en          : in  std_logic;
               count       : out std_logic_vector(VECTOR_LEN-1 downto 0));
   end component;
end package;

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

entity count_gen is
   generic( VECTOR_LEN  : positive  := 32;
            INIT_VAL    : integer   := 0);
   port(    clk         : in  std_logic;
            rst         : in  std_logic;
            en          : in  std_logic;
            count       : out std_logic_vector(VECTOR_LEN-1 downto 0));
end count_gen;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture rtl of count_gen is

   signal count_reg  : integer   := INIT_VAL;

begin

   -- increment the count value when enabled.
   counter : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            count_reg   <= INIT_VAL;
         elsif(en = '1') then
            count_reg   <= count_reg + 1;
         end if;
      end if;
   end process;
   
   count <= std_logic_vector(to_unsigned(count_reg, VECTOR_LEN));
   
end rtl;
