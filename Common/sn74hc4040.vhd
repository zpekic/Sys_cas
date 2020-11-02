----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:25:04 08/29/2020 
-- Design Name: 
-- Module Name:    sn74hc4040 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: https://www.futurlec.com/74HC/74HC4040.shtml
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

entity sn74hc4040 is
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
end sn74hc4040;

architecture Behavioral of sn74hc4040 is

signal q: std_logic_vector(12 downto 1);

begin

-- logic (not quite correct as this is sync, not ripple)
count: process(clock_10, reset_11, q)
begin
	if (reset_11 = '1') then
		q <= X"000";
	else
		if (falling_edge(clock_10)) then
			q <= std_logic_vector(unsigned(q) + 1);
		end if;
	end if;
end process;

-- mapping
q12_1 <= q(12);
q6_2	<= q(6);
q5_3	<= q(5);
q7_4	<= q(7);
q4_5	<= q(4);
q3_6 	<= q(3);
q2_7	<= q(2);
q1_9	<= q(1);
q9_12	<= q(9);
q8_13	<= q(8);
q10_14	<= q(10);
q11_15	<= q(11);

end Behavioral;

