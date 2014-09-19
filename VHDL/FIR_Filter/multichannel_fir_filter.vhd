----------------------------------------------------------------------------------------------------
--        Multi-channel FIR Filter
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;

package multichannel_fir_filter_pkg is
   --FIR filter component declaration
   component multichannel_fir_filter is
      generic( h0                   : coefficient_array;
               h1                   : coefficient_array);
      port(    clk                  : in  std_logic;
               clk_2x               : in  std_logic;
               rst                  : in  std_logic;
               x1                   : in  sig;
               x2                   : in  sig;
               y                    : out fir_sig);
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
   use work.multichannel_fir_tap_pkg.all;
   use work.muxer_pkg.all;
   use work.demuxer_pkg.all;

entity multichannel_fir_filter is
   generic( h0                   : coefficient_array;
            h1                   : coefficient_array);
   port(    clk                  : in  std_logic;
            clk_2x               : in  std_logic;
            rst                  : in  std_logic;
            x1                   : in  sig;
            x2                   : in  sig;
            y1                   : out fir_sig;
            y2                   : out fir_sig);
end multichannel_fir_filter;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of multichannel_fir_filter is
   signal xs            : std_logic_vector(NUM_SIG_BITS-1 downto 0)  := (others => '0');
   signal x_chain       : sig_array(h0'range)                        := (others => (others => '0'));
   signal running_sum   : fir_sig_array(h0'range)                    := (others => (others => '0'));
   signal y1_slv        : std_logic_vector(y1'range)                 := (others => '0');
   signal y2_slv        : std_logic_vector(y2'range)                 := (others => '0');
begin

   --mux input signals into one signal
   mux_sigs : muxer
      port map(clk      => clk,
               clk_2x   => clk_2x,
               rst      => rst,
               sig1     => std_logic_vector(x1),
               sig2     => std_logic_vector(x2),
               sigs     => xs);
   
   filter_loop : for tap in h0'low to h0'high generate
      signal coef : std_logic_vector(coefficient'range) := (others => '0');
   begin
   
      --choose the coefficient
      mux_coefs : muxer
         generic map(INIT_SEL => std_logic_vector( rotate_left(unsigned'("01"), tap) ) )
         port map(   clk      => clk,
                     clk_2x   => clk_2x,
                     rst      => rst,
                     sig1     => std_logic_vector(h0(tap)),
                     sig2     => std_logic_vector(h1(tap)),
                     sigs     => coef);

      head_tap_gen : if tap = h0'low generate
         head_tap : multichannel_fir_tap
         port map(clk      => clk_2x,
                  rst      => rst,
                  coef     => signed(coef),
                  sig_in   => signed(xs),
                  sig_out  => x_chain(tap),
                  sum_in   => (others => '0'),
                  sum_out  => running_sum(tap));
      end generate; --if head tap
      
      tail_taps_gen : if tap /= h0'low generate
         tail_tap : multichannel_fir_tap
         port map(clk      => clk_2x,
                  rst      => rst,
                  coef     => signed(coef),
                  sig_in   => x_chain(tap-1),
                  sig_out  => x_chain(tap),
                  sum_in   => running_sum(tap-1),
                  sum_out  => running_sum(tap));
      end generate; --if tail taps
      
   end generate; --filter loop
   
   --demux running sum to outputs 
   demux_sigs : demuxer
      port map(clk      => clk, 
               clk_2x   => clk_2x, 
               rst      => rst, 
               sigs     => std_logic_vector(running_sum(h0'high)),
               sig1     => y1_slv, 
               sig2     => y2_slv); 
      
   y1 <= signed(y1_slv);
   y2 <= signed(y2_slv);
   
end behave;
