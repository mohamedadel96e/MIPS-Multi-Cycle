LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pc IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    PCWrite : IN STD_LOGIC;
    PCIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    PCOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END pc;

ARCHITECTURE Behavioral OF pc IS

BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      PCOut <= (OTHERS => '0');
    ELSIF rising_edge(clk) AND PCWrite = '1' THEN
      PCOut <= PCIn;
    END IF;
  END PROCESS;
END Behavioral;