
LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY instruction_memory IS

    GENERIC (
        nbit_width : INTEGER := 32
    );

    PORT (

        address : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);

        instruction : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)

    );
END instruction_memory;
ARCHITECTURE BEHAV OF instruction_memory IS
    TYPE memory_instr IS ARRAY(0 TO 39) OF STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
    SIGNAL sig_memory_instr : memory_instr :=
    (
    -- ===== Section 1: Basic Instructions (No Hazards) =====
    X"20010005", -- 0:  addi $1, $0, 5        # $1 = 5
    X"20020003", -- 1:  addi $2, $0, 3        # $2 = 3
    X"20030007", -- 2:  addi $3, $0, 7        # $3 = 7
    X"2004000A", -- 3:  addi $4, $0, 10       # $4 = 10
    
    -- ===== Section 2: EX Hazard - Back-to-Back Dependencies =====
    X"00221820", -- 4:  add $3, $1, $2        # $3 = $1 + $2 = 5 + 3 = 8 (EX Hazard for next)
    X"00232020", -- 5:  add $4, $1, $3        # $4 = $1 + $3 = 5 + 8 = 13 (needs forwarding from inst 4)
    X"00443022", -- 6:  sub $6, $2, $4        # $6 = $2 - $4 = 3 - 13 = -10 (needs forwarding from inst 5)
    
    -- ===== Section 3: MEM Hazard - 1 Instruction Gap =====
    X"20050014", -- 7:  addi $5, $0, 20       # $5 = 20
    X"00000000", -- 8:  nop                   # No operation
    X"00A53820", -- 9:  add $7, $5, $5        # $7 = $5 + $5 = 20 + 20 = 40 (MEM hazard from inst 7)
    
    -- ===== Section 4: Load-Use Hazard =====
    X"8C080004", -- 10: lw $8, 4($0)          # $8 = mem[4]
    X"8C090005", -- 11: lw $9, 5($0)          # $9 = mem[5]
    X"01095020", -- 12: add $10, $8, $9       # $10 = $8 + $9 (load-use hazard)
    
    -- ===== Section 5: Store with Forwarding =====
    X"200B0064", -- 13: addi $11, $0, 100     # $11 = 100
    X"AC0B0006", -- 14: sw $11, 6($0)         # mem[6] = $11 (needs forwarding for store data)
    
    -- ===== Section 6: Multiple Dependencies =====
    X"200C0001", -- 15: addi $12, $0, 1       # $12 = 1
    X"218C0002", -- 16: addi $12, $12, 2      # $12 = $12 + 2 = 3 (RAW hazard)
    X"218C0003", -- 17: addi $12, $12, 3      # $12 = $12 + 3 = 6 (RAW hazard)
    X"218C0004", -- 18: addi $12, $12, 4      # $12 = $12 + 4 = 10 (RAW hazard)
    
    -- ===== Section 7: R-Type Instructions Testing =====
    X"200D000F", -- 19: addi $13, $0, 15      # $13 = 15
    X"200E000F", -- 20: addi $14, $0, 15      # $14 = 15
    X"01AE7824", -- 21: and $15, $13, $14     # $15 = $13 & $14 = 15 & 15 = 15
    X"01AE8025", -- 22: or $16, $13, $14      # $16 = $13 | $14 = 15 | 15 = 15
    X"01AE8827", -- 23: nor $17, $13, $14     # $17 = ~($13 | $14)
    
    -- ===== Section 8: Set Less Than (SLT) =====
    X"20120005", -- 24: addi $18, $0, 5       # $18 = 5
    X"2013000A", -- 25: addi $19, $0, 10      # $19 = 10
    X"0253A02A", -- 26: slt $20, $18, $19     # $20 = ($18 < $19) = 1 (5 < 10)
    X"0272A82A", -- 27: slt $21, $19, $18     # $21 = ($19 < $18) = 0 (10 < 5)
    
    -- ===== Section 9: Complex Forwarding Scenario =====
    X"20160001", -- 28: addi $22, $0, 1       # $22 = 1
    X"22D60002", -- 29: addi $22, $22, 2      # $22 = 3 (EX hazard)
    X"02D6B820", -- 30: add $23, $22, $22     # $23 = $22 + $22 = 6 (double EX hazard)
    X"02F7C020", -- 31: add $24, $23, $23     # $24 = $23 + $23 = 12 (EX hazard)
    
    -- ===== Section 10: Branch Testing =====
    X"201900FF", -- 32: addi $25, $0, 255     # $25 = 255
    X"201A00FF", -- 33: addi $26, $0, 255     # $26 = 255
    X"1339FFFF", -- 34: beq $25, $26, -1      # if ($25 == $26) branch (should branch)
    X"00000000", -- 35: nop                   # No operation
    
    -- ===== Section 11: Additional Store/Load =====
    X"201B0032", -- 36: addi $27, $0, 50      # $27 = 50
    X"AC1B0007", -- 37: sw $27, 7($0)         # mem[7] = $27 = 50
    X"8C1C0007", -- 38: lw $28, 7($0)         # $28 = mem[7] = 50
    X"239C0001"  -- 39: addi $28, $28, 1      # $28 = $28 + 1 = 51 (load-use hazard)
    );

BEGIN
    PROCESS (address)

    BEGIN
        instruction <= sig_memory_instr(to_integer(unsigned(address)));
    END PROCESS;

END BEHAV;