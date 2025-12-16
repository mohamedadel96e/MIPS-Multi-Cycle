-- 5-Stage Pipelined MIPS Processor (Condensed)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pipelined_mips IS
    GENERIC (nbit_width : INTEGER := 32);
    PORT (clk, reset : IN STD_LOGIC);
END pipelined_mips;

ARCHITECTURE BEHAV OF pipelined_mips IS

    COMPONENT pc PORT (clk : IN STD_LOGIC; reset : IN STD_LOGIC; input : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); output : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT pc_adder PORT (input : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); output : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT branch_adder PORT (pc_plus4, branch_offset : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); branch_target : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT instruction_memory PORT (address : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); instruction : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT control_unit PORT (opcode, funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0); RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jump : OUT STD_LOGIC; ALUOp : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)); END COMPONENT;
    COMPONENT register_file PORT (clk : IN STD_LOGIC; read_register1, read_register2, write_register : IN STD_LOGIC_VECTOR(4 DOWNTO 0); write_data : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); register_write_ctrl : IN STD_LOGIC; read_data1, read_data2 : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT sign_extend PORT (input : IN STD_LOGIC_VECTOR(15 DOWNTO 0); output : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT shift_left_2 PORT (input : IN STD_LOGIC_VECTOR(31 DOWNTO 0); output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); END COMPONENT;
    COMPONENT alu PORT (opcode : IN STD_LOGIC_VECTOR(2 DOWNTO 0); input1, input2 : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); result : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); zero : OUT STD_LOGIC); END COMPONENT;
    COMPONENT data_memory PORT (clk : IN STD_LOGIC; address, write_data : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); memory_write_ctrl, memory_read_ctrl : IN STD_LOGIC; read_data : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT mux GENERIC (nbit_width : INTEGER := 32); PORT (sel : IN STD_LOGIC; input0, input1 : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); output : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT mux3to1 GENERIC (nbit_width : INTEGER := 32); PORT (sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0); input0, input1, input2 : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); output : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT forwarding_unit PORT (idex_rs, idex_rt, exmem_rd, memwb_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0); exmem_RegWrite, memwb_RegWrite : IN STD_LOGIC; forwardA, forwardB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)); END COMPONENT;
    COMPONENT ifid_register PORT (clk, reset : IN STD_LOGIC; pc_plus4_in, instruction_in : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); pc_plus4_out, instruction_out : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0)); END COMPONENT;
    COMPONENT idex_register PORT (clk, reset : IN STD_LOGIC; RegDst_in, ALUSrc_in, MemRead_in, MemWrite_in, Branch_in, MemtoReg_in, RegWrite_in : IN STD_LOGIC; ALUOp_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0); pc_plus4_in, read_data1_in, read_data2_in, sign_extend_in : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); rs_in, rt_in, rd_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0); RegDst_out, ALUSrc_out, MemRead_out, MemWrite_out, Branch_out, MemtoReg_out, RegWrite_out : OUT STD_LOGIC; ALUOp_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); pc_plus4_out, read_data1_out, read_data2_out, sign_extend_out : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); rs_out, rt_out, rd_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)); END COMPONENT;
    COMPONENT exmem_register PORT (clk, reset : IN STD_LOGIC; MemRead_in, MemWrite_in, Branch_in, MemtoReg_in, RegWrite_in : IN STD_LOGIC; branch_target_in, alu_result_in, write_data_in : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); zero_in : IN STD_LOGIC; write_register_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0); MemRead_out, MemWrite_out, Branch_out, MemtoReg_out, RegWrite_out : OUT STD_LOGIC; branch_target_out, alu_result_out, write_data_out : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); zero_out : OUT STD_LOGIC; write_register_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)); END COMPONENT;
    COMPONENT memwb_register PORT (clk, reset : IN STD_LOGIC; MemtoReg_in, RegWrite_in : IN STD_LOGIC; mem_data_in, alu_result_in : IN STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); write_register_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0); MemtoReg_out, RegWrite_out : OUT STD_LOGIC; mem_data_out, alu_result_out : OUT STD_LOGIC_VECTOR(nbit_width-1 DOWNTO 0); write_register_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)); END COMPONENT;

    -- IF Stage
    SIGNAL pc_input, pc_output, pc_plus4, instruction_if : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    -- IF/ID
    SIGNAL ifid_pc_plus4, ifid_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- ID Stage
    SIGNAL opcode, funct : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL rs, rt, rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL read_data1_id, read_data2_id, sign_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL RegDst_id, Branch_id, MemRead_id, MemtoReg_id, MemWrite_id, ALUSrc_id, RegWrite_id, Jump_id : STD_LOGIC;
    SIGNAL ALUOp_id : STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- ID/EX
    SIGNAL idex_RegDst, idex_ALUSrc, idex_MemRead, idex_MemWrite, idex_Branch, idex_MemtoReg, idex_RegWrite : STD_LOGIC;
    SIGNAL idex_ALUOp : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL idex_pc_plus4, idex_read_data1, idex_read_data2, idex_sign_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL idex_rs, idex_rt, idex_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    -- EX Stage
    SIGNAL alu_input1, alu_input2, alu_result_ex, branch_target_ex, shift_output, forwarded_data1, forwarded_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL zero_ex : STD_LOGIC;
    SIGNAL write_register_ex : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL forwardA, forwardB : STD_LOGIC_VECTOR(1 DOWNTO 0);
    -- EX/MEM
    SIGNAL exmem_MemRead, exmem_MemWrite, exmem_Branch, exmem_MemtoReg, exmem_RegWrite, exmem_zero : STD_LOGIC;
    SIGNAL exmem_branch_target, exmem_alu_result, exmem_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL exmem_write_register : STD_LOGIC_VECTOR(4 DOWNTO 0);
    -- MEM Stage
    SIGNAL mem_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PCSrc : STD_LOGIC;
    SIGNAL branch_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- MEM/WB
    SIGNAL memwb_MemtoReg, memwb_RegWrite : STD_LOGIC;
    SIGNAL memwb_mem_data, memwb_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL memwb_write_register : STD_LOGIC_VECTOR(4 DOWNTO 0);
    -- WB
    SIGNAL write_back_data, jump_address, pc_from_branch : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    -- IF
    U_PC: pc PORT MAP(clk=>clk, reset=>reset, input=>pc_input, output=>pc_output);
    U_instruction_memory: instruction_memory PORT MAP(address=>pc_output, instruction=>instruction_if);
    U_pc_adder: pc_adder PORT MAP(input=>pc_output, output=>pc_plus4);
    jump_address <= ifid_pc_plus4(31 DOWNTO 28) & ifid_instruction(25 DOWNTO 0) & "00";
    U_mux_branch: mux GENERIC MAP(nbit_width=>32) PORT MAP(sel=>PCSrc, input0=>pc_plus4, input1=>exmem_branch_target, output=>pc_from_branch);
    U_mux_jump: mux GENERIC MAP(nbit_width=>32) PORT MAP(sel=>Jump_id, input0=>pc_from_branch, input1=>jump_address, output=>pc_input);

    -- IF/ID
    U_IFID_register: ifid_register PORT MAP(clk=>clk, reset=>reset, pc_plus4_in=>pc_plus4, instruction_in=>instruction_if, pc_plus4_out=>ifid_pc_plus4, instruction_out=>ifid_instruction);

    -- ID
    opcode <= ifid_instruction(31 DOWNTO 26); rs <= ifid_instruction(25 DOWNTO 21); rt <= ifid_instruction(20 DOWNTO 16); rd <= ifid_instruction(15 DOWNTO 11); funct <= ifid_instruction(5 DOWNTO 0); immediate <= ifid_instruction(15 DOWNTO 0);
    U_control_unit: control_unit PORT MAP(opcode=>opcode, funct=>funct, RegDst=>RegDst_id, Branch=>Branch_id, MemRead=>MemRead_id, MemtoReg=>MemtoReg_id, MemWrite=>MemWrite_id, ALUSrc=>ALUSrc_id, RegWrite=>RegWrite_id, ALUOp=>ALUOp_id, Jump=>Jump_id);
    U_register_file: register_file PORT MAP(clk=>clk, register_write_ctrl=>memwb_RegWrite, read_register1=>rs, read_register2=>rt, write_register=>memwb_write_register, read_data1=>read_data1_id, read_data2=>read_data2_id, write_data=>write_back_data);
    U_sign_extend: sign_extend PORT MAP(input=>immediate, output=>sign_extended);

    -- ID/EX
    U_IDEX_register: idex_register PORT MAP(clk=>clk, reset=>reset, RegDst_in=>RegDst_id, ALUSrc_in=>ALUSrc_id, ALUOp_in=>ALUOp_id, MemRead_in=>MemRead_id, MemWrite_in=>MemWrite_id, Branch_in=>Branch_id, MemtoReg_in=>MemtoReg_id, RegWrite_in=>RegWrite_id, pc_plus4_in=>ifid_pc_plus4, read_data1_in=>read_data1_id, read_data2_in=>read_data2_id, sign_extend_in=>sign_extended, rs_in=>rs, rt_in=>rt, rd_in=>rd, RegDst_out=>idex_RegDst, ALUSrc_out=>idex_ALUSrc, ALUOp_out=>idex_ALUOp, MemRead_out=>idex_MemRead, MemWrite_out=>idex_MemWrite, Branch_out=>idex_Branch, MemtoReg_out=>idex_MemtoReg, RegWrite_out=>idex_RegWrite, pc_plus4_out=>idex_pc_plus4, read_data1_out=>idex_read_data1, read_data2_out=>idex_read_data2, sign_extend_out=>idex_sign_extended, rs_out=>idex_rs, rt_out=>idex_rt, rd_out=>idex_rd);

    -- EX
    U_forwarding_unit: forwarding_unit PORT MAP(idex_rs=>idex_rs, idex_rt=>idex_rt, exmem_rd=>exmem_write_register, exmem_RegWrite=>exmem_RegWrite, memwb_rd=>memwb_write_register, memwb_RegWrite=>memwb_RegWrite, forwardA=>forwardA, forwardB=>forwardB);
    U_mux_forward_a: mux3to1 GENERIC MAP(nbit_width=>32) PORT MAP(sel=>forwardA, input0=>idex_read_data1, input1=>exmem_alu_result, input2=>write_back_data, output=>forwarded_data1);
    U_mux_forward_b: mux3to1 GENERIC MAP(nbit_width=>32) PORT MAP(sel=>forwardB, input0=>idex_read_data2, input1=>exmem_alu_result, input2=>write_back_data, output=>forwarded_data2);
    U_mux_alusrc: mux GENERIC MAP(nbit_width=>32) PORT MAP(sel=>idex_ALUSrc, input0=>forwarded_data2, input1=>idex_sign_extended, output=>alu_input2);
    U_alu: alu PORT MAP(opcode=>idex_ALUOp, input1=>forwarded_data1, input2=>alu_input2, result=>alu_result_ex, zero=>zero_ex);
    U_mux_regdst: mux GENERIC MAP(nbit_width=>5) PORT MAP(sel=>idex_RegDst, input0=>idex_rt, input1=>idex_rd, output=>write_register_ex);
    U_shift_left_2: shift_left_2 PORT MAP(input=>idex_sign_extended, output=>shift_output);
    U_branch_adder: branch_adder PORT MAP(pc_plus4=>idex_pc_plus4, branch_offset=>shift_output, branch_target=>branch_target_ex);

    -- EX/MEM
    U_EXMEM_register: exmem_register PORT MAP(clk=>clk, reset=>reset, MemRead_in=>idex_MemRead, MemWrite_in=>idex_MemWrite, Branch_in=>idex_Branch, MemtoReg_in=>idex_MemtoReg, RegWrite_in=>idex_RegWrite, branch_target_in=>branch_target_ex, zero_in=>zero_ex, alu_result_in=>alu_result_ex, write_data_in=>forwarded_data2, write_register_in=>write_register_ex, MemRead_out=>exmem_MemRead, MemWrite_out=>exmem_MemWrite, Branch_out=>exmem_Branch, MemtoReg_out=>exmem_MemtoReg, RegWrite_out=>exmem_RegWrite, branch_target_out=>exmem_branch_target, zero_out=>exmem_zero, alu_result_out=>exmem_alu_result, write_data_out=>exmem_write_data, write_register_out=>exmem_write_register);

    -- MEM
    U_data_memory: data_memory PORT MAP(clk=>clk, address=>exmem_alu_result, write_data=>exmem_write_data, memory_write_ctrl=>exmem_MemWrite, memory_read_ctrl=>exmem_MemRead, read_data=>mem_data_out);
    PCSrc <= exmem_Branch AND exmem_zero;

    -- MEM/WB
    U_MEMWB_register: memwb_register PORT MAP(clk=>clk, reset=>reset, MemtoReg_in=>exmem_MemtoReg, RegWrite_in=>exmem_RegWrite, mem_data_in=>mem_data_out, alu_result_in=>exmem_alu_result, write_register_in=>exmem_write_register, MemtoReg_out=>memwb_MemtoReg, RegWrite_out=>memwb_RegWrite, mem_data_out=>memwb_mem_data, alu_result_out=>memwb_alu_result, write_register_out=>memwb_write_register);

    -- WB
    U_mux_memtoreg: mux GENERIC MAP(nbit_width=>32) PORT MAP(sel=>memwb_MemtoReg, input0=>memwb_alu_result, input1=>memwb_mem_data, output=>write_back_data);

END BEHAV;
