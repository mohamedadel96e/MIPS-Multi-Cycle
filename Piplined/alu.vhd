LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY alu IS
    GENERIC (
        nbit_width : INTEGER := 32
    );
    PORT (
        opcode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        input1, input2 : IN STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        result : OUT STD_LOGIC_VECTOR(nbit_width - 1 DOWNTO 0);
        zero : OUT STD_LOGIC
    );
END alu;

ARCHITECTURE BEHAV OF alu IS
    SIGNAL temp_result : STD_LOGIC_VECTOR(nbit_width DOWNTO 0);
BEGIN
    -- with opcode select
    --   temp_result <= ('0' & input1) + ('0' & input2) when "011",  -- Addition
    --  ('0' & input1) - ('0' & input2) when "100",  -- Subtraction
    --('0' & input1) and ('0' & input2)when "101",  -- AND
    --('0' & input1) or ('0' & input2) when "110",   -- OR
    --  ('0' & input1) + ('0' & input2) when "001",  -- calculate address for LW / SW
    --('0' & input1) + ('0' & input2) when others;  -- addi

    --zero <= '1' when (temp_result = '0' & x"00000000") else '0';

    --result <= temp_result(nbit_width-1 downto 0);  -- ignore the carry

    PROCESS (opcode, input1, input2)

    BEGIN

        CASE opcode IS

                --when "011" => -- addition 

                --temp_result <= ('0' & input1) + ('0' & input2);

                --zero <= '0';
            WHEN "100" => -- subtraction 

                temp_result <= ('0' & input1) - ('0' & input2);

                zero <= '0';
            WHEN "101" => -- and

                temp_result <= ('0' & input1) AND ('0' & input2);

                zero <= '0';
            WHEN "000" => -- Nand

                temp_result <= ('0' & input1) NAND ('0' & input2);

                zero <= '0';
            WHEN "011" => --slt

                IF (input1 < input2) THEN
                    temp_result <= (0 => '1', OTHERS => '0');
                    zero <= '0';
                ELSE
                    temp_result <= (OTHERS => '0');
                    zero <= '0';
                END IF;

            WHEN "110" => -- or

                temp_result <= ('0' & input1) OR ('0' & input2);

                zero <= '0';
            WHEN "001" => -- lw sw 

                temp_result <= ('0' & input1) + ('0' & input2);

                zero <= '0';
            WHEN "111" => --addi

                temp_result <= ('0' & input1) + ('0' & input2);

                zero <= '0';

            WHEN OTHERS => --beq/bneq	  --check with instruction 
                IF (input1 = input2) THEN
                    zero <= '1';

                ELSE
                    zero <= '0';

                END IF;

        END CASE;

    END PROCESS;

    -- ignore the carry

    result <= temp_result(nbit_width - 1 DOWNTO 0);

END BEHAV;