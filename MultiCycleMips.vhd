library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity MultiCycleMIPS is 
  port (
    clk : in std_logic;
    reset : in std_logic
  );
end entity;



architecture Structural of MultiCycleMIPS is
  -- Internal Signals
  signal PCIn, PCOut, MemAddress, MemDataOut, IRData, MDRData : std_logic_vector(31 downto 0);
  signal ReadData1, ReadData2, AData, BData, ALUResult, ALUOut : std_logic_vector(31 downto 0);
  signal SignExtended, SignExtShifted : std_logic_vector(31 downto 0);
  signal ALUControlSig : std_logic_vector(2 downto 0);
  signal ZeroFlag : std_logic;
  
  -- Control Signals
  signal PCWrite, MemRead, MemWrite, IRWrite, RegDst, MemtoReg, RegWrite, ALUSrcA : std_logic;
  signal ALUSrcB, PCSource : std_logic_vector(1 downto 0);
  signal ALUOp : std_logic_vector(1 downto 0);
  signal IorD : std_logic;
  signal Opcode : std_logic_vector(5 downto 0);
  signal WriteReg : std_logic_vector(4 downto 0);
  signal WriteData : std_logic_vector(31 downto 0);
  signal ALUAIn, ALUBIn : std_logic_vector(31 downto 0);
  signal JumpAddress : std_logic_vector(31 downto 0);  -- New signal

begin
  -- ==================================================
  -- Component Instantiations
  -- ==================================================

  -- Program Counter (PC) Register
  PC: entity work.pc
      port map (clk, reset, PCWrite, PCIn, PCOut);

  -- Memory (IMEM + DMEM)
  Mem: entity work.Memory
      port map (clk, MemRead, MemWrite, MemAddress, BData, MemDataOut);

  -- Instruction Register (IR)
  IR_Reg: entity work.IR
      port map (clk, IRWrite, MemDataOut, IRData);

  -- Memory Data Register (MDR)
  MDR_Reg: entity work.MDR
      port map (clk, MemDataOut, MDRData);

  -- Register File
  RF: entity work.Registers_File
      port map (clk, RegWrite, IRData(25 downto 21), IRData(20 downto 16),
                WriteReg, WriteData, ReadData1, ReadData2);

  -- A and B Registers (Hold ALU Inputs)
  A_Reg: entity work.Reg
      generic map (32) port map (clk, ReadData1, AData);
  B_Reg: entity work.Reg
      generic map (32) port map (clk, ReadData2, BData);

  -- ALU and ALU Control
  ALUUnit: entity work.ALU
      port map (ALUControlSig, ALUAIn, ALUBIn, ALUResult, ZeroFlag);
  ALUCtrl: entity work.ALU_Control
      port map (ALUOp, IRData(5 downto 0), ALUControlSig);

  -- ALUOut Register (Stores ALU Result)
  ALUOut_Reg: entity work.Reg
      generic map (32) port map (clk, ALUResult, ALUOut);

  -- Control Unit
  CtrlUnit: entity work.Control_Unit
      port map (clk, reset, IRData(31 downto 26), ZeroFlag, PCWrite, MemRead,
                MemWrite, IRWrite, RegDst, MemtoReg, RegWrite, ALUSrcA,
                ALUSrcB, ALUOp, PCSource, IorD);

  -- Sign Extender
  SignExtend: entity work.Sign_Extend
      port map (IRData(15 downto 0), SignExtended);

  -- Shift Left by 2 (Branch/Jump Offset)
  ShiftLeft2: entity work.Shift_Left_2
      port map (SignExtended, SignExtShifted);

  -- ==================================================
  -- Multiplexers (MUXes)
  -- ==================================================

  -- ALU Input A MUX (PC vs A)
  ALUA_MUX: entity work.MUX_2to1
      generic map (32) port map (ALUSrcA, PCOut, AData, ALUAIn);

  -- ALU Input B MUX (4-to-1)
  ALUB_MUX: entity work.MUX_4to1
      generic map (32) port map (
          Sel => ALUSrcB,
          In0 => BData,
          In1 => x"00000004", -- +4 for PC increment
          In2 => SignExtended,
          In3 => SignExtShifted,
          OutMux => ALUBIn
      );

  -- Memory Address MUX (PC vs ALUOut)
  MemAddr_MUX: entity work.MUX_2to1
      generic map (32) port map (IorD, PCOut, ALUOut, MemAddress);

  -- Write Register MUX (rt vs rd)
  WriteReg_MUX: entity work.MUX_2to1
      generic map (5) port map (RegDst, IRData(20 downto 16), IRData(15 downto 11), WriteReg);

  -- Write Data MUX (MDR vs ALUOut)
  WriteData_MUX: entity work.MUX_2to1
      generic map (32) port map (MemtoReg, ALUOut, MDRData, WriteData);

  -- PC Input MUX (3-to-1)
  JumpAddress <= PCOut(31 downto 28) & IRData(25 downto 0) & "00";
  PC_MUX: entity work.MUX_3to1
      generic map (32) port map (
          Sel => PCSource,
          In0 => ALUResult,    -- PC+4 or computed address
          In1 => ALUOut,       -- Branch target
          In2 => JumpAddress, -- Jump target
          OutMux => PCIn
      );

end Structural;