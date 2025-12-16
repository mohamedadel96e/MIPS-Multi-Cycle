LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Sign_Extend IS
  PORT (
    Immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    Extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE Behavioral OF Sign_Extend IS
BEGIN
  -- Extended <= (15 downto 0 => Immediate(15)) & Immediate;
  Extended <= STD_LOGIC_VECTOR(resize(signed(Immediate), 32));
END Behavioral;