library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Memory is 
  port (
    clk      : in std_logic;
    MemRead  : in std_logic;
    MemWrite : in std_logic;
    Address  : in std_logic_vector(31 downto 0);
    DataIn   : in std_logic_vector(31 downto 0);
    DataOut  : out std_logic_vector(31 downto 0)
  );
end entity;

architecture Behavioral of Memory is
  type RAM_Array is array (0 to 2047) of std_logic_vector(7 downto 0);  -- byte-addressable
  signal RAM : RAM_Array := (
    ---4-- add $R3, $R1, $R2
    0 => "00000000",  -- byte 0
    1 => "00100010",  -- byte 1
    2 => "00011000",  -- byte 2
    3 => "00100000",  -- byte 3

    --8-- addi $R1,$R3,50
    4 => "00100000",  -- byte 4
    5 => "01100001",  -- byte 5
    6 => "00000000",  -- byte 6
    7 => "00110010",  -- byte 7

    --C-- addi $R2,$R3,48
    8 => "00100000",  -- byte 8
    9 => "01100010",  -- byte 9
    10 => "00000000", -- byte 10
    11 => "00110000", -- byte 11 
	
	--10-- add $R2,$R2,$R0
    12 => "00000000", -- byte 12
    13 => "01000000", -- byte 13
    14 => "00010000", -- byte 14
    15 => "00100000", -- byte 15

    --14-- beq $R1,$R2,1
    16 => "00010000", -- byte 16
    17 => "00100010", -- byte 17
    18 => "00000000", -- byte 18
    19 => "00000001", -- byte 19

    --18-- j 3
    20 => "00001000", -- byte 20
    21 => "00000000", -- byte 21
    22 => "00000000", -- byte 22
    23 => "00000011", -- byte 23

    -- sub $R0,$R1,$R2
    24 => "00000000", -- byte 24
    25 => "00100010", -- byte 25
    26 => "00000000", -- byte 26
    27 => "00100010", -- byte 27

    -- lw $R10,47($R20)
    28 => "10001110", -- byte 28
    29 => "10001010", -- byte 29
    30 => "00000000", -- byte 30
    31 => "00101111", -- byte 31

    -- sw $R10,47($R20)
    32 => "10101110", -- byte 32
    33 => "10001010", -- byte 33
    34 => "00000000", -- byte 34
    35 => "00101111", -- byte 35

    -- addi $R3,$R4,10
    36 => "00100000", -- byte 36
    37 => "01100100", -- byte 37
    38 => "00000000", -- byte 38
    39 => "00001010", -- byte 39

    -- and $R5,$R6,$R7
    40 => "00000000", -- byte 40
    41 => "00110110", -- byte 41
    42 => "00110111", -- byte 42
    43 => "00110101", -- byte 43

    -- or $R8,$R9,$R10
    44 => "00000000", -- byte 44
    45 => "01001000", -- byte 45
    46 => "01001001", -- byte 46
    47 => "01001010", -- byte 47

    -- slt $R11,$R12,$R13
    48 => "00000000", -- byte 48
    49 => "01001100", -- byte 49
    50 => "01001101", -- byte 50
    51 => "01001011", -- byte 51

    -- mul $R14,$R15
    52 => "00000000", -- byte 52
    53 => "01111000", -- byte 53
    54 => "01111001", -- byte 54
    55 => "00000000", -- byte 55

    -- lui $R16,1000
    56 => "00111100", -- byte 56
    57 => "00000000", -- byte 57
    58 => "00010000", -- byte 58
    59 => "00000000", -- byte 59

    -- addi $R17,$R18,-5
    60 => "00100000", -- byte 60
    61 => "01001000", -- byte 61
    62 => "01001001", -- byte 62
    63 => "11111011", -- byte 63

    -- jal 1000
    64 => "00001100", -- byte 64
    65 => "00000000", -- byte 65
    66 => "00000000", -- byte 66
    67 => "00111111", -- byte 67

    -- sub $R23,$R24,$R25
    68 => "00000000", -- byte 68
    69 => "01011000", -- byte 69
    70 => "01011001", -- byte 70
    71 => "01010111", -- byte 71

    -- xori $R26,$R27,3
    72 => "00111000", -- byte 72
    73 => "01101100", -- byte 73
    74 => "01101101", -- byte 74
    75 => "00000011", -- byte 75

    -- addi $R28,$R29,-100
    76 => "00100000", -- byte 76
    77 => "01110010", -- byte 77
    78 => "01110011", -- byte 78
    79 => "11111100", -- byte 79

    -- slti $R30,$R31,200
    80 => "00101000", -- byte 80
    81 => "01111110", -- byte 81
    82 => "01111111", -- byte 82
    83 => "00000001", -- byte 83

    -- or $R0,$R1,$R2
    84 => "00000000", -- byte 84
    85 => "00000000", -- byte 85
    86 => "00000001", -- byte 86
    87 => "00001000", -- byte 87

    -- andi $R3,$R4,15
    88 => "00110000", -- byte 88
    89 => "01100100", -- byte 89
    90 => "01100101", -- byte 90
    91 => "00001111", -- byte 91

    -- j 1
    92 => "00001000", -- byte 92
    93 => "00000001", -- byte 93
    94 => "11111001", -- byte 94
    95 => "00000001", -- byte 95

    -- lw $R5,60($R6)
    96 => "10001100", -- byte 96
    97 => "01100000", -- byte 97
    98 => "00000110", -- byte 98
    99 => "00000000", -- byte 99

    -- sw $R7,100($R8)
    100 => "10101100", -- byte 100
    101 => "01100100", -- byte 101
    102 => "00000111", -- byte 102
    103 => "00000000", -- byte 103

    -- addi $R9,$R10,25
    104 => "00100000", -- byte 104
    105 => "01011000", -- byte 105
    106 => "01011001", -- byte 106
    107 => "00011001", -- byte 107

    -- slt $R13,$R14,$R15
    108 => "00000000", -- byte 108
    109 => "01011100", -- byte 109
    110 => "01011101", -- byte 110
    111 => "01011011", -- byte 111

    -- j 8000
    112 => "00001000", -- byte 112
    113 => "00000010", -- byte 113
    114 => "11111000", -- byte 114
    115 => "00000000", -- byte 115

    -- addi $R16,$R17,5
    116 => "00100000", -- byte 116
    117 => "01010000", -- byte 117
    118 => "01010001", -- byte 118
    119 => "00000101", -- byte 119

    -- lui $R18,10000
    120 => "00111100", -- byte 120
    121 => "00000000", -- byte 121
    122 => "01001000", -- byte 122
    123 => "00100111", -- byte 123

    -- lw $R19,100($R20)
    124 => "10001100", -- byte 124
    125 => "01010000", -- byte 125
    126 => "00000000", -- byte 126
    127 => "00000000", -- byte 127

    -- sw $R21,200($R22)
    128 => "10101100", -- byte 128
    129 => "01011000", -- byte 129
    130 => "00000001", -- byte 130
    131 => "00000000", -- byte 131

    -- j 10000
    132 => "00001000", -- byte 132
    133 => "00001000", -- byte 133
    134 => "00100111", -- byte 134
    135 => "00000000", -- byte 135
	
	-- Data stored (starting at byte 136)
    136 => "11011110", -- DE
    137 => "10101101", -- AD
    138 => "10111110", -- BE
    139 => "11101111", -- EF

    140 => "11001010", -- CA
    141 => "11111110", -- FE
    142 => "10111010", -- BA
    143 => "10111110", -- BE

    144 => "00010010", -- 12
    145 => "00110100", -- 34
    146 => "01010110", -- 56
    147 => "01111000", -- 78

    148 => "00001011", -- 0B
    149 => "10101101", -- AD
    150 => "11110000", -- F0
    151 => "00001101", -- 0D

    -- More data if you want
    152 => "11111111", -- FF
    153 => "00000000", -- 00
    154 => "11111111", -- FF
    155 => "00000000", -- 00

    others => "00000000" -- default for other locations
);

begin

  -- Write process (store 4 bytes)
  process(clk, MemWrite)
  begin
    if rising_edge(clk) and MemWrite = '1' then
      RAM(to_integer(unsigned(Address)))     <= DataIn(31 downto 24); -- byte 0
      RAM(to_integer(unsigned(Address)) + 1) <= DataIn(23 downto 16); -- byte 1
      RAM(to_integer(unsigned(Address)) + 2) <= DataIn(15 downto 8);  -- byte 2
      RAM(to_integer(unsigned(Address)) + 3) <= DataIn(7 downto 0);   -- byte 3
    end if;
  end process;

  -- Read (concatenate 4 bytes)
  DataOut <= RAM(to_integer(unsigned(Address)))     &  -- byte 0
             RAM(to_integer(unsigned(Address)) + 1) &  -- byte 1
             RAM(to_integer(unsigned(Address)) + 2) &  -- byte 2
             RAM(to_integer(unsigned(Address)) + 3)    -- byte 3
             when MemRead = '1' else (others => '0');

end architecture;
