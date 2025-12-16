library IEEE;
use IEEE.std_logic_1164.all;

entity tb_datapath is
end tb_datapath;

architecture BEHAV of tb_datapath is

	COMPONENT datapath
		Port (
         	      clk : in  std_logic
        	      );
	END COMPONENT;

signal clock : std_logic; 

begin

	U_datapath: datapath PORT MAP (
               clk => clock
     	       );

process
    begin
 	 for i in 0 to 21 loop  --loop count
        	clock <= '1';
 		wait for 50 ns;
 		clock <= '0';
		wait for 50 ns;
 	 end loop;
end process;

end BEHAV;
