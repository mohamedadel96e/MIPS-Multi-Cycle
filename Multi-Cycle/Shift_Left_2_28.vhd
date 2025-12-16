LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Shift_Left_2_28 IS
  PORT (
    input : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
    output : OUT STD_LOGIC_VECTOR(27 DOWNTO 0));
END Shift_Left_2_28;

ARCHITECTURE behavior OF Shift_Left_2_28 IS
BEGIN
  output <= input & "00";
END behavior;