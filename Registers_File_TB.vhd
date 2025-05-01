library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Registers_File_TB is 
end entity;

architecture Behavioral of Registers_File_TB is
  signal clk, RegWrite : std_logic := '0';
  signal ReadReg1, ReadReg2, WriteReg : std_logic_vector(4 downto 0);
  signal WriteData, ReadData1, ReadData2 : std_logic_vector(31 downto 0);
  constant clk_period : time := 10 ns;
begin
  uut: entity work.Registers_File port map (
      clk, RegWrite, ReadReg1, ReadReg2, WriteReg, WriteData, ReadData1, ReadData2
  );

  clk_process: process
  begin
      clk <= '0'; wait for clk_period/2;
      clk <= '1'; wait for clk_period/2;
  end process;

  stim_proc: process
  begin
      -- Initialize
      RegWrite <= '0'; WriteReg <= "00000"; WriteData <= x"00000000"; wait for clk_period;

      -- Write to Register 5
      WriteReg <= "00101"; WriteData <= x"12345678"; RegWrite <= '1'; wait for clk_period;
      RegWrite <= '0'; wait for clk_period;

      -- Read from Register 5
      ReadReg1 <= "00101"; wait for 1 ns;
      assert ReadData1 = x"12345678" report "Register Write/Read Failed" severity error;

      -- Ensure Register 0 is Read-Only
      WriteReg <= "00000"; WriteData <= x"DEADBEEF"; RegWrite <= '1'; wait for clk_period;
      RegWrite <= '0'; ReadReg1 <= "00000"; wait for 1 ns;
      assert ReadData1 = x"00000000" report "Register 0 is Writable" severity error;

      wait;
  end process;
end Behavioral;