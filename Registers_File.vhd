LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Registers_File IS
  PORT (

    -- I/P
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    RegWrite : IN STD_LOGIC;
    ReadReg1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    ReadReg2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    WriteReg : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    WriteData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- O/P
    ReadData1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    ReadData2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END ENTITY;
ARCHITECTURE Behavioral OF Registers_File IS

  TYPE Reg_Array IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Registers : Reg_Array := (
    0 => (OTHERS => '0'), -- $zero hardwired to 0
    1 => x"00000001", -- $at
    2 => x"00000002", -- $v0
    3 => x"00000003", -- $v1
    4 => x"00000004", -- $a0
    5 => x"00000005", -- $a1
    6 => x"00000006", -- $a2
    7 => x"00000000", -- $a3
    8 => x"00000008", -- $t0
    9 => x"00000009", -- $t1
    10 => x"00000000", -- $t2
    11 => x"0000000B", -- $t3
    12 => x"0000000C", -- $t4
    13 => x"0000000D", -- $t5
    14 => x"0000000E", -- $t6
    15 => x"0000000F", -- $t7
    16 => x"00000010", -- $s0
    17 => x"00000011", -- $s1
    18 => x"00000012", -- $s2
    19 => x"00000013", -- $s3
    20 => x"00000014", -- $s4
    21 => x"00000015", -- $s5
    22 => x"00000016", -- $s6
    23 => x"00000017", -- $s7
    24 => x"00000018", -- $t8
    25 => x"00000019", -- $t9
    26 => x"0000001A", -- $k0
    27 => x"0000001B", -- $k1
    28 => x"0000001C", -- $gp
    29 => x"0000001D", -- $sp
    30 => x"0000001E", -- $fp
    31 => x"0000001F" -- $ra
  );

BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Registers <= (OTHERS => (OTHERS => '0'));
    ELSIF rising_edge(clk) AND RegWrite = '1' THEN
      Registers(to_integer(unsigned(WriteReg))) <= WriteData;
    END IF;
  END PROCESS;
  ReadData1 <= (OTHERS => '0') WHEN ReadReg1 = "00000"
    ELSE
    registers(to_integer(unsigned(ReadReg1)));
  ReadData2 <= (OTHERS => '0') WHEN ReadReg2 = "00000"
    ELSE
    registers(to_integer(unsigned(ReadReg2)));
END Behavioral; -- Behavioral