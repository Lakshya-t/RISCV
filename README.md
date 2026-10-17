# RISC-V (RV32I) Processor Cores in Verilog

This repository contains two complete hardware implementations of the 32-bit RISC-V Instruction Set Architecture (**RV32I** Base Integer Subset) designed in synthesizable Verilog HDL:

1. **[`single-cycle/`](single-cycle/):** A non-pipelined, single-cycle baseline processor serving as the functional golden verification model.
2. **[`pipelined/`](pipelined/):** A high-throughput 5-stage classic RISC pipelined processor with dynamic data forwarding, load-use hazard stalling, and branch flushing.

---

## 📊 Microarchitecture Comparison

| Feature | Single-Cycle Core (`single-cycle/`) | 5-Stage Pipelined Core (`pipelined/`) |
| :--- | :--- | :--- |
| **Pipeline Stages** | 1 (Non-pipelined) | 5 (IF, ID, EX, MEM, WB) |
| **Clock Frequency** | 50 MHz (20 ns cycle period) | 50 MHz+ (decomposed critical path) |
| **Ideal CPI** | 1.0 | 1.0 (approaching) |
| **Data Hazards** | N/A (completed in one cycle) | Resolved via EX-to-EX & MEM-to-EX Forwarding |
| **Load-Use Hazards** | N/A | Hardware detection with 1-cycle stall bubble |
| **Control Hazards** | Single-cycle branch resolution | Evaluated in EX; 2-cycle flush penalty on branch taken |
| **Memory Model** | Harvard (Separate byte ROM & RAM) | Harvard (Word-aligned 4 KB ROM & RAM) |
| **Register File** | 32 × 32-bit, `x0` hardwired to 0 | 32 × 32-bit, `x0` hardwired to 0 + internal write bypass |
| **Supported ISA** | RV32I (R, I, S, B, U, J) | RV32I (R, I, S, B, U, J) |

---

## 📁 Repository Organization

```text
RISC-V/
├── README.md                      # Root repository overview and architectural comparison
├── single-cycle/                  # Single-Cycle RV32I Processor Core
│   ├── src/                       # Design source files
│   │   ├── top_riscv.v            # Top-level single-cycle core
│   │   ├── data_path.v            # Datapath routing logic
│   │   ├── control_unit.v         # Opcode & funct decoder
│   │   ├── register_file.v        # 32 x 32-bit register file (x0 write protected)
│   │   ├── alu.v                  # Arithmetic Logic Unit (10 operations + branch comp)
│   │   ├── instruction_fetch_unit.v # Program Counter and sequential step logic
│   │   ├── instruction_memory.v   # 24-instruction preloaded ROM
│   │   ├── data_memory.v          # 32-byte synchronous RAM
│   │   └── imm_gen.v              # Immediate generation module
│   ├── testbench/                 # Testbench files
│   │   └── top_tb.v               # Single-cycle testbench
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
    │   ├── Instruction_Memory.v   # 1024-word preloaded ROM (24-instruction suite)
    │   ├── Data_Memory.v          # 1024-word RAM (4 KB)
    │   ├── Sign_Extend.v          # Immediate generator for I, S, B, J, and U (LUI)
    │   ├── PC.v                   # Program Counter register with stall-enable
    │   ├── PC_Adder.v             # 32-bit adder for PC increments and targets
    │   └── Mux.v                  # Parameterized 2:1 and 3:1 multiplexers
    ├── testbench/
    │   └── pipeline_tb.v          # Pipelined testbench with waveform dumping and assertions
    ├── run_sim.sh                 # One-click pipelined simulation script
    └── README.md                  # Detailed 5-stage pipeline architecture documentation
```

---

## ⚙️ Supported Instruction Set (RV32I)

Both processors provide complete hardware decode and execution for the base integer subset:

- **R-Type:** `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
- **I-Type Arithmetic & Shifts:** `ADDI`, `SLLI`, `SLTI`, `SLTIU`, `XORI`, `SRLI`, `SRAI`, `ORI`, `ANDI`
- **Loads:** `LW`
- **Stores:** `SW`
- **Conditional Branches:** `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- **Upper Immediate & Jumps:** `LUI`, `AUIPC`, `JAL`, `JALR`

---

## 🔬 Simulation & Verification

Both cores are verified through comprehensive RTL behavioral simulation with zero compilation errors and zero warnings.

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
