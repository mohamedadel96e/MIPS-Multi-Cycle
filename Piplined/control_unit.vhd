-- Control Unit for Pipelined MIPS
-- Generates all control signals based on opcode

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY control_unit IS
    PORT (
        opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        -- Control signals
        RegDst : OUT STD_LOGIC;
        Branch : OUT STD_LOGIC;
        MemRead : OUT STD_LOGIC;
        MemtoReg : OUT STD_LOGIC;
        MemWrite : OUT STD_LOGIC;
        ALUSrc : OUT STD_LOGIC;
        RegWrite : OUT STD_LOGIC;
        ALUOp : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        Jump : OUT STD_LOGIC
    );
END control_unit;

ARCHITECTURE BEHAV OF control_unit IS
    COMPONENT control_value
        PORT (
            opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            RegDst : OUT STD_LOGIC;
            Branch : OUT STD_LOGIC;
            MemRead : OUT STD_LOGIC;
            MemtoReg : OUT STD_LOGIC;
            MemWrite : OUT STD_LOGIC;
            ALUSrc : OUT STD_LOGIC;
            RegWrite : OUT STD_LOGIC;
            ALUOp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT alu_control
        PORT (
            ALUOp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            ALU_ctrl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL alu_opcode : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN
    -- Jump signal: asserted for J-type instructions (opcode = 000010)
    Jump <= '1' WHEN opcode = "000010" ELSE
        '0';

    Ucontrol_value : control_value PORT MAP(
        opcode => opcode,
        RegDst => RegDst,
        Branch => Branch,
        MemRead => MemRead,
        MemtoReg => MemtoReg,
        MemWrite => MemWrite,
        ALUSrc => ALUSrc,
        RegWrite => RegWrite,
        ALUOp => alu_opcode
    );

    Ualu_control : alu_control PORT MAP(
        ALUOp => alu_opcode,
        funct => funct,
        ALU_ctrl => ALUOp
    );

END BEHAV;