# Single-Cycle MIPS Processor

## Overview
This repository contains the VHDL implementation of a single-cycle MIPS processor. The single-cycle architecture simplifies the design by executing each instruction in a single clock cycle.
## MIPS Architecture
The MIPS architecture is a RISC (Reduced Instruction Set Computing) architecture characterized by its simplicity, regularity, and ease of implementation. 

## Components
### Instruction Memory (IM)
- Stores the program instructions.
- Instructions are fetched from the instruction memory during the fetch stage of the processor pipeline.

### Register File (RF)
- Stores the general-purpose registers (GPRs) used for data manipulation.
- Provides operands for arithmetic and logical operations.

### ALU (Arithmetic Logic Unit)
- Performs arithmetic and logical operations on data operands.
- Executes operations specified by the decoded instruction.

### Data Memory (DM)
- Stores data accessed by load and store instructions.
- Reads from or writes to memory based on the memory access instruction.

### Control Unit (CU)
- Generates control signals based on the decoded instruction.
- Controls the operation of various components within the processor.

### PC (Program Counter)
- Holds the address of the next instruction to be fetched.
- Updated based on the control flow of the program.

## Operation
1. **Fetch:** Fetch the next instruction from the instruction memory using the Program Counter (PC).
2. **Decode:** Decode the instruction to determine the operation and required operands.
3. **Execute:** Execute the operation using the ALU and access registers or memory as necessary.
4. **Writeback:** Write the result back to the destination register or memory.

![Single Cycle datapath](img/singleCycle.png)