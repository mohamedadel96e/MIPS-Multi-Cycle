library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ALU_Control is 
  port (
    ALUOp: in std_logic_vector(1 downto 0);
    Funct: in std_logic_vector(5 downto 0);
    ALUControl: out std_logic_vector(2 downto 0)
  );
end entity;

architecture Behavioral of ALU_Control is

begin
  process (ALUOp, Funct)
  begin
    case ALUOp is 
      when "00" => ALUControl <= "010"; -- LW/SW: ADD
      when "01" => ALUControl <= "110"; -- BEQ: SUB
      when others => 
        case Funct is 
          when "100000" => ALUControl <= "010"; -- ADD
          when "100010" => ALUControl <= "110"; -- SUB
          when "100100" => ALUControl <= "000"; -- AND
          when "100101" => ALUControl <= "001"; -- OR
          when "101010" => ALUControl <= "111"; -- SLT
          when others => ALUControl <= "010"; -- ADD => Default
        end case;
    end case;
  end process;

end Behavioral ; 