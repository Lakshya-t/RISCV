#!/bin/bash
# Script to compile and simulate the single-cycle RISC-V processor

set -e

# Navigate to script directory
cd "$(dirname "$0")"

echo "=========================================================================="
echo "          Simulating RISC-V Single-Cycle Processor"
echo "=========================================================================="

if command -v vsim &> /dev/null && command -v vlog &> /dev/null; then
    echo "[INFO] ModelSim / QuestaSim detected. Running run_sim.do in batch mode..."
    vsim -c -do "do run_sim.do; quit"
elif command -v iverilog &> /dev/null; then
    echo "[INFO] ModelSim not found in PATH; running simulation via Icarus Verilog..."
    iverilog -Wall -g2012 -o single_sim \
        testbench/top_tb.v \
        src/top_riscv.v \
        src/instruction_fetch_unit.v \
        src/instruction_memory.v \
        src/control_unit.v \
        src/data_path.v \
        src/register_file.v \
        src/alu.v \
        src/data_memory.v \
        src/imm_gen.v
    vvp single_sim
    rm -f single_sim
else
    echo "[ERROR] Neither ModelSim (vsim) nor Icarus Verilog (iverilog) found in PATH."
    exit 1
fi

echo "Simulation completed successfully!"
