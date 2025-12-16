-- 5-Stage Pipelined MIPS Processor
-- Implements IF, ID, EX, MEM, WB stages with pipeline registers

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pipelined_mips IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC
    );
END pipelined_mips;

ARCHITECTURE BEHAV OF pipelined_mips IS

    -- Component declarations
    COMPONENT pc
        PORT (
            clk : IN STD_LOGIC;
            input : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT pc_adder
        PORT (
            input : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT branch_adder
        PORT (
            pc_plus4 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            branch_offset : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            branch_target : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT instruction_memory
        PORT (
            address : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            instruction : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT control_unit
        PORT (
            opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            RegDst : OUT STD_LOGIC;
            Branch : OUT STD_LOGIC;
            MemRead : OUT STD_LOGIC;
            MemtoReg : OUT STD_LOGIC;
            MemWrite : OUT STD_LOGIC;
            ALUSrc : OUT STD_LOGIC;
            RegWrite : OUT STD_LOGIC;
            ALUOp : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Jump : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT register_file
        PORT (
            clk : IN STD_LOGIC;
            read_register1, read_register2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            write_register : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            write_data : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            register_write_ctrl : IN STD_LOGIC;
            read_data1, read_data2 : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sign_extend
        PORT (
            input : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT shift_left_2
        PORT (
            input : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT alu
        PORT (
            opcode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            input1, input2 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            zero : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT data_memory
        PORT (
            clk : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            write_data : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            memory_write_ctrl, memory_read_ctrl : IN STD_LOGIC;
            read_data : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux
        GENERIC (
            nbit_width : INTEGER := 32
        );
        PORT (
            sel : IN STD_LOGIC;
            input0, input1 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- Pipeline Register components
    COMPONENT ifid_register
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            pc_plus4_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            instruction_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            pc_plus4_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            instruction_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT idex_register
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            RegDst_in : IN STD_LOGIC;
            ALUSrc_in : IN STD_LOGIC;
            ALUOp_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            MemRead_in : IN STD_LOGIC;
            MemWrite_in : IN STD_LOGIC;
            Branch_in : IN STD_LOGIC;
            MemtoReg_in : IN STD_LOGIC;
            RegWrite_in : IN STD_LOGIC;
            pc_plus4_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            read_data1_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            sign_extend_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            rt_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            rd_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            RegDst_out : OUT STD_LOGIC;
            ALUSrc_out : OUT STD_LOGIC;
            ALUOp_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            MemRead_out : OUT STD_LOGIC;
            MemWrite_out : OUT STD_LOGIC;
            Branch_out : OUT STD_LOGIC;
            MemtoReg_out : OUT STD_LOGIC;
            RegWrite_out : OUT STD_LOGIC;
            pc_plus4_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            read_data1_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            read_data2_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            sign_extend_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            rt_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            rd_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT exmem_register
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            MemRead_in : IN STD_LOGIC;
            MemWrite_in : IN STD_LOGIC;
            Branch_in : IN STD_LOGIC;
            MemtoReg_in : IN STD_LOGIC;
            RegWrite_in : IN STD_LOGIC;
            branch_target_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            zero_in : IN STD_LOGIC;
            alu_result_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            write_data_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            write_register_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            MemRead_out : OUT STD_LOGIC;
            MemWrite_out : OUT STD_LOGIC;
            Branch_out : OUT STD_LOGIC;
            MemtoReg_out : OUT STD_LOGIC;
            RegWrite_out : OUT STD_LOGIC;
            branch_target_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            zero_out : OUT STD_LOGIC;
            alu_result_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            write_data_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            write_register_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT memwb_register
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            MemtoReg_in : IN STD_LOGIC;
            RegWrite_in : IN STD_LOGIC;
            mem_data_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            alu_result_in : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            write_register_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            MemtoReg_out : OUT STD_LOGIC;
            RegWrite_out : OUT STD_LOGIC;
            mem_data_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            alu_result_out : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
            write_register_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    -- ====== IF Stage Signals ======
    SIGNAL pc_input, pc_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_plus4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL instruction_if : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- ====== IF/ID Pipeline Register Signals ======
    SIGNAL ifid_pc_plus4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ifid_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- ====== ID Stage Signals ======
    SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL funct : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL rs, rt, rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL read_data1_id, read_data2_id : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sign_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Control signals in ID
    SIGNAL RegDst_id, Branch_id, MemRead_id, MemtoReg_id : STD_LOGIC;
    SIGNAL MemWrite_id, ALUSrc_id, RegWrite_id, Jump_id : STD_LOGIC;
    SIGNAL ALUOp_id : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- ====== ID/EX Pipeline Register Signals ======
    SIGNAL idex_RegDst, idex_ALUSrc, idex_MemRead, idex_MemWrite : STD_LOGIC;
    SIGNAL idex_Branch, idex_MemtoReg, idex_RegWrite : STD_LOGIC;
    SIGNAL idex_ALUOp : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL idex_pc_plus4, idex_read_data1, idex_read_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL idex_sign_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL idex_rt, idex_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- ====== EX Stage Signals ======
    SIGNAL alu_input2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_result_ex : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL zero_ex : STD_LOGIC;
    SIGNAL write_register_ex : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL branch_target_ex : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL shift_output : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- ====== EX/MEM Pipeline Register Signals ======
    SIGNAL exmem_MemRead, exmem_MemWrite, exmem_Branch : STD_LOGIC;
    SIGNAL exmem_MemtoReg, exmem_RegWrite, exmem_zero : STD_LOGIC;
    SIGNAL exmem_branch_target, exmem_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL exmem_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL exmem_write_register : STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- ====== MEM Stage Signals ======
    SIGNAL mem_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PCSrc : STD_LOGIC;
    SIGNAL branch_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- ====== MEM/WB Pipeline Register Signals ======
    SIGNAL memwb_MemtoReg, memwb_RegWrite : STD_LOGIC;
    SIGNAL memwb_mem_data, memwb_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL memwb_write_register : STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- ====== WB Stage Signals ======
    SIGNAL write_back_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL jump_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_from_branch : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    -- ========================================
    -- STAGE 1: Instruction Fetch (IF)
    -- ========================================

    U_PC : pc PORT MAP(
        clk => clk,
        input => pc_input,
        output => pc_output
    );

    U_instruction_memory : instruction_memory PORT MAP(
        address => pc_output,
        instruction => instruction_if
    );

    U_pc_adder : pc_adder PORT MAP(
        input => pc_output,
        output => pc_plus4
    );

    -- Jump address calculation (concatenate pc_plus4[31:28] with instruction[25:0] << 2)
    jump_address <= ifid_pc_plus4(31 DOWNTO 28) & ifid_instruction(25 DOWNTO 0) & "00";

    -- PC source mux for branch
    U_mux_branch : mux GENERIC MAP(nbit_width => 32)
    PORT MAP(
        sel => PCSrc,
        input0 => pc_plus4,
        input1 => exmem_branch_target,
        output => pc_from_branch
    );

    -- PC source mux for jump
    U_mux_jump : mux GENERIC MAP(nbit_width => 32)
    PORT MAP(
        sel => Jump_id,
        input0 => pc_from_branch,
        input1 => jump_address,
        output => pc_input
    );

    -- ========================================
    -- IF/ID Pipeline Register
    -- ========================================

    U_IFID_register : ifid_register PORT MAP(
        clk => clk,
        reset => reset,
        pc_plus4_in => pc_plus4,
        instruction_in => instruction_if,
        pc_plus4_out => ifid_pc_plus4,
        instruction_out => ifid_instruction
    );

    -- ========================================
    -- STAGE 2: Instruction Decode (ID)
    -- ========================================

    -- Decode instruction fields
    opcode <= ifid_instruction(31 DOWNTO 26);
    rs <= ifid_instruction(25 DOWNTO 21);
    rt <= ifid_instruction(20 DOWNTO 16);
    rd <= ifid_instruction(15 DOWNTO 11);
    funct <= ifid_instruction(5 DOWNTO 0);
    immediate <= ifid_instruction(15 DOWNTO 0);

    U_control_unit : control_unit PORT MAP(
        opcode => opcode,
        funct => funct,
        RegDst => RegDst_id,
        Branch => Branch_id,
        MemRead => MemRead_id,
        MemtoReg => MemtoReg_id,
        MemWrite => MemWrite_id,
        ALUSrc => ALUSrc_id,
        RegWrite => RegWrite_id,
        ALUOp => ALUOp_id,
        Jump => Jump_id
    );

    U_register_file : register_file PORT MAP(
        clk => clk,
        register_write_ctrl => memwb_RegWrite,
        read_register1 => rs,
        read_register2 => rt,
        write_register => memwb_write_register,
        read_data1 => read_data1_id,
        read_data2 => read_data2_id,
        write_data => write_back_data
    );

    U_sign_extend : sign_extend PORT MAP(
        input => immediate,
        output => sign_extended
    );

    -- ========================================
    -- ID/EX Pipeline Register
    -- ========================================

    U_IDEX_register : idex_register PORT MAP(
        clk => clk,
        reset => reset,
        -- Control signals
        RegDst_in => RegDst_id,
        ALUSrc_in => ALUSrc_id,
        ALUOp_in => ALUOp_id,
        MemRead_in => MemRead_id,
        MemWrite_in => MemWrite_id,
        Branch_in => Branch_id,
        MemtoReg_in => MemtoReg_id,
        RegWrite_in => RegWrite_id,
        -- Data
        pc_plus4_in => ifid_pc_plus4,
        read_data1_in => read_data1_id,
        read_data2_in => read_data2_id,
        sign_extend_in => sign_extended,
        rt_in => rt,
        rd_in => rd,
        -- Outputs
        RegDst_out => idex_RegDst,
        ALUSrc_out => idex_ALUSrc,
        ALUOp_out => idex_ALUOp,
        MemRead_out => idex_MemRead,
        MemWrite_out => idex_MemWrite,
        Branch_out => idex_Branch,
        MemtoReg_out => idex_MemtoReg,
        RegWrite_out => idex_RegWrite,
        pc_plus4_out => idex_pc_plus4,
        read_data1_out => idex_read_data1,
        read_data2_out => idex_read_data2,
        sign_extend_out => idex_sign_extended,
        rt_out => idex_rt,
        rd_out => idex_rd
    );

    -- ========================================
    -- STAGE 3: Execute (EX)
    -- ========================================

    -- ALU source mux (register or immediate)
    U_mux_alusrc : mux GENERIC MAP(nbit_width => 32)
    PORT MAP(
        sel => idex_ALUSrc,
        input0 => idex_read_data2,
        input1 => idex_sign_extended,
        output => alu_input2
    );

    U_alu : alu PORT MAP(
        opcode => idex_ALUOp,
        input1 => idex_read_data1,
        input2 => alu_input2,
        result => alu_result_ex,
        zero => zero_ex
    );

    -- Register destination mux (rt or rd)
    U_mux_regdst : mux GENERIC MAP(nbit_width => 5)
    PORT MAP(
        sel => idex_RegDst,
        input0 => idex_rt,
        input1 => idex_rd,
        output => write_register_ex
    );

    -- Branch target address calculation
    U_shift_left_2 : shift_left_2 PORT MAP(
        input => idex_sign_extended,
        output => shift_output
    );

    U_branch_adder : branch_adder PORT MAP(
        pc_plus4 => idex_pc_plus4,
        branch_offset => shift_output,
        branch_target => branch_target_ex
    );

    -- ========================================
    -- EX/MEM Pipeline Register
    -- ========================================

    U_EXMEM_register : exmem_register PORT MAP(
        clk => clk,
        reset => reset,
        -- Control signals
        MemRead_in => idex_MemRead,
        MemWrite_in => idex_MemWrite,
        Branch_in => idex_Branch,
        MemtoReg_in => idex_MemtoReg,
        RegWrite_in => idex_RegWrite,
        -- Data
        branch_target_in => branch_target_ex,
        zero_in => zero_ex,
        alu_result_in => alu_result_ex,
        write_data_in => idex_read_data2,
        write_register_in => write_register_ex,
        -- Outputs
        MemRead_out => exmem_MemRead,
        MemWrite_out => exmem_MemWrite,
        Branch_out => exmem_Branch,
        MemtoReg_out => exmem_MemtoReg,
        RegWrite_out => exmem_RegWrite,
        branch_target_out => exmem_branch_target,
        zero_out => exmem_zero,
        alu_result_out => exmem_alu_result,
        write_data_out => exmem_write_data,
        write_register_out => exmem_write_register
    );

    -- ========================================
    -- STAGE 4: Memory Access (MEM)
    -- ========================================

    U_data_memory : data_memory PORT MAP(
        clk => clk,
        address => exmem_alu_result,
        write_data => exmem_write_data,
        memory_write_ctrl => exmem_MemWrite,
        memory_read_ctrl => exmem_MemRead,
        read_data => mem_data_out
    );

    -- Branch decision (Branch AND Zero)
    PCSrc <= exmem_Branch AND exmem_zero;

    -- ========================================
    -- MEM/WB Pipeline Register
    -- ========================================

    U_MEMWB_register : memwb_register PORT MAP(
        clk => clk,
        reset => reset,
        -- Control signals
        MemtoReg_in => exmem_MemtoReg,
        RegWrite_in => exmem_RegWrite,
        -- Data
        mem_data_in => mem_data_out,
        alu_result_in => exmem_alu_result,
        write_register_in => exmem_write_register,
        -- Outputs
        MemtoReg_out => memwb_MemtoReg,
        RegWrite_out => memwb_RegWrite,
        mem_data_out => memwb_mem_data,
        alu_result_out => memwb_alu_result,
        write_register_out => memwb_write_register
    );

    -- ========================================
    -- STAGE 5: Write Back (WB)
    -- ========================================

    -- MemtoReg mux (memory data or ALU result)
    U_mux_memtoreg : mux GENERIC MAP(nbit_width => 32)
    PORT MAP(
        sel => memwb_MemtoReg,
        input0 => memwb_alu_result,
        input1 => memwb_mem_data,
        output => write_back_data
    );

END BEHAV;