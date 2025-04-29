library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity Sign_Extend is
  port (
      Immediate : in  std_logic_vector(15 downto 0);
      Extended  : out std_logic_vector(31 downto 0)
  );
end entity;

architecture Behavioral of Sign_Extend is
begin
  Extended <= std_logic_vector(resize(signed(Immediate), 32));
end Behavioral;