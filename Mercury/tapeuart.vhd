----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:54:21 10/24/2020 
-- Design Name: 
-- Module Name:    tapeuart - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tapeuart is
    Port ( reset : in  STD_LOGIC;
           serout : out  STD_LOGIC;
           serin : in  STD_LOGIC;
			  freq_mark: in STD_LOGIC;
			  freq_space: in STD_LOGIC;
           audio_left : out  STD_LOGIC;
           audio_right : out  STD_LOGIC;
           adc_clk : in  STD_LOGIC;
           adc_samplefreq : in  STD_LOGIC;
           adc_miso : in  STD_LOGIC;
           adc_mosi : out  STD_LOGIC;
           adc_sck : out  STD_LOGIC;
           adc_csn : out  STD_LOGIC;
			  --
			  debugsel: in STD_LOGIC;
			  debug: out STD_LOGIC_VECTOR(15 downto 0)
			);
end tapeuart;

architecture Behavioral of tapeuart is

signal adc_trigger  : std_logic := '1';              -- go sample from ADC
signal adc_done     : std_logic := '0';              -- done sampling ADC
signal adc_dout     : std_logic_vector(9 downto 0);  -- ADC data out
--signal adc_data_reg : unsigned(9 downto 0);          -- ADC data registered
signal adc_channel  : std_logic_vector(2 downto 0);  -- ADC channel
signal min: unsigned(9 downto 0) := "1111111111";
signal max: unsigned(9 downto 0) := "0000000000";
signal adc_count, adc_old_count, freq_value: std_logic_vector(15 downto 0);
signal adc_value: std_logic_vector(7 downto 0);
signal f_in, f_out, f_in_audio: std_logic;
signal tick, delta, prev: unsigned(31 downto 0);
signal limit0, prev0: unsigned(31 downto 0);
signal limit1, prev1: unsigned(31 downto 0);
signal txd, ntxd, detect0, detect1, txd_audio: std_logic;
signal rxd, rxd_audio: std_logic;

begin

-- debug port
debug <= std_logic_vector(limit0(15 downto 0)) when (debugsel = '0') else std_logic_vector(limit1(15 downto 0));

-- output path
f_out <= freq_space when (serin = '0') else freq_mark;	-- always output to audio
audio_left  <= f_out; --baudrate_x2 when (PMOD(6) = '1') else baudrate_x4;
audio_right <= f_out; --baudrate_x2 when (PMOD(6) = '1') else baudrate_x4;

-- input path
f_in <= f_in_audio;

serout <= not (txd);

detect0 <= '1' when (delta > (limit0 - 20)) else '0'; -- X240 for 300baud, 120 for 600
detect1 <= '1' when (delta < (limit1 + 20)) else '0'; -- X160 for 300baud, B0 for 600

ntxd <= not (detect0 or txd);
txd <= not (detect1 or ntxd);

on_f_in: process(f_in)
begin
	if (rising_edge(f_in)) then
		delta <= tick - prev;
		prev <= tick;
	end if;
end process;

on_freq_space: process(freq_space)
begin
	if (rising_edge(freq_space)) then
		limit0 <= tick - prev0;
		prev0 <= tick;
	end if;
end process;

on_freq_mark: process(freq_mark)
begin
	if (rising_edge(freq_mark)) then
		limit1 <= tick - prev1;
		prev1 <= tick;
	end if;
end process;

  -- Mercury ADC component
  ADC : entity work.MercuryADC
    port map(
      clock    => adc_clk,
      trigger  => adc_trigger,
      diffn    => '0',
      channel  => "000",	-- channel 0 = left audio
      Dout     => adc_dout,
      OutVal   => adc_done,
      adc_miso => ADC_MISO,
      adc_mosi => ADC_MOSI,
      adc_cs   => ADC_CSN,
      adc_clk  => ADC_SCK
      );
		
on_adc_samplefreq: process(adc_samplefreq)
begin
	if (adc_done = '1') then
		adc_trigger <= '0';
	else
		if (rising_edge(adc_samplefreq)) then
			adc_trigger <= not adc_done;
			tick <= tick + 1;
		end if;
	end if;
end process;

  -- ADC sampling process
on_adc_done : process (adc_done)
begin
 if (rising_edge(adc_done)) then
		if (f_in_audio = '0') then
			if (unsigned(adc_dout) > "00" & X"24") then
				f_in_audio <= '1';
			end if;
		else
			if (unsigned(adc_dout) < "00" & X"24") then
				f_in_audio <= '0';
			end if;
		end if;
		--adc_value <= adc_dout(9 downto 2);
			
		if (unsigned(adc_dout) > max) then
			max <= unsigned(adc_dout);
		end if;

		if (unsigned(adc_dout) < min) then
			min <= unsigned(adc_dout);
		end if;

	end if;
end process;

end Behavioral;

