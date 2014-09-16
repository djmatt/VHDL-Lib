----------------------------------------------------------------------------------------------------
--        demuxer
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;

package demuxer_pkg is
   --demuxer componenet declaration
   component demuxer is
      port(    clk                  : in  std_logic;
               clk_2x               : in  std_logic;
               rst                  : in  std_logic;
               sigs                 : in  std_logic_vector;
               sig_1                : out std_logic_vector;
               sig_2                : out std_logic_vector);   
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
--This entity takes 2 input signals and interlaces them into 1 output signal.  During development 
--it was determined that the clock inputs must be phase aligned for best results
entity demuxer is
   port(    clk                  : in  std_logic;
            clk_2x               : in  std_logic;
            rst                  : in  std_logic;
            sigs                 : in  std_logic_vector;
            sig_1                : out std_logic_vector;
            sig_2                : out std_logic_vector);
end demuxer;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of demuxer is
   signal sigs_reg  : std_logic_vector(sig_1'range) := (others => '0');
   
   constant INIT_SEL : std_logic_vector(1 downto 0) := b"01";
   signal selector   : std_logic_vector(1 downto 0) := INIT_SEL;
   signal sel1       : std_logic_vector(sig_1'range) := (others => '0');
   signal sel2       : std_logic_vector(sig_2'range) := (others => '0');
   signal selx       : std_logic_vector(sig_1'range) := (others => '0');

begin
   
   --Register the input
   reg_in : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            sigs_reg <= (others => '0');
         else
            sigs_reg <= sigs;
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
            selector <= std_logic_vector(signed(selector) rol 1);
         end if;
      end if;
   end process;
   
   --Register the selection
   reg_sel : process(clk_2x)
   begin
      if(rising_edge(clk_2x)) then
         if(rst = '1') then
            sel1 <= (others => '0');
            sel2 <= (others => '0');
         else
            case selector is
               when b"01" => sel1 <= sigs;
               when b"10" => sel2 <= sigs;
               when others => selx <= sigs;
            end case;
         end if;
      end if;
   end process;
   
   --Register the output 
   reg_out : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            sig_1 <= (others => '0');
            sig_2 <= (others => '0');
         else
            sig_1 <= sel1;
            sig_2 <= sel2;
         end if;
      end if;
   end process;   
   
end behave;
