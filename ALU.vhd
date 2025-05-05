LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
  PORT (
    ALUControl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ALUResult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Zero : OUT STD_LOGIC
  );

END ENTITY;
ARCHITECTURE Behavioral OF ALU IS
  SIGNAL Result : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
  PROCESS (A, B, ALUControl)
  BEGIN
    CASE ALUControl IS
      WHEN "000" => Result <= STD_LOGIC_VECTOR(signed(A) + signed(B));
      WHEN "001" => Result <= STD_LOGIC_VECTOR(signed(A) - signed(B));
      WHEN "010" => Result <= A AND B;
      WHEN "011" => Result <= A OR B;
      WHEN "100" => Result <= A XOR B;
      -- WHEN "111" => Result <= (OTHERS => '0');
      --   IF signed(A) < signed(B) THEN
      --     Result(0) <= '1';
      --   END IF;
      WHEN OTHERS => Result <= (OTHERS => '0');
    END CASE;
  END PROCESS;
  ALUResult <= Result;
  Zero <= '1' WHEN Result = (31 DOWNTO 0 => '0') ELSE
    '0';
END ARCHITECTURE;