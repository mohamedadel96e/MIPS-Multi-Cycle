-- EX/MEM Pipeline Register
-- Stores control signals, ALU result, and write data between EX and MEM stages

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY exmem_register IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        -- Control signals input
        MemRead_in : IN STD_LOGIC;
        MemWrite_in : IN STD_LOGIC;
        Branch_in : IN STD_LOGIC;
        MemtoReg_in : IN STD_LOGIC;
        RegWrite_in : IN STD_LOGIC;
        -- Data inputs
        branch_target_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        zero_in : IN STD_LOGIC;
        alu_result_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        write_data_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        write_register_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Control signals output
        MemRead_out : OUT STD_LOGIC;
        MemWrite_out : OUT STD_LOGIC;
        Branch_out : OUT STD_LOGIC;
        MemtoReg_out : OUT STD_LOGIC;
        RegWrite_out : OUT STD_LOGIC;
        -- Data outputs
        branch_target_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        zero_out : OUT STD_LOGIC;
        alu_result_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        write_data_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        write_register_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END exmem_register;

ARCHITECTURE BEHAV OF exmem_register IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            -- Reset control signals
            MemRead_out <= '0';
            MemWrite_out <= '0';
            Branch_out <= '0';
            MemtoReg_out <= '0';
            RegWrite_out <= '0';
            -- Reset data signals
            branch_target_out <= (OTHERS => '0');
            zero_out <= '0';
            alu_result_out <= (OTHERS => '0');
            write_data_out <= (OTHERS => '0');
            write_register_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Update control signals
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            Branch_out <= Branch_in;
            MemtoReg_out <= MemtoReg_in;
            RegWrite_out <= RegWrite_in;
            -- Update data signals
            branch_target_out <= branch_target_in;
            zero_out <= zero_in;
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            write_register_out <= write_register_in;
        END IF;
    END PROCESS;
END BEHAV;