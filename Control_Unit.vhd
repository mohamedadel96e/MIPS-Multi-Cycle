LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY Control_Unit IS
  PORT (

    -- I/P
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    Opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    Zero : IN STD_LOGIC;

    -- O/P
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
END ENTITY;

ARCHITECTURE Behavioral OF Control_Unit IS
  TYPE State_Type IS (
    Fetch, 
    Decode, 
    MemAddr, 
    MemReadState,
    MemWriteBack, 
    MemWriteState, 
    ExecuteR, 
    ALUWriteBack, 
    Branch, 
    Jump);
  SIGNAL CurrentState, NextState : State_Type;

BEGIN
  PROCESS (clk, reset, Opcode)
  BEGIN
    IF reset = '1' THEN
      CurrentState <= Fetch; -- For Fetching the Instructions 
    ELSIF rising_edge(clk) THEN
      CurrentState <= NextState;
    END IF;
  END PROCESS;

  PROCESS (CurrentState, Opcode, Zero)
  BEGIN
    PCWrite <= '0';
    MemRead <= '0';
    MemWrite <= '0';
    IRWrite <= '0';
    RegDst <= '0';
    MemtoReg <= '0';
    RegWrite <= '0';
    ALUSrcA <= '0';
    ALUSrcB <= "00";
    ALUOp <= "00";
    PCSource <= "00";
    IorD <= '0';
    PCWriteCondition <= '0';

    CASE CurrentState IS
      WHEN Fetch =>
        MemRead <= '1';
        IRWrite <= '1';
        ALUSrcB <= "01";
        PCWrite <= '1';
        NextState <= Decode;

      WHEN Decode =>
        ALUSrcB <= "11";
        ALUOp <= "00";
        CASE Opcode IS
          WHEN "000000" => NextState <= ExecuteR; -- R-type
          WHEN "100011" | "101011" => NextState <= MemAddr; -- LW/SW
          WHEN "000100" => NextState <= Branch; -- BEQ
          WHEN "000010" => NextState <= Jump; -- J
          WHEN OTHERS => NextState <= Fetch;
        END CASE;

      WHEN MemAddr => -- LW/SW
        ALUSrcA <= '1';
        ALUSrcB <= "10";
        ALUOp <= "00";
        IF Opcode = "100011" THEN
          NextState <= MemReadState;
        ELSE
          NextState <= MemWriteState;
        END IF;

      WHEN MemReadState =>
        MemRead <= '1';
        IorD <= '1';
        NextState <= MemWriteBack;

      WHEN MemWriteBack =>
        MemtoReg <= '1';
        RegWrite <= '1';
        NextState <= Fetch;

      WHEN MemWriteState =>
        MemWrite <= '1';
        IorD <= '1';
        NextState <= Fetch;

      WHEN ExecuteR =>
        ALUSrcA <= '1';
        ALUOp <= "10";
        NextState <= ALUWriteBack;

      WHEN ALUWriteBack =>
        RegDst <= '1';
        RegWrite <= '1';
        NextState <= Fetch;

      WHEN Branch =>
        ALUSrcA <= '1';
        ALUOp <= "01";
        PCSource <= "01";
        PCWriteCondition <= '1';
        IF Zero = '1' THEN
          PCWrite <= '1';
        END IF;
        NextState <= Fetch;

      WHEN Jump =>
        PCSource <= "10";
        PCWrite <= '1';
        NextState <= Fetch;

      WHEN OTHERS => NextState <= Fetch;
    END CASE;
  END PROCESS;
END ARCHITECTURE;