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
               clk2           : in  std_logic;
               clk3           : in  std_logic;
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
   --synthesis translate_off
   use work.tb_write_csv_pkg.all;
   --synthesis translate_on

entity filter_bank is
      generic( analysis_low   : coefficient_array;
               analysis_high  : coefficient_array;
               synthesis_low  : coefficient_array;
               synthesis_high : coefficient_array);
      port(    clk0           : in  std_logic;
               clk1           : in  std_logic;
               clk2           : in  std_logic;
               clk3           : in  std_logic;
               rst            : in  std_logic;
               x              : in  sig;
               y              : out sig);
end filter_bank;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture behave of filter_bank is
   constant BANK0_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank0.csv";
   constant BANK1_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank1.csv";
   constant BANK2_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank2.csv";
   constant BANK3_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank3.csv";
   constant BANK4_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank4.csv";
   constant BANK5_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank5.csv";
   constant BANK6_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank6.csv";
   constant BANK7_FILE : string := "X:\Education\Masters Thesis\matlab\filter_bank\bank7.csv";

   -- Numerics NM : N -> stage, M -> bank
   signal down_y00   : sig := (others => '0');
   signal down_y01   : sig := (others => '0');
   signal down_y10   : sig := (others => '0');
   signal down_y11   : sig := (others => '0');
   signal down_y12   : sig := (others => '0');
   signal down_y13   : sig := (others => '0');
   signal down_y20   : sig := (others => '0');
   signal down_y21   : sig := (others => '0');
   signal down_y22   : sig := (others => '0');
   signal down_y23   : sig := (others => '0');
   signal down_y24   : sig := (others => '0');
   signal down_y25   : sig := (others => '0');
   signal down_y26   : sig := (others => '0');
   signal down_y27   : sig := (others => '0');
   
   signal up_y00     : sig := (others => '0');
   signal up_y01     : sig := (others => '0');
   signal up_y10     : sig := (others => '0');
   signal up_y11     : sig := (others => '0');
   signal up_y12     : sig := (others => '0');
   signal up_y13     : sig := (others => '0');
   signal up_y20     : sig := (others => '0');
   signal up_y21     : sig := (others => '0');
   signal up_y22     : sig := (others => '0');
   signal up_y23     : sig := (others => '0');
   signal up_y24     : sig := (others => '0');
   signal up_y25     : sig := (others => '0');
   signal up_y26     : sig := (others => '0');
   signal up_y27     : sig := (others => '0');

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

   -------   Stage 1   Decomposition   ---------------------
   stage1_bank0_decomp : decomposition
      generic map(low_pass    => analysis_low,
                  high_pass   => analysis_high)
      port map(   clk_low     => clk2,
                  clk_high    => clk1,
                  rst         => rst,
                  x           => down_y00,
                  y_low       => down_y10,
                  y_high      => down_y11);

   stage1_bank1_decomp : decomposition
      generic map(low_pass    => analysis_low,
                  high_pass   => analysis_high)
      port map(   clk_low     => clk2,
                  clk_high    => clk1,
                  rst         => rst,
                  x           => down_y01,
                  y_low       => down_y12,
                  y_high      => down_y13);
                  
   -------   Stage 2   Decomposition   ---------------------
   stage2_bank0_decomp : decomposition
      generic map(low_pass    => analysis_low,
                  high_pass   => analysis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x           => down_y10,
                  y_low       => down_y20,
                  y_high      => down_y21);

   stage2_bank1_decomp : decomposition
      generic map(low_pass    => analysis_low,
                  high_pass   => analysis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x           => down_y11,
                  y_low       => down_y22,
                  y_high      => down_y23);

   stage2_bank2_decomp : decomposition
      generic map(low_pass    => analysis_low,
                  high_pass   => analysis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x           => down_y12,
                  y_low       => down_y24,
                  y_high      => down_y25);

   stage2_bank3_decomp : decomposition
      generic map(low_pass    => analysis_low,
                  high_pass   => analysis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x           => down_y13,
                  y_low       => down_y26,
                  y_high      => down_y27);

   -------   Filter Bank Region   --------------------------  
   up_y20 <= down_y20;
   up_y21 <= down_y21;
   up_y22 <= down_y22;
   up_y23 <= down_y23;
   up_y24 <= down_y24;
   up_y25 <= down_y25;
   up_y26 <= down_y26;
   up_y27 <= down_y27;
   
   --synthesis translate_off
   --Output to files for review
   writer20 : tb_write_csv
      generic map(FILENAME => BANK0_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y20));

   writer21 : tb_write_csv
      generic map(FILENAME => BANK1_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y21));

   writer22 : tb_write_csv
      generic map(FILENAME => BANK2_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y22));

   writer23 : tb_write_csv
      generic map(FILENAME => BANK3_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y23));

   writer24 : tb_write_csv
      generic map(FILENAME => BANK4_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y24));

   writer25 : tb_write_csv
      generic map(FILENAME => BANK5_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y25));

   writer26 : tb_write_csv
      generic map(FILENAME => BANK6_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y26));

   writer27 : tb_write_csv
      generic map(FILENAME => BANK7_FILE)
      port map(   clk      => clk3,
                  data     => std_logic_vector(down_y27));
   --synthesis translate_on

   -------   Stage 2   Reconstruction   --------------------
   stage2_bank0_recon : reconstruction
      generic map(low_pass    => synthesis_low,
                  high_pass   => synthesis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x_low       => up_y20,
                  x_high      => up_y21,
                  y           => up_y10);

   stage2_bank1_recon : reconstruction
      generic map(low_pass    => synthesis_low,
                  high_pass   => synthesis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x_low       => up_y22,
                  x_high      => up_y23,
                  y           => up_y11);

   stage2_bank2_recon : reconstruction
      generic map(low_pass    => synthesis_low,
                  high_pass   => synthesis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x_low       => up_y24,
                  x_high      => up_y25,
                  y           => up_y12);
                  
   stage2_bank3_recon : reconstruction
      generic map(low_pass    => synthesis_low,
                  high_pass   => synthesis_high)
      port map(   clk_low     => clk3,
                  clk_high    => clk2,
                  rst         => rst,
                  x_low       => up_y26,
                  x_high      => up_y27,
                  y           => up_y13);

   -------   Stage 1   Reconstruction   --------------------
--   up_y10 <= down_y10;
--   up_y11 <= down_y11;
--   up_y12 <= down_y12;
--   up_y13 <= down_y13;
   
   stage1_bank0_recon : reconstruction
      generic map(low_pass    => synthesis_low,
                  high_pass   => synthesis_high)
      port map(   clk_low     => clk2,
                  clk_high    => clk1,
                  rst         => rst,
                  x_low       => up_y10,
                  x_high      => up_y11,
                  y           => up_y00);

   stage1_bank1_recon : reconstruction
      generic map(low_pass    => synthesis_low,
                  high_pass   => synthesis_high)
      port map(   clk_low     => clk2,
                  clk_high    => clk1,
                  rst         => rst,
                  x_low       => up_y12,
                  x_high      => up_y13,
                  y           => up_y01);
                  
   -------   Stage 0   Reconstruction   --------------------
--   up_y00 <= down_y00;
--   up_y01 <= down_y01;
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
