----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: zpekic@hotmail.com
-- 
-- Create Date: 08/29/2020 11:13:02 PM
-- Design Name: FPGA cassette recorder demo
-- Module Name: sys_cas_mercury - Behavioral
-- Project Name: 
-- Target Devices: https://www.micro-nova.com/mercury/ + Baseboard
-- Input devices: 
--
-- Tool Versions: ISE 14.7 (nt)
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.99 - Kinda works...
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--use work.tms0800_package.all;

entity sys_cas_mercury is
    Port ( 
				-- 50MHz on the Mercury board
				CLK: in std_logic;
				
				-- 12MHz external clock
				EXT_CLK: in std_logic;
				
				-- Master reset button on Mercury board
				USR_BTN: in std_logic; 

				-- Switches on baseboard
				-- SW(0) -- 0: baudrate / min ADC, 1: mode / max ADC 
				-- SW(1) -- 0: show baudrate / mode, 1: show ADC audion signal min/max on 7seg LED
				-- SW(2) -- mode 0 -- see uartreceiver.vhd file for values
				-- SW(3) -- mode 1
				-- SW(4) -- mode 2
				-- SW(5) -- baudrate 0 -- from 300 (000) to 38400 (111)
				-- SW(6) -- baudrate 1
				-- SW(7)	-- baudrate 2

				SW: in std_logic_vector(7 downto 0); 

				-- Push buttons on baseboard
				-- BTN0 - not used, test DP3 on 7seg LED
				-- BTN1 - not used, test DP2 on 7seg LED
				-- BTN2 - not used, test DP1 on 7seg LED
				-- BTN3 - not used, test DP0 on 7seg LED
				BTN: in std_logic_vector(3 downto 0); 

				-- Stereo audio output on baseboard
				AUDIO_OUT_L, AUDIO_OUT_R: out std_logic;

				-- 7seg LED on baseboard 
				A_TO_G: out std_logic_vector(6 downto 0); 
				AN: out std_logic_vector(3 downto 0); 
				DOT: out std_logic; 
				-- 4 LEDs on Mercury board (3 and 2 are used by VGA VSYNC and HSYNC)
				LED: inout std_logic_vector(3 downto 0);

				-- ADC interface
				-- channel	input
				-- 0			Audio Left
				-- 1 			Audio Right
				-- 2			Temperature
				-- 3			Light	
				-- 4			Pot
				-- 5			Channel 5 (free)
				-- 6			Channel 6 (free)
				-- 7			Channel 7 (free)
				ADC_MISO: in std_logic;
				ADC_MOSI: out std_logic;
				ADC_SCK: out std_logic;
				ADC_CSN: out std_logic;
				--PS2_DATA: in std_logic;
				--PS2_CLOCK: in std_logic;

				--VGA interface
				--register state is traced to VGA after each instruction if SW0 = on
				--640*480 50Hz mode is used, which give 80*60 character display
				--but to save memory, only 80*50 are used which fits into 4k video RAM
				--HSYNC: out std_logic;
				--VSYNC: out std_logic;
				--RED: out std_logic_vector(2 downto 0);
				--GRN: out std_logic_vector(2 downto 0);
				--BLU: out std_logic_vector(1 downto 0);
				
				--PMOD interface
				PMOD: inout std_logic_vector(7 downto 0)
          );
end sys_cas_mercury;

architecture Structural of sys_cas_mercury is

component sn74hc4040 is
    Port ( q12_1 : out  STD_LOGIC;
           q6_2 : out  STD_LOGIC;
           q5_3 : out  STD_LOGIC;
           q7_4 : out  STD_LOGIC;
           q4_5 : out  STD_LOGIC;
           q3_6 : out  STD_LOGIC;
           q2_7 : out  STD_LOGIC;
           q1_9 : out  STD_LOGIC;
           clock_10 : in  STD_LOGIC;
           reset_11 : in  STD_LOGIC;
           q9_12 : out  STD_LOGIC;
           q8_13 : out  STD_LOGIC;
           q10_14 : out  STD_LOGIC;
           q11_15 : out  STD_LOGIC);
end component;

component fourdigitsevensegled is
    Port ( -- inputs
			  hexdata : in  STD_LOGIC_VECTOR (3 downto 0);
           digsel : in  STD_LOGIC_VECTOR (1 downto 0);
           showdigit : in  STD_LOGIC_VECTOR (3 downto 0);
           showdot : in  STD_LOGIC_VECTOR (3 downto 0);
			  -- outputs
           anode : out  STD_LOGIC_VECTOR (3 downto 0);
           segment : out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end component;

component freqcounter is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           freq : in  STD_LOGIC;
			  bcd:	in STD_LOGIC;
			  double: in STD_LOGIC;
			  limit: in STD_LOGIC_VECTOR(15 downto 0);
			  ge: out STD_LOGIC;
           value : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component uart_receiver is
    Port ( rx_clk4 : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rx : in  STD_LOGIC;
           mode : in  STD_LOGIC_VECTOR (2 downto 0);
			  frame_active: out  STD_LOGIC;
           frame_ready : out  STD_LOGIC;
           frame_valid : out  STD_LOGIC;
           frame_data : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component uart_sender is
	 Port (  tx_clk  : in  STD_LOGIC;
				reset  : in  STD_LOGIC;
				tx  : out  STD_LOGIC;
				ready: out STD_LOGIC;
				mode : in  STD_LOGIC_VECTOR (2 downto 0); 
				send : in  STD_LOGIC; 
				enable : in  STD_LOGIC;
				data : in STD_LOGIC_VECTOR(7 downto 0));
end component;
	
component tapeuart is
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
end component;

component debouncer8channel is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           signal_raw : in STD_LOGIC_VECTOR (7 downto 0);
           signal_debounced : out STD_LOGIC_VECTOR (7 downto 0));
end component;

type rom16x8 is array (0 to 7) of std_logic_vector(15 downto 0);
signal display_config: rom16x8 := (
-- 0 X X -- 8 bits 1 stop bit (9 bit frame)
	X"8001",
	X"8001",
	X"8001",
	X"8001",
-- 1 0 0 -- 8 bits, space parity (10 bit frame)
	X"8151",
-- 1 0 1 -- 8 bits, even parity (10 bit frame)
	X"81E1",
-- 1 1 0 -- 8 bits, odd parity (10 bit frame)
	X"8101",
-- 1 1 1 -- 8 bits, mark parity == 8 bits, 2 stop bits
	X"8002"
);

signal RESET: std_logic;

-- debug
signal display, display_host, display_streamer, display_baudrate: std_logic_vector(15 downto 0);
signal digsel: std_logic_vector(1 downto 0);
signal hexdata, hexsel, showdigit: std_logic_vector(3 downto 0);
signal warning: std_logic;
---
signal data: std_logic_vector(15 downto 0);
signal freq_uart, freq_uart4: std_logic;

--- frequency signals
signal freq24M, dotclk, freq0M75: std_logic;
signal prescale_baud, prescale_power: integer range 0 to 65535;
signal freq153600, freq76800, freq38400, freq19200, freq9600, freq4800, freq2400, freq1200, freq600, freq300, freq150: std_logic;		
signal freq4096, freq2, freq4: std_logic;	

---
signal switch, button: std_logic_vector(7 downto 0);

-- UART
--signal frame_ready, frame_valid, frame_active: std_logic;
--signal frame_data, uart_frame: std_logic_vector(15 downto 0);
signal baudrate_x1, baudrate_x2, baudrate_x4, baudrate_x8: std_logic;
--signal sr: std_logic_vector(31 downto 0);

-- https://reference.digilentinc.com/reference/pmod/pmodusbuart/reference-manual
alias nRTS: std_logic is PMOD(4); 	-- out, active low
alias RXD_TTY: std_logic is PMOD(5);		-- in
alias TXD_TTY: std_logic is PMOD(6);		-- out
alias nCTS: std_logic is PMOD(7);	-- in, active low

begin
   
-- connect to hobby-level oscilloscope such as https://www.parallax.com/product/32220
-- in addition, analog signals can be measured too
PMOD(0) <= baudrate_x4;
PMOD(1) <= baudrate_x1;
PMOD(2) <= RXD_TTY;
PMOD(3) <= TXD_TTY;
-- show same on LEDs
LED(0) <= baudrate_x4;
LED(1) <= baudrate_x1;
LED(2) <= RXD_TTY;
LED(3) <= TXD_TTY;
	
RESET <= USR_BTN;
	
clockgen: sn74hc4040 port map (
			clock_10 => CLK,	-- replace with EXT_CLK to use 48MHz "half-size" crystal on Mercury baseboard
			reset_11 => RESET,
			q1_9 => freq24M, 
			q2_7 => dotclk,
			q3_6 => open, --PMOD(7),			-- 6
			q4_5 => open, --PMOD(6),			-- 3
			q5_3 => open, --PMOD(5),			-- 1.5
			q6_2 => freq0M75, --PMOD(4), 		-- 0.75
			q7_4 =>   open,		-- 0.375
			q8_13 =>  open,		-- 0.1875
			q9_12 =>  open,		-- 0.093750
			q10_14 => open,		-- 0.046875
			q11_15 => digsel(0),	-- 0.0234375
			q12_1 =>  digsel(1)	-- 0.01171875
		);
--
prescale: process(CLK, freq153600, freq4096)
begin
	if (rising_edge(CLK)) then
		-- for standard baudrates
		if (prescale_baud = 0) then
			freq153600 <= not freq153600;
			prescale_baud <= (50000000 / (2 * 153600));
		else
			prescale_baud <= prescale_baud - 1;
		end if;
		-- for power of 2
		if (prescale_power = 0) then
			freq4096 <= not freq4096;
			prescale_power <= (50000000 / (2 * 4096));
		else
			prescale_power <= prescale_power - 1;
		end if;
	end if;
end process;
--
baudgen: sn74hc4040 port map (
			clock_10 => freq153600,
			reset_11 => RESET,
			q1_9 => freq76800, 
			q2_7 => freq38400,
			q3_6 => freq19200,		
			q4_5 => freq9600,		
			q5_3 => freq4800,		
			q6_2 => freq2400, 	
			q7_4 => freq1200,		
			q8_13 => freq600,		
			q9_12 =>  freq300,
			q10_14 => freq150,	
			q11_15 => open,	
			q12_1 =>  open	
		);
--
powergen: sn74hc4040 port map (
			clock_10 => freq4096,
			reset_11 => RESET,
			q1_9 => open, 
			q2_7 => open,
			q3_6 => open,		
			q4_5 => open,		
			q5_3 => open,		
			q6_2 => open, 	
			q7_4 => open,		
			q8_13 => open,		
			q9_12 =>  open,	
			q10_14 => freq4,	
			q11_15 => freq2,	
			q12_1 =>  open	
		);
----	
	debounce_sw: debouncer8channel Port map ( 
		clock => freq19200, 
		reset => RESET,
		signal_raw => SW,
		signal_debounced => switch
	);

	debounce_btn: debouncer8channel Port map ( 
		clock => freq19200, 
		reset => RESET,
		signal_raw(7 downto 4) => "0000",
		signal_raw(3 downto 0) => BTN,
		signal_debounced => button
	);

-- use 4 digit seven segment display on base board for some basic info
display <= display_host when (switch(1) = '0') else display_streamer;
display_host <= display_baudrate when (switch(0) = '0') else  display_config(to_integer(unsigned(switch(4 downto 2))));
				
leds: fourdigitsevensegled Port map ( 
			-- inputs
			hexdata => hexdata,
			digsel => digsel,
			showdigit => showdigit,
			--showdot(3) => "00", --std_logic_vector(max(9 downto 8)),
			--showdot(2) => "00", --std_logic_vector(min(9 downto 8)),
			showdot => button(3 downto 0),
			-- outputs
			anode => AN,
			segment(7) => DOT,
			segment(6 downto 0) => A_TO_G
		);

showdigit <= "0000" when (warning = '1' and freq2 = '1') else "1111"; 

with digsel select
	hexdata <= 	display(3 downto 0) when "00",	
					display(7 downto 4) when "01",
					display(11 downto 8) when "10",
					display(15 downto 12) when others;

baud_counter: freqcounter port map ( 
				reset => RESET,
				clk  => freq2,
				freq => baudrate_x1,
				bcd => '1',
				double => '1',
				limit => X"1200", -- indicate the reliable bps limit
				ge => warning,
				value => display_baudrate
			);
--
-- UART input coming either directly from USB2UART, or ADC
-- 
with switch(7 downto 5) select
		baudrate_x8 <= '1' when "111",		-- Not supported!
							freq153600 when "110", 
							freq76800 when "101",
							freq38400 when "100",		
							freq19200 when "011",		
							freq9600 when "010",		
							freq4800 when "001", 	
							freq2400 when others;		

with switch(7 downto 5) select
		baudrate_x4 <= freq153600 when "111",
							freq76800 when "110", 
							freq38400 when "101",
							freq19200 when "100",		
							freq9600 when "011",		
							freq4800 when "010",		
							freq2400 when "001", 	
							freq1200 when others;		

with switch(7 downto 5) select
		baudrate_x2 <= freq76800 when "111", 
							freq38400 when "110",
							freq19200 when "101",		
							freq9600 when "100",		
							freq4800 when "011",		
							freq2400 when "010", 	
							freq1200 when "001",
						   freq600 when others;

with switch(7 downto 5) select
		baudrate_x1 <= freq38400 when "111",
							freq19200 when "110",		
							freq9600 when "101",		
							freq4800 when "100",		
							freq2400 when "011", 
							freq1200 when "010",
							freq600  when "001",
							freq300 when others;		

streamer: tapeuart port map ( 
				reset => RESET,
				serout => RXD_TTY,
				serin => TXD_TTY,
				freq_mark => baudrate_x8,
				freq_space => baudrate_x4,
				audio_left => AUDIO_OUT_L,
				audio_right => AUDIO_OUT_R,
				adc_clk => freq24M,
				adc_samplefreq => freq0M75,
				adc_miso => ADC_MISO,
				adc_mosi => ADC_MOSI,
				adc_sck => ADC_SCK,
				adc_csn => ADC_CSN,
				----
				debugsel => switch(0),
				debug => display_streamer
			);

--
--serin: uart_receiver Port map ( 
--				rx_clk4 => baudrate_x4,
--				reset => RESET,
--				rx => RXD_TTY,	-- "txd" looking from the sender side
--				mode => switch(4 downto 2), 
--				frame_active => frame_active,
--				frame_ready => frame_ready, 
--				frame_valid => frame_valid,
--				frame_data => frame_data
--		);

--capture_frame: process(RESET, frame_data, frame_ready)
--begin
--	if (RESET = '1') then
--		sr <= X"FFFFFFFF";
--	else
--		if (rising_edge(frame_ready)) then
--			sr <= sr(15 downto 0) & frame_data;
--		end if;
--	end if;
--end process;


end;
