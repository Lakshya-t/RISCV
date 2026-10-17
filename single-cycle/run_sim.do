# ==============================================================================
# ModelSim / QuestaSim Simulation Macro - Single-Cycle RV32I Processor
# ==============================================================================

# Create and map working library
vlib work
vmap work work

# Compile synthesizable RTL modules and self-checking testbench
vlog -work work \
    src/instruction_fetch_unit.v \
    src/instruction_memory.v \
    src/control_unit.v \
    src/register_file.v \
    src/alu.v \
    src/data_memory.v \
    src/imm_gen.v \
    src/data_path.v \
    src/top_riscv.v \
    testbench/top_tb.v

# Elaborate top-level testbench with full visibility
vsim -voptargs="+acc" work.top_tb

# Log and plot signals in ModelSim waveform viewer
add wave -position insertpoint sim:/top_tb/*
add wave -position insertpoint sim:/top_tb/uut/*

# Run simulation until completion ($finish)
run -all
