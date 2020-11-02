----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:52 10/16/2020 
-- Design Name: 
-- Module Name:    uart_sender - Behavioral 
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

entity uart_sender is
    Port ( tx_clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           tx : out  STD_LOGIC;
			  ready: out STD_LOGIC;
			  -- mode:
			  -- 0 X X -- 8 bits 1 stop bit (9 bit frame)
			  -- 1 0 0 -- 8 bits, space parity (10 bit frame)
			  -- 1 0 1 -- 8 bits, even parity (10 bit frame)
			  -- 1 1 0 -- 8 bits, odd parity (10 bit frame)
			  -- 1 1 1 -- 8 bits, mark parity == 8 bits, 2 stop bits
           mode : in  STD_LOGIC_VECTOR (2 downto 0);
           send : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0));
end uart_sender;

architecture Behavioral of uart_sender is

component Am82S62 is
    Port ( p : in  STD_LOGIC_VECTOR (9 downto 1);
           inhibit : in  STD_LOGIC;
           even : buffer  STD_LOGIC;
           odd : out  STD_LOGIC);
end component;

signal trigger, busy: std_logic;
signal even, odd: std_logic;
signal bitcnt: std_logic_vector(3 downto 0);
signal frame: std_logic_vector(8 downto 0);

begin

trigger <= enable and send;
ready <= (not busy) when (bitcnt = X"0") else '0';

with bitcnt select
	tx <= '0' when X"1",			-- start bit
			frame(0) when X"2",
			frame(1) when X"3",
			frame(2) when X"4",
			frame(3) when X"5",
			frame(4) when X"6",
			frame(5) when X"7",
			frame(6) when X"8",
			frame(7) when X"9",
			frame(8) when X"A",	-- parity or stop
			'1' when others;		-- idle or stop

pgenerate: Am82S62 port map ( 
				p(9) => '0',
				p(8 downto 1) => data,
				inhibit => '0',
				even => even,
				odd => odd
		);

drive_send: process(reset, trigger)
begin
	if ((reset = '1') or (bitcnt = X"B")) then	-- end bitcnt can be made f(mode)
		busy <= '0';
	else
		if (rising_edge(trigger)) then
			busy <= '1';
			case mode is
				when "100" => -- space parity
					frame <= '0' & data;
				when "101" => -- even parity
					frame <= even & data;
				when "110" => -- odd parity
					frame <= odd & data;
				when "111" => -- mark parity
					frame <= '1' & data;
				when others =>
					frame <= '1' & data; 
			end case;
		end if;
	end if;
end process;

drive_tx: process(tx_clk, reset)
begin
	if (reset = '1') then
		bitcnt <= X"0";
	else
		if (rising_edge(tx_clk)) then
			if (busy = '1') then
				bitcnt <= std_logic_vector(unsigned(bitcnt) + 1);
			else
				bitcnt <= X"0";
			end if;
		end if;
	end if;
end process;
		
			
end Behavioral;

