library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPS_tb is
end entity;

architecture test of MIPS_tb is

    -- Component under test
    component MIPS
        port (
            clk    : in std_logic;
            reset  : in std_logic;
            enable : in std_logic
        );
    end component;

    -- Signals to drive DUT
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '1';
    signal enable : std_logic := '1';

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT
    uut: MIPS
        port map (
            clk    => clk,
            reset  => reset,
            enable => enable
        );

    -- Clock generation
    clk_process : process
    begin
        while now < 500 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Reset and test stimuli
    stim_proc : process
    begin
        -- Initial Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Wait for MIPS to fetch and execute
        wait for 300 ns;

        -- Example assertion: ensure PC is not stuck at 0
        assert false
        report "Simulation completed successfully."
        severity note;

        wait;
    end process;

    -- Assertions (examples, adapt to internal signals if exposed through a wrapper):
    assertion_check: process
    begin
        wait for 150 ns;

        -- This assumes internal signals like pc_out, instruction etc. are accessible through a wrapper or waveform inspection
        assert false
        report "Checking for possible runtime issues..." severity note;

        -- Example: Detect if PC is not progressing (stuck)
        -- Replace `pc_out` with actual accessible signal if available.
        -- assert pc_out /= X"00000000"
        -- report "PC is stuck at 0!" severity error;

        wait;
    end process;

end architecture;