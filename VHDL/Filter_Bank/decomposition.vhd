----------------------------------------------------------------------------------------------------
--        Signal Decomposition
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;

package decomposition_pkg is
   --FIR filter component declaration
   component decomposition is
      generic( low_pass    : coefficient_array;
               high_pass   : coefficient_array);
      port(    clk_low     : in  std_logic;
               clk_high    : in  std_logic;
               rst         : in  std_logic;
               x           : in  sig;
               y_low       : out sig;
               y_high      : out sig);
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

entity decomposition is
   generic( low_pass    : coefficient_array;
            high_pass   : coefficient_array);
   port(    clk_low     : in  std_logic;
            clk_high    : in  std_logic;
            rst         : in  std_logic;
            x           : in  sig;
            y_low       : out sig;
            y_high      : out sig);
end decomposition;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of decomposition is
begin
   
   --Decimate the signal using a low pass filter
   low_filter_bank : decimator
      generic map(h        => low_pass)
      port map(   clk_high => clk_high,
                  clk_low  => clk_low,
                  rst      => rst,
                  sig_high => x,
                  sig_low  => y_low);
   
   --Decimate the signal using a high pass filter
   high_filter_bank : decimator
      generic map(h        => high_pass)
      port map(   clk_high => clk_high,
                  clk_low  => clk_low,
                  rst      => rst,
                  sig_high => x,
                  sig_low  => y_high);

   
end behave;
