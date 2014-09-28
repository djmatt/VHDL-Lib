----------------------------------------------------------------------------------------------------
--        Signal Reconstruction
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;

package reconstruction_pkg is
   --FIR filter component declaration
   component reconstruction is
      generic( low_pass    : coefficient_array;
               high_pass   : coefficient_array);
      port(    clk_low     : in  std_logic;
               clk_high    : in  std_logic;
               rst         : in  std_logic;
               x_low       : in  sig;
               x_high      : in  sig;
               y           : out sig);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.dsp_pkg.all;
   use work.interpolator_pkg.all;

entity reconstruction is
   generic( low_pass    : coefficient_array;
            high_pass   : coefficient_array);
   port(    clk_low     : in  std_logic;
            clk_high    : in  std_logic;
            rst         : in  std_logic;
            x_low       : in  sig;
            x_high      : in  sig;
            y           : out sig);
end reconstruction;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of reconstruction is
   signal y_low   : sig := (others => '0');
   signal y_high  : sig := (others => '0');
begin
   
   --Decimate the signal using a low pass filter
   low_filter_bank : interpolator
      generic map(h        => low_pass)
      port map(   clk_high => clk_high,
                  clk_low  => clk_low,
                  rst      => rst,
                  sig_low  => x_low,
                  sig_high => y_low);
   
   --Decimate the signal using a high pass filter
   high_filter_bank : interpolator
      generic map(h        => high_pass)
      port map(   clk_high => clk_high,
                  clk_low  => clk_low,
                  rst      => rst,
                  sig_low  => x_high,
                  sig_high => y_high);
   
   --Sum the 2 banks together
   update_sum : process(clk_high)
   begin
      if(rising_edge(clk_high)) then
         if(rst = '1') then
            y <= (others => '0');
         else 
            y <= signed(y_low) + signed(y_high);
         end if;
      end if;
   end process;
   
end behave;
