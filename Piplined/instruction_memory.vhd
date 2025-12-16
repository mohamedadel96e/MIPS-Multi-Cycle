
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
    TYPE memory_instr IS ARRAY(0 TO 17) OF STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
    --addi,sub,or,and ,lw,sw ,Nand,slt ,beq
    SIGNAL sig_memory_instr : memory_instr :=
    (
    X"8c020002", --lw $2, 2($0)   ->  $2 = data_mem[2]	 
    X"8CC10000", --lw $1, 0($6)  
    X"8CA20000", --lw $2, 0($5)  
    X"8c010001", --lw $1, 1($0)   ->  $1 = data_mem[1]
    X"20050002", --addi $5, $0, 2	
    X"ACA40000", --sw $4,0($5)	
    X"20060001", -- addi $6, $0, 1
    X"20A50001", --addi $5, $5, 1
    X"20C60001", --addi $6, $6, 1	  
    X"20030014", --addi $3, $0, 20 (loop count : $3 = 20)
    X"00412020", --R_Type : add $4, $2, $1
    X"00253022", -- R_Type :sub $6,$1,$5 
    X"00876824", -- R_Type:and : $13,$4, &7  
    X"00876827", -- R_Type:Nand : $13,$4, &7  
    X"00242825", --R_Type:or:$1,$4,$5 
    X"00432038", --R_type :slt :$4,$2,$3	 
    --what happen if ($1 notEqual $4)   =====>  sig_zero=>'0' ======>andGate not active ======> if codition achive that
    X"10240002", --beq $1,$s4,2
    X"114B0001" --beq $10,$s11,1 
    --X"1460FFF8"   --bne $3,$0,-8
    );

BEGIN
    PROCESS (address)

    BEGIN
        instruction <= sig_memory_instr(to_integer(unsigned(address)));
    END PROCESS;

END BEHAV;