`timescale 1ns / 1ps

module top_tb;

    reg clk;
    reg reset;
    integer cycle_count;
    integer error_count;

    // 50 MHz clock generation (20 ns cycle period)
    always begin
        #10 clk = ~clk;
    end

    // Device Under Test (DUT)
    top_riscv dut (
        .clk(clk),
        .reset(reset)
    );

    // Waveform VCD dump
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_tb);
    end

    // Simulation stimulus and automated verification
    initial begin
        clk = 0;
        reset = 1'b1;
        cycle_count = 0;
        error_count = 0;

        $display("\n==========================================================================");
        $display("       RISC-V (RV32I) SINGLE-CYCLE PROCESSOR VERIFICATION");
        $display("==========================================================================");

        // Hold reset for 5 cycles
        #100;
        @(posedge clk);
        reset <= 1'b0;
        $display("[INFO] Time %0t ps: Reset de-asserted. Single-cycle execution started...\n", $time);

        // Run for 30 cycles (each instruction completes in 1 cycle)
        repeat (30) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end

        // Final Automated Verification Checks
        $display("\n==========================================================================");
        $display("                   FINAL SINGLE-CYCLE VERIFICATION REPORT");
        $display("==========================================================================");
        $display("Total Simulated Cycles: %0d", cycle_count);
        $display("--------------------------------------------------------------------------");
        $display("Register File Verification:");
        $display("  x5  (addi 5)      = %0d (Expected: 5)",          dut.dpu.rf.registers[5]);
        $display("  x6  (addi 3)      = %0d (Expected: 3)",          dut.dpu.rf.registers[6]);
        $display("  x7  (add 5+3)     = %0d (Expected: 8)",          dut.dpu.rf.registers[7]);
        $display("  x8  (sub 5-3)     = %0d (Expected: 2)",          dut.dpu.rf.registers[8]);
        $display("  x9  (and 5&3)     = %0d (Expected: 1)",          dut.dpu.rf.registers[9]);
        $display("  x10 (or  5|3)     = %0d (Expected: 7)",          dut.dpu.rf.registers[10]);
        $display("  x11 (xor 5^3)     = %0d (Expected: 6)",          dut.dpu.rf.registers[11]);
        $display("  x12 (sll 5<<3)    = %0d (Expected: 40)",         dut.dpu.rf.registers[12]);
        $display("  x13 (slt 3<5)     = %0d (Expected: 1)",          dut.dpu.rf.registers[13]);
        $display("  x14 (lw from RAM) = %0d (Expected: 8)",          dut.dpu.rf.registers[14]);
        $display("  x15 (addi x14+2)  = %0d (Expected: 10)",         dut.dpu.rf.registers[15]);
        $display("  x16 (lui 0x12345) = 0x%08h (Expected: 0x12345000)", dut.dpu.rf.registers[16]);
        $display("  x17 (bne skip)    = %0d (Expected: 0, SKIPPED)", dut.dpu.rf.registers[17]);
        $display("  x1  (jal link)    = 0x%08h (Expected: PC+4)",    dut.dpu.rf.registers[1]);
        $display("  x18 (jal skip)    = %0d (Expected: 0, SKIPPED)", dut.dpu.rf.registers[18]);
        $display("  x19 (final mark)  = %0d (Expected: 42)",         dut.dpu.rf.registers[19]);
        $display("--------------------------------------------------------------------------");
        $display("Data Memory Verification:");
        $display("  Data_RAM[0]       = %0d (Expected: 8)", dut.dpu.dmem.memory[0]);
        $display("--------------------------------------------------------------------------");

        // Self-checking assertions
        if (dut.dpu.rf.registers[5]  !== 5)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[6]  !== 3)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[7]  !== 8)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[8]  !== 2)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[9]  !== 1)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[10] !== 7)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[11] !== 6)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[12] !== 40) error_count = error_count + 1;
        if (dut.dpu.rf.registers[13] !== 1)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[14] !== 8)  error_count = error_count + 1;
        if (dut.dpu.rf.registers[15] !== 10) error_count = error_count + 1;
        if (dut.dpu.rf.registers[16] !== 32'h12345000) error_count = error_count + 1;
        if (dut.dpu.rf.registers[17] !== 0)  error_count = error_count + 1; // Must be skipped by BNE!
        if (dut.dpu.rf.registers[18] !== 0)  error_count = error_count + 1; // Must be skipped by JAL!
        if (dut.dpu.rf.registers[19] !== 42) error_count = error_count + 1;
        if (dut.dpu.dmem.memory[0]   !== 8)  error_count = error_count + 1;

        if (error_count == 0) begin
            $display(">>> SINGLE-CYCLE TEST PASSED: ALL 19 INSTRUCTION CHECKS FULLY VERIFIED! <<<");
        end else begin
            $display(">>> SINGLE-CYCLE TEST FAILED: %0d assertion errors encountered! <<<", error_count);
        end
        $display("==========================================================================\n");

        $finish;
    end

    // Real-Time Instruction Execution Monitor
    always @(posedge clk) begin
        if (!reset) begin
            if (dut.reg_write && (dut.instruction[11:7] != 5'd0)) begin
                $display("  Cycle %2d | PC = 0x%08h | Reg x%0d <= 0x%08h (%0d)", 
                         cycle_count, dut.pc, dut.instruction[11:7], dut.dpu.write_back_data, $signed(dut.dpu.write_back_data));
            end
        end
    end

endmodule