--to (x)=====>x4 ====>shift left
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY shift_left_2 IS
    PORT (
        input : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END shift_left_2;

ARCHITECTURE BEHAV OF shift_left_2 IS
BEGIN
    output <= input(29 DOWNTO 0) & "00";
END BEHAV;