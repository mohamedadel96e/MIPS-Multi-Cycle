# 5-Stage Pipelined MIPS Processor - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [What is Pipelining?](#what-is-pipelining)
3. [Architecture Overview](#architecture-overview)
4. [Pipeline Stages](#pipeline-stages)
5. [Data Hazards and Forwarding](#data-hazards-and-forwarding)
6. [Component Details](#component-details)
7. [Control Signals](#control-signals)
8. [Instruction Format](#instruction-format)
9. [Data Flow Diagrams](#data-flow-diagrams)
10. [Testing](#testing)
11. [File Structure](#file-structure)

---

## Project Overview

### What is This Project?

This project implements a **5-stage pipelined MIPS processor** in VHDL. Think of it as a mini-computer processor that can execute MIPS assembly instructions efficiently by working on multiple instructions simultaneously.

### Why Pipelining?

Imagine an assembly line in a factory:
- **Without Pipeline (Single-Cycle)**: You complete one entire car before starting the next.
- **With Pipeline**: While one worker adds wheels, another paints, and another installs seats - all working on different cars simultaneously.

Our processor does the same with instructions - while one instruction is being executed, another is being decoded, and another is being fetched!

### Key Features

✅ **5-Stage Pipeline**: IF → ID → EX → MEM → WB  
✅ **Data Hazard Detection**: Automatic detection of dependencies  
✅ **Data Forwarding**: Bypasses register file when data is ready  
✅ **Support for Multiple Instruction Types**: R-Type, I-Type, Load/Store, Branch  
✅ **32-bit Architecture**: 32 general-purpose registers, 32-bit data path  
✅ **Comprehensive Testing**: 40+ test instructions covering all scenarios  

### Performance

- **Theoretical Speedup**: Up to 5× faster than single-cycle (one instruction per clock in steady state)
- **Clock Frequency**: Limited by slowest pipeline stage
- **CPI (Cycles Per Instruction)**: Ideally 1, may increase with hazards

---

## What is Pipelining?

### Basic Concept

Pipelining divides instruction execution into smaller stages, allowing multiple instructions to be processed simultaneously in different stages.

```
Time →
Cycle 1:  [Inst1: IF]
Cycle 2:  [Inst2: IF] [Inst1: ID]
Cycle 3:  [Inst3: IF] [Inst2: ID] [Inst1: EX]
Cycle 4:  [Inst4: IF] [Inst3: ID] [Inst2: EX] [Inst1: MEM]
Cycle 5:  [Inst5: IF] [Inst4: ID] [Inst3: EX] [Inst2: MEM] [Inst1: WB]
```

### Advantages

1. **Increased Throughput**: Complete one instruction per clock cycle (in ideal case)
2. **Better Hardware Utilization**: All pipeline stages working simultaneously
3. **Faster Execution**: Overall program execution time reduced

### Challenges

1. **Data Hazards**: When an instruction needs data from a previous instruction
2. **Control Hazards**: Branch instructions can disrupt pipeline flow
3. **Structural Hazards**: Hardware resource conflicts (avoided by design)

---

## Architecture Overview

### High-Level Block Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                      5-STAGE PIPELINED MIPS                          │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────┐    ┌──────┐    ┌────┐    ┌─────┐    ┌────┐               │
│  │ IF │ -> │IF/ID │ -> │ ID │ -> │ID/EX│ -> │ EX │ -> ...         │
│  └────┘    └──────┘    └────┘    └─────┘    └────┘               │
│     ↑          ↑          ↑          ↑          ↑                   │
│     │          │          │          │          │                   │
│  [PC]    [Pipeline Reg] [Control] [Pipeline] [ALU + Forward]       │
│                                                                      │
│  ... -> ┌──────┐ -> ┌─────┐ -> ┌───────┐ -> ┌────┐               │
│         │EX/MEM│    │ MEM │    │MEM/WB │    │ WB │               │
│         └──────┘    └─────┘    └───────┘    └────┘               │
│             ↑          ↑           ↑           ↑                    │
│       [Pipeline Reg] [Data Mem] [Pipeline] [Writeback]            │
│                                                                      │
│                  ┌─────────────────┐                               │
│                  │ Forwarding Unit │ (Hazard Detection)            │
│                  └─────────────────┘                               │
└──────────────────────────────────────────────────────────────────────┘
```

### Major Components

1. **Pipeline Registers**: Store data between stages (IF/ID, ID/EX, EX/MEM, MEM/WB)
2. **Functional Units**: PC, ALU, Register File, Memory Units
3. **Control Logic**: Control Unit, Forwarding Unit
4. **Multiplexers**: Route data based on control signals

---

## Pipeline Stages

### Stage 1: Instruction Fetch (IF)

**Purpose**: Fetch the next instruction from memory

**Components Used**:
- Program Counter (PC)
- Instruction Memory
- PC Adder (+4)

**Operations**:
1. Read instruction from memory at address = PC
2. Increment PC by 4 (next instruction)
3. Store PC+4 and instruction in IF/ID register

**Timing**: 1 clock cycle

```vhdl
-- Key signals:
pc_output          -- Current PC value
instruction_if     -- Fetched instruction
pc_plus4          -- Next sequential PC (PC + 4)
```

### Stage 2: Instruction Decode (ID)

**Purpose**: Decode instruction and read register operands

**Components Used**:
- Control Unit
- Register File
- Sign Extender

**Operations**:
1. Decode instruction fields (opcode, rs, rt, rd, immediate)
2. Generate all control signals
3. Read up to 2 registers from register file
4. Sign-extend 16-bit immediate to 32 bits
5. Store everything in ID/EX register

**Timing**: 1 clock cycle

```vhdl
-- Instruction fields extracted:
opcode    <= instruction(31:26)  -- Operation type
rs        <= instruction(25:21)  -- Source register 1
rt        <= instruction(20:16)  -- Source register 2
rd        <= instruction(15:11)  -- Destination register
immediate <= instruction(15:0)   -- Immediate value
funct     <= instruction(5:0)    -- Function code (R-Type)
```

**Control Signals Generated**:
- RegDst, ALUSrc, MemRead, MemWrite, MemtoReg, RegWrite, Branch, ALUOp, Jump

### Stage 3: Execute (EX)

**Purpose**: Perform ALU operation and calculate addresses

**Components Used**:
- ALU (Arithmetic Logic Unit)
- Forwarding Unit
- 3-to-1 Forwarding Muxes
- Branch Adder
- Shift Left 2

**Operations**:
1. **Forwarding Unit**: Detect data hazards and generate forwarding signals
2. **Forward Muxes**: Select correct operands (register file, EX/MEM, or MEM/WB)
3. **ALU**: Perform arithmetic/logic operation
4. **RegDst Mux**: Select destination register (rt or rd)
5. **Branch Target**: Calculate branch target address
6. Store results in EX/MEM register

**Timing**: 1 clock cycle

```vhdl
-- Forwarding logic:
if (EX/MEM writes to register we need) then
    Forward from EX/MEM  -- forwardA/B = "01"
elsif (MEM/WB writes to register we need) then
    Forward from MEM/WB  -- forwardA/B = "10"
else
    Use register file    -- forwardA/B = "00"
end if
```

### Stage 4: Memory Access (MEM)

**Purpose**: Access data memory for load/store instructions

**Components Used**:
- Data Memory
- Branch Decision Logic

**Operations**:
1. **Load**: Read data from memory at address = ALU result
2. **Store**: Write data to memory at address = ALU result
3. **Branch**: Determine if branch should be taken (Branch AND Zero)
4. Store data and control signals in MEM/WB register

**Timing**: 1 clock cycle

```vhdl
-- Branch decision:
PCSrc <= Branch AND Zero  -- Take branch if condition met
```

### Stage 5: Write Back (WB)

**Purpose**: Write result back to register file

**Components Used**:
- MemtoReg Mux
- Register File (write port)

**Operations**:
1. **MemtoReg Mux**: Select between ALU result or memory data
2. **Register File**: Write selected data to destination register (if RegWrite = '1')

**Timing**: 1 clock cycle

```vhdl
-- Write back selection:
if MemtoReg = '1' then
    write_data <= memory_data    -- Load instruction
else
    write_data <= alu_result     -- ALU instruction
end if
```

### Pipeline Register Summary

| Register | Stored Information | Purpose |
|----------|-------------------|---------|
| **IF/ID** | PC+4, Instruction | Pass IF stage outputs to ID |
| **ID/EX** | Control signals, Register data, Immediate, Rs, Rt, Rd | Pass ID stage outputs to EX |
| **EX/MEM** | Control signals, ALU result, Write data, Destination register, Branch target | Pass EX stage outputs to MEM |
| **MEM/WB** | Control signals, Memory data, ALU result, Destination register | Pass MEM stage outputs to WB |

---

## Data Hazards and Forwarding

### What are Data Hazards?

A data hazard occurs when an instruction depends on the result of a previous instruction that hasn't completed yet.

### Example Without Forwarding

```assembly
add $1, $2, $3   # Cycle 1: Write $1 in cycle 5 (WB stage)
sub $4, $1, $5   # Cycle 2: Needs $1 in cycle 3 (EX stage) - HAZARD!
```

**Problem**: `sub` needs $1 in cycle 3, but `add` doesn't write it until cycle 5!

### Types of Data Hazards

#### 1. EX Hazard (Most Critical)

**Scenario**: Current instruction (in EX) needs data from previous instruction (in MEM)

```assembly
add $1, $2, $3   # In MEM stage
sub $4, $1, $5   # In EX stage - needs $1
```

**Solution**: Forward data from EX/MEM pipeline register to ALU input  
**Forwarding Signal**: `forwardA` or `forwardB` = "01"

#### 2. MEM Hazard

**Scenario**: Current instruction (in EX) needs data from instruction 2 cycles back (in WB)

```assembly
add $1, $2, $3   # In WB stage
nop              # In MEM stage
sub $4, $1, $5   # In EX stage - needs $1
```

**Solution**: Forward data from MEM/WB pipeline register to ALU input  
**Forwarding Signal**: `forwardA` or `forwardB` = "10"

#### 3. Load-Use Hazard (Special Case)

**Scenario**: Load instruction followed immediately by instruction using loaded data

```assembly
lw $1, 0($2)     # Load from memory
add $4, $1, $3   # Uses $1 immediately - STALL NEEDED!
```

**Problem**: Memory data not available until end of MEM stage  
**Solution**: 
- Option 1: Pipeline stall (add bubble/NOP)
- Option 2: Compiler reorders instructions
- Our implementation: Forwards from MEM/WB (assumes stall or reordering done)

### Forwarding Unit Logic

```vhdl
-- Forwarding for ALU Input A (Rs):
if (EX/MEM.RegWrite = '1' AND EX/MEM.Rd ≠ 0 AND EX/MEM.Rd = ID/EX.Rs) then
    forwardA <= "01"  -- Forward from EX/MEM
elsif (MEM/WB.RegWrite = '1' AND MEM/WB.Rd ≠ 0 AND MEM/WB.Rd = ID/EX.Rs) then
    forwardA <= "10"  -- Forward from MEM/WB
else
    forwardA <= "00"  -- No forwarding
end if

-- Same logic for forwardB (Rt)
```

### Forwarding Paths

```
┌─────────────────────────────────────────────────────────────┐
│                    Forwarding Paths                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  EX/MEM.ALU_Result ──┐                                     │
│                      │                                     │
│                      ├──> [3:1 MUX A] ──> ALU Input A     │
│  MEM/WB.WriteData ───┤          ↑                          │
│                      │          │                          │
│  ID/EX.ReadData1 ────┘    forwardA (2 bits)              │
│                                                             │
│  EX/MEM.ALU_Result ──┐                                     │
│                      │                                     │
│                      ├──> [3:1 MUX B] ──> ALU Input B     │
│  MEM/WB.WriteData ───┤          ↑                          │
│                      │          │                          │
│  ID/EX.ReadData2 ────┘    forwardB (2 bits)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why Forwarding Works

1. **ALU result available early**: ALU computes result at end of EX stage
2. **Bypass register file**: Don't wait for WB stage to write, use result directly
3. **Priority scheme**: EX/MEM has higher priority than MEM/WB (most recent data)
4. **Register $0 check**: Never forward for register $0 (always zero in MIPS)

---

## Component Details

### 1. Program Counter (pc.vhd)

**Purpose**: Stores the address of the current instruction

**Inputs**:
- `clk`: Clock signal
- `input`: Next PC value (from mux)

**Outputs**:
- `output`: Current PC value

**Behavior**: Updates on rising clock edge

```vhdl
process(clk)
begin
    if rising_edge(clk) then
        output <= input;
    end if;
end process;
```

### 2. Instruction Memory (instruction_memory.vhd)

**Purpose**: Stores program instructions (read-only)

**Inputs**:
- `address`: PC value (instruction address)

**Outputs**:
- `instruction`: 32-bit instruction at given address

**Characteristics**:
- **Asynchronous read**: Output immediately when address changes
- **Size**: 40 instructions (expandable)
- **Addressing**: Word-addressable (address 0, 1, 2... not byte addresses)

**Memory Contents**: See TEST_INSTRUCTIONS.md for detailed instruction list

### 3. Register File (register_file.vhd)

**Purpose**: Stores 32 general-purpose 32-bit registers

**Inputs**:
- `clk`: Clock signal
- `read_register1`, `read_register2`: Register addresses to read (5 bits each)
- `write_register`: Register address to write (5 bits)
- `write_data`: Data to write (32 bits)
- `register_write_ctrl`: Enable write operation

**Outputs**:
- `read_data1`, `read_data2`: Data from registers (32 bits each)

**Special Features**:
- **Register $0**: Always reads as 0 (hardwired)
- **Dual-read ports**: Can read 2 registers simultaneously
- **Single-write port**: Writes on rising clock edge
- **Asynchronous read**: Read data available immediately
- **Synchronous write**: Write occurs on clock edge

```vhdl
-- Register $0 is always zero
if (read_register1 = 0) then
    read_data1 <= x"00000000";
else
    read_data1 <= registers(read_register1);
end if;
```

### 4. ALU (alu.vhd)

**Purpose**: Performs arithmetic and logic operations

**Inputs**:
- `opcode`: Operation to perform (3 bits)
- `input1`, `input2`: Operands (32 bits each)

**Outputs**:
- `result`: Operation result (32 bits)
- `zero`: Flag indicating result is zero (for branches)

**Supported Operations**:

| Opcode | Operation | Description |
|--------|-----------|-------------|
| 000 | NAND | Bitwise NAND |
| 001 | OR | Bitwise OR |
| 010 | ADD | Addition (also used for address calculation) |
| 011 | SLT | Set Less Than (signed comparison) |
| 100 | SUB | Subtraction (also used for branch comparison) |
| 101 | AND | Bitwise AND |
| 110 | NOR | Bitwise NOR |

**Zero Flag**: Set when result equals zero (used for BEQ branch decision)

### 5. Control Unit (control_unit.vhd)

**Purpose**: Generates all control signals based on instruction opcode

**Inputs**:
- `opcode`: Instruction opcode (6 bits)
- `funct`: Function field for R-Type (6 bits)

**Outputs**: All control signals (see Control Signals section)

**Structure**:
- **Main Control** (control_value.vhd): Decodes opcode
- **ALU Control** (alu_control.vhd): Generates ALU operation code

**Instruction Types Supported**:

| Type | Opcode | Examples |
|------|--------|----------|
| R-Type | 000000 | add, sub, and, or, slt |
| Load Word | 100011 | lw |
| Store Word | 101011 | sw |
| Branch Equal | 000100 | beq |
| Add Immediate | 001000 | addi |
| Jump | 000010 | j |

### 6. Data Memory (data_memory.vhd)

**Purpose**: Stores program data (read/write)

**Inputs**:
- `clk`: Clock signal
- `address`: Memory address (32 bits, but only lower bits used)
- `write_data`: Data to write (32 bits)
- `memory_write_ctrl`: Enable write
- `memory_read_ctrl`: Enable read

**Outputs**:
- `read_data`: Data read from memory (32 bits)

**Characteristics**:
- **Size**: 256 words (32-bit each)
- **Synchronous operations**: Read/write on clock edge
- **Word-addressable**: Address specifies word, not byte
- **Initialized**: Pre-loaded with test data

### 7. Forwarding Unit (forwarding_unit.vhd)

**Purpose**: Detects data hazards and generates forwarding control signals

**Inputs**:
- `idex_rs`, `idex_rt`: Source registers in EX stage
- `exmem_rd`: Destination register in MEM stage
- `exmem_RegWrite`: Write enable in MEM stage
- `memwb_rd`: Destination register in WB stage
- `memwb_RegWrite`: Write enable in WB stage

**Outputs**:
- `forwardA`: Forwarding control for ALU input A (2 bits)
- `forwardB`: Forwarding control for ALU input B (2 bits)

**Logic**:
```
For each source register (Rs and Rt):
  1. Check EX hazard: Does EX/MEM write to this register?
     → Yes: Forward from EX/MEM (signal = "01")
  2. Check MEM hazard: Does MEM/WB write to this register?
     → Yes: Forward from MEM/WB (signal = "10")
  3. No hazard: Use register file (signal = "00")
```

**Priority**: EX/MEM has higher priority (more recent data)

### 8. 3-to-1 Multiplexer (mux3to1.vhd)

**Purpose**: Select between three data sources for forwarding

**Inputs**:
- `sel`: Selection signal (2 bits)
- `input0`: Data from register file
- `input1`: Data from EX/MEM (forwarded)
- `input2`: Data from MEM/WB (forwarded)

**Output**:
- `output`: Selected data

**Selection Logic**:
- `sel = "00"`: output = input0 (no forwarding)
- `sel = "01"`: output = input1 (forward from EX/MEM)
- `sel = "10"`: output = input2 (forward from MEM/WB)
- `sel = "11"`: output = all zeros (unused)

### 9. Pipeline Registers

#### IF/ID Register (ifid_register.vhd)

**Stores**: PC+4, Instruction  
**Timing**: Updates on rising clock edge  
**Reset**: All outputs to zero

#### ID/EX Register (idex_register.vhd)

**Stores**:
- Control signals (8 signals)
- Data: PC+4, Read data 1 & 2, Sign-extended immediate
- Register addresses: Rs, Rt, Rd

**Special Feature**: Rs added for forwarding unit

#### EX/MEM Register (exmem_register.vhd)

**Stores**:
- Control signals (5 signals)
- Data: Branch target, ALU result, Write data, Zero flag
- Register address: Destination register

#### MEM/WB Register (memwb_register.vhd)

**Stores**:
- Control signals (2 signals)
- Data: Memory data, ALU result
- Register address: Destination register

### 10. Other Components

#### PC Adder (pc_adder.vhd)
Adds 4 to PC (next sequential instruction)

#### Branch Adder (branch_adder.vhd)
Calculates branch target: PC+4 + (offset << 2)

#### Sign Extender (sign_extend.vhd)
Extends 16-bit immediate to 32 bits (preserves sign)

#### Shift Left 2 (shift_left_2.vhd)
Multiplies branch offset by 4 (word alignment)

#### 2-to-1 Multiplexer (mux.vhd)
Generic 2-input multiplexer (various widths)

---

## Control Signals

### Control Signal Table

| Signal | Source | Purpose | Values |
|--------|--------|---------|--------|
| **RegDst** | Control Unit | Select destination register | 0=Rt, 1=Rd |
| **ALUSrc** | Control Unit | Select ALU second operand | 0=Register, 1=Immediate |
| **MemRead** | Control Unit | Enable memory read | 0=No read, 1=Read |
| **MemWrite** | Control Unit | Enable memory write | 0=No write, 1=Write |
| **MemtoReg** | Control Unit | Select write-back data | 0=ALU result, 1=Memory data |
| **RegWrite** | Control Unit | Enable register write | 0=No write, 1=Write |
| **Branch** | Control Unit | Enable branch | 0=No branch, 1=Branch if zero |
| **Jump** | Control Unit | Enable jump | 0=No jump, 1=Jump |
| **ALUOp** | Control Unit → ALU Control | ALU operation code | 3-bit operation code |
| **forwardA** | Forwarding Unit | Forward control for ALU input A | 00=Reg, 01=EX/MEM, 10=MEM/WB |
| **forwardB** | Forwarding Unit | Forward control for ALU input B | 00=Reg, 01=EX/MEM, 10=MEM/WB |
| **PCSrc** | MEM Stage Logic | Select PC source | 0=PC+4, 1=Branch target |
| **Zero** | ALU | ALU result is zero | 0=Non-zero, 1=Zero |

### Control Signals by Instruction Type

#### R-Type (add, sub, and, or, slt, etc.)

```
RegDst    = 1  (use Rd)
ALUSrc    = 0  (use register)
MemRead   = 0
MemWrite  = 0
MemtoReg  = 0  (use ALU result)
RegWrite  = 1  (write to register)
Branch    = 0
Jump      = 0
ALUOp     = depends on funct field
```

#### Load Word (lw)

```
RegDst    = 0  (use Rt)
ALUSrc    = 1  (use immediate for address)
MemRead   = 1  (read from memory)
MemWrite  = 0
MemtoReg  = 1  (use memory data)
RegWrite  = 1  (write to register)
Branch    = 0
Jump      = 0
ALUOp     = 010 (ADD for address calculation)
```

#### Store Word (sw)

```
RegDst    = X  (don't care)
ALUSrc    = 1  (use immediate for address)
MemRead   = 0
MemWrite  = 1  (write to memory)
MemtoReg  = X  (don't care)
RegWrite  = 0  (no register write)
Branch    = 0
Jump      = 0
ALUOp     = 010 (ADD for address calculation)
```

#### Branch Equal (beq)

```
RegDst    = X  (don't care)
ALUSrc    = 0  (compare registers)
MemRead   = 0
MemWrite  = 0
MemtoReg  = X  (don't care)
RegWrite  = 0  (no register write)
Branch    = 1  (branch if equal)
Jump      = 0
ALUOp     = 100 (SUB for comparison)
```

#### Add Immediate (addi)

```
RegDst    = 0  (use Rt)
ALUSrc    = 1  (use immediate)
MemRead   = 0
MemWrite  = 0
MemtoReg  = 0  (use ALU result)
RegWrite  = 1  (write to register)
Branch    = 0
Jump      = 0
ALUOp     = 010 (ADD)
```

---

## Instruction Format

### MIPS Instruction Types

#### R-Type (Register)
```
31      26 25    21 20    16 15    11 10     6 5      0
┌──────────┬────────┬────────┬────────┬────────┬────────┐
│  opcode  │   rs   │   rt   │   rd   │  shamt │ funct  │
│  (6 bit) │ (5 bit)│ (5 bit)│ (5 bit)│ (5 bit)│ (6 bit)│
└──────────┴────────┴────────┴────────┴────────┴────────┘
```
- **opcode**: Always 000000 for R-Type
- **rs**: First source register
- **rt**: Second source register
- **rd**: Destination register
- **shamt**: Shift amount (usually 0)
- **funct**: Specifies operation (add, sub, etc.)

**Example**: `add $1, $2, $3` → 0x00430820

#### I-Type (Immediate)
```
31      26 25    21 20    16 15                      0
┌──────────┬────────┬────────┬────────────────────────┐
│  opcode  │   rs   │   rt   │      immediate         │
│  (6 bit) │ (5 bit)│ (5 bit)│      (16 bit)          │
└──────────┴────────┴────────┴────────────────────────┘
```
- **opcode**: Operation type (addi, lw, sw, beq)
- **rs**: Source register (or base for lw/sw)
- **rt**: Destination register (or source for sw/beq)
- **immediate**: 16-bit constant or offset

**Examples**:
- `addi $1, $2, 5` → 0x20410005
- `lw $1, 4($2)` → 0x8C410004
- `sw $1, 8($2)` → 0xAC410008
- `beq $1, $2, 10` → 0x1022000A

#### J-Type (Jump)
```
31      26 25                                        0
┌──────────┬──────────────────────────────────────────┐
│  opcode  │            address                       │
│  (6 bit) │            (26 bit)                      │
└──────────┴──────────────────────────────────────────┘
```
- **opcode**: 000010 for jump
- **address**: 26-bit target address (shifted left 2)

**Example**: `j 1000` → 0x080003E8

### Instruction Encoding Examples

```assembly
Instruction          Binary/Hex                        Description
─────────────────────────────────────────────────────────────────────
add $3, $1, $2      0x00221820    $3 = $1 + $2
sub $6, $1, $5      0x00253022    $6 = $1 - $5
and $15, $13, $14   0x01AE7824    $15 = $13 & $14
or $16, $13, $14    0x01AE8025    $16 = $13 | $14
slt $20, $18, $19   0x0253A02A    $20 = ($18 < $19) ? 1 : 0
addi $1, $0, 5      0x20010005    $1 = $0 + 5
lw $8, 4($0)        0x8C080004    $8 = Memory[4]
sw $11, 6($0)       0xAC0B0006    Memory[6] = $11
beq $25, $26, -1    0x1339FFFF    if($25==$26) branch
```

---

## Data Flow Diagrams

### Complete Instruction Flow

```
Clock Cycle 1:
  IF: Fetch Inst1
  
Clock Cycle 2:
  IF: Fetch Inst2
  ID: Decode Inst1, Read Registers
  
Clock Cycle 3:
  IF: Fetch Inst3
  ID: Decode Inst2, Read Registers
  EX: Execute Inst1 (ALU operation, forwarding check)
  
Clock Cycle 4:
  IF: Fetch Inst4
  ID: Decode Inst3, Read Registers
  EX: Execute Inst2
  MEM: Memory access for Inst1 (if load/store)
  
Clock Cycle 5 (Steady State):
  IF: Fetch Inst5
  ID: Decode Inst4, Read Registers
  EX: Execute Inst3
  MEM: Memory access for Inst2
  WB: Write back Inst1 result
```

### Data Path for R-Type Instruction (e.g., add $3, $1, $2)

```
Stage 1 (IF):
  PC → Instruction Memory → Instruction
  PC + 4 → Next PC

Stage 2 (ID):
  Instruction[25:21] → Register File (Rs=$1) → Read Data 1
  Instruction[20:16] → Register File (Rt=$2) → Read Data 2
  Control Unit → Generate control signals

Stage 3 (EX):
  Forwarding Unit → Check hazards → forwardA, forwardB
  Read Data 1 → [3:1 MUX A] → ALU Input 1
  Read Data 2 → [3:1 MUX B] → ALU Input 2
  ALU → Compute $1 + $2 → Result
  Instruction[15:11] → Rd=$3

Stage 4 (MEM):
  ALU Result → (pass through, no memory access)
  Rd=$3 → (pass through)

Stage 5 (WB):
  ALU Result → Register File (Write Rd=$3)
```

### Data Path for Load Instruction (e.g., lw $1, 4($2))

```
Stage 1 (IF):
  PC → Instruction Memory → Instruction

Stage 2 (ID):
  Instruction[25:21] → Register File (Rs=$2) → Base Address
  Instruction[15:0] → Sign Extend → Offset (4)
  Control Unit → MemRead=1, MemtoReg=1, RegWrite=1

Stage 3 (EX):
  Base Address + Offset → ALU → Memory Address
  Instruction[20:16] → Rt=$1 (destination)

Stage 4 (MEM):
  Memory Address → Data Memory → Read Data
  MemRead=1 → Enable read

Stage 5 (WB):
  Memory Data → [MemtoReg MUX] → Write Data
  Register File (Write Rt=$1) ← Write Data
```

### Forwarding Scenario Example

```assembly
Instruction 1: add $1, $2, $3   # Produces $1
Instruction 2: sub $4, $1, $5   # Needs $1 (EX hazard)
```

```
Cycle 3:
  Inst1 in EX: Computing $1 = $2 + $3
  
Cycle 4:
  Inst1 in MEM: ALU result ($1) in EX/MEM register
  Inst2 in EX: Needs $1 value
  Forwarding Unit detects: EX/MEM.Rd ($1) = ID/EX.Rs ($1)
  forwardA = "01" → Forward EX/MEM.ALUResult to ALU Input A
  
Result: Inst2 gets correct value without waiting for WB!
```

---

## Testing

### Test Bench (tb_pipelined_mips.vhd)

The testbench simulates the processor and monitors its behavior.

**Key Features**:
- Clock generation (period = 10 ns → 100 MHz)
- Reset control
- Signal monitoring
- Can run for specified number of cycles

**Usage**:
```vhdl
-- Run simulation for 500 ns (50 clock cycles)
-- Monitor register file and memory contents
-- Verify forwarding signals
```

### Test Instructions

The instruction memory contains 40 carefully designed test instructions covering:

1. ✅ Basic initialization
2. ✅ EX hazards (back-to-back dependencies)
3. ✅ MEM hazards (1-cycle gap)
4. ✅ Load-use hazards
5. ✅ Store with forwarding
6. ✅ Multiple consecutive dependencies
7. ✅ All R-Type operations
8. ✅ Comparison operations (SLT)
9. ✅ Complex double dependencies
10. ✅ Branch instructions
11. ✅ Store-load sequences

See **TEST_INSTRUCTIONS.md** for complete documentation of each test case.

### Verification Checklist

- [ ] All instructions execute in correct order
- [ ] Register values match expected results
- [ ] Forwarding signals (forwardA, forwardB) correct for each hazard
- [ ] Memory writes occur at correct addresses with correct data
- [ ] Branch decisions are correct
- [ ] No invalid states in pipeline registers
- [ ] PC increments correctly (except for branches/jumps)

### Expected Results

After running all 40 instructions (ignoring infinite branch loop):

| Register | Expected Value | Source |
|----------|---------------|--------|
| $1 | 5 | Instruction 0 |
| $2 | 3 | Instruction 1 |
| $3 | 8 | Instruction 4 |
| $4 | 13 | Instruction 5 |
| $7 | 40 | Instruction 9 |
| $12 | 10 | Instruction 18 |
| $20 | 1 | Instruction 26 |
| $21 | 0 | Instruction 27 |
| $24 | 12 | Instruction 31 |
| $28 | 51 | Instruction 39 |

Memory:
- Memory[6] = 100 (from instruction 14)
- Memory[7] = 50 (from instruction 37)

---

## File Structure

### Source Files (.vhd)

#### Core Components
- **pipelined_mips.vhd**: Top-level processor entity
- **pc.vhd**: Program Counter
- **instruction_memory.vhd**: Read-only instruction storage
- **register_file.vhd**: 32 general-purpose registers
- **alu.vhd**: Arithmetic Logic Unit
- **data_memory.vhd**: Read/write data storage

#### Pipeline Registers
- **ifid_register.vhd**: IF/ID pipeline register
- **idex_register.vhd**: ID/EX pipeline register
- **exmem_register.vhd**: EX/MEM pipeline register
- **memwb_register.vhd**: MEM/WB pipeline register

#### Control and Hazard Detection
- **control_unit.vhd**: Main control logic
- **control_value.vhd**: Opcode decoder
- **alu_control.vhd**: ALU operation decoder
- **forwarding_unit.vhd**: Data hazard detection and forwarding

#### Supporting Components
- **mux.vhd**: Generic 2-to-1 multiplexer
- **mux3to1.vhd**: 3-to-1 multiplexer for forwarding
- **pc_adder.vhd**: PC incrementer
- **branch_adder.vhd**: Branch target calculator
- **sign_extend.vhd**: Sign extension unit
- **shift_left_2.vhd**: Shift for branch offset

#### Testing
- **tb_pipelined_mips.vhd**: Testbench for simulation

### Documentation Files (.md)

- **PROJECT_DOCUMENTATION.md**: This file - complete project documentation
- **TEST_INSTRUCTIONS.md**: Detailed explanation of all test instructions

### Project Organization

```
Piplined/
├── Core Components
│   ├── pipelined_mips.vhd       (Top level)
│   ├── pc.vhd
│   ├── instruction_memory.vhd
│   ├── register_file.vhd
│   ├── alu.vhd
│   └── data_memory.vhd
│
├── Pipeline Registers
│   ├── ifid_register.vhd
│   ├── idex_register.vhd
│   ├── exmem_register.vhd
│   └── memwb_register.vhd
│
├── Control Logic
│   ├── control_unit.vhd
│   ├── control_value.vhd
│   ├── alu_control.vhd
│   └── forwarding_unit.vhd
│
├── Utility Components
│   ├── mux.vhd
│   ├── mux3to1.vhd
│   ├── pc_adder.vhd
│   ├── branch_adder.vhd
│   ├── sign_extend.vhd
│   └── shift_left_2.vhd
│
├── Testing
│   └── tb_pipelined_mips.vhd
│
└── Documentation
    ├── PROJECT_DOCUMENTATION.md
    └── TEST_INSTRUCTIONS.md
```

---

## How Everything Works Together

### Step-by-Step Execution Example

Let's trace a simple program through the pipeline:

```assembly
0: addi $1, $0, 5     # $1 = 5
1: addi $2, $0, 3     # $2 = 3
2: add $3, $1, $2     # $3 = $1 + $2 = 8
3: add $4, $1, $3     # $4 = $1 + $3 = 13 (EX hazard!)
4: sub $5, $4, $2     # $5 = $4 - $2 = 10 (EX hazard!)
```

### Clock-by-Clock Execution

**Cycle 1**: 
```
IF: Fetch instruction 0 (addi $1, $0, 5)
```

**Cycle 2**:
```
IF: Fetch instruction 1 (addi $2, $0, 3)
ID: Decode instruction 0, read $0, immediate=5
```

**Cycle 3**:
```
IF: Fetch instruction 2 (add $3, $1, $2)
ID: Decode instruction 1, read $0, immediate=3
EX: Execute instruction 0, ALU computes 0+5=5
```

**Cycle 4**:
```
IF: Fetch instruction 3 (add $4, $1, $3)
ID: Decode instruction 2, read $1, $2
EX: Execute instruction 1, ALU computes 0+3=3
MEM: Instruction 0 passes through (no memory access)
```

**Cycle 5**:
```
IF: Fetch instruction 4 (sub $5, $4, $2)
ID: Decode instruction 3, read $1, $3
EX: Execute instruction 2, ALU computes $1+$2
    - No forwarding needed (all values in register file)
MEM: Instruction 1 passes through
WB: Write $1 = 5 to register file
```

**Cycle 6**:
```
IF: Fetch instruction 5
ID: Decode instruction 4, read $4, $2
EX: Execute instruction 3 ($4 = $1 + $3)
    - Forwarding Unit detects: needs $3 from EX/MEM
    - forwardB = "01" (forward from instruction 2's result)
    - ALU computes $1 + 8 = 13 using forwarded value!
MEM: Instruction 2 (ALU result = 8)
WB: Write $2 = 3 to register file
```

**Cycle 7**:
```
IF: Fetch instruction 6
ID: Decode instruction 5
EX: Execute instruction 4 ($5 = $4 - $2)
    - Forwarding Unit detects: needs $4 from EX/MEM
    - forwardA = "01" (forward from instruction 3's result)
    - ALU computes 13 - $2 = 10 using forwarded value!
MEM: Instruction 3 (ALU result = 13)
WB: Write $3 = 8 to register file
```

This example demonstrates how the pipeline maintains throughput while handling data hazards through forwarding!

---

## Performance Analysis

### Ideal Performance

- **CPI (Cycles Per Instruction)**: 1.0 (one instruction completed per cycle in steady state)
- **Speedup over single-cycle**: Up to 5× (theoretical maximum)
- **Throughput**: 5 instructions in flight simultaneously

### Real Performance Factors

1. **Pipeline Fill Time**: First instruction takes 5 cycles to complete
2. **Data Hazards**: Forwarding eliminates most stalls, but load-use may require stalls
3. **Control Hazards**: Branches can cause bubbles (not fully implemented)
4. **Clock Period**: Determined by slowest stage (typically MEM or EX)

### Throughput Calculation

```
Instructions Executed: N
Total Cycles: 5 (fill) + N (steady state) - 1
CPI = (5 + N - 1) / N ≈ 1.0 for large N
```

For 40 instructions:
```
Cycles = 5 + 40 - 1 = 44 cycles
CPI = 44/40 = 1.1
```

Single-cycle would take 40 cycles (assuming same clock), so speedup ≈ 40/44 × 5 = 4.5×

---

## Advanced Topics

### Pipeline Hazards Not Fully Addressed

1. **Control Hazards**: Branch prediction and branch delay slots not implemented
2. **Structural Hazards**: Avoided by design (separate instruction/data memory)
3. **Load-Use Stalls**: Forwarding unit detects but doesn't insert stalls

### Possible Enhancements

1. **Hazard Detection Unit**: Insert pipeline bubbles (NOPs) for load-use hazards
2. **Branch Prediction**: Predict branch outcomes to reduce control hazard penalties
3. **Branch Delay Slot**: Execute instruction after branch regardless of outcome
4. **Cache Memory**: Add instruction and data caches for realistic memory hierarchy
5. **Exception Handling**: Handle overflow, divide-by-zero, etc.
6. **More Instructions**: Multiply, divide, floating-point operations
7. **Performance Counters**: Track stalls, hazards, and efficiency metrics

---

## Common Questions

### Q1: Why do we need pipeline registers?

**Answer**: Pipeline registers store the results of each stage and pass them to the next stage on each clock cycle. Without them, data would be lost as new instructions enter the pipeline.

### Q2: Why can't we just stall instead of forwarding?

**Answer**: Stalling (inserting bubbles) reduces performance. Forwarding allows us to use data as soon as it's computed, maintaining the ideal CPI of 1.0.

### Q3: What happens if we don't implement forwarding?

**Answer**: Without forwarding, many data hazards would require stalls. For back-to-back dependent instructions, we'd need to wait 2-3 cycles, significantly reducing performance.

### Q4: Why is register $0 always zero?

**Answer**: In MIPS architecture, $0 is hardwired to zero by convention. It's useful as a source of constant zero and as a destination for discarded results.

### Q5: How does branch prediction fit in?

**Answer**: This implementation doesn't include branch prediction. In a full processor, branch prediction would guess the branch outcome to avoid stalling the pipeline.

### Q6: Can this processor run real MIPS programs?

**Answer**: It supports a subset of MIPS instructions (R-Type, I-Type, basic memory, branches). Real programs would need more instructions (multiply, floating-point, exceptions, etc.).

### Q7: What's the critical path?

**Answer**: The critical path is likely the EX stage (ALU operation + forwarding mux + control). This determines the maximum clock frequency.

---

## Debugging Tips

### Common Issues and Solutions

1. **Incorrect Register Values**
   - Check forwarding signals (forwardA, forwardB)
   - Verify control signals (RegWrite, MemtoReg)
   - Ensure register $0 always reads as zero

2. **Memory Not Updating**
   - Verify MemWrite control signal
   - Check address calculation
   - Confirm clock edge timing

3. **Branches Not Working**
   - Check Branch control signal
   - Verify Zero flag from ALU
   - Check PCSrc calculation (Branch AND Zero)

4. **Forwarding Not Working**
   - Verify Rs/Rt values in ID/EX register
   - Check Rd values in EX/MEM and MEM/WB
   - Confirm RegWrite signals
   - Check priority (EX/MEM before MEM/WB)

5. **Simulation Errors**
   - Check for uninitialized signals
   - Verify all port connections
   - Ensure generic parameter consistency (nbit_width)
   - Check for race conditions in testbench

### Debugging Checklist

- [ ] All component ports connected correctly
- [ ] Clock signal reaches all flip-flops
- [ ] Reset signal initializes all registers
- [ ] Control signals propagate through pipeline
- [ ] Forwarding unit receives correct inputs
- [ ] Multiplexer select signals are 2 bits (not 1)
- [ ] Register addresses are 5 bits
- [ ] Data buses are 32 bits

---

## References and Resources

### MIPS Architecture
- "Computer Organization and Design" by Patterson & Hennessy
- MIPS Instruction Set Reference
- MIPS Green Sheet (quick reference)

### Pipeline Concepts
- Computer Architecture: A Quantitative Approach
- Digital Design and Computer Architecture by Harris & Harris

### VHDL Resources
- VHDL Tutorial and Reference
- IEEE 1076 VHDL Standard
- Online VHDL simulators and tools

---

## Conclusion

This 5-stage pipelined MIPS processor demonstrates fundamental concepts in computer architecture:

✅ **Pipelining**: Overlapping instruction execution for higher throughput  
✅ **Hazard Detection**: Identifying data dependencies  
✅ **Data Forwarding**: Bypassing register file for efficiency  
✅ **Control Logic**: Generating signals based on instruction type  
✅ **Register File**: Fast access to temporary values  
✅ **Memory Hierarchy**: Separate instruction and data memories  

The implementation showcases how modern processors achieve high performance while managing complex dependencies and maintaining correct program execution.

---

## Appendix: Quick Reference

### Signal Width Reference

| Signal Type | Width | Description |
|-------------|-------|-------------|
| Data | 32 bits | All data values, addresses, instructions |
| Register Address | 5 bits | Selects 1 of 32 registers |
| Control Signals | 1 bit | Most control signals (enable/disable) |
| ALU Control | 3 bits | ALU operation selection |
| Forwarding Control | 2 bits | Selects forwarding source |
| Opcode | 6 bits | Instruction type |
| Funct | 6 bits | R-Type operation code |
| Immediate | 16 bits | I-Type immediate value |

### Instruction Opcode Reference

| Instruction | Opcode | Funct | Type |
|-------------|--------|-------|------|
| add | 000000 | 100000 | R |
| sub | 000000 | 100010 | R |
| and | 000000 | 100100 | R |
| or | 000000 | 100101 | R |
| nor | 000000 | 100111 | R |
| slt | 000000 | 101010 | R |
| addi | 001000 | - | I |
| lw | 100011 | - | I |
| sw | 101011 | - | I |
| beq | 000100 | - | I |
| j | 000010 | - | J |

### Component Connection Summary

```
PC → Instruction Memory → IF/ID → Register File → ID/EX
                                                      ↓
MEM/WB ← Data Memory ← EX/MEM ← ALU ← Forwarding Muxes
   ↓                                            ↑
Register File ← WB Mux                   Forwarding Unit
                                         (monitors EX/MEM, MEM/WB)
```