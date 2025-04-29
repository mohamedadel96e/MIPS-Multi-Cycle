library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity Registers_File is 
  port (
    clk: in std_logic;
    RegWrite: in std_logic;
    ReadReg1: in std_logic_vector(4 downto 0);
    ReadReg2: in std_logic_vector(4 downto 0);
    WriteReg: in std_logic_vector(4 downto 0);
    WriteData: in std_logic_vector(31 downto 0);
    ReadData1: out std_logic_vector(31 downto 0);
    ReadData2: out std_logic_vector(31 downto 0)
  );
end entity;


architecture Behavioral of Registers_File is

  type Reg_Array is array (0 to 31) of std_logic_vector(31 downto 0);
  signal Registers: Reg_Array := (others => (others => '0'));

begin
  process (clk)
  begin
    if rising_edge(clk) and RegWrite = '1' then 
      Registers(to_integer(unsigned(WriteReg))) <= WriteData;
    end if;
  end process;
  ReadData1 <= Registers(to_integer(unsigned(ReadReg1)));
  ReadData2 <= Registers(to_integer(unsigned(ReadReg2)));

end Behavioral ; -- Behavioral