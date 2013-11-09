----------------------------------------------------------------------------------------------------
--        Data Descrambler
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com
-- Copyright 2013

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package descrambler_pkg is
   component descrambler is
      port(    clk                  : in  std_logic;
               rst                  : in  std_logic;
               poly_mask            : in  std_logic_vector;
               seed                 : in  std_logic_vector;
               scrambled_datain     : in  std_logic_vector;
               unscrambled_dataout  : out std_logic_vector);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.lfsr_pkg.all;

--This entity uses an LFSR to descramble the data. When using a scrambler, ensure the same
--polynomial is used.
entity descrambler is
   port(    --Process clock.  Every clock cycle unscrambled data in is processed through the
            --scrambler producing scrambled data out.
            clk                  : in  std_logic;
            --Ansychronous reset. While high: resets the LFSR to the seed value and sets the
            --poly_mask used for the feedback polynomial
            rst                  : in  std_logic;
            --Place '1's in the bits where the polynomial calls for taps.  Read up on LFSR's before
            --selecting a polynomial, not all choices will yield "good" random numbers.
            --(e.g. X^5 + X^3 + 1 would be poly_mask(4 downto 0) <= "10100";)
            poly_mask            : in  std_logic_vector;
            --Must be identical in length to poly_mask. Initial value of the shift register.  Is
            --only set during rst = '1'.  DO NOT SET TO ALL '0's
            seed                 : in  std_logic_vector;
            --Scrambled data
            scrambled_datain     : in  std_logic_vector;
            --Unscrambled data
            unscrambled_dataout  : out std_logic_vector);
end descrambler;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of descrambler is
   signal feedback_to_lfsr       : std_logic_vector(scrambled_datain'range);
   signal feedback_from_lfsr     : std_logic_vector(scrambled_datain'range);
begin
   --Use this lfsr to generate random patterns to descramble the data with
   descrambling_lfsr : lfsr
      port map(   clk         => clk,
                  rst         => rst,
                  poly_mask   => poly_mask,
                  seed        => seed,
                  feedin      => feedback_to_lfsr,
                  feedout     => feedback_from_lfsr);

   --Feedback to the LFSR is the scrambled data.
   feedback_to_lfsr <= scrambled_datain;

   --Descramble the data by xor'ing the data with feedback from the LFSR
   unscrambled_dataout <= feedback_from_lfsr xor scrambled_datain;
end behave;
