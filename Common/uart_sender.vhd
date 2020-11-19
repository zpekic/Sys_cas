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
			  rts: out STD_LOGIC;
			  cts: in STD_LOGIC;
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

type rom12x16 is array (0 to 15) of std_logic_vector(11 downto 0);
constant nanocode: rom12x16 := (
	"1000" & X"11",	-- 0
	"1010" & X"21",	-- 1	send
	"0100" & X"33",	-- 2	
	"0111" & X"43",	-- 3	cts
	"0100" & X"55",	-- 4
	"0100" & X"66",	-- 5
	"0100" & X"77",	-- 6
	"0100" & X"88",	-- 7
	"0100" & X"99",	-- 8
	"0100" & X"AA",	-- 9
	"0100" & X"BB",	-- A
	"0100" & X"CC",	-- B
	"0100" & X"DD",	-- C
	"1000" & X"11",	-- D
	"1000" & X"11",	-- E
	"1000" & X"11"		-- F
);

signal even, odd, parbit: std_logic;
signal frame: std_logic_vector(8 downto 0);

-- nano control unit
signal cond: std_logic;
signal npc: std_logic_vector(3 downto 0);
signal control: std_logic_vector(11 downto 0); 
--alias load: std_logic is control(10);
alias next_if: std_logic_vector(1 downto 0) is control(9 downto 8);
alias next_then: std_logic_vector(3 downto 0) is control(7 downto 4);
alias next_else: std_logic_vector(3 downto 0) is control(3 downto 0);

begin

-- data paths 
pgenerate: Am82S62 port map ( 
				p(9) => '0',
				p(8 downto 1) => data,
				inhibit => '0',
				even => even,
				odd => odd
		);

with mode select parbit <=
		'0' when "100",	-- 8 bits, space parity (10 bit frame)
		even when "101",	-- 8 bits, even parity (10 bit frame)
		odd when "110",	-- 8 bits, odd parity (10 bit frame)
		'1' when "111",	-- 8 bits, mark parity == 8 bits, 2 stop bits
		'1' when others;	-- 8 bits 1 stop bit (9 bit frame)

-- control unit
control <= nanocode(to_integer(unsigned(npc)));

with next_if select cond <=
	send	when "10",
	cts 	when "11",
	'1'	when others;

on_tx_clk: process(reset, tx_clk, control, cond)
begin
	if ((reset = '1') or (enable = '0')) then
		npc <= X"0";
	else
		if (rising_edge(tx_clk)) then
			if (cond = '1') then
				npc <= next_then;
			else
				npc <= next_else;
			end if;
			if (npc = X"1") then		-- bad practice!
				frame <= parbit & data;
			end if;
		end if;
	end if;
end process;

-- output
ready <= control(11);
rts <= control(10);
with npc select tx <= 
			'0' when X"4",			-- start bit
			frame(0) when X"5",
			frame(1) when X"6",
			frame(2) when X"7",
			frame(3) when X"8",
			frame(4) when X"9",
			frame(5) when X"A",
			frame(6) when X"B",
			frame(7) when X"C",
			frame(8) when X"D",	-- parity or stop
			'1' when others;		-- idle or stop

--trigger <= enable and send;
--ready <= (not busy) when (bitcnt = X"0") else '0';

--drive_send: process(reset, trigger)
--begin
--	if ((reset = '1') or (bitcnt = X"B")) then	-- end bitcnt can be made f(mode)
--		busy <= '0';
--	else
--		if (rising_edge(trigger)) then
--			busy <= '1';
--			case mode is
--				when "100" => -- space parity
--					frame <= '0' & data;
--				when "101" => -- even parity
--					frame <= even & data;
--				when "110" => -- odd parity
--					frame <= odd & data;
--				when "111" => -- mark parity
--					frame <= '1' & data;
--				when others =>
--					frame <= '1' & data; 
--			end case;
--		end if;
--	end if;
--end process;
--
--drive_tx: process(tx_clk, reset)
--begin
--	if (reset = '1') then
--		bitcnt <= X"0";
--	else
--		if (rising_edge(tx_clk)) then
--			if (busy = '1') then
--				bitcnt <= std_logic_vector(unsigned(bitcnt) + 1);
--			else
--				bitcnt <= X"0";
--			end if;
--		end if;
--	end if;
--end process;
			
end Behavioral;

