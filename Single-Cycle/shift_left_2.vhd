--to (x)=====>x4 ====>shift left
library ieee;
use ieee.std_logic_1164.all;


entity shift_left_2 is
    Port ( 
	  input : in  std_logic_vector (31 downto 0);
          output : out  std_logic_vector (31 downto 0)
	 );
end shift_left_2;

architecture BEHAV of shift_left_2 is
begin
     output <= input(29 downto 0)&"00";
end BEHAV;
