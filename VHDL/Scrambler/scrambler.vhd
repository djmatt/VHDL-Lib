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

library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.lfsr_pkg.all;

--This entity uses an LFSR to scramble the data. When using a descrambler, ensure the same polynomial is used.
entity scrambler is
   port(    clk                  : in  std_logic;
            rst                  : in  std_logic;
            poly_mask            : in  std_logic_vector;
            seed                 : in  std_logic_vector;
            unscrambled_datain   : in  std_logic_vector;
            scrambled_dataout    : out std_logic_vector);
end scrambler;

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
