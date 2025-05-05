library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Shift_Left_2 is
  port (
      Input  : in  std_logic_vector(31 downto 0);
      Output : out std_logic_vector(31 downto 0)
  );
end entity;

architecture Behavioral of Shift_Left_2 is
begin
  Output <= Input(29 downto 0) & "00"; -- Shift left by 2
end Behavioral;