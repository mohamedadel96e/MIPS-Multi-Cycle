library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ALU_TB is 
end entity;

architecture rtl of ALU_TB is
  signal ALUControl : std_logic_vector(2 downto 0);
  signal A, B, ALUResult : std_logic_vector(31 downto 0);
  signal Zero : std_logic;
begin
  uut: entity work.ALU port map (ALUControl, A, B, ALUResult, Zero);

  stim_proc: process
  begin
      -- Test ADD (ALUControl=010)
      ALUControl <= "010";
      A <= x"00000005"; B <= x"00000003"; wait for 10 ns;
      assert ALUResult = x"00000008" and Zero = '0' report "ADD Failed" severity error;

      -- Test SUB (ALUControl=110)
      ALUControl <= "110";
      A <= x"00000005"; B <= x"00000003"; wait for 10 ns;
      assert ALUResult = x"00000002" and Zero = '0' report "SUB Failed" severity error;

      -- Test Set Less Than (SLT) (ALUControl=111)
      ALUControl <= "111";
      A <= x"00000002"; B <= x"00000005"; wait for 10 ns;
      assert ALUResult(0) = '1' and Zero = '0' report "SLT Failed" severity error;

      -- Test Zero Flag
      ALUControl <= "110";
      A <= x"00000005"; B <= x"00000005"; wait for 10 ns;
      assert Zero = '1' report "Zero Flag Failed" severity error;

      wait;
  end process;
end rtl;