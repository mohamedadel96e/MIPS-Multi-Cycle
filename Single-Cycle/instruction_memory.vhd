
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity instruction_memory is
  
generic (
             nbit_width : integer := 32
            );
    
Port (
      
address : in std_logic_vector(nbit_width-1 downto 0);
  
instruction : out std_logic_vector(nbit_width-1 downto 0)
      
);
end instruction_memory;


architecture BEHAV of instruction_memory is

   
type memory_instr is array(0 to 17) of std_logic_vector(nbit_width-1 downto 0);	
--addi,sub,or,and ,lw,sw ,Nand,slt ,beq
signal sig_memory_instr : memory_instr := 
(	 
X"8c020002",  --lw $2, 2($0)   ->  $2 = data_mem[2]	 
X"8CC10000",  --lw $1, 0($6)  
X"8CA20000" , --lw $2, 0($5)  
X"8c010001",  --lw $1, 1($0)   ->  $1 = data_mem[1]
X"20050002",  --addi $5, $0, 2	
X"ACA40000",  --sw $4,0($5)	
X"20060001",  -- addi $6, $0, 1
X"20A50001",  --addi $5, $5, 1
X"20C60001",  --addi $6, $6, 1	  
X"20030014",  --addi $3, $0, 20 (loop count : $3 = 20)
X"00412020",  --R_Type : add $4, $2, $1
X"00253022" , -- R_Type :sub $6,$1,$5 
X"00876824",  -- R_Type:and : $13,$4, &7  
X"00876827",	-- R_Type:Nand : $13,$4, &7  
X"00242825" ,   --R_Type:or:$1,$4,$5 
X"00432038" ,	--R_type :slt :$4,$2,$3	 
--what happen if ($1 notEqual $4)   =====>  sig_zero=>'0' ======>andGate not active ======> if codition achive that
X"10240002" ,	 --beq $1,$s4,2
X"114B0001"	     --beq $10,$s11,1 
--X"1460FFF8"   --bne $3,$0,-8
);

begin
 process(address)
  
begin
 instruction <= sig_memory_instr(to_integer(unsigned(address)));
 end process;

end BEHAV;
