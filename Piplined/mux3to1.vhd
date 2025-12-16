-- 3-to-1 Multiplexer for Data Forwarding
-- Selects between:
--   00: Register file output (no forwarding)
--   01: EX/MEM stage output (forward from ALU result)
--   10: MEM/WB stage output (forward from write-back data)

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux3to1 IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        input0 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0); -- From register file
        input1 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0); -- From EX/MEM
        input2 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0); -- From MEM/WB
        output : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
    );
END mux3to1;

ARCHITECTURE BEHAV OF mux3to1 IS
BEGIN
    WITH sel SELECT output <=
        input0 WHEN "00",  -- No forwarding
        input1 WHEN "01",  -- Forward from EX/MEM (ALU result)
        input2 WHEN "10",  -- Forward from MEM/WB (write-back data)
        (OTHERS => '0') WHEN OTHERS;
END BEHAV;
