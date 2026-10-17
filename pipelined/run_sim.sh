#!/bin/bash
# Script to compile and simulate the 5-stage pipelined RISC-V processor

set -e

echo "Compiling 5-stage Pipelined RISC-V Core..."
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

echo "Running simulation..."
vvp pipe_sim

echo "Cleaning up binary..."
rm -f pipe_sim

echo "Simulation finished! Waveform saved to pipeline_waveform.vcd"
