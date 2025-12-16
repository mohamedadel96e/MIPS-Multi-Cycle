library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Control_Unit_TB is
end entity;

architecture sim of Control_Unit_TB is

  -- Clock period definition
  constant clk_period : time := 10 ns;

  -- Signals for DUT
  signal clk        : std_logic := '0';
  signal reset      : std_logic := '1';
  signal Opcode     : std_logic_vector(5 downto 0) := (others => '0');
  signal Zero       : std_logic := '0';
  signal PCWrite    : std_logic;
  signal MemRead    : std_logic;
  signal MemWrite   : std_logic;
  signal IRWrite    : std_logic;
  signal RegDst     : std_logic;
  signal MemtoReg   : std_logic;
  signal RegWrite   : std_logic;
  signal ALUSrcA    : std_logic;
  signal ALUSrcB    : std_logic_vector(1 downto 0);
  signal ALUOp      : std_logic_vector(1 downto 0);
  signal PCSource   : std_logic_vector(1 downto 0);
  signal IorD       : std_logic;

begin

  DUT: entity work.Control_Unit
    port map (
      clk        => clk,
      reset      => reset,
      Opcode     => Opcode,
      Zero       => Zero,
      PCWrite    => PCWrite,
      MemRead    => MemRead,
      MemWrite   => MemWrite,
      IRWrite    => IRWrite,
      RegDst     => RegDst,
      MemtoReg   => MemtoReg,
      RegWrite   => RegWrite,
      ALUSrcA    => ALUSrcA,
      ALUSrcB    => ALUSrcB,
      ALUOp      => ALUOp,
      PCSource   => PCSource,
      IorD       => IorD
    );

  -- Clock generation
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Stimulus process
  stimulus: process
  begin
    -- Initial reset
    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    -- R-type (000000)
    Opcode <= "000000";
    wait for 80 ns;

    -- lw (100011)
    Opcode <= "100011";
    wait for 80 ns;

    -- sw (101011)
    Opcode <= "101011";
    wait for 80 ns;

    -- beq (000100)
    Opcode <= "000100";
    Zero <= '1'; -- rs == rt
    wait for 80 ns;
    Zero <= '0';

    -- j (000010)
    Opcode <= "000010";
    wait for 80 ns;

    -- Finish simulation
    wait for 40 ns;
    assert false report "Testbench simulation complete." severity note;
    wait;
  end process;

end architecture;
