-- MEM/WB Pipeline Register
-- Stores control signals and data between MEM and WB stages

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY memwb_register IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        -- Control signals input
        MemtoReg_in : IN STD_LOGIC;
        RegWrite_in : IN STD_LOGIC;
        -- Data inputs
        mem_data_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        alu_result_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        write_register_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Control signals output
        MemtoReg_out : OUT STD_LOGIC;
        RegWrite_out : OUT STD_LOGIC;
        -- Data outputs
        mem_data_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        alu_result_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        write_register_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END memwb_register;

ARCHITECTURE BEHAV OF memwb_register IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            -- Reset control signals
            MemtoReg_out <= '0';
            RegWrite_out <= '0';
            -- Reset data signals
            mem_data_out <= (OTHERS => '0');
            alu_result_out <= (OTHERS => '0');
            write_register_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Update control signals
            MemtoReg_out <= MemtoReg_in;
            RegWrite_out <= RegWrite_in;
            -- Update data signals
            mem_data_out <= mem_data_in;
            alu_result_out <= alu_result_in;
            write_register_out <= write_register_in;
        END IF;
    END PROCESS;
END BEHAV;