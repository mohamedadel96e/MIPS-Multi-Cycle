
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY sign_extend IS
    GENERIC (
        nbit_input_width : INTEGER := 16;
        nbit_output_width : INTEGER := 32
    );
    PORT (
        input : IN STD_LOGIC_VECTOR (nbit_input_width - 1 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR (nbit_output_width - 1 DOWNTO 0)
    );
END sign_extend;

ARCHITECTURE BEHAV OF sign_extend IS
BEGIN
    output <= x"0000" & input WHEN input(nbit_input_width - 1) = '0' ELSE
        x"FFFF" & input;
END BEHAV;