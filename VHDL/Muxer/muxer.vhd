----------------------------------------------------------------------------------------------------
--        muxer
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;

package muxer_pkg is
   --muxer componenet declaration
   component muxer is
      generic( INIT_SEL : std_logic_vector(1 downto 0)   := b"10");
      port(    clk      : in  std_logic;
               clk_2x   : in  std_logic;
               rst      : in  std_logic;
               sig1     : in  std_logic_vector;
               sig2     : in  std_logic_vector;
               sigs     : out std_logic_vector);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
--This entity takes 2 input signals and interlaces them into 1 output signal.    During development 
--it was determined that the clock inputs must be phase aligned for best results
entity muxer is
   generic( INIT_SEL : std_logic_vector(1 downto 0)   := b"10");
   port(    clk      : in  std_logic;
            clk_2x   : in  std_logic;
            rst      : in  std_logic;
            sig1     : in  std_logic_vector;
            sig2     : in  std_logic_vector;
            sigs     : out std_logic_vector);
end muxer;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of muxer is
   signal sig1_reg   : std_logic_vector(sig1'range)   := (others => '0');
   signal sig2_reg   : std_logic_vector(sig2'range)   := (others => '0');
   signal selector   : std_logic_vector(1 downto 0)   := INIT_SEL;
   signal sigs_reg   : std_logic_vector(sigs'range)   := (others => '0');

begin
   
   --Register the inputs
   reg_in : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            sig1_reg <= (others => '0');
            sig2_reg <= (others => '0');  
         else
            sig1_reg <= sig1;
            sig2_reg <= sig2;  
         end if;
      end if;
   end process;
   
   --Selection
   update_selection : process(clk_2x)
   begin
      if(rising_edge(clk_2x)) then
         if(rst = '1') then
            selector <= INIT_SEL;
         else
            selector <= std_logic_vector(rotate_left(unsigned(selector), 1));
         end if;
      end if;
   end process;
   
   --Register the output
   reg_out : process(clk_2x)
   begin
      if(rising_edge(clk_2x)) then
         if(rst = '1') then
            sigs_reg <= (others => '0');
         else
            case selector is
               when b"01" => sigs_reg <= sig1;
               when b"10" => sigs_reg <= sig2;
               when others => sigs_reg <= (others => '-');
            end case;
         end if;
      end if;
   end process;
   sigs <= sigs_reg;
   
end behave;
