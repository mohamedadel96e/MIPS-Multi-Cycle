# Pipelined MIPS Test Instructions Documentation

This document provides a comprehensive explanation of all test instructions in the instruction memory, their purpose, inputs, and expected outputs. The test suite is designed to thoroughly test the forwarding unit and data hazard detection.

---

## Table of Contents
1. [Basic Instructions (No Hazards)](#section-1-basic-instructions-no-hazards)
2. [EX Hazard - Back-to-Back Dependencies](#section-2-ex-hazard---back-to-back-dependencies)
3. [MEM Hazard - 1 Instruction Gap](#section-3-mem-hazard---1-instruction-gap)
4. [Load-Use Hazard](#section-4-load-use-hazard)
5. [Store with Forwarding](#section-5-store-with-forwarding)
6. [Multiple Dependencies](#section-6-multiple-dependencies)
7. [R-Type Instructions Testing](#section-7-r-type-instructions-testing)
8. [Set Less Than (SLT)](#section-8-set-less-than-slt)
9. [Complex Forwarding Scenario](#section-9-complex-forwarding-scenario)
10. [Branch Testing](#section-10-branch-testing)
11. [Additional Store/Load](#section-11-additional-storeload)

---

## Section 1: Basic Instructions (No Hazards)

**Purpose**: Initialize registers with simple values. No data hazards occur here.

### Instruction 0: `addi $1, $0, 5`
- **Address**: 0
- **Hex**: `0x20010005`
- **Operation**: Add Immediate
- **Description**: $1 = $0 + 5
- **Inputs**: $0 = 0, Immediate = 5
- **Expected Output**: $1 = 5
- **Hazard**: None

### Instruction 1: `addi $2, $0, 3`
- **Address**: 1
- **Hex**: `0x20020003`
- **Operation**: Add Immediate
- **Description**: $2 = $0 + 3
- **Inputs**: $0 = 0, Immediate = 3
- **Expected Output**: $2 = 3
- **Hazard**: None

### Instruction 2: `addi $3, $0, 7`
- **Address**: 2
- **Hex**: `0x20030007`
- **Operation**: Add Immediate
- **Description**: $3 = $0 + 7
- **Inputs**: $0 = 0, Immediate = 7
- **Expected Output**: $3 = 7
- **Hazard**: None

### Instruction 3: `addi $4, $0, 10`
- **Address**: 3
- **Hex**: `0x2004000A`
- **Operation**: Add Immediate
- **Description**: $4 = $0 + 10
- **Inputs**: $0 = 0, Immediate = 10
- **Expected Output**: $4 = 10
- **Hazard**: None

---

## Section 2: EX Hazard - Back-to-Back Dependencies

**Purpose**: Test forwarding from EX/MEM stage when instructions have immediate dependencies.

### Instruction 4: `add $3, $1, $2`
- **Address**: 4
- **Hex**: `0x00221820`
- **Operation**: Add (R-Type)
- **Description**: $3 = $1 + $2
- **Inputs**: $1 = 5, $2 = 3
- **Expected Output**: $3 = 8
- **Hazard**: None (first in sequence)
- **Note**: This instruction produces a result that the next instruction needs

### Instruction 5: `add $4, $1, $3`
- **Address**: 5
- **Hex**: `0x00232020`
- **Operation**: Add (R-Type)
- **Description**: $4 = $1 + $3
- **Inputs**: $1 = 5, $3 = 8 (from instruction 4)
- **Expected Output**: $4 = 13
- **Hazard**: **EX Hazard** - Reads $3 which is being computed by instruction 4
- **Forwarding**: forwardB = "01" (forward from EX/MEM stage)
- **Critical**: Without forwarding, would read old value of $3 (7)

### Instruction 6: `sub $6, $2, $4`
- **Address**: 6
- **Hex**: `0x00443022`
- **Operation**: Subtract (R-Type)
- **Description**: $6 = $2 - $4
- **Inputs**: $2 = 3, $4 = 13 (from instruction 5)
- **Expected Output**: $6 = -10 (0xFFFFFFF6 in 2's complement)
- **Hazard**: **EX Hazard** - Reads $4 which is being computed by instruction 5
- **Forwarding**: forwardB = "01" (forward from EX/MEM stage)

---

## Section 3: MEM Hazard - 1 Instruction Gap

**Purpose**: Test forwarding from MEM/WB stage when there's one instruction between producer and consumer.

### Instruction 7: `addi $5, $0, 20`
- **Address**: 7
- **Hex**: `0x20050014`
- **Operation**: Add Immediate
- **Description**: $5 = $0 + 20
- **Inputs**: $0 = 0, Immediate = 20
- **Expected Output**: $5 = 20
- **Hazard**: None

### Instruction 8: `nop`
- **Address**: 8
- **Hex**: `0x00000000`
- **Operation**: No Operation
- **Description**: Placeholder instruction (creates gap)
- **Expected Output**: No effect
- **Hazard**: None

### Instruction 9: `add $7, $5, $5`
- **Address**: 9
- **Hex**: `0x00A53820`
- **Operation**: Add (R-Type)
- **Description**: $7 = $5 + $5
- **Inputs**: $5 = 20 (from instruction 7, now in WB stage)
- **Expected Output**: $7 = 40
- **Hazard**: **MEM Hazard** - Reads $5 which was computed 2 instructions ago
- **Forwarding**: forwardA = "10", forwardB = "10" (forward from MEM/WB stage)

---

## Section 4: Load-Use Hazard

**Purpose**: Test load instruction followed by an instruction that uses the loaded data.

### Instruction 10: `lw $8, 4($0)`
- **Address**: 10
- **Hex**: `0x8C080004`
- **Operation**: Load Word
- **Description**: $8 = Memory[4]
- **Inputs**: Base = $0 = 0, Offset = 4
- **Expected Output**: $8 = Memory[4] (value depends on data memory contents)
- **Hazard**: None

### Instruction 11: `lw $9, 5($0)`
- **Address**: 11
- **Hex**: `0x8C090005`
- **Operation**: Load Word
- **Description**: $9 = Memory[5]
- **Inputs**: Base = $0 = 0, Offset = 5
- **Expected Output**: $9 = Memory[5]
- **Hazard**: None

### Instruction 12: `add $10, $8, $9`
- **Address**: 12
- **Hex**: `0x01095020`
- **Operation**: Add (R-Type)
- **Description**: $10 = $8 + $9
- **Inputs**: $8 = Memory[4], $9 = Memory[5]
- **Expected Output**: $10 = Memory[4] + Memory[5]
- **Hazard**: **Load-Use Hazard** - Uses loaded values from instructions 10 and 11
- **Forwarding**: forwardA = "10", forwardB = "10" (forward from MEM/WB stage)
- **Note**: In a full implementation, this might require a pipeline stall

---

## Section 5: Store with Forwarding

**Purpose**: Test store instruction that needs forwarded data.

### Instruction 13: `addi $11, $0, 100`
- **Address**: 13
- **Hex**: `0x200B0064`
- **Operation**: Add Immediate
- **Description**: $11 = $0 + 100
- **Inputs**: $0 = 0, Immediate = 100
- **Expected Output**: $11 = 100 (0x64)
- **Hazard**: None

### Instruction 14: `sw $11, 6($0)`
- **Address**: 14
- **Hex**: `0xAC0B0006`
- **Operation**: Store Word
- **Description**: Memory[6] = $11
- **Inputs**: $11 = 100, Base = $0 = 0, Offset = 6
- **Expected Output**: Memory[6] = 100
- **Hazard**: **EX Hazard** - Needs value of $11 from previous instruction
- **Forwarding**: forwardB = "01" (forward from EX/MEM for store data)
- **Critical**: Store must write the correct (forwarded) value to memory

---

## Section 6: Multiple Dependencies

**Purpose**: Test consecutive instructions with RAW (Read After Write) hazards.

### Instruction 15: `addi $12, $0, 1`
- **Address**: 15
- **Hex**: `0x200C0001`
- **Operation**: Add Immediate
- **Description**: $12 = $0 + 1
- **Inputs**: $0 = 0, Immediate = 1
- **Expected Output**: $12 = 1
- **Hazard**: None

### Instruction 16: `addi $12, $12, 2`
- **Address**: 16
- **Hex**: `0x218C0002`
- **Operation**: Add Immediate
- **Description**: $12 = $12 + 2
- **Inputs**: $12 = 1 (from instruction 15), Immediate = 2
- **Expected Output**: $12 = 3
- **Hazard**: **EX Hazard** - Reads and writes same register
- **Forwarding**: forwardA = "01"

### Instruction 17: `addi $12, $12, 3`
- **Address**: 17
- **Hex**: `0x218C0003`
- **Operation**: Add Immediate
- **Description**: $12 = $12 + 3
- **Inputs**: $12 = 3 (from instruction 16), Immediate = 3
- **Expected Output**: $12 = 6
- **Hazard**: **EX Hazard** - Reads and writes same register
- **Forwarding**: forwardA = "01"

### Instruction 18: `addi $12, $12, 4`
- **Address**: 18
- **Hex**: `0x218C0004`
- **Operation**: Add Immediate
- **Description**: $12 = $12 + 4
- **Inputs**: $12 = 6 (from instruction 17), Immediate = 4
- **Expected Output**: $12 = 10
- **Hazard**: **EX Hazard** - Reads and writes same register
- **Forwarding**: forwardA = "01"

---

## Section 7: R-Type Instructions Testing

**Purpose**: Test various R-Type ALU operations with forwarding.

### Instruction 19: `addi $13, $0, 15`
- **Address**: 19
- **Hex**: `0x200D000F`
- **Operation**: Add Immediate
- **Description**: $13 = $0 + 15
- **Inputs**: $0 = 0, Immediate = 15 (0xF)
- **Expected Output**: $13 = 15 (0x0000000F)
- **Hazard**: None

### Instruction 20: `addi $14, $0, 15`
- **Address**: 20
- **Hex**: `0x200E000F`
- **Operation**: Add Immediate
- **Description**: $14 = $0 + 15
- **Inputs**: $0 = 0, Immediate = 15 (0xF)
- **Expected Output**: $14 = 15 (0x0000000F)
- **Hazard**: None

### Instruction 21: `and $15, $13, $14`
- **Address**: 21
- **Hex**: `0x01AE7824`
- **Operation**: AND (R-Type)
- **Description**: $15 = $13 & $14
- **Inputs**: $13 = 15, $14 = 15
- **Expected Output**: $15 = 15 (0xF & 0xF = 0xF)
- **Hazard**: **MEM Hazard** - Both source registers from 2 instructions back
- **Forwarding**: forwardA = "10", forwardB = "10"

### Instruction 22: `or $16, $13, $14`
- **Address**: 22
- **Hex**: `0x01AE8025`
- **Operation**: OR (R-Type)
- **Description**: $16 = $13 | $14
- **Inputs**: $13 = 15, $14 = 15
- **Expected Output**: $16 = 15 (0xF | 0xF = 0xF)
- **Hazard**: None (values already in register file)

### Instruction 23: `nor $17, $13, $14`
- **Address**: 23
- **Hex**: `0x01AE8827`
- **Operation**: NOR (R-Type)
- **Description**: $17 = ~($13 | $14)
- **Inputs**: $13 = 15, $14 = 15
- **Expected Output**: $17 = 0xFFFFFFF0 (~15)
- **Hazard**: None

---

## Section 8: Set Less Than (SLT)

**Purpose**: Test comparison operation (SLT) with different operand orders.

### Instruction 24: `addi $18, $0, 5`
- **Address**: 24
- **Hex**: `0x20120005`
- **Operation**: Add Immediate
- **Description**: $18 = $0 + 5
- **Inputs**: $0 = 0, Immediate = 5
- **Expected Output**: $18 = 5
- **Hazard**: None

### Instruction 25: `addi $19, $0, 10`
- **Address**: 25
- **Hex**: `0x2013000A`
- **Operation**: Add Immediate
- **Description**: $19 = $0 + 10
- **Inputs**: $0 = 0, Immediate = 10
- **Expected Output**: $19 = 10
- **Hazard**: None

### Instruction 26: `slt $20, $18, $19`
- **Address**: 26
- **Hex**: `0x0253A02A`
- **Operation**: Set Less Than (R-Type)
- **Description**: $20 = ($18 < $19) ? 1 : 0
- **Inputs**: $18 = 5, $19 = 10
- **Expected Output**: $20 = 1 (because 5 < 10)
- **Hazard**: **MEM Hazard**
- **Forwarding**: forwardA = "10", forwardB = "10"

### Instruction 27: `slt $21, $19, $18`
- **Address**: 27
- **Hex**: `0x0272A82A`
- **Operation**: Set Less Than (R-Type)
- **Description**: $21 = ($19 < $18) ? 1 : 0
- **Inputs**: $19 = 10, $18 = 5
- **Expected Output**: $21 = 0 (because 10 is not < 5)
- **Hazard**: **MEM Hazard**
- **Forwarding**: forwardA = "10", forwardB = "10"

---

## Section 9: Complex Forwarding Scenario

**Purpose**: Test multiple simultaneous forwarding paths (double dependency).

### Instruction 28: `addi $22, $0, 1`
- **Address**: 28
- **Hex**: `0x20160001`
- **Operation**: Add Immediate
- **Description**: $22 = $0 + 1
- **Inputs**: $0 = 0, Immediate = 1
- **Expected Output**: $22 = 1
- **Hazard**: None

### Instruction 29: `addi $22, $22, 2`
- **Address**: 29
- **Hex**: `0x22D60002`
- **Operation**: Add Immediate
- **Description**: $22 = $22 + 2
- **Inputs**: $22 = 1 (from instruction 28), Immediate = 2
- **Expected Output**: $22 = 3
- **Hazard**: **EX Hazard**
- **Forwarding**: forwardA = "01"

### Instruction 30: `add $23, $22, $22`
- **Address**: 30
- **Hex**: `0x02D6B820`
- **Operation**: Add (R-Type)
- **Description**: $23 = $22 + $22
- **Inputs**: $22 = 3 (from instruction 29)
- **Expected Output**: $23 = 6
- **Hazard**: **Double EX Hazard** - Both ALU inputs need same forwarded value
- **Forwarding**: forwardA = "01", forwardB = "01"
- **Critical**: Tests forwarding unit's ability to forward same value to both inputs

### Instruction 31: `add $24, $23, $23`
- **Address**: 31
- **Hex**: `0x02F7C020`
- **Operation**: Add (R-Type)
- **Description**: $24 = $23 + $23
- **Inputs**: $23 = 6 (from instruction 30)
- **Expected Output**: $24 = 12
- **Hazard**: **Double EX Hazard**
- **Forwarding**: forwardA = "01", forwardB = "01"

---

## Section 10: Branch Testing

**Purpose**: Test branch instruction with equality comparison.

### Instruction 32: `addi $25, $0, 255`
- **Address**: 32
- **Hex**: `0x201900FF`
- **Operation**: Add Immediate
- **Description**: $25 = $0 + 255
- **Inputs**: $0 = 0, Immediate = 255
- **Expected Output**: $25 = 255 (0xFF)
- **Hazard**: None

### Instruction 33: `addi $26, $0, 255`
- **Address**: 33
- **Hex**: `0x201A00FF`
- **Operation**: Add Immediate
- **Description**: $26 = $0 + 255
- **Inputs**: $0 = 0, Immediate = 255
- **Expected Output**: $26 = 255 (0xFF)
- **Hazard**: None

### Instruction 34: `beq $25, $26, -1`
- **Address**: 34
- **Hex**: `0x1339FFFF`
- **Operation**: Branch if Equal
- **Description**: if ($25 == $26) PC = PC + 4 + (-1 × 4)
- **Inputs**: $25 = 255, $26 = 255
- **Expected Behavior**: Branch taken (values are equal)
- **Branch Target**: Address 34 (loops to itself)
- **Hazard**: **MEM Hazard** - Compares registers from 2 instructions back
- **Forwarding**: May need forwarding for branch comparison
- **Note**: This creates an infinite loop for testing purposes

### Instruction 35: `nop`
- **Address**: 35
- **Hex**: `0x00000000`
- **Operation**: No Operation
- **Description**: Not executed if branch taken
- **Hazard**: None

---

## Section 11: Additional Store/Load

**Purpose**: Test store followed by load from same address, then use loaded value.

### Instruction 36: `addi $27, $0, 50`
- **Address**: 36
- **Hex**: `0x201B0032`
- **Operation**: Add Immediate
- **Description**: $27 = $0 + 50
- **Inputs**: $0 = 0, Immediate = 50 (0x32)
- **Expected Output**: $27 = 50
- **Hazard**: None

### Instruction 37: `sw $27, 7($0)`
- **Address**: 37
- **Hex**: `0xAC1B0007`
- **Operation**: Store Word
- **Description**: Memory[7] = $27
- **Inputs**: $27 = 50, Base = $0 = 0, Offset = 7
- **Expected Output**: Memory[7] = 50
- **Hazard**: **EX Hazard** - Store data needs forwarding
- **Forwarding**: forwardB = "01"

### Instruction 38: `lw $28, 7($0)`
- **Address**: 38
- **Hex**: `0x8C1C0007`
- **Operation**: Load Word
- **Description**: $28 = Memory[7]
- **Inputs**: Base = $0 = 0, Offset = 7
- **Expected Output**: $28 = 50 (value stored by instruction 37)
- **Hazard**: None
- **Note**: Tests store-to-load forwarding through memory

### Instruction 39: `addi $28, $28, 1`
- **Address**: 39
- **Hex**: `0x239C0001`
- **Operation**: Add Immediate
- **Description**: $28 = $28 + 1
- **Inputs**: $28 = 50 (from instruction 38), Immediate = 1
- **Expected Output**: $28 = 51
- **Hazard**: **Load-Use Hazard** - Uses value just loaded
- **Forwarding**: forwardA = "10" (forward from MEM/WB)

---

## Summary of Hazard Types Tested

### 1. **EX Hazards (ForwardA/B = "01")**
- Instructions 5, 6, 13-18, 29-31, 37
- Producer instruction is 1 cycle ahead (in MEM stage)
- Forwarding from EX/MEM pipeline register

### 2. **MEM Hazards (ForwardA/B = "10")**
- Instructions 9, 12, 21, 26, 27, 39
- Producer instruction is 2 cycles ahead (in WB stage)
- Forwarding from MEM/WB pipeline register

### 3. **Load-Use Hazards**
- Instructions 12, 39
- Special case requiring potential pipeline stall in full implementation
- Tests critical path through memory

### 4. **Double Dependencies**
- Instructions 30, 31
- Both ALU inputs need forwarding from same source
- Tests forwarding to both forwardA and forwardB simultaneously

### 5. **Store Data Hazards**
- Instructions 14, 37
- Store instruction needs forwarded value for write data
- Critical for memory consistency

---

## Expected Forwarding Unit Behavior

| Instruction | forwardA | forwardB | Description |
|-------------|----------|----------|-------------|
| 5  | 00 | 01 | Forward $3 from EX/MEM |
| 6  | 00 | 01 | Forward $4 from EX/MEM |
| 9  | 10 | 10 | Forward $5 from MEM/WB |
| 12 | 10 | 10 | Forward $8,$9 from MEM/WB |
| 14 | 00 | 01 | Forward $11 for store |
| 16 | 01 | 00 | Forward $12 from EX/MEM |
| 17 | 01 | 00 | Forward $12 from EX/MEM |
| 18 | 01 | 00 | Forward $12 from EX/MEM |
| 21 | 10 | 10 | Forward $13,$14 from MEM/WB |
| 26 | 10 | 10 | Forward $18,$19 from MEM/WB |
| 27 | 10 | 10 | Forward $19,$18 from MEM/WB |
| 29 | 01 | 00 | Forward $22 from EX/MEM |
| 30 | 01 | 01 | Forward $22 to both inputs |
| 31 | 01 | 01 | Forward $23 to both inputs |
| 37 | 00 | 01 | Forward $27 for store |
| 39 | 10 | 00 | Forward $28 from MEM/WB |

---

## Register Summary After Execution

Assuming memory contains appropriate values and ignoring branch loop:

| Register | Final Value | Computed By |
|----------|-------------|-------------|
| $1  | 5   | Instruction 0 |
| $2  | 3   | Instruction 1 |
| $3  | 8   | Instruction 4 |
| $4  | 13  | Instruction 5 |
| $5  | 20  | Instruction 7 |
| $6  | -10 | Instruction 6 |
| $7  | 40  | Instruction 9 |
| $10 | Memory[4] + Memory[5] | Instruction 12 |
| $11 | 100 | Instruction 13 |
| $12 | 10  | Instruction 18 |
| $13 | 15  | Instruction 19 |
| $14 | 15  | Instruction 20 |
| $15 | 15  | Instruction 21 |
| $16 | 15  | Instruction 22 |
| $17 | 0xFFFFFFF0 | Instruction 23 |
| $18 | 5   | Instruction 24 |
| $19 | 10  | Instruction 25 |
| $20 | 1   | Instruction 26 |
| $21 | 0   | Instruction 27 |
| $22 | 3   | Instruction 29 |
| $23 | 6   | Instruction 30 |
| $24 | 12  | Instruction 31 |
| $25 | 255 | Instruction 32 |
| $26 | 255 | Instruction 33 |
| $27 | 50  | Instruction 36 |
| $28 | 51  | Instruction 39 |

---

## Notes

- All values are in decimal unless specified as hex (0x...)
- Negative numbers are represented in 32-bit 2's complement
- Register $0 always contains 0
- Memory addresses are byte-addressable
- Branch offset is multiplied by 4 (word-aligned)
