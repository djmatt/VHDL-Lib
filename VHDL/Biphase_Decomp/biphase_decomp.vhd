----------------------------------------------------------------------------------------------------
--        Bi-Phase Decomposition
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package biphase_decomp_pkg is
   component biphase_decomp is
      port( clk   : in  std_logic;
            rst   : in  std_logic;
            x     : in  std_logic_vector;
            x0    : out std_logic_vector;
            x1    : out std_logic_vector);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
entity biphase_decomp is
   port( clk   : in  std_logic;
         rst   : in  std_logic;
         x     : in  std_logic_vector;
         x0    : out std_logic_vector;
         x1    : out std_logic_vector);         
end biphase_decomp;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE (structural)
----------------------------------------------------------------------------------------------------
architecture structural of biphase_decomp is
   signal output_choice : std_logic;
   signal x_reg         : std_logic_vector(x'range);
   signal x0_reg        : std_logic_vector(x'range);
   signal x1_reg        : std_logic_vector(x'range);
begin

   --Latch on to the input
   x_latch : process(clk, rst)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            x_reg <= (others => '0');
         else
            x_reg <= x;   
         end if;   
      end if;
   end process;
   
   --Select output
   --TODO: for larger than biphase implement this part using a circular shift register with a single bit for each output
   tictoc : process(clk, rst)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            output_choice <= '0';
         else
            output_choice <= not output_choice;
         end if;
      end if;
   end process;
   
   --Send data to the current output
   muxing : process(clk, rst)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            x0_reg <= (others => '0');
            x1_reg <= (others => '0');
         else
            if(output_choice = '0') then
               x0_reg <= x_reg;
            else
               x1_reg <= x_reg;
            end if;
         end if;
      end if;
   end process;
   
   --connect registers to output
   x0 <= x0_reg;
   x1 <= x1_reg;
   
end structural;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE (behavioral)
----------------------------------------------------------------------------------------------------
--architecture behave of biphase_decomp is
--begin
--
--end behave;
