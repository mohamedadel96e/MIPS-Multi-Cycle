
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY alu_control IS
    PORT (
        ALUOp : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        funct : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        ALU_ctrl : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
    );
END alu_control;

ARCHITECTURE BEHAV OF alu_control IS
BEGIN
    PROCESS (ALUOp, funct)
    BEGIN
        CASE ALUOp IS
            WHEN "00" => ALU_ctrl <= "001"; -- lw / sw	 --addition(10)
            WHEN "01" => ALU_ctrl <= "010"; -- beq	/bneq 	 --sub(01)
            WHEN "11" => ALU_ctrl <= "111"; -- I type
            WHEN OTHERS => -- R type
                CASE funct IS
                    WHEN "100000" => ALU_ctrl <= "001"; -- add (use same as lw/sw addition)
                    WHEN "100010" => ALU_ctrl <= "100"; -- sub
                    WHEN "100100" => ALU_ctrl <= "101"; -- and
                    WHEN "100101" => ALU_ctrl <= "110"; -- or	 
                    WHEN "100111" => ALU_ctrl <= "000"; --NAND
                    WHEN "111000" => ALU_ctrl <= "011"; --set on less than
                    WHEN OTHERS => ALU_ctrl <= "---";
                END CASE;
        END CASE;
    END PROCESS;
END BEHAV;