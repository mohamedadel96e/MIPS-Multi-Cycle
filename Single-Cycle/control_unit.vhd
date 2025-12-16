
library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    Port ( 
	  opcode , funct : in  std_logic_vector (5 downto 0);
          RegDst , Branch , MemRead , MemtoReg , MemWrite , AluSrc , RegWrite : out  std_logic;
          ALUOp : out  std_logic_vector (2 downto 0)
	 );
end control_unit;

architecture BEHAV of control_unit is

	COMPONENT control_value
	   PORT(
		opcode : in  std_logic_vector(5 downto 0);
	  	RegDst , Branch , MemRead , MemtoReg , MemWrite , AluSrc , RegWrite : out  std_logic;
         	ALUOp : out  std_logic_vector (1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT alu_control
	    PORT(
		 ALUOp : in  std_logic_vector (1 downto 0);
          	 funct : in  std_logic_vector (5 downto 0);
	 	 ALU_ctrl : out  std_logic_vector (2 downto 0)
		);
	END COMPONENT;

	signal alu_opcode:std_logic_vector(1 downto 0);

begin

Ucontrol_value : control_value PORT MAP(
					opcode => opcode,
					RegDst => RegDst,
					Branch => Branch,
					MemRead => MemRead,
					MemtoReg => MemtoReg,
					MemWrite => MemWrite,
					AluSrc => AluSrc,
					RegWrite => RegWrite,
					ALUOp => alu_opcode
				       );

Ualu_control : alu_control PORT MAP(
				    ALUOp => alu_opcode,
				    funct => funct,
				    ALU_ctrl => ALUOp
				   );
	
end BEHAV;

