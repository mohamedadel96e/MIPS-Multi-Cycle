LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY MIPS IS

  PORT (
    clk, reset : IN STD_LOGIC;
    enable : IN STD_LOGIC
  );
END ENTITY;
ARCHITECTURE bahave OF MIPS IS
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
  COMPONENT IR IS
    PORT (
      clk : IN STD_LOGIC;
      IRWrite : IN STD_LOGIC;
      DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;
  COMPONENT MDR IS
    PORT (
      clk : IN STD_LOGIC;
      DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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
  COMPONENT Shift_Left_2 IS
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
  COMPONENT pc IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      PCWrite : IN STD_LOGIC;
      PCIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      PCOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT shiftleft2_28 IS
    PORT (
      input : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
      output : OUT STD_LOGIC_VECTOR(27 DOWNTO 0));
  END COMPONENT;
  SIGNAL Mux_ToPc, pc_out, Mux_ToAddress, RegA_Out, RegB_Out, MemData, MDR_ToMux, Mux_ToWriteData, srcA, srcB, SignExtend, shift_left32ToMux, Mux1_ToALU, Mux2_ToALU, ALUResult_TOALUOut, ALUOut, jumpAddress, instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL MuxToWriteReg : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL pc_write, pc_write_condition, Iord, memory_read, memory_write, memorytoregister, IR_write, ALUSrcA, RegWrite, RegDst, AndToOr, OrToPC, Zero : STD_LOGIC;
  SIGNAL ALUSrcB, PCSource, ALUOp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL ALUControl_to_Alu : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN

  AndToOr <= zero AND pc_write_condition;
  OrToPC <= pc_write OR AndToOr;

  jumpAddress(31 DOWNTO 28) <= pc_out(31 DOWNTO 28);
  Pc_comp : pc
  PORT MAP(
    clk => clk,
    reset => reset,
    PCWrite => enable,
    PCIn => Mux_ToPc,
    PCOut => pc_out

  );
  memory_comp : Memory
  PORT MAP(
    clk => clk,
    MemRead => memory_read,
    MemWrite => memory_write,
    Address => Mux_ToAddress,
    DataIn => RegB_Out,
    Dataout => MemData

  );
  Ir_comp : IR
  PORT MAP(
    clk => clk,
    IRWrite => IR_write,
    DataIn => MemData,
    DataOut => instruction
  );
  MemoryDataRegister : MDR
  PORT MAP(
    clk => clk,
    DataIn => MemData,
    DataOut => MDR_ToMux
  );
  Registers : Registers_File
  PORT MAP(
    clk => clk,
    reset => reset,
    RegWrite => RegWrite,
    ReadReg1 => instruction(25 DOWNTO 21),
    ReadReg2 => instruction(20 DOWNTO 16),
    WriteReg => MuxToWriteReg,
    WriteData => Mux_ToWriteData,
    ReadData1 => srcA,
    ReadData2 => srcB

  );
  Sign_Extender : Sign_Extend
  PORT MAP(
    Immediate => instruction(15 DOWNTO 0),
    Extended => SignExtend
  );
  Shift_Left1 : Shift_Left_2
  PORT MAP(
    Input => SignExtend,
    Output => shift_left32ToMux
  );
  Sl2_comp : shiftleft2_28
  PORT MAP(
    input => instruction(25 DOWNTO 0),
    output => jumpAddress(27 DOWNTO 0)

  );
  CU_comp : Control_Unit
  PORT MAP(
    clk => clk,
    reset => reset,
    Opcode => instruction(31 DOWNTO 26),
    Zero => Zero,
    PCWrite => pc_write,
    MemRead => memory_read,
    MemWrite => memory_write,
    IRWrite => IR_write,
    RegDst => RegDst,
    MemtoReg => memorytoregister,
    RegWrite => RegWrite,
    ALUSrcA => ALUSrcA,
    ALUSrcB => ALUSrcB,
    ALUOp => ALUOp,
    PCSource => PCSource,
    IorD => Iord

  );

  ALU_comp : ALU
  PORT MAP(
    ALUControl => ALUControl_to_Alu,
    A => Mux1_ToALU,
    B => Mux2_ToALU,
    ALUResult => ALUResult_TOALUOut,
    Zero => Zero

  );
  ALU_Control_comp : ALU_Control
  PORT MAP(
    ALUOp => ALUOp,
    Funct => instruction(5 DOWNTO 0),
    ALUControl => ALUControl_to_Alu

  );
  Reg_A : Reg
  PORT MAP(
    clk => clk,
    reset => reset,
    enable => enable,
    DataIn => srcA,
    DataOut => RegA_Out
  );

  Reg_B : Reg
  PORT MAP(
    clk => clk,
    reset => reset,
    enable => enable,
    DataIn => srcB,
    DataOut => RegB_Out
  );

  ALU_OUT_comp : Reg
  PORT MAP(
    clk => clk,
    reset => reset,
    enable => enable,
    DataIn => ALUResult_TOALUOut,
    DataOut => ALUOut
  );
  mux1 : MUX_2to1
  GENERIC MAP(
    N => 32
  )
  PORT MAP(
    Sel => IorD,
    In0 => pc_out,
    In1 => ALUOut,
    OutMux => Mux_ToAddress

  );

  mux2 : MUX_2to1
  GENERIC MAP(
    N => 5
  )
  PORT MAP(
    Sel => RegDst,
    In0 => instruction(20 DOWNTO 16),
    In1 => instruction(15 DOWNTO 11),
    OutMux => MuxToWriteReg

  );

  mux3 : MUX_2to1
  GENERIC MAP(
    N => 32
  )
  PORT MAP(
    Sel => memorytoregister,
    In0 => ALUOut,
    In1 => MDR_ToMux,
    OutMux => Mux_ToWriteData

  );

  mux4 : MUX_2to1
  GENERIC MAP(
    N => 32
  )
  PORT MAP(
    Sel => ALUSrcA,
    In0 => pc_out,
    In1 => srcA,
    OutMux => Mux1_ToALU

  );

  mux5 : MUX_4to1
  GENERIC MAP(
    N => 32
  )
  PORT MAP(
    Sel => ALUSrcB,
    In0 => srcB,
    In1 => X"00000004",
    In2 => SignExtend,
    In3 => shift_left32ToMux,
    OutMux => Mux2_ToALU

  );

  mux6 : MUX_3to1
  GENERIC MAP(
    N => 32
  )
  PORT MAP(
    Sel => PCSource,
    In0 => ALUOut,
    In1 => jumpAddress,
    In2 => ALUResult_TOALUOut,
    OutMux => Mux_ToPc

  );
END ARCHITECTURE;