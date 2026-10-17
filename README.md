# RISC-V (RV32I) Processor Cores in Verilog

This repository contains two hardware implementations of the 32-bit RISC-V Instruction Set Architecture (**RV32I** Base Integer Subset, word-oriented memory model) designed in synthesizable Verilog HDL:

1. **[`single-cycle/`](single-cycle/):** A non-pipelined, single-cycle processor serving as the functional baseline model.
2. **[`pipelined/`](pipelined/):** A 5-stage classic RISC pipelined processor featuring hardware data forwarding, load-use hazard stalling, and branch flushing.

---

## 📊 Microarchitecture Comparison

| Feature | Single-Cycle Core (`single-cycle/`) | 5-Stage Pipelined Core (`pipelined/`) |
| :--- | :--- | :--- |
| **Pipeline Stages** | 1 (Non-pipelined) | 5 (IF, ID, EX, MEM, WB) |
| **Simulation Clock** | 50 MHz (20 ns cycle period) | 50 MHz (20 ns cycle period) |
| **Ideal CPI** | 1.0 | 1.0 (approaching) |
| **Data Hazards** | N/A (completed in one cycle) | Resolved via EX-to-EX & MEM-to-EX Forwarding |
| **Load-Use Hazards** | N/A | Hardware detection with 1-cycle stall bubble |
| **Control Hazards** | Single-cycle branch resolution | Evaluated in EX; 2-cycle flush penalty on branch taken |
| **Memory Model** | Harvard (Word-aligned 4 KB ROM & RAM) | Harvard (Word-aligned 4 KB ROM & RAM) |
| **Register File** | 32 × 32-bit, `x0` hardwired to 0 | 32 × 32-bit, `x0` hardwired to 0 + internal write bypass |
| **Supported ISA** | RV32I Base Subset (R, I, S, B, U, J) | RV32I Base Subset (R, I, S, B, U, J) |

---

## 📁 Repository Organization

```text
RISCV/
├── README.md                      # Root repository overview and architectural comparison
├── single-cycle/                  # Single-Cycle RV32I Processor Core
│   ├── src/                       # Design source files
│   │   ├── top_riscv.v            # Top-level single-cycle core
│   │   ├── data_path.v            # Datapath routing logic
│   │   ├── control_unit.v         # Opcode & funct decoder
│   │   ├── register_file.v        # 32 x 32-bit register file (x0 write protected)
│   │   ├── alu.v                  # Arithmetic Logic Unit (10 operations + branch comp)
│   │   ├── instruction_fetch_unit.v # Program Counter and sequential step logic
│   │   ├── instruction_memory.v   # 1024-word preloaded ROM (benchmark suite)
│   │   ├── data_memory.v          # 1024-word RAM (4 KB)
│   │   └── imm_gen.v              # Immediate generation module
│   ├── testbench/                 # Testbench files
│   │   └── top_tb.v               # Single-cycle self-checking testbench
│   ├── run_sim.sh                 # One-click simulation script
│   └── README.md                  # Detailed single-cycle architecture documentation
│
└── pipelined/                     # 5-Stage Pipelined RV32I Processor Core
    ├── src/
    │   ├── Pipeline_Top.v         # Top-level 5-stage pipelined processor
    │   ├── Fetch_Cycle.v          # Instruction Fetch stage (IF) with stall/flush
    │   ├── Decode_Cycle.v         # Instruction Decode stage (ID) with IF/ID registers
    │   ├── Execute_Cycle.v        # Execute stage (EX) with ALU, branch comp, & ID/EX
    │   ├── Memory_Cycle.v         # Memory Access stage (MEM) with EX/MEM registers
    │   ├── Writeback_Cycle.v      # Writeback stage (WB) with 3:1 result multiplexer
    │   ├── Hazard_Unit.v          # Forwarding unit, load-use detector, & flusher
    │   ├── ALU.v                  # 32-bit ALU with signed/unsigned comparison flags
    │   ├── Control_Unit_Top.v     # Pipelined instruction decoder
    │   ├── Register_File.v        # Register bank with x0 protection & internal bypass
    │   ├── Instruction_Memory.v   # 1024-word preloaded ROM (benchmark suite)
    │   ├── Data_Memory.v          # 1024-word RAM (4 KB)
    │   ├── Sign_Extend.v          # Immediate generator for I, S, B, J, and U formats
    │   ├── PC.v                   # Program Counter register with stall-enable
    │   ├── PC_Adder.v             # 32-bit adder for PC increments and targets
    │   └── Mux.v                  # Parameterized 2:1 and 3:1 multiplexers
    ├── testbench/
    │   └── pipeline_tb.v          # Pipelined testbench with waveform dumping and assertions
    ├── run_sim.sh                 # One-click pipelined simulation script
    └── README.md                  # Detailed 5-stage pipeline architecture documentation
```

---

## ⚙️ Supported Instruction Set (RV32I Base Integer Subset)

Both processors provide hardware decode and execution for the base integer subset:

- **R-Type:** `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
- **I-Type Arithmetic & Shifts:** `ADDI`, `SLLI`, `SLTI`, `SLTIU`, `XORI`, `SRLI`, `SRAI`, `ORI`, `ANDI`
- **Loads & Stores (Word-Aligned):** `LW`, `SW` (decodes `funct3 = 010`; other sub-word variants act as safe NOPs)
- **Conditional Branches:** `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- **Upper Immediate & Jumps:** `LUI`, `AUIPC`, `JAL`, `JALR`

*Note: Environment call/break (`ECALL`, `EBREAK`), memory barrier (`FENCE`), and sub-word accesses (`LB`, `LH`, `LBU`, `LHU`, `SB`, `SH`) default to safe NOP operations without state modification.*

---

## 🔬 Simulation & Verification

Both cores are verified through comprehensive behavioral simulation with 0 compilation errors and 0 warnings under standard tool flags. Each testbench performs 34 automated self-checking assertions and terminates with a non-zero exit code on failure.

### Running the Single-Cycle Core
```bash
cd single-cycle
./run_sim.sh
```
*Executes the benchmark program and outputs automated self-checking assertion results.*

### Running the 5-Stage Pipelined Core
```bash
cd pipelined
./run_sim.sh
```
*Executes the benchmark program and outputs real-time forwarding, stall, and flush events.*
