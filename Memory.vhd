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
  CONSTANT MEM_SIZE : INTEGER := 2048; -- 2KB memory (2048 bytes)
  TYPE RAM_Array IS ARRAY (0 TO MEM_SIZE-1) OF STD_LOGIC_VECTOR(7 DOWNTO 0); -- byte-addressable
  SIGNAL RAM : RAM_Array := (
    -- Initialize with your program and data
    -- First 136 bytes are instructions (same as your original)
    0 => "00000000", 1 => "00100010", 2 => "00011000", 3 => "00100000",
    4 => "00100000", 5 => "01100001", 6 => "00000000", 7 => "00110010",
    8 => "00100000", 9 => "01100010", 10 => "00000000", 11 => "00110000",
    12 => "00000000", 13 => "01000000", 14 => "00010000", 15 => "00100000",
    16 => "00010000", 17 => "00100010", 18 => "00000000", 19 => "00000001",
    20 => "00001000", 21 => "00000000", 22 => "00000000", 23 => "00000011",
    24 => "00000000", 25 => "00100010", 26 => "00000000", 27 => "00100010",
    28 => "10001110", 29 => "10001010", 30 => "00000000", 31 => "00101111",
    32 => "10101110", 33 => "10001010", 34 => "00000000", 35 => "00101111",
    36 => "00100000", 37 => "01100100", 38 => "00000000", 39 => "00001010",
    40 => "00000000", 41 => "00110110", 42 => "00110111", 43 => "00110101",
    44 => "00000000", 45 => "01001000", 46 => "01001001", 47 => "01001010",
    48 => "00000000", 49 => "01001100", 50 => "01001101", 51 => "01001011",
    52 => "00000000", 53 => "01111000", 54 => "01111001", 55 => "00000000",
    56 => "00111100", 57 => "00000000", 58 => "00010000", 59 => "00000000",
    60 => "00100000", 61 => "01001000", 62 => "01001001", 63 => "11111011",
    64 => "00001100", 65 => "00000000", 66 => "00000000", 67 => "00111111",
    68 => "00000000", 69 => "01011000", 70 => "01011001", 71 => "01010111",
    72 => "00111000", 73 => "01101100", 74 => "01101101", 75 => "00000011",
    76 => "00100000", 77 => "01110010", 78 => "01110011", 79 => "11111100",
    80 => "00101000", 81 => "01111110", 82 => "01111111", 83 => "00000001",
    84 => "00000000", 85 => "00000000", 86 => "00000001", 87 => "00001000",
    88 => "00110000", 89 => "01100100", 90 => "01100101", 91 => "00001111",
    92 => "00001000", 93 => "00000001", 94 => "11111001", 95 => "00000001",
    96 => "10001100", 97 => "01100000", 98 => "00000110", 99 => "00000000",
    100 => "10101100", 101 => "01100100", 102 => "00000111", 103 => "00000000",
    104 => "00100000", 105 => "01011000", 106 => "01011001", 107 => "00011001",
    108 => "00000000", 109 => "01011100", 110 => "01011101", 111 => "01011011",
    112 => "00001000", 113 => "00000010", 114 => "11111000", 115 => "00000000",
    116 => "00100000", 117 => "01010000", 118 => "01010001", 119 => "00000101",
    120 => "00111100", 121 => "00000000", 122 => "01001000", 123 => "00100111",
    124 => "10001100", 125 => "01010000", 126 => "00000000", 127 => "00000000",
    128 => "10101100", 129 => "01011000", 130 => "00000001", 131 => "00000000",
    132 => "00001000", 133 => "00001000", 134 => "00100111", 135 => "00000000",
    
    -- Data section (same as your original)
    136 => "11011110", 137 => "10101101", 138 => "10111110", 139 => "11101111",
    140 => "11001010", 141 => "11111110", 142 => "10111010", 143 => "10111110",
    144 => "00010010", 145 => "00110100", 146 => "01010110", 147 => "01111000",
    148 => "00001011", 149 => "10101101", 150 => "11110000", 151 => "00001101",
    152 => "11111111", 153 => "00000000", 154 => "11111111", 155 => "00000000",
    
    OTHERS => "00000000"
  );

  -- Function to convert byte address to word address (4-byte aligned)
  FUNCTION get_index(addr : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN INTEGER IS
    VARIABLE word_addr : UNSIGNED(31 DOWNTO 0);
  BEGIN
    word_addr := unsigned(addr) / 4;
    RETURN to_integer(word_addr MOD MEM_SIZE/4) * 4; -- Ensure address is within bounds
  END FUNCTION;

BEGIN
  -- Write process (synchronous)
  PROCESS(clk)
    VARIABLE index : INTEGER;
  BEGIN
    IF rising_edge(clk) THEN
      IF MemWrite = '1' THEN
        index := get_index(Address);
        IF index+3 < MEM_SIZE THEN -- Check bounds
          RAM(index)   <= DataIn(31 DOWNTO 24);
          RAM(index+1) <= DataIn(23 DOWNTO 16);
          RAM(index+2) <= DataIn(15 DOWNTO 8);
          RAM(index+3) <= DataIn(7 DOWNTO 0);
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- Read process (asynchronous)
  PROCESS(MemRead, Address)
    VARIABLE index : INTEGER;
  BEGIN
    IF MemRead = '1' THEN
      index := get_index(Address);
      IF index+3 < MEM_SIZE THEN -- Check bounds
        DataOut <= RAM(index) & RAM(index+1) & RAM(index+2) & RAM(index+3);
      ELSE
        DataOut <= (OTHERS => '0');
      END IF;
    ELSE
      DataOut <= (OTHERS => '0');
    END IF;
  END PROCESS;
END ARCHITECTURE;