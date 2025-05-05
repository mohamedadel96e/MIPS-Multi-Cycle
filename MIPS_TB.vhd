LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.textio.ALL;

ENTITY MIPS_TB IS
END ENTITY;

ARCHITECTURE test OF MIPS_TB IS
    COMPONENT MIPS IS
        PORT (
            clk, reset : IN STD_LOGIC;
            enable : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '1';
    SIGNAL enable : STD_LOGIC := '0';

    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instantiate MIPS processor
    uut : MIPS PORT MAP(
        clk => clk,
        reset => reset,
        enable => enable
    );

    -- Clock generation
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
        enable <= '0';
        WAIT FOR clk_period * 2;

        -- Start simulation
        reset <= '0';
        enable <= '1';

        -- Run for sufficient cycles
        WAIT FOR clk_period * 50;

        -- Add specific checks here
        -- Example:
        -- assert <<signal uut.reg_file.registers(1) : std_logic_vector>> = x"00000005"
        --   report "Register 1 incorrect" severity error;

        WAIT;
    END PROCESS;

END ARCHITECTURE;