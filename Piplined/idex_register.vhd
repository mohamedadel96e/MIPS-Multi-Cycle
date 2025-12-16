-- ID/EX Pipeline Register
-- Stores control signals, register data, and instruction fields between ID and EX stages

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY idex_register IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        -- Control signals input
        RegDst_in : IN STD_LOGIC;
        ALUSrc_in : IN STD_LOGIC;
        ALUOp_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        MemRead_in : IN STD_LOGIC;
        MemWrite_in : IN STD_LOGIC;
        Branch_in : IN STD_LOGIC;
        MemtoReg_in : IN STD_LOGIC;
        RegWrite_in : IN STD_LOGIC;
        -- Data inputs
        pc_plus4_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        read_data1_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        read_data2_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        sign_extend_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        rt_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Control signals output
        RegDst_out : OUT STD_LOGIC;
        ALUSrc_out : OUT STD_LOGIC;
        ALUOp_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        MemRead_out : OUT STD_LOGIC;
        MemWrite_out : OUT STD_LOGIC;
        Branch_out : OUT STD_LOGIC;
        MemtoReg_out : OUT STD_LOGIC;
        RegWrite_out : OUT STD_LOGIC;
        -- Data outputs
        pc_plus4_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        read_data1_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        read_data2_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        sign_extend_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        rt_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END idex_register;

ARCHITECTURE BEHAV OF idex_register IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            -- Reset control signals
            RegDst_out <= '0';
            ALUSrc_out <= '0';
            ALUOp_out <= (OTHERS => '0');
            MemRead_out <= '0';
            MemWrite_out <= '0';
            Branch_out <= '0';
            MemtoReg_out <= '0';
            RegWrite_out <= '0';
            -- Reset data signals
            pc_plus4_out <= (OTHERS => '0');
            read_data1_out <= (OTHERS => '0');
            read_data2_out <= (OTHERS => '0');
            sign_extend_out <= (OTHERS => '0');
            rt_out <= (OTHERS => '0');
            rd_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Update control signals
            RegDst_out <= RegDst_in;
            ALUSrc_out <= ALUSrc_in;
            ALUOp_out <= ALUOp_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            Branch_out <= Branch_in;
            MemtoReg_out <= MemtoReg_in;
            RegWrite_out <= RegWrite_in;
            -- Update data signals
            pc_plus4_out <= pc_plus4_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            sign_extend_out <= sign_extend_in;
            rt_out <= rt_in;
            rd_out <= rd_in;
        END IF;
    END PROCESS;
END BEHAV;