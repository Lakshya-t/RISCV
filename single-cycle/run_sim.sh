#!/bin/bash
# Script to compile and simulate the single-cycle RISC-V processor

set -e

echo "Compiling Single-Cycle RISC-V Core..."
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

echo "Running simulation..."
vvp single_sim

echo "Cleaning up binary..."
rm -f single_sim

echo "Simulation finished! Waveform saved to waveform.vcd"
