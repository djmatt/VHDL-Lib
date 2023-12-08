--------------------------------------------------------------------------------------------------
--        Pulse Width Modulation
--------------------------------------------------------------------------------------------------
-- Matthew Dallmeyer - d01matt@gmail.com

--------------------------------------------------------------------------------------------------
--        PACKAGE
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

package pwm_pkg is
   component pwm is
      generic( CLK_PERIOD        : time      := 10ns;
               PWM_PERIOD        : time      := 5us;
               ADDED_PRECISION   : natural   := 8);
      port(    clk               : in  std_logic;
               rst               : in  std_logic;
               data              : in  signed;
               pwm_pulses        : out std_logic);
   end component;
end package;

--------------------------------------------------------------------------------------------------
--        ENTITY
--------------------------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.pulse_gen_pkg.all;
   use work.count_gen_pkg.all;

library work;

entity pwm is
   generic( CLK_PERIOD        : time      := 10ns;
            PWM_PERIOD        : time      := 5us;
            ADDED_PRECISION   : natural   := 8);
   port(    clk               : in  std_logic;
            rst               : in  std_logic;
            data              : in  signed;
            pwm_pulses        : out std_logic);
end pwm;

--------------------------------------------------------------------------------------------------
--        ARCHITECTURE
--------------------------------------------------------------------------------------------------
architecture rtl of pwm is

   --Building out the configuration, based on the generics and the width of data.
   constant CLKS_PER_PULSE    : natural            := ((PWM_PERIOD / time'val(1)) / (CLK_PERIOD / time'val(1)));
   constant FULL_WIDTH        : natural            := data'length + ADDED_PRECISION;
   constant MAX_DATA_VALUE    : integer            := 2 ** FULL_WIDTH;
   constant COUNT_INIT_VAL    : integer            := 0 - (2 ** (FULL_WIDTH-1));
   constant COUNT_STEP_VAL    : integer            := MAX_DATA_VALUE / CLKS_PER_PULSE;

   --Internal signals
   signal rst_clock_counter   : std_logic;
   signal freq_pulse          : std_logic;
   signal sample_reg          : signed(data'range) := (others => '0');
   signal count               : integer;
   signal count_signed        : signed(FULL_WIDTH-1 downto 0);
   signal compare_count       : signed(data'range);
   signal pwm_pulse_reg       : std_logic          := '0';

   --Setting up the debug signals
   attribute   MARK_DEBUG                       : string;
   signal      freq_pulse_debug                 : std_logic;
   attribute   MARK_DEBUG of freq_pulse_debug   : signal is "true";
   signal      sample_reg_debug                 : signed(sample_reg'range);
   attribute   MARK_DEBUG of sample_reg_debug   : signal is "true";
   signal      compare_count_debug              : signed(compare_count'range);
   attribute   MARK_DEBUG of compare_count_debug: signal is "true";
   signal      pwm_pulse_reg_debug              : std_logic;
   attribute   MARK_DEBUG of pwm_pulse_reg_debug: signal is "true";

begin

   --Generate a pulse on the pwm frequency
   pwm_freq_pulse : pulse_gen
   generic map(CLKS_PER_PULSE => CLKS_PER_PULSE)
   port map(   clk            => clk,
               rst            => rst,
               pulse          => freq_pulse);

   --Sample the input signal on the pwm freq pulse
   downsampler_proc : process(clk)
   begin
      if(rising_edge(clk)) then
         if(rst = '1') then
            sample_reg  <= (others => '0');
         elsif(freq_pulse = '1') then
            sample_reg  <= data;
         end if;
      end if;--rising_edge(clk)
   end process downsampler_proc;

   --Generate a counter that will count up from the minimum value
   rst_clock_counter <= rst or freq_pulse;

   clock_counter : count_gen
   generic map(INIT_VAL    => COUNT_INIT_VAL,
               STEP_VAL    => COUNT_STEP_VAL)
   port map(   clk         => clk,
               rst         => rst_clock_counter,
               en          => '1',
               count       => count);

   count_signed <= to_signed(count, count_signed'length);
   compare_count  <= count_signed(FULL_WIDTH-1 downto ADDED_PRECISION);

   --Compare count to sampled value, is '1' while count < sample_reg
   comparator_proc : process(clk)
   begin
      if(rising_edge(clk)) then
         if(compare_count < sample_reg) then
            pwm_pulse_reg <= '1';
         else
            pwm_pulse_reg <= '0';
         end if;
      end if; --rising_edge(clk)
   end process comparator_proc;

   pwm_pulses <= pwm_pulse_reg;

   --Create copies of signals for ILA debug
   debug_proc : process(clk)
   begin
      if(rising_edge(clk)) then
         freq_pulse_debug     <= freq_pulse;
         sample_reg_debug     <= sample_reg;
         compare_count_debug  <= compare_count;
         pwm_pulse_reg_debug  <= pwm_pulse_reg;
      end if;
   end process;

end rtl;
