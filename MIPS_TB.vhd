LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MIPS_TB IS
END ENTITY MIPS_TB;

ARCHITECTURE test OF MIPS_TB IS
    COMPONENT MIPS IS
        PORT (
            clk, reset : IN STD_LOGIC;
            enable : IN STD_LOGIC
        );
    END COMPONENT;

    -- Signals for the MIPS processor
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '1';
    SIGNAL enable : STD_LOGIC := '1';

    -- Clock period definition
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instantiate the MIPS processor
    uut: MIPS PORT MAP (
        clk => clk,
        reset => reset,
        enable => enable
    );

    -- Clock process
    clk_process: PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Hold reset state for 2 clock cycles
        reset <= '1';
        WAIT FOR clk_period * 2;
        
        -- Release reset
        reset <= '0';
        WAIT FOR clk_period;
        
        -- Enable the processor
        enable <= '1';
        
        -- Run for 20 clock cycles to observe behavior
        WAIT FOR clk_period * 20;
        
        -- End simulation
        WAIT;
    END PROCESS;

END ARCHITECTURE test;