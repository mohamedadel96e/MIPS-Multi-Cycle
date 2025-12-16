
library ieee;
use ieee.std_logic_1164.all;

entity mux is
    generic( 
            nbit_width : integer := 32
           );
    Port (
	   sel : in  std_logic;
           input0,input1 : in  std_logic_vector (nbit_width-1 downto 0);
           output : out  std_logic_vector (nbit_width-1 downto 0)
	 );
end mux;

architecture BEHAV of mux is
begin
	output <= input0 when (sel = '0') else input1;
end BEHAV;

