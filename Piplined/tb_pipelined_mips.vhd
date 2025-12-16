-- Testbench for 5-Stage Pipelined MIPS Processor
-- Demonstrates pipeline operation with sample instructions

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_pipelined_mips IS
END tb_pipelined_mips;

ARCHITECTURE test OF tb_pipelined_mips IS

    -- Component declaration
    COMPONENT pipelined_mips
        GENERIC (
            nbit_width : INTEGER := 32
        );
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT;

    -- Test signals
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';

    -- Clock period
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the pipelined MIPS processor
    UUT : pipelined_mips
    GENERIC MAP(
        nbit_width => 32
    )
    PORT MAP(
        clk => clk,
        reset => reset
    );

    -- Clock generation process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- Initial reset
        reset <= '1';
        WAIT FOR clk_period * 2;
        reset <= '0';

        -- Let the pipeline execute instructions
        -- The instruction memory contains:
        -- 1. lw $2, 2($0)     - Load word from memory[2] to $2
        -- 2. lw $1, 0($6)     - Load word from memory[$6] to $1
        -- 3. lw $2, 0($5)     - Load word from memory[$5] to $2
        -- 4. lw $1, 1($0)     - Load word from memory[1] to $1
        -- 5. addi $5, $0, 2   - Add immediate: $5 = $0 + 2
        -- 6. sw $4, 0($5)     - Store word: memory[$5] = $4
        -- 7. addi $6, $0, 1   - Add immediate: $6 = $0 + 1
        -- 8. addi $5, $5, 1   - Add immediate: $5 = $5 + 1
        -- 9. addi $6, $6, 1   - Add immediate: $6 = $6 + 1
        -- 10. addi $3, $0, 20 - Add immediate: $3 = $0 + 20
        -- 11. add $4, $2, $1  - R-type: $4 = $2 + $1
        -- 12. sub $6, $1, $5  - R-type: $6 = $1 - $5
        -- 13. and $13, $4, $7 - R-type: $13 = $4 AND $7
        -- 14. nand $13, $4, $7- R-type: $13 = $4 NAND $7
        -- 15. or $5, $1, $4   - R-type: $5 = $1 OR $4
        -- 16. slt $4, $2, $3  - R-type: $4 = ($2 < $3) ? 1 : 0
        -- 17. beq $1, $4, 2   - Branch if $1 == $4, offset = 2
        -- 18. beq $10, $11, 1 - Branch if $10 == $11, offset = 1

        -- Run for enough cycles to see pipeline in action
        -- Note: Pipeline takes 5 cycles to fill and complete first instruction
        WAIT FOR clk_period * 50;

        REPORT "Simulation completed successfully!" SEVERITY note;
        WAIT;
    END PROCESS;

END test;