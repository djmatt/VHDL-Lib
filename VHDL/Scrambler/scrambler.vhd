----------------------------------------------------------------------------------------------------
--        Data Scrambler
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com
-- Copyright 2013

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package scrambler_pkg is
   component scrambler is
      port(    clk                  : in  std_logic;
               rst                  : in  std_logic;
               poly_mask            : in  std_logic_vector;
               seed                 : in  std_logic_vector;
               unscrambled_datain   : in  std_logic_vector;
               scrambled_dataout    : out std_logic_vector);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.lfsr_pkg.all;

--This entity uses an LFSR to scramble the data. When using a descrambler, ensure the same
--polynomial is used.
entity scrambler is
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
            --Data to be scrambled
            unscrambled_datain   : in  std_logic_vector;
            --Scrambled data
            scrambled_dataout    : out std_logic_vector);
end scrambler;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of scrambler is
   signal feedback_to_lfsr       : std_logic_vector(unscrambled_datain'range);
   signal feedback_from_lfsr     : std_logic_vector(unscrambled_datain'range);
begin
   --Use this lfsr to generate random patterns to scramble the data with
   scrambling_lfsr : lfsr
      port map(   clk         => clk,
                  rst         => rst,
                  poly_mask   => poly_mask,
                  seed        => seed,
                  feedin      => feedback_to_lfsr,
                  feedout     => feedback_from_lfsr);

   --Scramble the data by xor'ing the data with feedback from the LFSR
   feedback_to_lfsr <= feedback_from_lfsr xor unscrambled_datain;

   --Feedback to the LFSR is the scrambled data.
   scrambled_dataout <= feedback_to_lfsr;
end behave;
