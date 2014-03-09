----------------------------------------------------------------------------------------------------
--        CSV file writer for testbenches
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package tb_write_csv_pkg is
   component tb_write_csv is
      generic( FILENAME : string := "temp.csv");
      port(    clk      : in  std_logic;
               data     : in  std_logic_vector);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library std;
   use std.textio.all;

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_textio.all;

-- TODO
entity tb_write_csv is
   generic( -- TODO
            FILENAME : string := "temp.csv");
   port(    -- TODO
            clk      : in  std_logic;
            -- TODO
            data     : in  std_logic_vector);
end tb_write_csv;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of tb_write_csv is
   -- TODO
   file output: text is out FILENAME;
begin

   writer : process 
      variable L: line; 
   begin
      wait until rising_edge(clk);
      write(L, string'("0x"));
      hwrite(L, data);
      writeline(output, L);
   end process;

end behave;