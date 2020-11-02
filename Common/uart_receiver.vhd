----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:02:07 09/20/2020 
-- Design Name: 
-- Module Name:    uart_receiver - Behavioral 
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

entity uart_receiver is
    Port ( rx_clk4 : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rx : in  STD_LOGIC;
			  -- mode:
			  -- 0 X X -- 8 bits 1 stop bit (9 bit frame)
			  -- 1 0 0 -- 8 bits, space parity (10 bit frame)
			  -- 1 0 1 -- 8 bits, even parity (10 bit frame)
			  -- 1 1 0 -- 8 bits, odd parity (10 bit frame)
			  -- 1 1 1 -- 8 bits, mark parity == 8 bits, 2 stop bits
			  mode: in STD_LOGIC_VECTOR (2 downto 0);
			  frame_active: out  STD_LOGIC;
           frame_ready : out  STD_LOGIC;
           frame_valid : out  STD_LOGIC;
           frame_data : out  STD_LOGIC_VECTOR (15 downto 0)
	);
end uart_receiver;

architecture Behavioral of uart_receiver is

component Am82S62 is
    Port ( p : in  STD_LOGIC_VECTOR (9 downto 1);
           inhibit : in  STD_LOGIC;
           even : buffer  STD_LOGIC;
           odd : out  STD_LOGIC);
end component;

signal bitcnt: std_logic_vector(5 downto 0);
signal data: std_logic_vector(15 downto 0);
signal enable, done, busy, even, odd, valid: std_logic;
signal delay: std_logic_vector(2 downto 0);

begin

-- connect to outputs
frame_ready <= done;
frame_active <= busy;
frame_valid <= valid;

with mode select
			valid <= (not (data(10)) and (not data(1)) and data(0)) when "100",
						(not (data(10)) and even and data(0)) when "101",
						(not (data(10)) and odd and data(0)) when "110",
						(not (data(10)) and data(1) and data(0)) when "111",
						(not (data(10)) and data(1)) when others; -- start and stop

-- assume space is detected when 3 samples in a row are '0'
on_rxclk4: process(reset, rx_clk4, rx, enable)
begin
	if (reset = '1') then
		bitcnt <= "111111";
		delay <= "111";
		busy <= '0';
		done <= '0';
	else
		if (rising_edge(rx_clk4)) then

			delay <= delay(1 downto 0) & rx;

			if (bitcnt = "111111") then
				if (delay = "000") then
					bitcnt <= "101001"; -- 0x2B = 43 = 10 bits * 4 clocks +3
					data <= X"FFFE"; --"1111111111111111";
					busy <= '1';
					done <= '0';
				else
					busy <= '0';
					done <= '0';
				end if;
			else
				if (bitcnt = "000000") then
					busy <= '0';
					done <= '1';
					frame_data <= valid & "00000" & even & odd & data(2) & data(3) & data(4) & data(5) & data(6) & data(7) & data(8) & data(9);
					bitcnt <= "111111";
				else
					if (bitcnt(1 downto 0) = "00") then
						data <= data(14 downto 0) & rx; -- & rx;
					end if;
					busy <= '1';
					done <= '0';
				end if;
				bitcnt <= std_logic_vector(unsigned(bitcnt) - 1);
			end if;
		end if;
	end if;
end process;

pcheck: Am82S62 port map ( 
			p => data(9 downto 1),
         inhibit => '0',
         even => even,
         odd => odd
		);

end Behavioral;

