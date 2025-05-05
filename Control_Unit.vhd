library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Control_Unit is 
  port (

    -- I/P
    clk: in std_logic;
    reset: in std_logic;
    Opcode: in std_logic_vector(5 downto 0);
    Zero: in std_logic;

    -- O/P
    PCWrite: out std_logic;
    MemRead: out std_logic;
    MemWrite: out std_logic;
    IRWrite: out std_logic;
    RegDst: out std_logic;
    MemtoReg: out std_logic;
    RegWrite: out std_logic;
    ALUSrcA: out std_logic;
    ALUSrcB: out std_logic_vector(1 downto 0);
    ALUOp: out std_logic_vector(1 downto 0);
    PCSource: out std_logic_vector(1 downto 0);
    IorD: out std_logic
  );
end entity;

architecture Behavioral of Control_Unit is 
  type State_Type is (Fetch, Decode, MemAddr, MemReadState, 
  MemWriteBack, MemWriteState, ExecuteR, ALUWriteBack, Branch, Jump);
  signal CurrentState, NextState : State_Type;
  
  begin
    process (clk, reset, Opcode)
    begin
      if reset = '1' then 
        CurrentState <= Fetch; -- For Fetching the Instructions 
      elsif rising_edge(clk) then 
        CurrentState <= NextState;
      end if;
    end process;

    process (CurrentState, Opcode, Zero)
    begin
      PCWrite <= '0'; MemRead <= '0'; MemWrite <= '0'; IRWrite <= '0';
      RegDst <= '0'; MemtoReg <= '0'; RegWrite <= '0'; ALUSrcA <= '0';
      ALUSrcB <= "00"; ALUOp <= "00"; PCSource <= "00"; IorD <= '0';



      case CurrentState is 
        when Fetch => 
          MemRead <= '1'; IRWrite <='1'; ALUSrcB <= "01";
          PCWrite <= '1'; NextState <= Decode;

        when Decode =>
          ALUSrcB <= "11"; ALUOp <= "00";
          case Opcode is
            when "000000" => NextState <= ExecuteR; -- R-type
            when "100011" | "101011" => NextState <= MemAddr; -- LW/SW
            when "000100" => NextState <= Branch; -- BEQ
            when "000010" => NextState <= Jump; -- J
            when others => NextState <= Fetch;
          end case;

        when MemAddr => -- LW/SW
          ALUSrcA <= '1'; ALUSrcB <= "10"; ALUOp <= "00";
          if Opcode = "100011" then NextState <= MemReadState;
          else NextState <= MemWriteState;
          end if; 
        
        when MemReadState =>
          MemRead <= '1'; IorD <= '1'; NextState <= MemWriteBack;

        when MemWriteBack =>
          MemtoReg <= '1'; RegWrite <= '1'; NextState <= Fetch;

        when MemWriteState =>
          MemWrite <= '1'; IorD <= '1'; NextState <= Fetch;

        when ExecuteR =>
          ALUSrcA <= '1'; ALUOp <= "10"; NextState <= ALUWriteBack;

        when ALUWriteBack =>
          RegDst <= '1'; RegWrite <= '1'; NextState <= Fetch;

        when Branch =>
          ALUSrcA <= '1'; ALUOp <= "01"; PCSource <= "01";
          if Zero = '1' then PCWrite <= '1'; end if;
          NextState <= Fetch;

        when Jump => 
          PCSource <= "10"; PCWrite <= '1'; NextState <= Fetch;
        
        when others => NextState <= Fetch;
      end case;
    end process;
end architecture;