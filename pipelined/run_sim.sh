#!/bin/bash
# Script to compile and simulate the 5-stage pipelined RISC-V processor

set -e

# Navigate to script directory
cd "$(dirname "$0")"

echo "=========================================================================="
echo "          Simulating RISC-V 5-Stage Pipelined Processor"
echo "=========================================================================="

if command -v vsim &> /dev/null && command -v vlog &> /dev/null; then
    echo "[INFO] ModelSim / QuestaSim detected. Running run_sim.do in batch mode..."
    vsim -c -do "do run_sim.do; quit"
elif command -v iverilog &> /dev/null; then
    echo "[INFO] ModelSim not found in PATH; running simulation via Icarus Verilog..."
    iverilog -Wall -g2012 -o pipe_sim \
        src/Mux.v \
        src/PC.v \
        src/PC_Adder.v \
        src/ALU.v \
        src/Control_Unit_Top.v \
        src/Register_File.v \
        src/Sign_Extend.v \
        src/Instruction_Memory.v \
        src/Data_Memory.v \
        src/Hazard_Unit.v \
        src/Fetch_Cycle.v \
        src/Decode_Cycle.v \
        src/Execute_Cycle.v \
        src/Memory_Cycle.v \
        src/Writeback_Cycle.v \
        src/Pipeline_Top.v \
        testbench/pipeline_tb.v
    vvp pipe_sim
    rm -f pipe_sim
else
    echo "[ERROR] Neither ModelSim (vsim) nor Icarus Verilog (iverilog) found in PATH."
    exit 1
fi

echo "Simulation completed successfully!"
