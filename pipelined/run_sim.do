# ==============================================================================
# ModelSim / QuestaSim Simulation Macro - 5-Stage Pipelined RV32I Processor
# ==============================================================================

# Create and map working library
vlib work
vmap work work

# Compile synthesizable RTL modules and self-checking testbench
vlog -work work \
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

# Elaborate top-level testbench with full visibility
vsim -voptargs="+acc" work.pipeline_tb

# Log and plot signals in ModelSim waveform viewer
add wave -position insertpoint sim:/pipeline_tb/*
add wave -position insertpoint sim:/pipeline_tb/uut/*
add wave -position insertpoint sim:/pipeline_tb/uut/HU/*

# Run simulation until completion ($finish)
run -all
