----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:11:45 10/08/2020 
-- Design Name: 
-- Module Name:    freqcounter - Behavioral 
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

entity freqcounter is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           freq : in  STD_LOGIC;
			  bcd:	in STD_LOGIC;
			  double: in STD_LOGIC;
			  limit: in STD_LOGIC_VECTOR(15 downto 0);
			  ge: out STD_LOGIC;
           value : out  STD_LOGIC_VECTOR (15 downto 0));
end freqcounter;

architecture Behavioral of freqcounter is

component adder16 is
    Port ( cin : in  STD_LOGIC;
           a : in  STD_LOGIC_VECTOR (15 downto 0);
           b : in  STD_LOGIC_VECTOR (15 downto 0);
           na : in  STD_LOGIC;
           nb : in  STD_LOGIC;
           bcd : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR (15 downto 0);
           cout : out  STD_LOGIC);
end component;

signal r0, r1, r2, a, sum: std_logic_vector(15 downto 0);
signal display: std_logic_vector(2 downto 0);
signal c0, c1, c2, cout: std_logic;

begin

-- select which reg to display
with display select
	value <= 	r0 when "001",
					r1 when "010",
					r2 when "100",
					X"FFFF" when others;

with display select
	ge <=		 	c0 when "001",
					c1 when "010",
					c2 when "100",
					'0' when others;
					
-- the "next" reg is being updated, so bring it to the nibble adder "a" inputs
with display select
	a <= 			r1 when "001",
					r2 when "010",
					r0 when "100",
					X"0000" when others;

-- compare with limit, BCD or binary
comparator: adder16 Port map ( 
				cin => '1',
				a => sum,
				b => limit,
				na => '0',
				nb => '1',
				bcd => bcd,
				y => open,
				cout => cout
			);

-- add to count, BCD or binary, 1 or 2
adder: adder16 Port map ( 
				cin => double,
				a => a,
				b => X"0001",
				na => '0',
				nb => '0',
				bcd => bcd,
				y => sum,
				cout => open
			);

-- drive the "pipeline"
-- r0: clear	count		display
-- r1: count	display	clear 
-- r2: display	clear		count
update_ring: process(reset, clk)
begin
	if (reset = '1') then
		display <= "001";
	else
		if (rising_edge(clk)) then
			display <= display(1 downto 0) & display(2);
		end if;
	end if;
end process;

update_r0: process(reset, freq, display)
begin
	if (reset = '1' or display(1) = '1') then
		r0 <= X"0000";
	else
		if (rising_edge(freq) and display(2) = '1') then
			r0 <= sum; --std_logic_vector(unsigned(r0) + 1);
			c0 <= cout;
		end if;
	end if;
end process;

update_r1: process(reset, freq, display)
begin
	if (reset = '1' or display(2) = '1') then
		r1 <= X"0000";
	else
		if (rising_edge(freq) and display(0) = '1') then
			r1 <= sum; --std_logic_vector(unsigned(r1) + 1);
			c1 <= cout;
		end if;
	end if;
end process;

update_r2: process(reset, freq, display)
begin
	if (reset = '1' or display(0) = '1') then
		r2 <= X"0000";
	else
		if (rising_edge(freq) and display(1) = '1') then
			r2 <= sum; --std_logic_vector(unsigned(r2) + 1);
			c2 <= cout;
		end if;
	end if;
end process;

end Behavioral;

