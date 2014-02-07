----------------------------------------------------------------------------------------------------
--        Reduce
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package reduce_pkg is
   component reduce_and is
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;

   component reduce_or is
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;

   component reduce_xor is
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
   
   component reduce_nand is
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;

   component reduce_nor is
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;

   component reduce_nxor is
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

--Reduce module
--This module takes a bit vector and reduces it to a single value using a single gate type.  This 
--module can take any sized input vector to reduce to a single-bit output value.  This module was 
--implemented to optimize for latency.  Only the and/or/xor gates are supported.  This module
--provides the foundation for all the reduce operations presented in the reduce package.
entity reduce is
   
   generic( gate  :     string);
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce;
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.reduce_pkg.all;

--Reduce-and takes an input vector of any length and returns a value based on and'ing all the bits 
--together. An and gate returns a 1 when both inputs are 1, similarly a reduce-and gate will return
--a 1 when all inputs are 1, 0 otherwise.
entity reduce_and is 
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce_and;
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.reduce_pkg.all;

--Reduce-or takes an input vector of any length and returns a value based on or'ing all the bits 
--together. An or gate returns a 0 when neither input is 1, similarly a reduce-or gate will return
--a 0 when none of the inputs are 1, 1 otherwise.
entity reduce_or is 
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce_or;
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.reduce_pkg.all;

--Reduce-xor takes an input vector of any length and returns a value based on xor'ing all the bits 
--together. This particular reductions is useful when you want to know when a bit-vector has an
--even or odd number of 1's in the vector.  This reduce operation returns a 1 when there are an odd
--number of 1's in the vector, 0 otherwise.
entity reduce_xor is 
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce_xor;
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.reduce_pkg.all;

--Reduce-nand takes an input vector of any length and returns a value based on and'ing all the bits 
--together. An nand gate returns a 1 when both inputs are 0, similarly a reduce-nand gate will 
--return a 1 when all inputs are 0, 1 otherwise.
entity reduce_nand is 
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce_nand;
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.reduce_pkg.all;

--Reduce-nor takes an input vector of any length and returns a value based on nor'ing all the bits 
--together. An nor gate returns a 1 when neither input is 0, similarly a reduce-or gate will return
--a 1 when none of the inputs are 1, 1 otherwise.
entity reduce_nor is 
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce_nor;
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.reduce_pkg.all;

--Reduce-nxor is technically not a legitimate reduction operation.  This is because the nxor is not
--an operation that satisfies the associative property.  Therefore this operation is the invert of 
--result of the reduce-xor operation.  This reduce operation returns a 1 when there are an even
--number of 1's in the vector, 0 otherwise.
entity reduce_nxor is 
   port(    data  : in  std_logic_vector;
            result: out std_logic);
end reduce_nxor;

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
----------------------------------------------------------------------------------------------------
architecture implement of reduce_and is
   component reduce is
      generic( gate  :     string);
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
begin
   reduce_imp  : reduce
      generic map(gate  => "and")
      port map(   data  => data,
                  result=> result);
end implement;
----------------------------------------------------------------------------------------------------
architecture implement of reduce_or is
   component reduce is
      generic( gate  :     string);
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
begin
   reduce_imp  : reduce
      generic map(gate  => "or")
      port map(   data  => data,
                  result=> result);
end implement;
----------------------------------------------------------------------------------------------------
architecture implement of reduce_xor is
   component reduce is
      generic( gate  :     string);
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
begin
   reduce_imp  : reduce
      generic map(gate  => "xor")
      port map(   data  => data,
                  result=> result);
end implement;
----------------------------------------------------------------------------------------------------
architecture implement of reduce_nand is
   signal inverted   : std_logic;

   component reduce is
      generic( gate  :     string);
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
begin
   reduce_imp  : reduce
      generic map(gate  => "or")
      port map(   data  => data,
                  result=> inverted);
                  
   result   <= not inverted;
end implement;
----------------------------------------------------------------------------------------------------
architecture implement of reduce_nor is
   signal inverted   : std_logic;

   component reduce is
      generic( gate  :     string);
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
begin
   reduce_imp  : reduce
      generic map(gate  => "and")
      port map(   data  => data,
                  result=> inverted);

   result   <= not inverted;
end implement;
----------------------------------------------------------------------------------------------------
architecture implement of reduce_nxor is
   signal inverted   : std_logic;
   component reduce is
      generic( gate  :     string);
      port(    data  : in  std_logic_vector;
               result: out std_logic);
   end component;
begin
   reduce_imp  : reduce
      generic map(gate  => "xor")
      port map(   data  => data,
                  result=> inverted);
    
   result   <= not inverted;
end implement;
