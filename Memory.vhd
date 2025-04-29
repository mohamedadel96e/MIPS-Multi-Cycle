library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Memory is 
port (
  clk: in std_logic;
  MemRead: in std_logic;
  MemWrite: in std_logic;
  Address: in std_logic_vector(31 downto 0);
  DataIn: in std_logic_vector(31 downto 0);
  Dataout: out std_logic_vector(31 downto 0)
);
end entity;

architecture Behavioral of Memory is 
  type RAM_Array is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal RAM: RAM_Array := (OTHERS => (OTHERS => '0'));

begin 
  process (clk)
  begin
    if rising_edge(clk) and MemWrite = '1' then 
    RAM(to_integer(unsigned(Address(9 downto 2)))) <= DataIn;
    end if;
  end process;
  DataOut <= RAM(to_integer(unsigned(Address(9 downto 2)))) when MemRead = '1' else (others => '0');

end architecture;