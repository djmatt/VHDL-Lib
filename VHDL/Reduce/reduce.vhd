----------------------------------------------------------------------------------------------------
--        Reduce
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com
-- Copyright 2013

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package reduce_pkg is
   component reduce is
      generic( gate  :     string);
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.reduce_pkg.all;

entity reduce is
   generic( gate  :     string);
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture recursiveTree of reduce is                                         
   constant dlength  : positive := data'length;                                     
begin
   base_case : if(dlength = 1) generate
      result <= data(data'low);
   end generate;

   recurse_case : if(dlength > 1) generate                              
      constant halflen     : positive := dlength/2;                                 
      signal   lower_half  : std_logic_vector(1 to halflen);               
      signal   upper_half  : std_logic_vector(1 to dlength - halflen);  
      signal   lower_result: std_logic;                                                            
      signal   upper_result: std_logic;
   begin

      --Separate the input vector into lower and upper halves
      lower_copy: for tap in lower_half'range generate
         lower_half(tap)  <= data(tap-1+data'low);
      end generate;

      upper_copy: for tap in upper_half'range generate
         upper_half(tap) <= data(tap-1+data'low+halflen);
      end generate;

      --Reduce the lower and upper halves recursively
      reduce_lower : entity work.reduce
         generic map(gate  => gate)
         port map(   data  => lower_half,
                     result=> lower_result);
      
      reduce_higher : entity work.reduce
         generic map(gate  => gate)
         port map(   data  => upper_half,
                     result=> upper_result);
                  
      --Reduce the results of the lower and upper halves
      reduce_and : if(gate = "and") generate
         result <= lower_result and upper_result;
      end generate;

      reduce_or  : if(gate = "or") generate
         result <= lower_result or upper_result;
      end generate;

      reduce_xor : if(gate = "xor") generate
         result <= lower_result xor upper_result;
      end generate;

   end generate;
end recursiveTree;