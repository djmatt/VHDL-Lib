----------------------------------------------------------------------------------------------------
--        Decimator
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
library work;
   use work.dsp_pkg.all;
   
package decimator_pkg is
   component decimator is
      port(    clk_high : in  std_logic;
               clk_low  : in  std_logic;
               rst      : in  std_logic;
               sig_high : in  sig;
               sig_low  : out sig);
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
   use work.demuxer_pkg.all;
   use work.multichannel_fir_filter_pkg.all;

entity decimator is
   port(    clk_high : in  std_logic;
            clk_low  : in  std_logic;
            rst      : in  std_logic;
            sig_high : in  sig;
            sig_low  : out sig);
end decimator;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of decimator is
   constant DEC_1    : coefficient_array := (x"0000",
                                             x"0000",
                                             x"0000",
                                             x"0000",
                                             x"0000",
                                             x"4010",
                                             x"0000",
                                             x"0000",
                                             x"0000",
                                             x"0000",
                                             x"0000");
                                             
   constant DEC_2    : coefficient_array := (x"0000",
                                             x"0070",
                                             x"fe7b",
                                             x"0453",
                                             x"f512",
                                             x"27c2",
                                             x"27c2",
                                             x"f512",
                                             x"0453",
                                             x"fe7b",
                                             x"0070");
      
   signal sig1       :  sig      := (others => '0');
   signal sig2       :  sig      := (others => '0');
   signal filtered1  :  fir_sig  := (others => '0');
   signal filtered2  :  fir_sig  := (others => '0');
   signal sum        :  fir_sig  := (others => '0');
begin
   
   --Demux the signal   
   demux_sig : demuxer
   port map(clk            => clk_low, 
            clk_2x         => clk_high, 
            rst            => rst, 
            sigs           => std_logic_vector(sig_high),
            sig(sig1)      => sig1, 
            sig(sig2)      => sig2); 
   
   --Low pass the demuxed signals using the multichannel approach
   anti_alias : multichannel_fir_filter
      generic map(h0       => DEC_1,
                  h1       => DEC_2)
      port map(   clk      => clk_low,
                  clk_2x   => clk_high,
                  rst      => rst,
                  x1       => sig1,
                  x2       => sig2,
                  y1       => filtered1,
                  y2       => filtered2);
   
   --Sum the 2 filtered signals together
   update_sum : process(clk_low)
   begin
      if(rising_edge(clk_low)) then
         if(rst = '1') then
            sum <= (others => '0');
         else 
            sum <= filtered1 + filtered2;
         end if;
      end if;
   end process;
   
   sig_low <= sum(30 downto 15);

end behave;
