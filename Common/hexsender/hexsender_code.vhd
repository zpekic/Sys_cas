--------------------------------------------------------
-- mcc V0.9.0630 - Custom microcode compiler (c)2020-... 
--    https://github.com/zpekic/MicroCodeCompiler
--------------------------------------------------------
-- Auto-generated file, do not modify. To customize, create 'code_template.vhd' file in mcc.exe folder
-- Supported placeholders:  [NAME], [SIZES], [TYPE], [FIELDS], [SIGNAL], [MEMORY].
--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.numeric_std.all;

package hexsender_code is

-- memory block size
constant CODE_DATA_WIDTH: 	positive := 40;
constant CODE_ADDRESS_WIDTH: 	positive := 6;
constant CODE_ADDRESS_LAST: 	positive := 63;
constant CODE_IF_WIDTH: 	positive := 3;


type hexsender_code_memory is array(0 to 63) of std_logic_vector(39 downto 0);

signal hexsender_uinstruction: std_logic_vector(39 downto 0);

--
-- L0009.ready: 1 valuesno,yesdefault no
--
alias hexsender_ready: 	std_logic is hexsender_uinstruction(39);
constant ready_no: 	std_logic := '0';
constant ready_yes: 	std_logic := '1';

--
-- L0014.seq_cond: 3 valuestrue,start,len_is_zero,len_gt_deflen,rec_is_one,bus_ack,tty_ready,falsedefault true
--
alias hexsender_seq_cond: 	std_logic_vector(2 downto 0) is hexsender_uinstruction(38 downto 36);
constant seq_cond_true: 	integer := 0;
constant seq_cond_start: 	integer := 1;
constant seq_cond_len_is_zero: 	integer := 2;
constant seq_cond_len_gt_deflen: 	integer := 3;
constant seq_cond_rec_is_one: 	integer := 4;
constant seq_cond_bus_ack: 	integer := 5;
constant seq_cond_tty_ready: 	integer := 6;
constant seq_cond_false: 	integer := 7;

--
-- L0024.pad1: 2 values 0 .. 3 default 0
--
alias hexsender_pad1: 	std_logic_vector(1 downto 0) is hexsender_uinstruction(35 downto 34);
-- Values from "00" to "11" allowed

--
-- L0025.seq_then: 6 values next, repeat, return, fork, @ default next
--
alias hexsender_seq_then: 	std_logic_vector(5 downto 0) is hexsender_uinstruction(33 downto 28);
constant seq_then_next: 	std_logic_vector(5 downto 0) := "000000";
constant seq_then_repeat: 	std_logic_vector(5 downto 0) := "000001";
constant seq_then_return: 	std_logic_vector(5 downto 0) := "000010";
constant seq_then_fork: 	std_logic_vector(5 downto 0) := "000011";
-- Jump targets allowed!

--
-- L0026.pad2: 2 values 0 .. 3 default 0
--
alias hexsender_pad2: 	std_logic_vector(1 downto 0) is hexsender_uinstruction(27 downto 26);
-- Values from "00" to "11" allowed

--
-- L0027.seq_else: 6 values next, repeat, return, fork, @ default next
--
alias hexsender_seq_else: 	std_logic_vector(5 downto 0) is hexsender_uinstruction(25 downto 20);
constant seq_else_next: 	std_logic_vector(5 downto 0) := "000000";
constant seq_else_repeat: 	std_logic_vector(5 downto 0) := "000001";
constant seq_else_return: 	std_logic_vector(5 downto 0) := "000010";
constant seq_else_fork: 	std_logic_vector(5 downto 0) := "000011";
-- Jump targets allowed!

--
-- L0031.ma_current: 2 valuessame,zero,inc,ma_startdefault same
--
alias hexsender_ma_current: 	std_logic_vector(1 downto 0) is hexsender_uinstruction(19 downto 18);
constant ma_current_same: 	std_logic_vector(1 downto 0) := "00";
constant ma_current_zero: 	std_logic_vector(1 downto 0) := "01";
constant ma_current_inc: 	std_logic_vector(1 downto 0) := "10";
constant ma_current_ma_start: 	std_logic_vector(1 downto 0) := "11";

--
-- L0039.data: 1 valuessame,busdefault same
--
alias hexsender_data: 	std_logic is hexsender_uinstruction(17);
constant data_same: 	std_logic := '0';
constant data_bus: 	std_logic := '1';

--
-- L0045.outchar: 3 valuessame,colon,space,cr,lf,hex,-,-default same
--
alias hexsender_outchar: 	std_logic_vector(2 downto 0) is hexsender_uinstruction(16 downto 14);
constant outchar_same: 	std_logic_vector(2 downto 0) := "000";
constant outchar_colon: 	std_logic_vector(2 downto 0) := "001";
constant outchar_space: 	std_logic_vector(2 downto 0) := "010";
constant outchar_cr: 	std_logic_vector(2 downto 0) := "011";
constant outchar_lf: 	std_logic_vector(2 downto 0) := "100";
constant outchar_hex: 	std_logic_vector(2 downto 0) := "101";
-- Value "110" not allowed (name '-' is not assignable)
-- Value "111" not allowed (name '-' is not assignable)

--
-- L0057.checksum: 3 valuessame,zero,add_len,add_hiaddr,add_loaddr,add_rec,add_data,complement_of_2default same
--
alias hexsender_checksum: 	std_logic_vector(2 downto 0) is hexsender_uinstruction(13 downto 11);
constant checksum_same: 	std_logic_vector(2 downto 0) := "000";
constant checksum_zero: 	std_logic_vector(2 downto 0) := "001";
constant checksum_add_len: 	std_logic_vector(2 downto 0) := "010";
constant checksum_add_hiaddr: 	std_logic_vector(2 downto 0) := "011";
constant checksum_add_loaddr: 	std_logic_vector(2 downto 0) := "100";
constant checksum_add_rec: 	std_logic_vector(2 downto 0) := "101";
constant checksum_add_data: 	std_logic_vector(2 downto 0) := "110";
constant checksum_complement_of_2: 	std_logic_vector(2 downto 0) := "111";

--
-- L0069.len: 2 valuessame,ma_current_minus_ma_end,def_len,decdefault same
--
alias hexsender_len: 	std_logic_vector(1 downto 0) is hexsender_uinstruction(10 downto 9);
constant len_same: 	std_logic_vector(1 downto 0) := "00";
constant len_ma_current_minus_ma_end: 	std_logic_vector(1 downto 0) := "01";
constant len_def_len: 	std_logic_vector(1 downto 0) := "10";
constant len_dec: 	std_logic_vector(1 downto 0) := "11";

--
-- L0077.rec: 2 valuessame,zero,one,-default same
--
alias hexsender_rec: 	std_logic_vector(1 downto 0) is hexsender_uinstruction(8 downto 7);
constant rec_same: 	std_logic_vector(1 downto 0) := "00";
constant rec_zero: 	std_logic_vector(1 downto 0) := "01";
constant rec_one: 	std_logic_vector(1 downto 0) := "10";
-- Value "11" not allowed (name '-' is not assignable)

--
-- L0085.hexsel: 4 valueszero,one,lolen_hi,lolen_lo,hiaddr_hi,hiaddr_lo,loaddr_hi,loaddr_lo,rec_hi,rec_lo,data_hi,data_lo,checksum_hi,checksum_lo,-,fdefault zero
--
alias hexsender_hexsel: 	std_logic_vector(3 downto 0) is hexsender_uinstruction(6 downto 3);
constant hexsel_zero: 	std_logic_vector(3 downto 0) := X"0";
constant hexsel_one: 	std_logic_vector(3 downto 0) := X"1";
constant hexsel_lolen_hi: 	std_logic_vector(3 downto 0) := X"2";
constant hexsel_lolen_lo: 	std_logic_vector(3 downto 0) := X"3";
constant hexsel_hiaddr_hi: 	std_logic_vector(3 downto 0) := X"4";
constant hexsel_hiaddr_lo: 	std_logic_vector(3 downto 0) := X"5";
constant hexsel_loaddr_hi: 	std_logic_vector(3 downto 0) := X"6";
constant hexsel_loaddr_lo: 	std_logic_vector(3 downto 0) := X"7";
constant hexsel_rec_hi: 	std_logic_vector(3 downto 0) := X"8";
constant hexsel_rec_lo: 	std_logic_vector(3 downto 0) := X"9";
constant hexsel_data_hi: 	std_logic_vector(3 downto 0) := X"A";
constant hexsel_data_lo: 	std_logic_vector(3 downto 0) := X"B";
constant hexsel_checksum_hi: 	std_logic_vector(3 downto 0) := X"C";
constant hexsel_checksum_lo: 	std_logic_vector(3 downto 0) := X"D";
-- Value X"E" not allowed (name '-' is not assignable)
constant hexsel_f: 	std_logic_vector(3 downto 0) := X"F";

--
-- L0104.bus_control: 2 valuesnop,-,request,request_and_readdefault nop
--
alias hexsender_bus_control: 	std_logic_vector(1 downto 0) is hexsender_uinstruction(2 downto 1);
constant bus_control_nop: 	std_logic_vector(1 downto 0) := "00";
-- Value "01" not allowed (name '-' is not assignable)
constant bus_control_request: 	std_logic_vector(1 downto 0) := "10";
constant bus_control_request_and_read: 	std_logic_vector(1 downto 0) := "11";

--
-- L0111.tty_send: 1 valuesno,yesdefault yes
--
alias hexsender_tty_send: 	std_logic is hexsender_uinstruction(0);
constant tty_send_no: 	std_logic := '0';
constant tty_send_yes: 	std_logic := '1';



constant hexsender_microcode: hexsender_code_memory := (

-- L0126@0000._reset: ma_current <= zero
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 01, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
0 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "01" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0128@0001._reset1: ma_current <= zero
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 01, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
1 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "01" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0130@0002._reset2: ma_current <= zero
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 01, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
2 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "01" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0132@0003._reset3: ma_current <= zero
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 01, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
3 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "01" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0135@0004.waitStart: ready = yes, ma_current <= ma_start,if start then next else repeat
--  ready = 1, if (001) pad1 = 00, then 000000 pad2 = 00, else 000001, ma_current <= 11, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
4 => '1' & O"1" & "00" & O"00" & "00" & O"01" & "11" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0138@0005.nextRow: checksum <= zero, len <= ma_current_minus_ma_end, rec <= zero
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 001, len <= 01, rec <= 01, hexsel = 0000, bus_control = 00, tty_send = 1;
5 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "00" & '0' & O"0" & O"1" & "01" & "01" & X"0" & "00" & '1',

-- L0140@0006. if len_is_zero then printEnd else next
--  ready = 0, if (010) pad1 = 00, then 100100 pad2 = 00, else 000000, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
6 => '0' & O"2" & "00" & O"44" & "00" & O"00" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0142@0007. if len_gt_deflen then next else lastLine
--  ready = 0, if (011) pad1 = 00, then 000000 pad2 = 00, else 001001, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
7 => '0' & O"3" & "00" & O"00" & "00" & O"11" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0144@0008. len <= def_len,if false then next else printLine
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 001010, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 10, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
8 => '0' & O"7" & "00" & O"00" & "00" & O"12" & "00" & '0' & O"0" & O"0" & "10" & "00" & X"0" & "00" & '1',

-- L0147@0009.lastLine: rec <= one, ma_current <= zero
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 01, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 10, hexsel = 0000, bus_control = 00, tty_send = 1;
9 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "01" & '0' & O"0" & O"0" & "00" & "10" & X"0" & "00" & '1',

-- L0149@000A.printLine: outchar <= colon,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 001, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
10 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"1" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0152@000B. if false then next else tty_space
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101011, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
11 => '0' & O"7" & "00" & O"00" & "00" & O"53" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0154@000C. outchar <= hex, hexsel = lolen_hi,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 0010, bus_control = 00, tty_send = 1;
12 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"2" & "00" & '1',

-- L0157@000D. outchar <= hex, hexsel = lolen_lo, checksum <= add_len,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 010, len <= 00, rec <= 00, hexsel = 0011, bus_control = 00, tty_send = 1;
13 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"2" & "00" & "00" & X"3" & "00" & '1',

-- L0160@000E. if false then next else tty_space
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101011, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
14 => '0' & O"7" & "00" & O"00" & "00" & O"53" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0162@000F. outchar <= hex, hexsel = hiaddr_hi,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 0100, bus_control = 00, tty_send = 1;
15 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"4" & "00" & '1',

-- L0165@0010. outchar <= hex, hexsel = hiaddr_lo, checksum <= add_hiaddr,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 011, len <= 00, rec <= 00, hexsel = 0101, bus_control = 00, tty_send = 1;
16 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"3" & "00" & "00" & X"5" & "00" & '1',

-- L0168@0011. outchar <= hex, hexsel = loaddr_hi,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 0110, bus_control = 00, tty_send = 1;
17 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"6" & "00" & '1',

-- L0171@0012. outchar <= hex, hexsel = loaddr_lo, checksum <= add_loaddr,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 100, len <= 00, rec <= 00, hexsel = 0111, bus_control = 00, tty_send = 1;
18 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"4" & "00" & "00" & X"7" & "00" & '1',

-- L0174@0013. if false then next else tty_space
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101011, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
19 => '0' & O"7" & "00" & O"00" & "00" & O"53" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0176@0014. outchar <= hex, hexsel = rec_hi,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 1000, bus_control = 00, tty_send = 1;
20 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"8" & "00" & '1',

-- L0179@0015. outchar <= hex, hexsel = rec_lo, checksum <= add_rec,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 101, len <= 00, rec <= 00, hexsel = 1001, bus_control = 00, tty_send = 1;
21 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"5" & "00" & "00" & X"9" & "00" & '1',

-- L0182@0016. if false then next else tty_space
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101011, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
22 => '0' & O"7" & "00" & O"00" & "00" & O"53" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0184@0017. if rec_is_one then printEnd else next
--  ready = 0, if (100) pad1 = 00, then 100100 pad2 = 00, else 000000, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
23 => '0' & O"4" & "00" & O"44" & "00" & O"00" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0186@0018.nextByte: if len_is_zero then printChk else next
--  ready = 0, if (010) pad1 = 00, then 011111 pad2 = 00, else 000000, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
24 => '0' & O"2" & "00" & O"37" & "00" & O"00" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0189@0019. bus_control = request,if bus_ack then next else repeat
--  ready = 0, if (101) pad1 = 00, then 000000 pad2 = 00, else 000001, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 10, tty_send = 1;
25 => '0' & O"5" & "00" & O"00" & "00" & O"01" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "10" & '1',

-- L0192@001A. bus_control = request_and_read, data <= bus
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 00, data <= 1, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 11, tty_send = 1;
26 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "00" & '1' & O"0" & O"0" & "00" & "00" & X"0" & "11" & '1',

-- L0194@001B. outchar <= hex, hexsel = data_hi,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 1010, bus_control = 00, tty_send = 1;
27 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"A" & "00" & '1',

-- L0197@001C. outchar <= hex, hexsel = data_lo, checksum <= add_data,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 110, len <= 00, rec <= 00, hexsel = 1011, bus_control = 00, tty_send = 1;
28 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"6" & "00" & "00" & X"B" & "00" & '1',

-- L0200@001D. if false then next else tty_space
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101011, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
29 => '0' & O"7" & "00" & O"00" & "00" & O"53" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0202@001E. ma_current <= inc, len <= dec,if false then next else nextByte
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 011000, ma_current <= 10, data <= 0, outchar <= 000, checksum <= 000, len <= 11, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
30 => '0' & O"7" & "00" & O"00" & "00" & O"30" & "10" & '0' & O"0" & O"0" & "11" & "00" & X"0" & "00" & '1',

-- L0205@001F.printChk: checksum <= complement_of_2
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 111, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
31 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "00" & '0' & O"0" & O"7" & "00" & "00" & X"0" & "00" & '1',

-- L0207@0020. outchar <= hex, hexsel = checksum_hi,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 1100, bus_control = 00, tty_send = 1;
32 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"C" & "00" & '1',

-- L0210@0021. outchar <= hex, hexsel = checksum_lo,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 1101, bus_control = 00, tty_send = 1;
33 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"D" & "00" & '1',

-- L0213@0022. if false then next else printCRLF
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101000, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
34 => '0' & O"7" & "00" & O"00" & "00" & O"50" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0215@0023. if false then next else nextRow
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 000101, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
35 => '0' & O"7" & "00" & O"00" & "00" & O"05" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0218@0024.printEnd: outchar <= hex, hexsel = f,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 1111, bus_control = 00, tty_send = 1;
36 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"F" & "00" & '1',

-- L0221@0025. outchar <= hex, hexsel = f,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 101, checksum <= 000, len <= 00, rec <= 00, hexsel = 1111, bus_control = 00, tty_send = 1;
37 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"5" & O"0" & "00" & "00" & X"F" & "00" & '1',

-- L0224@0026. if false then next else printCRLF
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101000, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
38 => '0' & O"7" & "00" & O"00" & "00" & O"50" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0226@0027. if false then next else waitStart
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 000100, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
39 => '0' & O"7" & "00" & O"00" & "00" & O"04" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0228@0028.printCRLF: outchar <= cr,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 011, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
40 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"3" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0231@0029. outchar <= lf,if false then next else tty_out
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 101100, ma_current <= 00, data <= 0, outchar <= 100, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
41 => '0' & O"7" & "00" & O"00" & "00" & O"54" & "00" & '0' & O"4" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0234@002A. if false then next else return
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 000010, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
42 => '0' & O"7" & "00" & O"00" & "00" & O"02" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0236@002B.tty_space: outchar <= space
--  ready = 0, if (000) pad1 = 00, then 000000 pad2 = 00, else 000000, ma_current <= 00, data <= 0, outchar <= 010, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
43 => '0' & O"0" & "00" & O"00" & "00" & O"00" & "00" & '0' & O"2" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0238@002C.tty_out: if tty_ready then next else repeat
--  ready = 0, if (110) pad1 = 00, then 000000 pad2 = 00, else 000001, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
44 => '0' & O"6" & "00" & O"00" & "00" & O"01" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- L0240@002D. tty_send = yes,if false then next else return
--  ready = 0, if (111) pad1 = 00, then 000000 pad2 = 00, else 000010, ma_current <= 00, data <= 0, outchar <= 000, checksum <= 000, len <= 00, rec <= 00, hexsel = 0000, bus_control = 00, tty_send = 1;
45 => '0' & O"7" & "00" & O"00" & "00" & O"02" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1',

-- 18 location(s) in following ranges will be filled with default value
-- 002E .. 003F

others => '0' & O"0" & "00" & O"00" & "00" & O"00" & "00" & '0' & O"0" & O"0" & "00" & "00" & X"0" & "00" & '1'
);

end hexsender_code;

