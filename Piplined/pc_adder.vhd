LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY pc_adder IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        input : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
    );
END pc_adder;

ARCHITECTURE BEHAV OF pc_adder IS
BEGIN
    output <= input + X"00000001";
END BEHAV;