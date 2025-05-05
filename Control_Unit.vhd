LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Control_Unit IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    Opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Instruction bits [31-26]
    Zero : IN STD_LOGIC; -- From ALU
    -- Main control outputs
    PCWrite : OUT STD_LOGIC;
    PCWriteCond : OUT STD_LOGIC;
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
  TYPE state_type IS (
    FETCH, -- Instruction fetch
    DECODE, -- Instruction decode
    MEM_ADDR, -- Memory address computation
    MEM_READ, -- Memory read
    MEM_WRITEBACK, -- Write to register from memory
    EXECUTE, -- R-type execution
    ALU_WRITEBACK, -- Write to register from ALU
    BRANCH, -- Branch completion
    JUMP -- Jump completion
  );
  SIGNAL current_state, next_state : state_type;

BEGIN
  -- State register
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      current_state <= FETCH;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  -- State machine and control signals
  PROCESS (current_state, Opcode, Zero)
  BEGIN
    -- Default control signals
    PCWrite <= '0';
    PCWriteCond <= '0';
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

    CASE current_state IS
        --------------------------
      WHEN FETCH =>
        MemRead <= '1'; -- Read instruction
        IRWrite <= '1'; -- Update IR
        ALUSrcB <= "01"; -- Use constant 4
        -- PCWrite  <= '1';         -- Update PC to PC+4
        IF (current_state /= BRANCH) AND (current_state /= JUMP) THEN
          PCWrite <= '1';
        END IF;
        next_state <= DECODE;

        --------------------------
      WHEN DECODE =>
        ALUSrcB <= "11"; -- Sign-extended offset << 2
        CASE Opcode IS
          WHEN "100011" => -- LW
            next_state <= MEM_ADDR;
          WHEN "101011" => -- SW
            next_state <= MEM_ADDR;
          WHEN "000000" => -- R-type
            next_state <= EXECUTE;
          WHEN "000100" => -- BEQ
            next_state <= BRANCH;
          WHEN "000010" => -- J
            next_state <= JUMP;
          WHEN OTHERS =>
            next_state <= FETCH; -- Handle illegal ops
        END CASE;

        --------------------------
      WHEN MEM_ADDR => -- Memory address calc
        ALUSrcA <= '1'; -- Use register A
        ALUSrcB <= "10"; -- Use sign-extended offset
        ALUOp <= "00"; -- Add operation
        IF Opcode = "100011" THEN -- LW
          next_state <= MEM_READ;
        ELSE -- SW
          next_state <= MEM_READ; -- Same state for SW (no writeback)
        END IF;

        --------------------------
      WHEN MEM_READ =>
        IF Opcode = "100011" THEN -- LW
          MemRead <= '1';
          IorD <= '1'; -- Use ALU output as address
          next_state <= MEM_WRITEBACK;
        ELSE -- SW
          MemWrite <= '1';
          IorD <= '1';
          next_state <= FETCH;
        END IF;

        --------------------------
      WHEN MEM_WRITEBACK => -- LW writeback
        RegDst <= '0'; -- Write to rt
        MemtoReg <= '1'; -- From memory
        RegWrite <= '1';
        next_state <= FETCH;

        --------------------------
      WHEN EXECUTE => -- R-type execution
        ALUSrcA <= '1';
        ALUSrcB <= "00"; -- Use register B
        ALUOp <= "10"; -- Use funct field
        next_state <= ALU_WRITEBACK;

        --------------------------
      WHEN ALU_WRITEBACK => -- R-type writeback
        RegDst <= '1'; -- Write to rd
        MemtoReg <= '0'; -- From ALU
        RegWrite <= '1';
        next_state <= FETCH;

        --------------------------
      WHEN BRANCH => -- BEQ completion
        ALUSrcA <= '1';
        ALUSrcB <= "00"; -- Use register B
        ALUOp <= "01"; -- Subtract
        PCWriteCond <= Zero; -- Update PC if Zero=1
        PCSource <= "01"; -- Use ALU result (branch target)
        next_state <= FETCH;

        --------------------------
      WHEN JUMP => -- J completion
        PCWrite <= '1';
        PCSource <= "10"; -- Use jump target
        next_state <= FETCH;

        --------------------------
      WHEN OTHERS =>
        next_state <= FETCH;
    END CASE;
  END PROCESS;
END ARCHITECTURE;