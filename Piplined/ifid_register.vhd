-- IF/ID Pipeline Register
-- Stores instruction and PC+4 between IF and ID stages

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ifid_register IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        -- Inputs from IF stage
        pc_plus4_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        instruction_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        -- Outputs to ID stage
        pc_plus4_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        instruction_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
    );
END ifid_register;

ARCHITECTURE BEHAV OF ifid_register IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            pc_plus4_out <= (OTHERS => '0');
            instruction_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            pc_plus4_out <= pc_plus4_in;
            instruction_out <= instruction_in;
        END IF;
    END PROCESS;
END BEHAV;