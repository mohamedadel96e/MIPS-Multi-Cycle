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
  PROCESS (ALUOp, Funct)
  BEGIN
    CASE ALUOp IS
      WHEN "00" => ALUControl <= "011"; -- LW/SW: ADD
      WHEN "01" => ALUControl <= "100"; -- BEQ: SUB
      WHEN OTHERS =>
        CASE Funct IS
          WHEN "100000" => ALUControl <= "011"; -- ADD
          WHEN "100010" => ALUControl <= "100"; -- SUB
          WHEN "100100" => ALUControl <= "000"; -- AND
          WHEN "100101" => ALUControl <= "001"; -- OR
          WHEN "100110" => ALUControl <= "010"; -- XOR
            -- when "101010" => ALUControl <= "111"; -- SLT (not implemented in ALU)
          WHEN OTHERS => ALUControl <= "011"; -- Default to ADD
        END CASE;
    END CASE;
  END PROCESS;
END Behavioral;