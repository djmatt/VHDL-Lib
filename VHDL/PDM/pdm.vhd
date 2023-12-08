--------------------------------------------------------------------------------------------------
--        Pulse Density Modulation
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

package pdm_pkg is
   component pdm is
      port(    clk               : in  std_logic;
               rst               : in  std_logic;
               data              : in  signed;
               pdm_pulses        : out std_logic);
   end component;
end package;

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;

entity pdm is
   port(    clk               : in  std_logic;
            rst               : in  std_logic;
            data              : in  signed;
            pdm_pulses        : out std_logic);
end pdm;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture rtl of pdm is
   --useful constants
   constant NEG_ONE           : signed := to_signed((0 - 2**(data'length-1)), data'length);
   constant POS_ONE           : signed := not(NEG_ONE);

   --Internal signals
   signal sample_reg          : signed(data'range) := (others => '0');
   signal error               : signed(data'high+1 downto data'low);
   signal cumError            : signed(error'high+1 downto data'low);
   signal cumError_reg        : signed(data'range) := (others => '0');
   signal pdm_pulse           : std_logic;
   signal pdm_pulse_reg       : std_logic          := '0';
   signal pdm_signed          : signed(data'range);

begin

   --Register the input data
   reg_data_proc : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            sample_reg  <= (others => '0');
         else
            sample_reg  <= data;
         end if;
      end if;--rising_edge(clk)
   end process reg_data_proc;

   --Generate a '+1' when the input data is above the cumulative error
   --Generate a '-1' when the input data is below the cumulative error
   comparator_proc : process(clk)
   begin
      if(sample_reg >= cumError_reg) then
         pdm_pulse <= '1';
         pdm_signed <= POS_ONE;
      else
         pdm_pulse <= '0';
         pdm_signed <= NEG_ONE;
      end if;
   end process comparator_proc;

   --The error is difference of the input value from the generated output.
   error    <= resize(pdm_signed,error'length) - resize(sample_reg,error'length);
   --Accumulate the error into the cumulative error. The cumulative error should always be
   --between POS_ONE and NEG_ONE values.  (restriction applies only on register clock edge)
   cumError <= resize(error, cumError'length) + resize(cumError_reg, cumError'length);

   --register the cumulative error for the next clock cycle
   reg_error_proc : process(clk)
   begin
      if(rising_edge(clk)) then

         -- synthesis translate_off
         assert ( (cumError >= resize(NEG_ONE, cumError'length))
              and (cumError <= resize(POS_ONE, cumError'length)) )
            report "pdm.vhd: Cumulative Error overflowed (should never happen)"
            severity failure;
         -- synthesis translate_on

         if(rst = '1') then
            cumError_reg <= (others => '0');
         else
            cumError_reg <= resize(cumError, cumError_reg'length);
         end if;
      end if;
   end process reg_error_proc;

   --register the pdm pulses prior to output
   reg_pulse_proc : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            pdm_pulse_reg <= '0';
         else
            pdm_pulse_reg <= pdm_pulse;
         end if;
      end if;
   end process reg_pulse_proc;

   --output the pdm pulses
   pdm_pulses <= pdm_pulse_reg;
end rtl;
