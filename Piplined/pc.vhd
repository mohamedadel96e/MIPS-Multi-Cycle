
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pc IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        input : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
    );
END pc;

ARCHITECTURE BEHAV OF PC IS
    SIGNAL sig_output : STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0) := X"00000000";
BEGIN
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            sig_output <= input;
        END IF;
    END PROCESS;
    output <= sig_output;
END BEHAV;