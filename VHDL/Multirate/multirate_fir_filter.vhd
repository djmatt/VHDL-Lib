----------------------------------------------------------------------------------------------------
--        Multirate FIR Filter
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;

package multirate_fir_filter_pkg is
   --FIR filter component declaration
   component multirate_fir_filter is
      generic( h        : coefficient_array);
      port(    clk_low  : in  std_logic;
               clk_high : in  std_logic;
               rst      : in  std_logic;
               x        : in  sig;
               y        : out sig);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.dsp_pkg.all;
   use work.decimator_pkg.all;
   use work.interpolator_pkg.all;
   use work.fir_filter_pkg.all;

entity multirate_fir_filter is
   generic( h        : coefficient_array);
   port(    clk_low  : in  std_logic;
            clk_high : in  std_logic;
            rst      : in  std_logic;
            x        : in  sig;
            y        : out sig);
end multirate_fir_filter;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of multirate_fir_filter is
   signal decimated  : sig := (others => '0');
   signal filtered   : fir_sig := (others => '0');
begin
   
   --Decimate the signal by 2
   downsampling : decimator
      generic map(h        => LOW_PASS)
      port map(   clk_high => clk_high,
                  clk_low  => clk_low,
                  rst      => rst,
                  sig_high => x,
                  sig_low  => decimated);
   
   --Filter the decimated signal
   filter : fir_filter
      generic map(h    => h)
      port map(   clk  => clk_low,
                  rst  => rst,
                  x    => decimated,
                  y    => filtered);
   
   --Interpolate the filtered signal up by 2
   upsample : interpolator
      generic map(h        => LOW_PASS)
      port map(   clk_high => clk_high,
                  clk_low  => clk_low,
                  rst      => rst,
                  sig_low  => filtered(30 downto 15),
                  sig_high => y);
   
end behave;
