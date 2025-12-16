LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

USE ieee.std_logic_unsigned.ALL;

ENTITY register_file IS
    GENERIC (
        nbit_width : INTEGER := 32;
        num_of_registers : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        read_register1, read_register2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        write_register : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        register_write_ctrl : IN STD_LOGIC;
        read_data1, read_data2 : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0)
    );
END register_file;

ARCHITECTURE BEHAV OF register_file IS

    TYPE registerfile_mem IS ARRAY (0 TO num_of_registers - 1) OF STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
    -- default value in the all register is (0)
    --with aperations that full 
    SIGNAL reg_mem : registerfile_mem := (OTHERS => (OTHERS => '0'));

BEGIN

    PROCESS (clk)
    BEGIN
        IF (clk'event AND clk = '1') THEN
            IF (register_write_ctrl = '1') THEN
                IF (conv_integer(write_register) = 0) THEN
                    reg_mem(0) <= (OTHERS => '0'); -- Ensure $zero remains 0
                ELSE
                    reg_mem(conv_integer(write_register)) <= write_data;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk, read_register1, read_register2)
    BEGIN
        IF (conv_integer(read_register1) = 0) THEN
            read_data1 <= x"00000000";
        ELSE
            read_data1 <= reg_mem(conv_integer(read_register1));
        END IF;

        IF (conv_integer(read_register2) = 0) THEN
            read_data2 <= x"00000000";
        ELSE
            read_data2 <= reg_mem(conv_integer(read_register2));
        END IF;
    END PROCESS;
END BEHAV;