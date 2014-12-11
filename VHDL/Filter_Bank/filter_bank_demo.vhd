--------------------------------------------------------------------------------------------------
--        3-stage Filter Bank
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;

package filter_bank_pkg is
   --FIR filter component declaration
   component filter_bank is
      generic( analysis_low   : coefficient_array;
               analysis_high  : coefficient_array;
               synthesis_low  : coefficient_array;
               synthesis_high : coefficient_array);
      port(    clk0           : in  std_logic;
               clk1           : in  std_logic;
               rst            : in  std_logic;
               x              : in  sig;
               y              : out sig);
   end component;
end package;

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.dsp_pkg.all;
   use work.decomposition_pkg.all;
   use work.reconstruction_pkg.all;

entity filter_bank is
      generic( analysis_low   : coefficient_array;
               analysis_high  : coefficient_array;
               synthesis_low  : coefficient_array;
               synthesis_high : coefficient_array);
      port(    clk0           : in  std_logic;
               clk1           : in  std_logic;
               rst            : in  std_logic;
               x              : in  sig;
               y              : out sig);
end filter_bank;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture behave of filter_bank is
   -- Numerics NM : N -> stage, M -> bank
   signal down_y00   : sig := (others => '0');
   signal down_y01   : sig := (others => '0');
   
   signal up_y00     : sig := (others => '0');
   signal up_y01     : sig := (others => '0');

begin
   -------   Stage 0   Decomposition   ---------------------
   stage0_decomp : decomposition
      generic map(low_pass    => analysis_low,
                  high_pass   => analysis_high)
      port map(   clk_low     => clk1,
                  clk_high    => clk0,
                  rst         => rst,
                  x           => x,
                  y_low       => down_y00,
                  y_high      => down_y01);

   -------   Filter Banks   --------------------------------   
   up_y00 <= down_y00;
   up_y01 <= down_y01;

   -------   Stage 0   Reconstruction   --------------------
   stage0_bank0_recon : reconstruction
      generic map(low_pass    => synthesis_low,
                  high_pass   => synthesis_high)
      port map(   clk_low     => clk1,
                  clk_high    => clk0,
                  rst         => rst,
                  x_low       => up_y00,
                  x_high      => up_y01,
                  y           => y);

end behave;
