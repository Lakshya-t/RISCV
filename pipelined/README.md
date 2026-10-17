# RISC-V (RV32I) 5-Stage Pipelined Processor Core

A 32-bit 5-stage pipelined processor implementing the base integer subset (**RV32I**) of the RISC-V Instruction Set Architecture (ISA), designed and implemented in synthesizable Verilog HDL.

---

## 📌 Features

- **Architecture:** 32-bit Pipelined RISC-V Core (RV32I).
- **Execution Model:** Classic 5-stage pipeline: **Instruction Fetch (IF)**, **Instruction Decode (ID)**, **Execute (EX)**, **Memory Access (MEM)**, and **Writeback (WB)**.
- **Hazard Handling:**
  - **Data Forwarding Unit:** Resolves Read-After-Write (RAW) data dependencies via EX-to-EX and MEM-to-EX forwarding paths.
  - **Load-Use Stall Unit:** Automatically detects load-use hazards and inserts a 1-cycle stall bubble.
  - **Control Hazard Flushing:** Flushes in-flight instructions upon taken branches (`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`) and jumps (`JAL`, `JALR`).
- **Register File:** 32 × 32-bit registers with dual asynchronous read ports, synchronous write port, internal write-to-read bypass, and hardware write-protection on `x0`.
- **Supported Formats:** Full hardware decode and execution for **R-type**, **I-type** (arithmetic, shifts, and loads), **S-type** (`SW`), **B-type** (branches), **U-type** (`LUI`, `AUIPC`), and **J-type** (`JAL`, `JALR`).

---

## 📊 Microarchitecture Specifications

| Parameter | Specification | Details |
| :--- | :--- | :--- |
| **Architecture** | RISC-V RV32I | 32-bit Base Integer Instruction Set |
| **Pipeline Depth** | 5 Stages | IF, ID, EX, MEM, WB with synchronous pipeline registers |
| **Simulation Clock** | 50 MHz (20 ns period) | Active-low synchronous reset |
| **Memory Architecture** | Harvard Architecture | Word-aligned 4 KB ROM (Instructions) & 4 KB RAM (Data) |
| **Hazard Resolution** | Hardware Forwarding & Stalling | EX-to-EX, MEM-to-EX bypass, 1-cycle load-use stall bubble |
| **Branch Penalty** | 2-Cycle Flush | Synchronous flush of IF/ID and ID/EX on taken branch or jump |
| **Hardwired Zero** | Hardware Protected | Register `x0` reads constant zero; writes to `x0` are discarded |

---

## 🏗️ 5-Stage Pipeline Architecture Block Diagram

```text
+----------------------------------------------------------------------------------------+
|                                     pipeline_tb.v                                      |
|                       (Clock: 50 MHz, Active-Low Reset: 100 ns)                        |
+-------------------------------------------+--------------------------------------------+
                                            | clk, rst
                                            v
+----------------------------------------------------------------------------------------+
|                            Pipeline_Top.v (Pipelined Core)                             |
|                                                                                        |
|   [ FETCH ]          [ DECODE ]          [ EXECUTE ]        [ MEMORY ]   [ WRITEBACK ] |
|                                                                                        |
|   +-----------+      +------------+      +------------+     +----------+  +---------+  |
|   |    PC     |      |  RegFile   |      |    ALU     |     | Data RAM |  | 3:1 Mux |  |
|   |     +     |-(IF)->     +      |-(ID)->     +      |-(EX->  (RAM)   |->| Result  |  |
|   |  ROM IMEM |      | Control/Imm|      | Forwarding |     |Load/Store|  |Writeback|  |
|   +-----------+      +------------+      +------+-----+     +----+-----+  +----+----+  |
|         ^                                       |                |             |       |
|         | Branch/Jump Target: PC + imm          |                |             |       |
|         +---------------------------------------+                |             |       |
|                                                 ^                v             v       |
|   +---------------------------------------------+----------------+-------------+---+   |
|   |                    Hazard_Unit.v (Hazard Resolution Unit)                      |   |
|   |   - ForwardA / ForwardB: Routes EX/MEM and MEM/WB results to ALU inputs        |   |
|   |   - Load-Use Detection: Asserts stall_f, stall_d, and inserts bubble (flush_e) |   |
|   |   - Control Hazards: Flushes IF/ID and ID/EX registers when branch is taken    |   |
|   +--------------------------------------------------------------------------------+   |
+----------------------------------------------------------------------------------------+
```

---

## 📁 Repository Structure (`pipelined/`)

| File | Module | Stage | Description |
| :--- | :--- | :---: | :--- |
| [`src/Pipeline_Top.v`](src/Pipeline_Top.v) | `Pipeline_Top` | Top | Top-level processor interconnecting all 5 pipeline stages and the Hazard Unit. |
| [`src/Fetch_Cycle.v`](src/Fetch_Cycle.v) | `Fetch_Cycle` | IF | Program Counter logic, sequential incrementer (`PC + 4`), and ROM instruction fetch. |
| [`src/Decode_Cycle.v`](src/Decode_Cycle.v) | `Decode_Cycle` | ID | Control Unit, 32-register bank, immediate sign extension, and IF/ID pipeline registers. |
| [`src/Execute_Cycle.v`](src/Execute_Cycle.v) | `Execute_Cycle` | EX | Forwarding muxes, Arithmetic Logic Unit (ALU), branch evaluator, and ID/EX registers. |
| [`src/Memory_Cycle.v`](src/Memory_Cycle.v) | `Memory_Cycle` | MEM | 1024-word Data Memory RAM interface and EX/MEM pipeline registers. |
| [`src/Writeback_Cycle.v`](src/Writeback_Cycle.v) | `Writeback_Cycle` | WB | 3-to-1 writeback multiplexer selecting ALU result, memory data, or `PC + 4`. |
| [`src/Hazard_Unit.v`](src/Hazard_Unit.v) | `Hazard_Unit` | Control | Forwarding unit, load-use hazard detector, and pipeline stall/flush generator. |
| [`src/ALU.v`](src/ALU.v) | `ALU` | EX | 32-bit ALU supporting 10 arithmetic/logic operations and branch comparison flags. |
| [`src/Control_Unit_Top.v`](src/Control_Unit_Top.v) | `Control_Unit_Top` | ID | Main instruction decoder generating all pipeline control signals across opcodes. |
| [`src/Register_File.v`](src/Register_File.v) | `Register_File` | ID/WB | 32 × 32-bit register file with asynchronous dual reads, sync write, and `x0` protection. |
| [`src/Instruction_Memory.v`](src/Instruction_Memory.v) | `Instruction_Memory` | IF | 1024-word ROM pre-loaded with the 19-instruction self-checking test suite. |
| [`src/Data_Memory.v`](src/Data_Memory.v) | `Data_Memory` | MEM | 1024-word RAM for synchronous store (`SW`) and asynchronous load (`LW`) operations. |
| [`src/Sign_Extend.v`](src/Sign_Extend.v) | `Sign_Extend` | ID | Immediate generation unit supporting I, S, B, J, and U (`LUI`, `AUIPC`) formats. |
| [`src/PC.v`](src/PC.v) | `PC_Module` | IF | Synchronous program counter register with stall-enable input. |
| [`src/PC_Adder.v`](src/PC_Adder.v) | `PC_Adder` | IF/EX | 32-bit adder for PC increments and branch target calculation. |
| [`src/Mux.v`](src/Mux.v) | `Mux`, `Mux_3_by_1` | - | 2-to-1 and 3-to-1 parameterized multiplexers. |
| [`testbench/pipeline_tb.v`](testbench/pipeline_tb.v) | `pipeline_tb` | TB | Self-checking testbench generating 50 MHz clock, reset, and automated assertion report. |

---

## ⚙️ Supported Instruction Set

### 1. R-Type (Register to Register) — `opcode: 0110011`
| Instruction | funct3 | funct7 | Operation | Description |
| :--- | :---: | :---: | :--- | :--- |
| **ADD** | `000` | `0000000` | `rd = rs1 + rs2` | Addition |
| **SUB** | `000` | `0100000` | `rd = rs1 - rs2` | Subtraction |
| **SLL** | `001` | `0000000` | `rd = rs1 << rs2[4:0]` | Shift Left Logical |
| **SLT** | `010` | `0000000` | `rd = (rs1 < rs2) ? 1 : 0` | Set Less Than (signed) |
| **SLTU** | `011` | `0000000` | `rd = (rs1 < rs2) ? 1 : 0` | Set Less Than Unsigned |
| **XOR** | `100` | `0000000` | `rd = rs1 ^ rs2` | Bitwise XOR |
| **SRL** | `101` | `0000000` | `rd = rs1 >> rs2[4:0]` | Shift Right Logical |
| **SRA** | `101` | `0100000` | `rd = rs1 >>> rs2[4:0]` | Shift Right Arithmetic |
| **OR** | `110` | `0000000` | `rd = rs1 \| rs2` | Bitwise OR |
| **AND** | `111` | `0000000` | `rd = rs1 & rs2` | Bitwise AND |

### 2. I-Type (Immediate Arithmetic, Shifts & Loads)
- **Arithmetic & Shifts (`opcode: 0010011`):** `ADDI`, `SLLI`, `SLTI`, `SLTIU`, `XORI`, `SRLI`, `SRAI`, `ORI`, `ANDI`
- **Loads (`opcode: 0000011`):** `LW`
- **JALR (`opcode: 1100111`):** `JALR` (Jump and Link Register: `rd = PC + 4`, `PC = (rs1 + imm) & ~1`)

### 3. S-Type (Store Instructions) — `opcode: 0100011`
- `SW` (Store Word)

### 4. B-Type (Conditional Branches) — `opcode: 1100011`
- `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- Target calculation: `PC <= PC + sign_extended(offset)`.

### 5. U-Type & J-Type (Upper Immediate & Jump)
- **`LUI` (`opcode: 0110111`):** Load Upper Immediate (`rd <= imm[31:12] << 12`).
- **`AUIPC` (`opcode: 0010111`):** Add Upper Immediate to PC (`rd <= PC + (imm[31:12] << 12)`).
- **`JAL` (`opcode: 1101111`):** Jump and Link (`PC <= PC + offset`, `rd <= PC + 4`).

---

## 🔬 Verification & Validation

The pipelined processor was tested and validated through behavioural simulation:
- **Zero Warnings / Zero Errors:** Clean elaboration and zero warnings under RTL behavioral simulation.
- **Hazard Suite Validation:** The test sequence in [`src/Instruction_Memory.v`](src/Instruction_Memory.v) exercises back-to-back RAW dependencies (verifying EX-to-EX forwarding), load-use dependencies (verifying 1-cycle pipeline bubble insertion), and conditional branch flushes.
- **Waveform Inspection:** Complete signal transitions, pipeline registers, and forwarding multiplexers can be viewed via GTKWave (`pipeline_waveform.vcd`).
