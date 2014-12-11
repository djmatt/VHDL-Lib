--------------------------------------------------------------------------------------------------
--        file reader for testbenches
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package tb_read_csv_pkg is
   component tb_read_csv is
      generic( FILENAME : string := "temp.csv");
      port(    clk      : in  std_logic;
               data     : out std_logic_vector);
   end component;
end package;

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library std;
   use std.textio.all;

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_textio.all;

-- This entity reads the contents of a csv file to output a signal.  Only one signal per file.
entity tb_read_csv is
   generic( -- The name of the file to write the data to.
            FILENAME : string := "temp.csv");
   port(    -- the clock synchronous with data
            clk      : in  std_logic;
            -- This signal will be written to a file on each rising clock edge
            data     : out std_logic_vector);
            -- TODO: Add a end-of-file flag.
end tb_read_csv;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture behave of tb_read_csv is
   file input: text open read_mode is FILENAME;
begin

   writer : process 
      variable L: line; 
      variable d: std_logic_vector(data'range) := (others => '0');
   begin
      wait until rising_edge(clk);
      readline(input, L);
      hread(L, d);
      data <= d;
   end process;

end behave;