----------------------------------------------------------------------------------------------------
--        Pulse Extender
----------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

----------------------------------------------------------------------------------------------------
--        PACKAGE
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

package pulse_extender_pkg is
   component pulse_extender is
      generic( EXTEND_COUNT         : natural      := 0;
               ACTIVE_LEVEL         : std_logic    := '1';
               RESET_LEVEL          : std_logic    := '0');
      port(    clk                  : in  std_logic;
               rst                  : in  std_logic;
               pulse                : in  std_logic;
               extended_pulse       : out std_logic);
   end component;
end package;

----------------------------------------------------------------------------------------------------
--        ENTITY
----------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

library work;
   use work.reduce_pkg.all;

--This entity takes an input pulse and extends its active state for the specified durations.
entity pulse_extender is
   generic( --The number of clock cycles to keep the pulse in the active state
            EXTEND_COUNT         : natural      := 0;
            --The active level of the pulse, use '1' for active high and '0' for active low
            ACTIVE_LEVEL         : std_logic    := '1';
            --The active level of the pulse during the modules reset.  Useful for initialization 
            --reset sequences
            RESET_LEVEL          : std_logic    := '0');
   port(    --The clock driving the module
            clk                  : in  std_logic;
            --Active High. Resets the module
            rst                  : in  std_logic;
            --The input pulse.  When the pulse leaves the active state, the module will hold the 
            --active state for the amount specified in EXTEND_COUNT.
            pulse                : in  std_logic;
            --The output extended pulse.
            extended_pulse       : out std_logic);
end pulse_extender;

----------------------------------------------------------------------------------------------------
--        ARCHITECTURE
----------------------------------------------------------------------------------------------------
architecture behave of pulse_extender is
   --This register will contain the past history of the input pulse
   signal shift_reg  : std_logic_vector(0 to EXTEND_COUNT)  := (others => RESET_LEVEL);
      alias data_in  : std_logic is shift_reg(0);
      alias history  : std_logic_vector(0 to EXTEND_COUNT-1) is shift_reg(1 to EXTEND_COUNT);
begin

   --Shifting the input through the pulse history
   shifter: process(clk, rst)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            data_in <= RESET_LEVEL;
            shift_reg <= (others => '0');
         else
            --copying the pulse into the shift register
            data_in <= pulse;
            --right shifting the shift register
            history <= shift_reg(history'range);
         end if;
      end if;      
   end process;
   
   --Determine if the history has any pulse in it. If it does, then we are still holding the 
   --extended pulse 
   active_high : if(ACTIVE_LEVEL = '1') generate
      extend_check_high : reduce_or
      port map(   data     => shift_reg,
                  result   => extended_pulse);
   end generate;
   
   active_low : if(ACTIVE_LEVEL = '0') generate
      extend_check_low  : reduce_and
      port map(   data     => shift_reg,
                  result   => extended_pulse);
   end generate;

end behave;
