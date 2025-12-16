library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pc_adder is
    generic (
        nbit_width : integer := 32
    );
    Port (
        input : in  std_logic_vector(nbit_width-1 downto 0);
        output : out  std_logic_vector(nbit_width-1 downto 0)
    );
end pc_adder;

architecture BEHAV of pc_adder is
begin
    output <= input + X"00000001";
end BEHAV;

