library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use ieee.std_logic_unsigned.all;

entity register_file is
    generic (
        nbit_width : integer := 32;
        num_of_registers : integer := 32
    );
    port (
	clk : in std_logic;
        read_register1, read_register2 : in std_logic_vector(4 downto 0);
        write_register : in std_logic_vector(4 downto 0);
        write_data : in std_logic_vector(nbit_width-1 downto 0);
        register_write_ctrl : in std_logic;
        read_data1, read_data2 : out std_logic_vector(nbit_width-1 downto 0)
    );
end register_file;

architecture BEHAV of register_file is 

type registerfile_mem is array (0 to num_of_registers-1) of std_logic_vector(nbit_width-1 downto 0); 
-- default value in the all register is (0)
--with aperations that full 
    signal reg_mem : registerfile_mem := (others => (others => '0'));

begin

	process(clk)
	begin
		if(clk'event and clk='1') then
			if (register_write_ctrl='1') then
				reg_mem(conv_integer(write_register)) <= write_data;
			end if;
		end if;
	end process;
	
	process(clk, read_register1, read_register2)
	 begin
  	    if (conv_integer(read_register1) = 0) then
     		read_data1 <= x"00000000";
 	    else
                read_data1 <= reg_mem(conv_integer(read_register1));
  	   end if;

  	   if (conv_integer(read_register2) = 0) then
   	       read_data2 <= x"00000000";
    	   else
     	       read_data2 <= reg_mem(conv_integer(read_register2));
    	   end if;
	end process;

	
end BEHAV;
