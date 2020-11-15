----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:45:29 11/11/2020 
-- Design Name: 
-- Module Name:    HexSender - Behavioral 
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

use work.hexsender_code.all;
use work.hexsender_map.all;

entity HexSender is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  ready: out STD_LOGIC;
           ma_start : in  STD_LOGIC_VECTOR (7 downto 0);
           ma_end : in  STD_LOGIC_VECTOR (7 downto 0);
           rec_sel : in  STD_LOGIC_VECTOR (1 downto 0);
           tty_ready : in  STD_LOGIC;
           tty_send : out  STD_LOGIC;
           tty_out : out  STD_LOGIC;
           bus_req : out  STD_LOGIC;
           bus_rd : out  STD_LOGIC;
           bus_ack : in  STD_LOGIC;
           bus_data : in  STD_LOGIC_VECTOR (7 downto 0);
           bus_address : out  STD_LOGIC_VECTOR (15 downto 0));
end HexSender;

architecture Behavioral of HexSender is

component hexsender_control_unit is
     Generic (
            CODE_DEPTH : positive;
            IF_WIDTH : positive
          );
     Port ( 
          -- standard inputs
          reset : in  STD_LOGIC;
          clk : in  STD_LOGIC;
          -- design specific inputs
          seq_cond : in  STD_LOGIC_VECTOR (IF_WIDTH - 1 downto 0);
          seq_then : in  STD_LOGIC_VECTOR (CODE_DEPTH - 1 downto 0);
          seq_else : in  STD_LOGIC_VECTOR (CODE_DEPTH - 1 downto 0);
          seq_fork : in  STD_LOGIC_VECTOR (CODE_DEPTH - 1 downto 0);
          cond : in  STD_LOGIC_VECTOR (2 ** IF_WIDTH - 1 downto 0);
          -- outputs
          ui_nextinstr : buffer  STD_LOGIC_VECTOR (CODE_DEPTH - 1 downto 0);
          ui_address : out  STD_LOGIC_VECTOR (CODE_DEPTH - 1 downto 0));
end component;

signal def_len: std_logic_vector(15 downto 0);
begin

-- default record length selection
with rec_len select
	def_len <= 	X"0002" when "00",
					X"0004" when "01",
					X"0008" when "10",
					X"0010" when others; -- usually 16 bytes per record
					
-- control unit
cu: hexsender_control_unit
		generic map (
			CODE_DEPTH => CODE_ADDRESS_WIDTH,
			IF_WIDTH => CODE_IF_WIDTH
		)
		port map (
			-- inputs
			reset => reset,
			clk => clk,
			seq_cond => hexsender_seq_cond,
			seq_then => hexsender_seq_then,
			seq_else => hexsender_seq_else,	
			seq_fork => "000000",	-- not used in this design
			cond(seq_cond_true) => '1',
			cond(seq_cond_start) => '1',	-- TODO
			cond(seq_cond_len_is_zero) => len_is_zero,
			cond(seq_cond_len_gt_deflen) => len_gt_deflen,
			cond(seq_cond_rec_is_one) => rec_is_one,
			cond(seq_cond_bus_ack) => bus_ack,
			cond(seq_cond_tty_ready) => tty_ready,
			cond(seq_cond_false) => '0',
			-- outputs
			ui_nextinstr => open, 		-- NEXT microinstruction to be executed
			ui_address => ui_address	-- address of CURRENT microinstruction
		);

hexsender_uinstruction <= cpu_microcode(to_integer(unsigned(ui_address)));

-- conditions
len_gt_deflen <= '1' when (unsigned(len) > unsigned(def_len)) else '0';
len_is_zero <= '1' when (len = X"0000") else '0';
rec_is_one <= '1' when (rec = X"01") else '0';


-- consume microcode fields
ready <= hexsender_ready;


end Behavioral;

