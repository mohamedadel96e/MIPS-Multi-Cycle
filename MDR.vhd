library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity MDR is 
  port (
    clk: in std_logic;
    DataIn: in std_logic_vector(31 downto 0);
    DataOut: out std_logic_vector(31 downto 0)
  );
end entity;

architecture Behavioral of MDR is 
begin 
  process (clk) 
  begin
    if rising_edge(clk) then 
      DataOut <= DataIn; 
    end if;
  end process;
end architecture;