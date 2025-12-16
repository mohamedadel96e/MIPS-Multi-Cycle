library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity IR is 
  port (
    clk: in std_logic;
    IRWrite: in std_logic;
    DataIn: in std_logic_vector(31 downto 0);
    DataOut: out std_logic_vector(31 downto 0)
  );
end entity;


architecture Behavioral of IR is 
  signal Instruction: std_logic_vector(31 downto 0);
begin 
  process (clk)
  begin
    if rising_edge(clk) and IRWrite = '1' then 
      Instruction <= DataIn;
    end if;
  end process;
  DataOut <= Instruction;

end architecture;