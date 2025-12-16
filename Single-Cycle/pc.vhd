
library ieee;
use ieee.std_logic_1164.all;

entity pc is
    generic (
        nbit_width : integer := 32
    );
    Port (
          clk : in  std_logic;
          input : in  std_logic_vector(nbit_width-1 downto 0);
          output : out  std_logic_vector(nbit_width-1 downto 0)
         );
end pc;

architecture BEHAV of PC is
signal sig_output : std_logic_vector(nbit_width-1 downto 0) := X"00000000";
begin
    process(clk)
    begin
	if (rising_edge(clk)) then
            sig_output <= input;
        end if;
    end process;
output <= sig_output;
end BEHAV;

