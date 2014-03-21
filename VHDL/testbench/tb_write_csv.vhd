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

-- This entity writes the contents of a signal to a csv file.  Only one signal is written to file.
entity tb_write_csv is
   generic( -- The name of the file to write the data to.
            FILENAME : string := "temp.csv");
   port(    -- the clock synchronous with data
            clk      : in  std_logic;
            -- This signal will be written to a file on each rising clock edge
            data     : in  std_logic_vector);
end tb_write_csv;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of tb_write_csv is
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