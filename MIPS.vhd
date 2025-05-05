LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MIPS IS
  PORT (
    clk, reset : IN STD_LOGIC;
    enable : IN STD_LOGIC
  );
END ENTITY;

ARCHITECTURE behave OF MIPS IS
  COMPONENT ALU IS
    PORT (
      ALUControl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      ALUResult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      Zero : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT ALU_Control IS
    PORT (
      ALUOp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      Funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      ALUControl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Control_Unit IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      Opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      Zero : IN STD_LOGIC;
      PCWrite : OUT STD_LOGIC;
      PCWriteCondition: OUT STD_LOGIC;
      MemRead : OUT STD_LOGIC;
      MemWrite : OUT STD_LOGIC;
      IRWrite : OUT STD_LOGIC;
      RegDst : OUT STD_LOGIC;
      MemtoReg : OUT STD_LOGIC;
      RegWrite : OUT STD_LOGIC;
      ALUSrcA : OUT STD_LOGIC;
      ALUSrcB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      ALUOp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      PCSource : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      IorD : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT MUX_2to1 IS
    GENERIC (N : INTEGER := 32);
    PORT (
      Sel : IN STD_LOGIC;
      In0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      In1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      OutMux : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT MUX_3to1 IS
    GENERIC (N : INTEGER := 32);
    PORT (
      Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      In0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      In1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      In2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      OutMux : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT MUX_4to1 IS
    GENERIC (N : INTEGER := 32);
    PORT (
      Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      In0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      In1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      In2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      In3 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      OutMux : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Memory IS
    PORT (
      clk : IN STD_LOGIC;
      MemRead : IN STD_LOGIC;
      MemWrite : IN STD_LOGIC;
      Address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      Dataout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Reg IS
    GENERIC (N : INTEGER := 32);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      enable : IN STD_LOGIC;
      DataIn : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      DataOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Registers_File IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      RegWrite : IN STD_LOGIC;
      ReadReg1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      ReadReg2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      WriteReg : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      WriteData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      ReadData1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      ReadData2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Shift_Left_2_32 IS
    PORT (
      Input : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      Output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Sign_Extend IS
    PORT (
      Immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      Extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Shift_Left_2_28 IS
    PORT (
      input : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
      output : OUT STD_LOGIC_VECTOR(27 DOWNTO 0)
    );
  END COMPONENT;

  -- Signals
  SIGNAL Mux_ToPc, pc_out, Mux_ToAddress, MemData, MDR_Out, Mux_ToWriteData : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL srcA, srcB, RegA_Out, RegB_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL SignExtend_Out, shift_left32_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ALU_A, ALU_B, ALUResult, ALUOut_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL jumpAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL MuxToWriteReg : STD_LOGIC_VECTOR(4 DOWNTO 0);
  
  -- Control signals
  SIGNAL pc_write, pc_write_condition, IorD, MemRead, MemWrite : STD_LOGIC;
  SIGNAL IR_write, RegDst, MemtoReg, RegWrite, ALUSrcA : STD_LOGIC;
  SIGNAL ALUSrcB, PCSource, ALUOp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL ALUControl : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Zero, AndToOr, OrToPC : STD_LOGIC;

BEGIN
  -- Control signal logic
  AndToOr <= Zero AND pc_write_condition;
  OrToPC <= pc_write OR AndToOr;
  
  -- Jump address construction
  jumpAddress(31 DOWNTO 28) <= pc_out(31 DOWNTO 28);
  
  -- Program Counter
  PC: Reg GENERIC MAP (N => 32)
  PORT MAP (
    clk => clk,
    reset => reset,
    enable => OrToPC,
    DataIn => Mux_ToPc,
    DataOut => pc_out
  );
  
  -- Memory Address Mux
  MemAddrMux: MUX_2to1 GENERIC MAP (N => 32)
  PORT MAP (
    Sel => IorD,
    In0 => pc_out,
    In1 => ALUOut_Out,
    OutMux => Mux_ToAddress
  );
  
  -- Main Memory
  MainMemory: Memory
  PORT MAP (
    clk => clk,
    MemRead => MemRead,
    MemWrite => MemWrite,
    Address => Mux_ToAddress,
    DataIn => RegB_Out,
    Dataout => MemData
  );
  
  -- Instruction Register
  IR_Reg: Reg GENERIC MAP (N => 32)
  PORT MAP (
    clk => clk,
    reset => reset,
    enable => IR_write,
    DataIn => MemData,
    DataOut => instruction
  );
  
  -- Memory Data Register
  MDR_Reg: Reg GENERIC MAP (N => 32)
  PORT MAP (
    clk => clk,
    reset => reset,
    enable => '1',
    DataIn => MemData,
    DataOut => MDR_Out
  );
  
  -- Register File
  RegFile: Registers_File
  PORT MAP (
    clk => clk,
    reset => '0',
    RegWrite => RegWrite,
    ReadReg1 => instruction(25 DOWNTO 21),
    ReadReg2 => instruction(20 DOWNTO 16),
    WriteReg => MuxToWriteReg,
    WriteData => Mux_ToWriteData,
    ReadData1 => srcA,
    ReadData2 => srcB
  );
  
  -- Register A
  RegA: Reg GENERIC MAP (N => 32)
  PORT MAP (
    clk => clk,
    reset => reset,
    enable => '1',
    DataIn => srcA,
    DataOut => RegA_Out
  );
  
  -- Register B
  RegB: Reg GENERIC MAP (N => 32)
  PORT MAP (
    clk => clk,
    reset => reset,
    enable => '1',
    DataIn => srcB,
    DataOut => RegB_Out
  );
  
  -- Sign Extender
  SignExt: Sign_Extend
  PORT MAP (
    Immediate => instruction(15 DOWNTO 0),
    Extended => SignExtend_Out
  );
  
  -- Shift Left 2 (32-bit)
  SL2_32: Shift_Left_2_32
  PORT MAP (
    Input => SignExtend_Out,
    Output => shift_left32_Out
  );
  
  -- Shift Left 2 (26 to 28-bit for jump)
  SL2_28: Shift_Left_2_28
  PORT MAP (
    input => instruction(25 DOWNTO 0),
    output => jumpAddress(27 DOWNTO 0)
  );
  
  -- ALU Source A Mux
  ALUSrcAMux: MUX_2to1 GENERIC MAP (N => 32)
  PORT MAP (
    Sel => ALUSrcA,
    In0 => pc_out,
    In1 => RegA_Out,
    OutMux => ALU_A
  );
  
  -- ALU Source B Mux
  ALUSrcBMux: MUX_4to1 GENERIC MAP (N => 32)
  PORT MAP (
    Sel => ALUSrcB,
    In0 => RegB_Out,
    In1 => x"00000004",  -- Constant 4
    In2 => SignExtend_Out,
    In3 => shift_left32_Out,
    OutMux => ALU_B
  );
  
  -- ALU
  ALU_Unit: ALU
  PORT MAP (
    ALUControl => ALUControl,
    A => ALU_A,
    B => ALU_B,
    ALUResult => ALUResult,
    Zero => Zero
  );
  
  -- ALU Control
  ALU_Control_Unit: ALU_Control
  PORT MAP (
    ALUOp => ALUOp,
    Funct => instruction(5 DOWNTO 0),
    ALUControl => ALUControl
  );
  
  -- ALU Out Register
  ALUOut: Reg GENERIC MAP (N => 32)
  PORT MAP (
    clk => clk,
    reset => reset,
    enable => '1',
    DataIn => ALUResult,
    DataOut => ALUOut_Out
  );
  
  -- PC Source Mux
  PCSrcMux: MUX_3to1 GENERIC MAP (N => 32)
  PORT MAP (
    Sel => PCSource,
    In0 => ALUResult,
    In1 => ALUOut_Out,
    In2 => jumpAddress,
    OutMux => Mux_ToPc
  );
  
  -- Register Destination Mux
  RegDstMux: MUX_2to1 GENERIC MAP (N => 5)
  PORT MAP (
    Sel => RegDst,
    In0 => instruction(20 DOWNTO 16),  -- rt
    In1 => instruction(15 DOWNTO 11),  -- rd
    OutMux => MuxToWriteReg
  );
  
  -- Memory to Register Mux
  MemToRegMux: MUX_2to1 GENERIC MAP (N => 32)
  PORT MAP (
    Sel => MemtoReg,
    In0 => ALUOut_Out,
    In1 => MDR_Out,
    OutMux => Mux_ToWriteData
  );
  
  -- Control Unit
  ControlUnit: Control_Unit
  PORT MAP (
    clk => clk,
    reset => reset,
    Opcode => instruction(31 DOWNTO 26),
    Zero => Zero,
    PCWrite => pc_write,
    PCWriteCondition => pc_write_condition,
    MemRead => MemRead,
    MemWrite => MemWrite,
    IRWrite => IR_write,
    RegDst => RegDst,
    MemtoReg => MemtoReg,
    RegWrite => RegWrite,
    ALUSrcA => ALUSrcA,
    ALUSrcB => ALUSrcB,
    ALUOp => ALUOp,
    PCSource => PCSource,
    IorD => IorD
  );

END ARCHITECTURE;