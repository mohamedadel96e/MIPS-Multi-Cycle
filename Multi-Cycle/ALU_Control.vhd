LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU_Control IS
  PORT (
    ALUOp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    Funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    ALUControl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE Behavioral OF ALU_Control IS
BEGIN
  PROCESS(ALUOp, Funct)
  BEGIN
    CASE ALUOp IS
      WHEN "00" => -- LW/SW/ADDI
        ALUControl <= "000"; -- ADD
        
      WHEN "01" => -- BEQ
        ALUControl <= "001"; -- SUB
        
      WHEN "10" => -- R-type
        CASE Funct IS
          WHEN "100000" => ALUControl <= "000"; -- ADD
          WHEN "100010" => ALUControl <= "001"; -- SUB
          WHEN "100100" => ALUControl <= "010"; -- AND
          WHEN "100101" => ALUControl <= "011"; -- OR
          WHEN "100110" => ALUControl <= "100"; -- XOR
          WHEN "101010" => ALUControl <= "111";
          WHEN OTHERS   => ALUControl <= "000"; -- Default ADD
        END CASE;
        
      WHEN OTHERS =>
        ALUControl <= "000"; -- Default ADD
    END CASE;
  END PROCESS;
END ARCHITECTURE;