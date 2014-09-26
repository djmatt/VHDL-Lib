----------------------------------------------------------------------------------------------------
--        Interpolator
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;
   
package interpolator_pkg is
   component interpolator is
      generic( h        : coefficient_array);
      port(    clk_high : in  std_logic;
               clk_low  : in  std_logic;
               rst      : in  std_logic;
               sig_low  : in  sig;
               sig_high : out sig);
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
   use work.muxer_pkg.all;
   use work.multichannel_fir_filter_pkg.all;

entity interpolator is
   generic( h        : coefficient_array);
   port(    clk_high : in  std_logic;
            clk_low  : in  std_logic;
            rst      : in  std_logic;
            sig_low  : in  sig;
            sig_high : out sig);
end interpolator;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of interpolator is
   constant H0       : coefficient_array(1 to (h'length+1)/2) := slice_coefficient_array(h, 2, 1);
   constant H1       : coefficient_array(1 to (h'length+1)/2) := slice_coefficient_array(h, 2, 2);
      
   signal filtered1  :  fir_sig;
   signal filtered2  :  fir_sig;
   signal combined   :  fir_sig;
begin
   
   --Low pass the input signal using the multichannel approach
   low_pass : multichannel_fir_filter
      generic map(h0       => H0,
                  h1       => H1)
      port map(   clk      => clk_low,
                  clk_2x   => clk_high,
                  rst      => rst,
                  x1       => sig_low,
                  x2       => sig_low,
                  y1       => filtered1,
                  y2       => filtered2);
    
   --Mux the poly-phase filter results into one signal  
   --NOTE: If this design were to ever support interpolation factor > 2, the mux would need to select the input signals in descending order         
   mux_sigs : muxer
   generic map(INIT_SEL    => b"01")
   port map(clk            => clk_low,
            clk_2x         => clk_high,
            rst            => rst,
            sig1           => std_logic_vector(filtered1),
            sig2           => std_logic_vector(filtered2),
            fir_sig(sigs)  => combined);
   
   sig_high <= combined(29 downto 14);

end behave;
