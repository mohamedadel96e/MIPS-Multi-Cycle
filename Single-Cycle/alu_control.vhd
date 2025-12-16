
library ieee;
use ieee.std_logic_1164.all;

entity alu_control is
    Port ( 
        ALUOp : in  std_logic_vector (1 downto 0);
        funct : in  std_logic_vector (5 downto 0);
        ALU_ctrl : out  std_logic_vector (2 downto 0)     
    );
end alu_control;

architecture BEHAV of alu_control is
begin
    process(ALUOp,funct)
    begin
        case ALUOp is
            when "00" => ALU_ctrl <= "001";  -- lw / sw	 --addition(10)
            when "01" => ALU_ctrl <= "010";  -- beq	/bneq 	 --sub(01)
			when "11" => ALU_ctrl <= "111";  -- I type
            when others =>   -- R type
                case funct is 
                     when "100000" => ALU_ctrl <= "111";  -- add
                     when "100010" => ALU_ctrl <= "100";  -- sub
                     when "100100" => ALU_ctrl <= "101";  -- and
                     when "100101" => ALU_ctrl <= "110";  -- or	 
					 when "100111" => ALU_ctrl <= "000";  --NAND
					 when "111000" => ALU_ctrl <= "011"; --set on less than
		     when others => ALU_ctrl <= "---";
                end case;  
        end case;
    end process;
end BEHAV;

