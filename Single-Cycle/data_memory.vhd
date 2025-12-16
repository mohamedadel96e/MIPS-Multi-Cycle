library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    generic (
        nbit_width : integer := 32
    );
    Port (
	clk : in std_logic;
        address : in std_logic_vector(nbit_width-1 downto 0);
        write_data : in std_logic_vector(nbit_width-1 downto 0);
        memory_write_ctrl , memory_read_ctrl : in std_logic;
        read_data : out std_logic_vector(nbit_width-1 downto 0)
    );
end data_memory;

architecture BEHAV of data_memory is
    type datamemory_mem is array (0 to 19) of std_logic_vector(nbit_width-1 downto 0);
    signal data_mem : datamemory_mem := (
					x"00000011",
					x"00111000",
					x"00100001",
					x"01000001",
					x"00111100",
					x"01111000",
					x"10000001",
					x"00011000",
					x"00000000",
					x"01000010",
					x"01100000",
					x"00100101",
					x"00000011",
					x"00000000",
					x"00000000",
					x"01111100",
					x"00000000",
					x"00111111",
					x"01000011",
					x"00011100"
					);
begin
    process(clk,address)
    begin
	     if (memory_read_ctrl = '1') then
                read_data <= data_mem(to_integer(unsigned(address)));
            end if;
            if (memory_write_ctrl = '1') then
                data_mem(to_integer(unsigned(address))) <= write_data;
            end if;
    end process;
end BEHAV;

