LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Memory IS
  PORT (
    clk : IN STD_LOGIC;
    MemRead : IN STD_LOGIC;
    MemWrite : IN STD_LOGIC;
    Address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE Behavioral OF Memory IS
  CONSTANT MEM_SIZE : INTEGER := 2048; -- 2KB memory
  TYPE RAM_Array IS ARRAY (0 TO MEM_SIZE-1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  
  -- Initialize memory with default MIPS program
  SIGNAL RAM : RAM_Array := (
  -- ========== INSTRUCTIONS ========== --
  -- add $8, $16, $17   (0x02114020)
  -- 00000010_00010001_01000000_00100000
  0 => x"02", 1 => x"11", 2 => x"40", 3 => x"20",

  -- lw $25, 4($24)     (0x8D190004)
  4 => x"8D", 5 => x"19", 6 => x"00", 7 => x"04",

  -- sw $25, 8($24)     (0xAD190008)
  8 => x"AD", 9 => x"19", 10 => x"00", 11 => x"08",

  -- addi $10, $0, 5    (0x200A0005)
  12 => x"20", 13 => x"0A", 14 => x"00", 15 => x"05",

  -- beq $8, $9, -8     (0x1109FFF8)
  16 => x"11", 17 => x"09", 18 => x"FF", 19 => x"F8",

  -- j 0x00400000       (0x08010000)
  20 => x"08", 21 => x"01", 22 => x"00", 23 => x"00",

  -- and $11, $8, $9    (0x01095824)
  24 => x"01", 25 => x"09", 26 => x"58", 27 => x"24",

  -- or $12, $8, $9     (0x01096025)
  28 => x"01", 29 => x"09", 30 => x"60", 31 => x"25",

  -- slt $13, $8, $9    (0x0109682A)
  32 => x"01", 33 => x"09", 34 => x"68", 35 => x"2A",

  -- ========== DATA SECTION ========== --
  -- Data at address 0x10010000 (256)
  256 => x"12", 257 => x"34", 258 => x"56", 259 => x"78",

  -- Data at address 0x10010004 (260)
  260 => x"9A", 261 => x"BC", 262 => x"DE", 263 => x"F0",

  -- Initialize rest to zero
  OTHERS => x"00"
);


BEGIN
  PROCESS(clk)
    VARIABLE byte_addr : INTEGER;
  BEGIN
    IF rising_edge(clk) THEN
      -- Convert to byte address within bounds
      byte_addr := to_integer(unsigned(Address(10 DOWNTO 0)));
      
      -- Write operation
      IF MemWrite = '1' AND byte_addr+3 < MEM_SIZE THEN
        RAM(byte_addr)   <= DataIn(31 DOWNTO 24);
        RAM(byte_addr+1) <= DataIn(23 DOWNTO 16);
        RAM(byte_addr+2) <= DataIn(15 DOWNTO 8);
        RAM(byte_addr+3) <= DataIn(7 DOWNTO 0);
      END IF;
    END IF;
  END PROCESS;
  
  -- Read operation (asynchronous)
  DataOut <= RAM(to_integer(unsigned(Address(10 DOWNTO 0)))) &
             RAM(to_integer(unsigned(Address(10 DOWNTO 0)))+1) &
             RAM(to_integer(unsigned(Address(10 DOWNTO 0)))+2) &
             RAM(to_integer(unsigned(Address(10 DOWNTO 0)))+3)
           WHEN MemRead = '1' AND (to_integer(unsigned(Address(10 DOWNTO 0)))+3 < MEM_SIZE)
           ELSE (OTHERS => '0');
END ARCHITECTURE;