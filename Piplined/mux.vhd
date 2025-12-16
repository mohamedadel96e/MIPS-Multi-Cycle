
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        sel : IN STD_LOGIC;
        input0, input1 : IN STD_LOGIC_VECTOR (nbit_width - 1 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR (nbit_width - 1 DOWNTO 0)
    );
END mux;

ARCHITECTURE BEHAV OF mux IS
BEGIN
    output <= input0 WHEN (sel = '0') ELSE
        input1;
END BEHAV;