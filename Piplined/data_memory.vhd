LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_memory IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        memory_write_ctrl, memory_read_ctrl : IN STD_LOGIC;
        read_data : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
    );
END data_memory;

ARCHITECTURE BEHAV OF data_memory IS
    TYPE datamemory_mem IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0); -- Word Addresable 
    SIGNAL data_mem : datamemory_mem := (
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
        x"00011100",
        others => x"00000000"
    );
BEGIN
    PROCESS (clk, address)
    BEGIN
        IF (memory_read_ctrl = '1') THEN
            read_data <= data_mem(to_integer(unsigned(address)));
        END IF;
        IF (memory_write_ctrl = '1') THEN
            data_mem(to_integer(unsigned(address))) <= write_data;
        END IF;
    END PROCESS;
END BEHAV;