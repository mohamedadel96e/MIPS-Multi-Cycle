
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_value is
    Port ( 
	  opcode : in  std_logic_vector(5 downto 0);
	  RegDst , Branch , MemRead , MemtoReg , MemWrite , AluSrc , RegWrite : out  std_logic;
          ALUOp : out  std_logic_vector (1 downto 0)
	 );
end control_value;

architecture BEHAV of control_value is
 signal ctrl_values: std_logic_vector(8 downto 0);
begin

process(opcode)
     begin
	case opcode is
		  when "000000" => ctrl_values <= "100000110";  -- R type  D"0"  
	      when "100011" => ctrl_values <= "001101100";  -- lw	 D"35"
	      when "101011" => ctrl_values <= "-00-11000";  -- sw	 D"43"
	      when "000101" => ctrl_values <= "-10-00001";  -- bneq	 D"5"
		  when "000100" => ctrl_values <= "-10-00001";  -- beq	 D"4"
	      when "001000" => ctrl_values <= "000001111";  -- addi	 D"8"
	      when others   => ctrl_values <= "---------";	 --others
	end case;
     end process;														

	RegDst <= ctrl_values(8);
	Branch <= ctrl_values(7);
	MemRead <= ctrl_values(6);
	MemtoReg <= ctrl_values(5);
	MemWrite <= ctrl_values(4);
	AluSrc <= ctrl_values(3);
	RegWrite <= ctrl_values(2);
	ALUOp <= ctrl_values(1 downto 0);

end BEHAV;
