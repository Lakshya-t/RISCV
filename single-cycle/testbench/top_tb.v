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

        // Run for 60 cycles (all instructions complete)
        repeat (60) begin
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
        $display("  x1  (jal link)       = 0x%08h (Expected: 0x000000c0)", dut.dpu.rf.registers[1]);
        $display("  x2  (sll 5<<3)       = %0d (Expected: 40)",         dut.dpu.rf.registers[2]);
        $display("  x3  (srl 40>>3)      = %0d (Expected: 5)",          dut.dpu.rf.registers[3]);
        $display("  x4  (addi -16)       = %0d (Expected: -16)",        $signed(dut.dpu.rf.registers[4]));
        $display("  x5  (addi 5)         = %0d (Expected: 5)",          dut.dpu.rf.registers[5]);
        $display("  x6  (addi 3)         = %0d (Expected: 3)",          dut.dpu.rf.registers[6]);
        $display("  x7  (add 5+3)        = %0d (Expected: 8)",          dut.dpu.rf.registers[7]);
        $display("  x8  (sub 8-3, fwd1)  = %0d (Expected: 5)",          dut.dpu.rf.registers[8]);
        $display("  x9  (and 5&5, fwd2)  = %0d (Expected: 5)",          dut.dpu.rf.registers[9]);
        $display("  x10 (or  5|3)        = %0d (Expected: 7)",          dut.dpu.rf.registers[10]);
        $display("  x11 (xor 5^3)        = %0d (Expected: 6)",          dut.dpu.rf.registers[11]);
        $display("  x12 (slli 5<<17)     = 0x%08h (Expected: 0x000a0000)", dut.dpu.rf.registers[12]);
        $display("  x13 (srli >>16)      = %0d (Expected: 10)",         dut.dpu.rf.registers[13]);
        $display("  x14 (lw from RAM[0]) = %0d (Expected: 88)",         dut.dpu.rf.registers[14]);
        $display("  x15 (load-use+12)    = %0d (Expected: 100)",        dut.dpu.rf.registers[15]);
        $display("  x16 (lui 0x12345)    = 0x%08h (Expected: 0x12345000)", dut.dpu.rf.registers[16]);
        $display("  x17 (jalr link)      = 0x%08h (Expected: 0x000000cc)", dut.dpu.rf.registers[17]);
        $display("  x18 (flushed trap)   = %0d (Expected: 0, FLUSHED)", dut.dpu.rf.registers[18]);
        $display("  x19 (final marker)   = %0d (Expected: 42)",         dut.dpu.rf.registers[19]);
        $display("  x20 (sra -16>>>3)    = %0d (Expected: -2)",         $signed(dut.dpu.rf.registers[20]));
        $display("  x21 (srai -16>>>2)   = %0d (Expected: -4)",         $signed(dut.dpu.rf.registers[21]));
        $display("  x22 (slt -16<5)      = %0d (Expected: 1)",          dut.dpu.rf.registers[22]);
        $display("  x23 (sltu neg<5)     = %0d (Expected: 0)",          dut.dpu.rf.registers[23]);
        $display("  x24 (slti -16<-10)   = %0d (Expected: 1)",          dut.dpu.rf.registers[24]);
        $display("  x25 (sltiu neg<10)   = %0d (Expected: 0)",          dut.dpu.rf.registers[25]);
        $display("  x26 (store val)      = %0d (Expected: 88)",         dut.dpu.rf.registers[26]);
        $display("  x27 (lw RAM[1]->br)  = %0d (Expected: 100)",        dut.dpu.rf.registers[27]);
        $display("  x28 (auipc)          = 0x%08h (Expected: 0x0000206c)", dut.dpu.rf.registers[28]);
        $display("  x29 (loop count)     = %0d (Expected: 0)",          dut.dpu.rf.registers[29]);
        $display("  x30 (jalr odd tgt)   = %0d (Expected: 209)",        dut.dpu.rf.registers[30]);
        $display("--------------------------------------------------------------------------");
        $display("Data Memory Verification:");
        $display("  Data_RAM[0]          = %0d (Expected: 88)", dut.dpu.dmem.memory[0]);
        $display("  Data_RAM[1]          = %0d (Expected: 100)", dut.dpu.dmem.memory[1]);
        $display("--------------------------------------------------------------------------");

        // Self-checking assertions (32 checks)
        if (dut.dpu.rf.registers[1]  !== 32'h000000c0) error_count = error_count + 1;
        if (dut.dpu.rf.registers[2]  !== 40)           error_count = error_count + 1;
        if (dut.dpu.rf.registers[3]  !== 5)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[4]  !== 32'hfffffff0) error_count = error_count + 1;
        if (dut.dpu.rf.registers[5]  !== 5)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[6]  !== 3)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[7]  !== 8)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[8]  !== 5)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[9]  !== 5)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[10] !== 7)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[11] !== 6)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[12] !== 32'h000a0000) error_count = error_count + 1;
        if (dut.dpu.rf.registers[13] !== 10)           error_count = error_count + 1;
        if (dut.dpu.rf.registers[14] !== 88)           error_count = error_count + 1;
        if (dut.dpu.rf.registers[15] !== 100)          error_count = error_count + 1;
        if (dut.dpu.rf.registers[16] !== 32'h12345000) error_count = error_count + 1;
        if (dut.dpu.rf.registers[17] !== 32'h000000cc) error_count = error_count + 1;
        if (dut.dpu.rf.registers[18] !== 0)            error_count = error_count + 1; // Flushed / skipped
        if (dut.dpu.rf.registers[19] !== 42)           error_count = error_count + 1;
        if (dut.dpu.rf.registers[20] !== 32'hfffffffe) error_count = error_count + 1;
        if (dut.dpu.rf.registers[21] !== 32'hfffffffc) error_count = error_count + 1;
        if (dut.dpu.rf.registers[22] !== 1)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[23] !== 0)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[24] !== 1)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[25] !== 0)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[26] !== 88)           error_count = error_count + 1;
        if (dut.dpu.rf.registers[27] !== 100)          error_count = error_count + 1;
        if (dut.dpu.rf.registers[28] !== 32'h0000206c) error_count = error_count + 1;
        if (dut.dpu.rf.registers[29] !== 0)            error_count = error_count + 1;
        if (dut.dpu.rf.registers[30] !== 209)          error_count = error_count + 1;
        if (dut.dpu.dmem.memory[0]   !== 88)           error_count = error_count + 1;
        if (dut.dpu.dmem.memory[1]   !== 100)          error_count = error_count + 1;

        if (error_count == 0) begin
            $display(">>> SINGLE-CYCLE TEST PASSED: ALL 32 INSTRUCTION CHECKS FULLY VERIFIED! <<<");
        end else begin
            $display(">>> SINGLE-CYCLE TEST FAILED: %0d assertion error(s) encountered! <<<", error_count);
            $fatal(1, "Single-cycle verification suite failed!");
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