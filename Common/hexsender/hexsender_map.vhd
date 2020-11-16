--------------------------------------------------------
-- mcc V0.9.1115 - Custom microcode compiler (c)2020-... 
--    https://github.com/zpekic/MicroCodeCompiler
--------------------------------------------------------
-- Auto-generated file, do not modify. To customize, create 'mapper_template.vhd' file in mcc.exe folder
-- Supported placeholders:  [SIZES], [NAME], [TYPE], [SIGNAL], [MEMORY].
--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.numeric_std.all;

package hexsender_map is

-- memory block size
constant MAPPER_DATA_WIDTH: 	positive := 6;
constant MAPPER_ADDRESS_WIDTH: 	positive := 4;
constant MAPPER_ADDRESS_LAST: 	positive := 15;


type hexsender_mapper_memory is array(0 to 15) of std_logic_vector(5 downto 0);

signal hexsender_instructionstart: std_logic_vector(5 downto 0);



constant hexsender_mapper: hexsender_mapper_memory := (

-- L0134@0004. .map 0b????
0 => O"04",

1 => O"04",

2 => O"04",

3 => O"04",

4 => O"04",

5 => O"04",

6 => O"04",

7 => O"04",

8 => O"04",

9 => O"04",

10 => O"04",

11 => O"04",

12 => O"04",

13 => O"04",

14 => O"04",

15 => O"04");

end hexsender_map;

