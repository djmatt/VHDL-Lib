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

library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.lfsr_pkg.all;

--This entity uses an LFSR to descramble the data. When using a scrambler, ensure the same polynomial is used.
entity descrambler is
   port(    clk                  : in  std_logic;
            rst                  : in  std_logic;
            poly_mask            : in  std_logic_vector;
            seed                 : in  std_logic_vector;
            scrambled_datain     : in  std_logic_vector;
            unscrambled_dataout  : out std_logic_vector);
end descrambler;

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
