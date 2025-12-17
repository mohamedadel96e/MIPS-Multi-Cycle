library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity alu is
    generic (
        nbit_width : integer := 32
    );
    Port (
        opcode : in std_logic_vector(2 downto 0);
        input1, input2 : in std_logic_vector(nbit_width-1 downto 0); 
        result : out std_logic_vector(nbit_width-1 downto 0); 
        zero : out std_logic 
    );
end alu;

architecture BEHAV of alu is
    signal temp_result : std_logic_vector(nbit_width downto 0);
begin

   process(opcode, input1,input2) 
  
   begin
   
  case opcode is
             
   when "100" => -- subtraction 
  
   temp_result <= ('0' & input1) - ('0' & input2);
		
   zero <= '0';

               
   when "101" => -- and
         
   temp_result <= ('0' & input1) and  ('0' & input2);
	
   zero <= '0';		
   when "000" => -- Nand
         
   temp_result <= ('0' & input1) Nand  ('0' & input2);
	
   zero <= '0';	 
   when "011" => --slt
         
   if(input1<input2)then
	   	  temp_result <= (0 => '1' , others => '0');
		   zero <= '0';	
   else
	   	  temp_result <= ( others => '0');
		   zero <= '0';
		   end if;
	
   when "110" => -- or
          
   temp_result <= ('0' & input1) or ('0' & input2);
		
   zero <= '0';

                
   when "001" => -- lw sw 
           
   temp_result <=  ('0' & input1) + ('0' & input2);
		
   zero <= '0';

		  
   when "111" => --addi
			
   temp_result <= ('0' & input1) + ('0' & input2);
	
   zero <= '0'; 
	  
  when others => 	--beq/bneq	  --check with instruction 
  
  
if(input1=input2)then
  
	  
  zero <= '1';
  
  else

	  
  zero <= '0';   
	
 
 
  end if;
   
 
  
  end case;

 end process;   
   	
  -- ignore the carry

   

  result <= temp_result(nbit_width-1 downto 0);
   

  
end BEHAV;

