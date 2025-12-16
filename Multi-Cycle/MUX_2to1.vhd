library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity MUX_2to1 is
  generic (N : integer := 32);
  port (
      Sel   : in  std_logic;
      In0   : in  std_logic_vector(N-1 downto 0);
      In1   : in  std_logic_vector(N-1 downto 0);
      OutMux: out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture Behavioral of MUX_2to1 is
begin
  OutMux <= In1 when Sel = '1' else In0;
end Behavioral;