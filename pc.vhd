LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pc IS
  PORT (
    clk: in std_logic;
    reset: in std_logic;
    PCWrite: in std_logic;
    PCIn: in std_logic_vector(31 downto 0);
    PCOut: out std_logic_vector(31 downto 0)
  );
END pc;

ARCHITECTURE Behavioral OF pc IS
  SIGNAL PC : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      PC <= (OTHERS => '0');
    ELSIF rising_edge(clk) AND PCWrite = '1' THEN
      PC <= PCIn;
    END IF;
  END PROCESS;
  PCOut <= PC;
END Behavioral;