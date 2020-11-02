----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:44:37 09/23/2020 
-- Design Name: 
-- Module Name:    Am82S62 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: https://www.datasheetarchive.com/pdf/download.php?id=121e106981f6092056dec34398a623e6e96d03&type=O&term=Am82S62
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Am82S62 is
    Port ( p : in  STD_LOGIC_VECTOR (9 downto 1);
           inhibit : in  STD_LOGIC;
           even : buffer  STD_LOGIC;
           odd : out  STD_LOGIC);
end Am82S62;

architecture Behavioral of Am82S62 is

signal p14, p58, a0, a1, a2, a3: std_logic;

begin

p14 <= not ((p(1) xor p(2)) xor (p(3) xor p(4)));
p58 <= not ((p(5) xor p(6)) xor (p(7) xor p(8)));

a0 <= (not p14) and p58 and (not p(9));
a1 <= p14 and (not p58) and (not p(9));
a2 <= p14 and p58 and p(9);
a3 <= (not p14) and (not p58) and p(9);

even <= not (inhibit or a0 or a1 or a2 or a3);
odd <= not (inhibit or even);

end Behavioral;

