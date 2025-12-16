-- Forwarding Unit for Data Hazard Detection
-- Detects when previous instructions will write to registers that current instruction reads
-- Generates control signals for forwarding muxes to bypass register file reads

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY forwarding_unit IS
    PORT (
        -- Source registers from ID/EX stage (current instruction in EX)
        idex_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        idex_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        
        -- Destination register from EX/MEM stage (previous instruction)
        exmem_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        exmem_RegWrite : IN STD_LOGIC;
        
        -- Destination register from MEM/WB stage (instruction before previous)
        memwb_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        memwb_RegWrite : IN STD_LOGIC;
        
        -- Forwarding control outputs
        forwardA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Controls mux for ALU input A
        forwardB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)  -- Controls mux for ALU input B
    );
END forwarding_unit;

ARCHITECTURE BEHAV OF forwarding_unit IS
BEGIN
    PROCESS (idex_rs, idex_rt, exmem_rd, exmem_RegWrite, memwb_rd, memwb_RegWrite)
    BEGIN
        -- Default: No forwarding (00 = use register file output)
        forwardA <= "00";
        forwardB <= "00";
        
        -- Forwarding for ALU input A (Rs)
        -- EX hazard: Forward from EX/MEM stage (priority 1)
        IF (exmem_RegWrite = '1' AND exmem_rd /= "00000" AND exmem_rd = idex_rs) THEN
            forwardA <= "01"; -- Forward from EX/MEM (ALU result)
        -- MEM hazard: Forward from MEM/WB stage (priority 2)
        ELSIF (memwb_RegWrite = '1' AND memwb_rd /= "00000" AND memwb_rd = idex_rs) THEN
            forwardA <= "10"; -- Forward from MEM/WB (write-back data)
        END IF;
        
        -- Forwarding for ALU input B (Rt)
        -- EX hazard: Forward from EX/MEM stage (priority 1)
        IF (exmem_RegWrite = '1' AND exmem_rd /= "00000" AND exmem_rd = idex_rt) THEN
            forwardB <= "01"; -- Forward from EX/MEM (ALU result)
        -- MEM hazard: Forward from MEM/WB stage (priority 2)
        ELSIF (memwb_RegWrite = '1' AND memwb_rd /= "00000" AND memwb_rd = idex_rt) THEN
            forwardB <= "10"; -- Forward from MEM/WB (write-back data)
        END IF;
    END PROCESS;
END BEHAV;
