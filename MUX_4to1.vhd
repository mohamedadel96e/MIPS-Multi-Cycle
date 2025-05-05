library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity MUX_4to1 is
  generic (N : integer := 32);
  port (
      Sel    : in  std_logic_vector(1 downto 0);
      In0    : in  std_logic_vector(N-1 downto 0);
      In1    : in  std_logic_vector(N-1 downto 0);
      In2    : in  std_logic_vector(N-1 downto 0);
      In3    : in  std_logic_vector(N-1 downto 0);
      OutMux : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture Behavioral of MUX_4to1 is
begin
  OutMux <= In0 when Sel = "00" else
            In1 when Sel = "01" else
            In2 when Sel = "10" else
            In3;
end Behavioral;