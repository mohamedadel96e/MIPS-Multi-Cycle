
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY control_value IS
    PORT (
        opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        RegDst, Branch, MemRead, MemtoReg, MemWrite, AluSrc, RegWrite : OUT STD_LOGIC;
        ALUOp : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END control_value;

ARCHITECTURE BEHAV OF control_value IS
    SIGNAL ctrl_values : STD_LOGIC_VECTOR(8 DOWNTO 0);
BEGIN

    PROCESS (opcode)
    BEGIN
        CASE opcode IS
            WHEN "000000" => ctrl_values <= "100000110"; -- R type  D"0"  
            WHEN "100011" => ctrl_values <= "001101100"; -- lw	 D"35"
            WHEN "101011" => ctrl_values <= "-00-11000"; -- sw	 D"43"
            WHEN "000101" => ctrl_values <= "-10-00001"; -- bneq	 D"5"
            WHEN "000100" => ctrl_values <= "-10-00001"; -- beq	 D"4"
            WHEN "001000" => ctrl_values <= "000001111"; -- addi	 D"8"
            WHEN OTHERS => ctrl_values <= "---------";	 --others
        END CASE;
    END PROCESS;

    RegDst <= ctrl_values(8);
    Branch <= ctrl_values(7);
    MemRead <= ctrl_values(6);
    MemtoReg <= ctrl_values(5);
    MemWrite <= ctrl_values(4);
    AluSrc <= ctrl_values(3);
    RegWrite <= ctrl_values(2);
    ALUOp <= ctrl_values(1 DOWNTO 0);

END BEHAV;