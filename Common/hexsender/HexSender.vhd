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
			  start : in  STD_LOGIC;
			  ready: out STD_LOGIC;
           ma_start : in  STD_LOGIC_VECTOR (15 downto 0);
           ma_end_or_len : in  STD_LOGIC_VECTOR (15 downto 0);
			  ma_sel_len: in STD_LOGIC;
           rec_sel : in  STD_LOGIC_VECTOR (1 downto 0);
           tty_ready : in  STD_LOGIC;
           tty_send : out  STD_LOGIC;
           tty_out : out  STD_LOGIC_VECTOR(7 downto 0);
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

-- some ASCII codes to be output
constant cr: std_logic_vector(7 downto 0) := X"0D";
constant lf: std_logic_vector(7 downto 0) := X"0A";
constant space: std_logic_vector(7 downto 0) := X"20";
constant colon: std_logic_vector(7 downto 0) := X"3A";

type rom8x16 is array (0 to 15) of std_logic_vector(7 downto 0);
constant hex2ascii: rom8x16 := (
	X"30",	-- 0
	X"31",
	X"32",
	X"33",
	X"34",
	X"35",
	X"36",
	X"37",
	X"38",
	X"39",	-- 9
	X"41",	-- A
	X"42",
	X"43",
	X"44",
	X"45",
	X"46"		-- F
);

-- controller
signal ui_address : STD_LOGIC_VECTOR (CODE_ADDRESS_WIDTH - 1 downto 0);

-- internal registers
signal def_len, checksum, ma_current, len: std_logic_vector(15 downto 0);
signal data, outchar, rec: std_logic_vector(7 downto 0);

-- 16 bit adder to generate checksum
signal y_sum16, a_sum16, b_sum16: std_logic_vector(15 downto 0);

-- other signals
signal rec_is_one, len_is_zero, len_gt_deflen: std_logic;
signal hexsel: std_logic_vector(3 downto 0);

signal ma_end_ext: std_logic_vector(15 downto 0);
alias ma_end: std_logic_vector(15 downto 0) is ma_end_or_len;
alias ma_len: std_logic_vector(15 downto 0) is ma_end_or_len;

begin

-- when end address is presented, include it in output
-- when count is presented, 0 means only end record
ma_end_ext <= std_logic_vector(unsigned(ma_end) + 1) when (ma_sel_len = '0') else std_logic_vector(unsigned(ma_start) + unsigned(ma_len));

-- default record length selection
with rec_sel select
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
			cond(seq_cond_start) => start,					-- external start signal
			cond(seq_cond_len_is_zero) => len_is_zero,	-- last address reached
			cond(seq_cond_len_gt_deflen) => len_gt_deflen,	-- remaining count less than default record length
			cond(seq_cond_rec_is_one) => rec_is_one,		-- last record indicator
			cond(seq_cond_bus_ack) => bus_ack,				-- data bus is available
			cond(seq_cond_tty_ready) => tty_ready,			-- tty is ready for next char
			cond(seq_cond_false) => '0',
			-- outputs
			ui_nextinstr => open, 		-- NEXT microinstruction to be executed
			ui_address => ui_address	-- address of CURRENT microinstruction
		);

hexsender_uinstruction <= hexsender_microcode(to_integer(unsigned(ui_address)));

-- conditions
len_gt_deflen <= '1' when (unsigned(len) > unsigned(def_len)) else '0';
len_is_zero <= '1' when (len = X"0000") else '0';
rec_is_one <= '1' when (rec = X"01") else '0';

--consume microcode fields

-- 16-bit ma_current register holding the memory address to be read
update_ma_current: process(clk, hexsender_ma_current)
begin
if (rising_edge(clk)) then
	case hexsender_ma_current is
--			when ma_current_same =>
--				ma_current <= ma_current;
		when ma_current_zero =>
			ma_current <= (others => '0');
		when ma_current_inc =>
			ma_current <= std_logic_vector(unsigned(ma_current) + 1);
		when ma_current_ma_start =>
			ma_current <= ma_start;	
		when others =>
			null;
	end case;
end if;
end process;

-- 8-bit data register holds the byte read from memory
update_data: process(clk, hexsender_data)
begin
if (rising_edge(clk)) then
	 if (hexsender_data = data_bus) then
		 data <= bus_data;
	 end if;
end if;
end process;

-- 8-bit outchar register contains the ASCII code to be output to UART
update_outchar: process(clk, hexsender_outchar)
begin
if (rising_edge(clk)) then
	case hexsender_outchar is
--			when outchar_same =>
--				outchar <= outchar;
		when outchar_colon =>
			outchar <= colon;
		when outchar_space =>
			outchar <= space;
		when outchar_cr =>
			outchar <= cr;
		when outchar_lf =>
			outchar <= lf;
		when outchar_hex =>
			outchar <= hex2ascii(to_integer(unsigned(hexsel)));
		when others =>
			null;
	end case;
end if;
end process;

-- 16-bit checksum register is an accumulator that adds up record values for final checksum
update_checksum: process(clk, hexsender_checksum)
begin
if (rising_edge(clk)) then
	if (hexsender_checksum /= checksum_same) then
		checksum <= y_sum16;
	end if;
end if;
end process;

-- 16 bit adder to generate new checksum
with hexsender_checksum select a_sum16 <=
		(others => '0') when checksum_zero,
		not checksum when checksum_complement_of_2,
		checksum when others;

with hexsender_checksum select b_sum16 <=
		len when checksum_add_len,
		X"00" & ma_current(15 downto 8) when checksum_add_hiaddr,
		X"00" & ma_current(7 downto 0) when checksum_add_loaddr,
		X"00" & rec when checksum_add_rec,
		X"00" & data when checksum_add_data,
		X"0001" when checksum_complement_of_2,
		(others => '0') when others;

y_sum16 <= std_logic_vector(unsigned(a_sum16) + unsigned(b_sum16));

-- 16-bit len register hold the difference between last address and current one 
update_len: process(clk, hexsender_len)
begin
if (rising_edge(clk)) then
	case hexsender_len is
--			when len_same =>
--				len <= len;
		when len_ma_end_minus_ma_current =>
			len <= std_logic_vector(unsigned(ma_end_ext) - unsigned(ma_current));
--			if (ma_current > ma_end_ext) then
--				len_lt_zero <= '1';
--			else
--				len_lt_zero <= '0';
--			end if;
		when len_def_len =>
			len <= def_len;
		when len_dec =>
			len <= std_logic_vector(unsigned(len) - 1);
		when others =>
			null;
	end case;
end if;
end process;

-- 8-bit rec register holds the type of record being output
update_rec: process(clk, hexsender_rec)
begin
if (rising_edge(clk)) then
	case hexsender_rec is
--			when rec_same =>
--				rec <= rec;
		when rec_zero =>
			rec <= (others => '0');
		when rec_one =>
			rec <= X"01";
		when others =>
			null;
	end case;
end if;
end process;

-- 4-bit wide multiplexer to select which data source to convert to ASCII hex character
with hexsender_hexsel select hexsel <=
	(others => '0') when hexsel_zero, -- default value
	X"1" when hexsel_one,
	len(7 downto 4) when hexsel_lolen_hi,
	len(3 downto 0) when hexsel_lolen_lo,
	ma_current(15 downto 12) when hexsel_hiaddr_hi,
	ma_current(11 downto 8) when hexsel_hiaddr_lo,
	ma_current(7 downto 4) when hexsel_loaddr_hi,
	ma_current(3 downto 0) when hexsel_loaddr_lo,
	rec(7 downto 4) when hexsel_rec_hi,
	rec(3 downto 0) when hexsel_rec_lo,
	data(7 downto 4) when hexsel_data_hi,
	data(3 downto 0) when hexsel_data_lo,
	checksum(7 downto 4) when hexsel_checksum_hi,
	checksum(3 downto 0) when hexsel_checksum_lo,
	X"F" when hexsel_f,
	(others => '0') when others;

-- control the memory bus
bus_req <=	hexsender_bus_control(1);
bus_rd <= 	hexsender_bus_control(0);
bus_address <= ma_current;

-- control the UART 
tty_send <=	hexsender_tty_send;
tty_out <= outchar;

end Behavioral;

