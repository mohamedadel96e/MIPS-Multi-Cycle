-- Branch Adder Component
-- Adds PC+4 with shifted branch offset

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY branch_adder IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        pc_plus4 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        branch_offset : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        branch_target : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
    );
END branch_adder;

ARCHITECTURE BEHAV OF branch_adder IS
BEGIN
    branch_target <= pc_plus4 + branch_offset;
END BEHAV;