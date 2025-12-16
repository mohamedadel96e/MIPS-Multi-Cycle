library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_Register_TB is
end entity;

architecture Behavioral of PC_Register_TB is
    signal clk, reset, PCWrite : std_logic := '0';
    signal PCIn, PCOut : std_logic_vector(31 downto 0);
    constant clk_period : time := 10 ns;
begin
    uut: entity work.pc port map (clk, reset, PCWrite, PCIn, PCOut);

    clk_process: process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- Reset test
        reset <= '1'; wait for clk_period;
        assert PCOut = x"00400000" report "PC Reset Failed" severity error;
        reset <= '0';

        -- Write test
        PCIn <= x"DEADBEEF"; PCWrite <= '1'; wait for clk_period;
        assert PCOut = x"DEADBEEF" report "PC Write Failed" severity error;

        -- No-write test
        PCIn <= x"12345678"; PCWrite <= '0'; wait for clk_period;
        assert PCOut = x"DEADBEEF" report "PC Unexpected Update" severity error;

        wait for 50 ns;
    end process;
end Behavioral;