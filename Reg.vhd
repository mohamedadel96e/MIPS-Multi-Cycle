LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY Registers IS
  GENERIC (N : INTEGER := 32);
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    enable : IN STD_LOGIC;
    DataIn : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    DataOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE Behavioral OF Registers IS
BEGIN
  PROCESS (clk, reset, enable)
  BEGIN
    IF reset = '1' THEN
      DataOut <= (OTHERS => '0');
    ELSIF rising_edge(clk) AND enable = '1' THEN
      DataOut <= DataIn;
    END IF;
  END PROCESS;
END Behavioral;