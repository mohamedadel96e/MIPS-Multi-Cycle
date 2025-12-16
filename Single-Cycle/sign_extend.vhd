
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity sign_extend is
    generic( 
            nbit_input_width : integer := 16;
            nbit_output_width : integer := 32
           );
    Port (
          input : in  std_logic_vector (nbit_input_width-1 downto 0);
          output : out  std_logic_vector (nbit_output_width-1 downto 0)
	 );
end sign_extend;

architecture BEHAV of sign_extend is
begin
	output<= x"0000"&input when input(nbit_input_width-1) = '0' else  x"FFFF"&input;
end BEHAV;