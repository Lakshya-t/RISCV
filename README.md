# RISC-V (RV32I) Single-Cycle Processor Core

A 32-bit single-cycle processor implementing the base integer subset (**RV32I**) of the RISC-V Instruction Set Architecture (ISA), designed and implemented in Verilog HDL.

---

## 📌 Features

- **Architecture:** 32-bit Single-Cycle RISC-V Core (RV32I).
- **Execution Model:** Non-pipelined, single-cycle execution where each instruction completes in one clock cycle.
- **Register File:** 32 general-purpose 32-bit registers (`x0`–`x31`) with dual asynchronous read ports and a synchronous clocked write port.
- **Instruction Memory:** Byte-addressable ROM pre-loaded with a test program covering all supported instruction formats.
- **Data Memory:** 32-byte synchronous write, asynchronous read RAM storage.
- **Supported Formats:** Full hardware decode and execution for **R-type**, **I-type** (arithmetic and loads), **S-type** (stores), **B-type** (branches), **U-type** (`LUI`), and **J-type** (`JAL`).

---

## 📊 Microarchitecture Specifications

| Parameter | Specification | Details |
| :--- | :--- | :--- |
| **Architecture** | RISC-V RV32I | 32-bit Base Integer Instruction Set |
| **Execution Model** | Single-Cycle | Non-pipelined, CPI = 1.0 (ideal) |
| **Simulation Clock** | 50 MHz (20 ns period) | Active-high synchronous reset |
| **Memory Architecture** | Harvard Architecture | Separate byte-addressed ROM (Instructions) & RAM (Data) |
| **Register File** | 32 × 32-bit Registers | Dual asynchronous read ports, single synchronous write port |
| **Hardwired Zero** | Hardware Protected | Register `x0` reads constant zero; writes to `x0` are discarded |
| **ALU Operations** | 10 Operations | Arithmetic, logic, shifts, and signed/unsigned comparisons |

---

## 🏗️ Core Architecture Block Diagram

```text
+------------------------------------------------------------------------------------+
|                                      top_tb.v                                      |
|                      (Clock: 50 MHz, Active-High Reset: 100 ns)                    |
+------------------------------------------+-----------------------------------------+
                                           | clk, reset
                                           v
+------------------------------------------------------------------------------------+
|                              top_riscv.v (CPU Core)                                |
|                                                                                    |
|   [ instruction_fetch_unit.v ] ──( PC )──> [ instruction_memory.v (ROM) ]          |
|               ^                                          |                         |
|               | (branch target: PC+imm)                  | instruction[31:0]       |
|               |                                          v                         |
|   +-----------+------------------------------------+   +-----------------------+   |
|   |           |        data_path.v                 |   |    control_unit.v     |   |
|   |           |                                    |   |   (Decoder Brain)     |   |
|   |   [ register_file.v (x0-x31) ]                 |   +-----------+-----------+   |
|   |        | rs1, rs2 data                         |               |               |
|   |        v                                       |               | alu_control,  |
|   |   [ alu.v (Math / Logic / Branch Comp) ] <-----+---------------+ lb, sw, lui   |
|   |        |                                       |                               |
|   |        +──( branch taken: beq, bne, blt, bge )─+                               |
|   |        |                                       |                               |
|   |        v address, store data                   |                               |
|   |   [ data_memory.v (32-byte RAM) ]              |                               |
|   +------------------------------------------------+                               |
+------------------------------------------------------------------------------------+
```

---

## 💡 Key Architectural Decisions

- **Hardware Write-Protection for `x0`:** Register `x0` is hardwired to `32'b0`. Any write attempt targeting register index `0` is ignored in hardware, preserving ISA compliance without software overhead.
- **Immediate Generation:** Dedicated sign-extension and bit-slicing logic handles B-type, S-type, I-type, and U-type immediate layouts directly from the instruction bus.
- **Integrated Branch Logic:** Branch condition checks (`BEQ`, `BNE`, `BLT`, `BGE`) are computed in the ALU and fed directly to the fetch unit to update the next Program Counter within the same clock period.
- **Modular Hardware Hierarchy:** Strict separation between control plane (`control_unit.v`), datapath routing (`data_path.v`), register bank (`register_file.v`), and memory sub-systems.

---

## 📁 Repository Structure

| File | Module | Description |
| :--- | :--- | :--- |
| [`top_riscv.v`](top_riscv.v) | `top_riscv` | Top-level module interconnecting the fetch unit, ROM, control unit, and datapath. |
| [`data_path.v`](data_path.v) | `data_path` | Datapath wrapper routing data between the Register File, ALU, and Data Memory. |
| [`control_unit.v`](control_unit.v) | `control_unit` | Main decoder decoding `opcode`, `funct3`, and `funct7` into operational control signals. |
| [`alu.v`](alu.v) | `alu` | Arithmetic Logic Unit executing arithmetic, logical shifts, and branch condition comparisons. |
| [`register_file.v`](register_file.v) | `register_file` | 32 × 32-bit general-purpose register bank with asynchronous dual reads and synchronous writes. |
| [`instruction_fetch_unit.v`](instruction_fetch_unit.v) | `instruction_fetch_unit` | Program Counter (PC) logic managing sequential steps ($PC+4$), branch targets, and jump links. |
| [`instruction_memory.v`](instruction_memory.v) | `instruction_memory` | Byte-addressable ROM pre-loaded with 24 test instructions using little-endian byte ordering. |
| [`data_memory.v`](data_memory.v) | `data_memory` | 32-byte RAM for data storage supporting Load (`LW`/`LB`) and Store (`SW`) instructions. |
| [`imm_gen.v`](imm_gen.v) | `imm_gen` | Standalone immediate generation module. *(Immediate slicing is handled inline in `top_riscv.v`)*. |
| [`top_tb.v`](top_tb.v) | `top_tb` | Simulation testbench driving system clock (50 MHz) and active-high reset stimulus. |

---

## ⚙️ Supported Instruction Set

### 1. R-Type (Register to Register) — `opcode: 0110011`
| Instruction | funct3 | funct7 | Operation | Description |
| :--- | :---: | :---: | :--- | :--- |
| **ADD** | `000` | `0000000` | $rd = rs1 + rs2$ | Addition |
| **SUB** | `000` | `0100000` | $rd = rs1 - rs2$ | Subtraction |
| **SLL** | `001` | `0000000` | $rd = rs1 \ll rs2[4:0]$ | Shift Left Logical |
| **SLT** | `010` | `0000000` | $rd = (rs1 < rs2) \text{ ? } 1 : 0$ | Set Less Than (signed) |
| **SLTU** | `011` | `0000000` | $rd = (rs1 < rs2) \text{ ? } 1 : 0$ | Set Less Than Unsigned |
| **XOR** | `100` | `0000000` | $rd = rs1 \oplus rs2$ | Bitwise XOR |
| **SRL** | `101` | `0000000` | $rd = rs1 \gg rs2[4:0]$ | Shift Right Logical |
| **SRA** | `101` | `0100000` | $rd = rs1 \ggg rs2[4:0]$ | Shift Right Arithmetic |
| **OR** | `110` | `0000000` | $rd = rs1 \mid rs2$ | Bitwise OR |
| **AND** | `111` | `0000000` | $rd = rs1 \ \& \ rs2$ | Bitwise AND |

### 2. I-Type (Immediate Arithmetic & Loads)
- **Arithmetic (`opcode: 0010011`):** `ADDI`, `SLLI`, `SLTI`, `SLTIU`, `XORI`, `SRLI`, `ORI`, `ANDI`
- **Loads (`opcode: 0000011`):** `LB`, `LH`, `LW`, `LBU`, `LHU`

### 3. S-Type (Store Instructions) — `opcode: 0100011`
- `SB` (Store Byte), `SH` (Store Halfword), `SW` (Store Word)

### 4. B-Type (Conditional Branches) — `opcode: 1100011`
- `BEQ` (Branch if Equal), `BNE` (Branch if Not Equal), `BLT` (Branch if Less Than), `BGE` (Branch if Greater or Equal)
- Computes target address: $PC \leftarrow PC + \text{sign\_extended(offset)}$.

### 5. U-Type & J-Type (Upper Immediate & Jump)
- **`LUI` (`opcode: 0110111`):** Load Upper Immediate ($rd \leftarrow \text{imm}[31:12] \ll 12$).
- **`JAL` (`opcode: 1101111`):** Jump and Link ($PC \leftarrow PC + \text{offset}$, $rd \leftarrow PC + 4$).

---

## 📋 Pre-loaded ROM Test Program

[`instruction_memory.v`](instruction_memory.v) comes pre-loaded with 24 instructions that execute sequentially after reset deassertion:

```assembly
add  x6,  x8,  x9       # R-type ADD
sub  x1,  x2,  x0       # R-type SUB
sll  x2,  x1,  x2       # Shift left logical
xor  x21, x10, x12      # Bitwise XOR
srl  x21, x10, x12      # Shift right logical
sra  x30, x26, x27      # Shift right arithmetic
or   x31, x12, x13      # Bitwise OR
and  x17, x14, x15      # Bitwise AND
addi x10, x1,  10       # Add immediate
slli x6,  x3,  4        # Shift left logical immediate
xori x14, x5,  63       # XOR immediate
slti x1,  x2,  10       # Set less than immediate
srli x1,  x2,  3        # Shift right logical immediate
ori  x1,  x2,  15       # OR immediate
andi x1,  x2,  15       # AND immediate
lw   x5,  4(x6)         # Load word from data memory
sw   x7,  16(x6)        # Store word into data memory
beq  x2,  x4,  0        # Branch if equal
bne  x1,  x2,  8        # Branch if not equal (jumps to PC = 80)
bge  x3,  x4,  8        # Branch if greater or equal
blt  x1,  x2,  2        # Branch if less than
lui  x5,  0x12345       # Load upper immediate
jal  x1,  8             # Jump and link
```

---

## 🔬 Verification & Validation

The processor was verified through behavioral simulation:
- **Zero Warnings / Zero Errors:** Clean compilation and elaboration under Icarus Verilog (`iverilog`).
- **Testbench Execution:** [`top_tb.v`](top_tb.v) applies a 50 MHz clock signal and a 100 ns reset stimulus to confirm power-on state stabilization.
- **Waveform Inspection:** Signal traces (`waveform.vcd`) confirm correct ALU calculation, Program Counter advancement, branch evaluation, and register writeback cycles.

---

## 🚀 Future Roadmap

- [ ] **Pipelined Core:** Upgrade from single-cycle to a classic 5-stage RISC pipeline (Fetch, Decode, Execute, Memory, Writeback).
- [ ] **Hazard Handling:** Implement a Hazard Detection Unit and Forwarding Unit to resolve data and control hazards without stalling.
- [ ] **Memory Sub-system:** Implement byte-enable masking to support sub-word operations (`LB`, `LH`, `SB`, `SH`) across unaligned 32-bit words.
- [ ] **Privileged Architecture:** Add Control and Status Registers (CSRs) to support timer interrupts and basic trap handling.
