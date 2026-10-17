# RISC-V (RV32I) Single-Cycle Processor Core

A 32-bit single-cycle processor implementing the base integer subset (**RV32I**) of the RISC-V Instruction Set Architecture (ISA), designed and implemented in synthesizable Verilog HDL.

---

## 📌 Features

- **Architecture:** 32-bit Single-Cycle RISC-V Core (RV32I).
- **Execution Model:** Non-pipelined, single-cycle execution where each instruction completes in one clock cycle.
- **Register File:** 32 general-purpose 32-bit registers (`x0`–`x31`) with dual asynchronous read ports, a synchronous clocked write port, and hardware `x0` constant-zero protection.
- **Instruction Memory:** 1024-word ROM pre-loaded with a comprehensive self-checking verification program.
- **Data Memory:** 1024-word (4 KB) synchronous write, asynchronous read RAM storage.
- **Supported Formats:** Full hardware decode and execution for **R-type**, **I-type** (arithmetic, shifts, and loads), **S-type** (`SW`), **B-type** (all branches), **U-type** (`LUI`, `AUIPC`), and **J-type** (`JAL`, `JALR`).

---

## 📊 Microarchitecture Specifications

| Parameter | Specification | Details |
| :--- | :--- | :--- |
| **Architecture** | RISC-V RV32I | 32-bit Base Integer Instruction Set |
| **Execution Model** | Single-Cycle | Non-pipelined, CPI = 1.0 (ideal) |
| **Simulation Clock** | 50 MHz (20 ns period) | Active-high synchronous reset |
| **Memory Architecture** | Harvard Architecture | Word-aligned 4 KB ROM (Instructions) & 4 KB RAM (Data) |
| **Register File** | 32 × 32-bit Registers | Dual asynchronous read ports, single synchronous write port |
| **Hardwired Zero** | Hardware Protected | Register `x0` reads constant zero; writes to `x0` are discarded |
| **ALU Operations** | 10 Operations | Signed/unsigned arithmetic, logic, shifts, and branch flags |

---

## 🏗️ Core Architecture Block Diagram

```text
+------------------------------------------------------------------------------------+
|                                    top_tb.v                                        |
|                      (Clock: 50 MHz, Active-High Reset: 100 ns)                    |
+------------------------------------------+-----------------------------------------+
                                           | clk, reset
                                           v
+------------------------------------------------------------------------------------+
|                               top_riscv.v (CPU Core)                               |
|                                                                                    |
|   [ instruction_fetch_unit.v ] ──( PC )──> [ instruction_memory.v (ROM) ]          |
|               ^                                          |                         |
|               | (branch/jump target: PC+imm, rs1+imm)    | instruction[31:0]       |
|               |                                          v                         |
|   +-----------+------------------------------------+   +-----------------------+   |
|   |           |        data_path.v                 |   |    control_unit.v     |   |
|   |           |                                    |   |   (Decoder Brain)     |   |
|   |   [ register_file.v (x0-x31) ]                 |   +-----------+-----------+   |
|   |        | rs1, rs2 data                         |               |               |
|   |        v                                       |               | alu_control,  |
|   |   [ alu.v (Math / Logic / Branch Comp) ] <-----+---------------+ mem_write,    |
|   |        |                                       |               | mem_to_reg,   |
|   |        +──( branch taken: beq, bne, blt, bge )─+               | jump, jalr    |
|   |        |                                                       |               |
|   |        v address, store data (rs2)                             |               |
|   |   [ data_memory.v (4 KB RAM) ]                                 |               |
|   +----------------------------------------------------------------+               |
+------------------------------------------------------------------------------------+
```

---

## 💡 Key Architectural Decisions

- **Hardware Write-Protection for `x0`:** Register `x0` is hardwired to `32'b0`. Any write attempt targeting register index `0` is ignored in hardware, preserving ISA compliance without software overhead.
- **Immediate Generation:** Dedicated sign-extension and bit-slicing logic handles I-type, S-type, B-type, U-type, and J-type immediate layouts directly from the instruction bus.
- **Integrated Branch Comparator:** Branch condition checks (`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`) evaluate signed and unsigned comparisons directly in the ALU to resolve next Program Counter targets within the single-cycle window.
- **JAL / JALR Return Address Linkage:** Both `JAL` and `JALR` instructions write `PC + 4` into the destination register `rd` (`x1`/`ra`) for subroutine return linkage.
- **Modular Hardware Hierarchy:** Strict separation between control plane ([`src/control_unit.v`](src/control_unit.v)), datapath routing ([`src/data_path.v`](src/data_path.v)), register bank ([`src/register_file.v`](src/register_file.v)), and memory sub-systems.

---

## 📁 Repository Structure

| File | Module | Description |
| :--- | :--- | :--- |
| [`src/top_riscv.v`](src/top_riscv.v) | `top_riscv` | Top-level module interconnecting the fetch unit, ROM, control unit, and datapath. |
| [`src/data_path.v`](src/data_path.v) | `data_path` | Datapath wrapper routing data between the Register File, ALU, and Data Memory. |
| [`src/control_unit.v`](src/control_unit.v) | `control_unit` | Main decoder decoding `opcode`, `funct3`, and `funct7` into operational control signals. |
| [`src/alu.v`](src/alu.v) | `alu` | Arithmetic Logic Unit executing arithmetic, logical shifts, and branch condition comparisons. |
| [`src/register_file.v`](src/register_file.v) | `register_file` | 32 × 32-bit general-purpose register bank with asynchronous dual reads and synchronous writes. |
| [`src/instruction_fetch_unit.v`](src/instruction_fetch_unit.v) | `instruction_fetch_unit` | Program Counter (PC) logic managing sequential steps (`PC + 4`), branch targets, and jump links. |
| [`src/instruction_memory.v`](src/instruction_memory.v) | `instruction_memory` | 1024-word ROM pre-loaded with the self-checking test suite. |
| [`src/data_memory.v`](src/data_memory.v) | `data_memory` | 1024-word (4 KB) RAM for synchronous store (`SW`) and asynchronous load (`LW`) operations. |
| [`src/imm_gen.v`](src/imm_gen.v) | `imm_gen` | Immediate generation module supporting I, S, B, U, and J formats. |
| [`testbench/top_tb.v`](testbench/top_tb.v) | `top_tb` | Self-checking simulation testbench validating all 34 execution assertions. |

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
- Computes target address: `PC <= PC + sign_extended(offset)`.

### 5. U-Type & J-Type (Upper Immediate & Jump)
- **`LUI` (`opcode: 0110111`):** Load Upper Immediate (`rd <= imm[31:12] << 12`).
- **`AUIPC` (`opcode: 0010111`):** Add Upper Immediate to PC (`rd <= PC + (imm[31:12] << 12)`).
- **`JAL` (`opcode: 1101111`):** Jump and Link (`PC <= PC + offset`, `rd <= PC + 4`).
- **`JALR` (`opcode: 1100111`):** Jump and Link Register (`PC <= (rs1 + offset) & ~1`, `rd <= PC + 4`).

---

## 🔬 Verification & Validation

The processor was verified through behavioral simulation:
- **Zero Warnings / Zero Errors:** Clean compilation and elaboration under standard Verilog simulation environments.
- **Self-Checking Testbench:** [`testbench/top_tb.v`](testbench/top_tb.v) applies a 50 MHz clock signal, asserts a 100 ns reset sequence, and automatically asserts that all 34 benchmark test cases execute with mathematically exact results, terminating with a non-zero exit code on any failure.
- **Waveform Inspection:** Signal traces (`waveform.vcd`) confirm ALU calculations, branch redirection, jump links, and register writeback cycles.

---

## 🚀 Future Extensions

- [ ] **Hardware Multiplier / Divider (M-Extension):** Integrate hardware integer multiplier and divider units.
- [ ] **Sub-Word Memory Access:** Implement byte-enable masking to support `LB`, `LH`, `SB`, `SH` across unaligned words.
- [ ] **Privileged Architecture:** Add Control and Status Registers (CSRs) and basic trap/interrupt handling.
