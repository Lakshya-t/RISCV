`timescale 1ns / 1ps

module pipeline_tb;

    reg clk;
    reg rst;
    integer cycle_count;
    integer error_count;

    // Clock generator: 50 MHz (20 ns cycle period)
    always begin
        #10 clk = ~clk;
    end

    // Device Under Test (DUT)
    Pipeline_Top dut (
        .clk(clk),
        .rst(rst)
    );

    // Waveform VCD dump
    initial begin
        $dumpfile("pipeline_waveform.vcd");
        $dumpvars(0, pipeline_tb);
    end

    // Stimulus and Self-Checking Execution
    initial begin
        clk = 0;
        rst = 1'b0;
        cycle_count = 0;
        error_count = 0;

        $display("\n==========================================================================");
        $display("       RISC-V (RV32I) 5-STAGE PIPELINED PROCESSOR VERIFICATION");
        $display("==========================================================================");

        // Hold reset for 5 cycles
        #100;
        @(posedge clk);
        rst <= 1'b1;
        $display("[INFO] Time %0t ps: Reset de-asserted. Processor execution started...\n", $time);

        // Run for 80 cycles to execute entire benchmark program through writeback
        repeat (80) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end

        // Final Automated Verification Checks
        $display("\n==========================================================================");
        $display("                   FINAL PIPELINE VERIFICATION REPORT");
        $display("==========================================================================");
        $display("Total Simulated Cycles: %0d", cycle_count);
        $display("--------------------------------------------------------------------------");
        $display("Register File Verification:");
        $display("  x1  (jal link)       = 0x%08h (Expected: 0x000000c0)", dut.decode_stage.rf.registers[1]);
        $display("  x2  (sll 5<<3)       = %0d (Expected: 40)",         dut.decode_stage.rf.registers[2]);
        $display("  x3  (srl 40>>3)      = %0d (Expected: 5)",          dut.decode_stage.rf.registers[3]);
        $display("  x4  (addi -16)       = %0d (Expected: -16)",        $signed(dut.decode_stage.rf.registers[4]));
        $display("  x5  (addi 5)         = %0d (Expected: 5)",          dut.decode_stage.rf.registers[5]);
        $display("  x6  (addi 3)         = %0d (Expected: 3)",          dut.decode_stage.rf.registers[6]);
        $display("  x7  (add 5+3)        = %0d (Expected: 8, FWD)",     dut.decode_stage.rf.registers[7]);
        $display("  x8  (sub 8-3, fwd1)  = %0d (Expected: 5, FWD-EX)",  dut.decode_stage.rf.registers[8]);
        $display("  x9  (and 5&5, fwd2)  = %0d (Expected: 5, FWD-MEM)", dut.decode_stage.rf.registers[9]);
        $display("  x10 (or  5|3)        = %0d (Expected: 7)",          dut.decode_stage.rf.registers[10]);
        $display("  x11 (xor 5^3)        = %0d (Expected: 6)",          dut.decode_stage.rf.registers[11]);
        $display("  x12 (slli 5<<17)     = 0x%08h (Expected: 0x000a0000)", dut.decode_stage.rf.registers[12]);
        $display("  x13 (srli >>16)      = %0d (Expected: 10)",         dut.decode_stage.rf.registers[13]);
        $display("  x14 (lw from RAM[0]) = %0d (Expected: 88)",         dut.decode_stage.rf.registers[14]);
        $display("  x15 (load-use+12)    = %0d (Expected: 100, STALL)", dut.decode_stage.rf.registers[15]);
        $display("  x16 (lui 0x12345)    = 0x%08h (Expected: 0x12345000)", dut.decode_stage.rf.registers[16]);
        $display("  x17 (jalr link)      = 0x%08h (Expected: 0x000000cc)", dut.decode_stage.rf.registers[17]);
        $display("  x18 (flushed trap)   = %0d (Expected: 0, FLUSHED)", dut.decode_stage.rf.registers[18]);
        $display("  x19 (final marker)   = %0d (Expected: 42)",         dut.decode_stage.rf.registers[19]);
        $display("  x20 (sra -16>>>3)    = %0d (Expected: -2)",         $signed(dut.decode_stage.rf.registers[20]));
        $display("  x21 (srai -16>>>2)   = %0d (Expected: -4)",         $signed(dut.decode_stage.rf.registers[21]));
        $display("  x22 (slt -16<5)      = %0d (Expected: 1)",          dut.decode_stage.rf.registers[22]);
        $display("  x23 (sltu neg<5)     = %0d (Expected: 0)",          dut.decode_stage.rf.registers[23]);
        $display("  x24 (slti -16<-10)   = %0d (Expected: 1)",          dut.decode_stage.rf.registers[24]);
        $display("  x25 (sltiu neg<10)   = %0d (Expected: 0)",          dut.decode_stage.rf.registers[25]);
        $display("  x26 (store val)      = %0d (Expected: 88)",         dut.decode_stage.rf.registers[26]);
        $display("  x27 (lw RAM[1]->br)  = %0d (Expected: 100)",        dut.decode_stage.rf.registers[27]);
        $display("  x28 (auipc)          = 0x%08h (Expected: 0x0000206c)", dut.decode_stage.rf.registers[28]);
        $display("  x29 (loop count)     = %0d (Expected: 0)",          dut.decode_stage.rf.registers[29]);
        $display("  x30 (jalr odd tgt)   = %0d (Expected: 209)",        dut.decode_stage.rf.registers[30]);
        $display("--------------------------------------------------------------------------");
        $display("Data Memory Verification:");
        $display("  Data_RAM[0]          = %0d (Expected: 88)", dut.memory_stage.dmem.memory[0]);
        $display("  Data_RAM[1]          = %0d (Expected: 100)", dut.memory_stage.dmem.memory[1]);
        $display("--------------------------------------------------------------------------");

        // Self-checking assertions (32 checks)
        if (dut.decode_stage.rf.registers[1]  !== 32'h000000c0) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[2]  !== 40)           error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[3]  !== 5)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[4]  !== 32'hfffffff0) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[5]  !== 5)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[6]  !== 3)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[7]  !== 8)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[8]  !== 5)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[9]  !== 5)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[10] !== 7)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[11] !== 6)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[12] !== 32'h000a0000) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[13] !== 10)           error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[14] !== 88)           error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[15] !== 100)          error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[16] !== 32'h12345000) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[17] !== 32'h000000cc) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[18] !== 0)            error_count = error_count + 1; // Flushed / skipped
        if (dut.decode_stage.rf.registers[19] !== 42)           error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[20] !== 32'hfffffffe) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[21] !== 32'hfffffffc) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[22] !== 1)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[23] !== 0)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[24] !== 1)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[25] !== 0)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[26] !== 88)           error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[27] !== 100)          error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[28] !== 32'h0000206c) error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[29] !== 0)            error_count = error_count + 1;
        if (dut.decode_stage.rf.registers[30] !== 209)          error_count = error_count + 1;
        if (dut.memory_stage.dmem.memory[0]   !== 88)           error_count = error_count + 1;
        if (dut.memory_stage.dmem.memory[1]   !== 100)          error_count = error_count + 1;

        if (error_count == 0) begin
            $display(">>> PIPELINED TEST PASSED: ALL 32 INSTRUCTION CHECKS, FORWARDING, STALLS, AND FLUSHES VERIFIED! <<<");
        end else begin
            $display(">>> PIPELINED TEST FAILED: %0d assertion error(s) encountered! <<<", error_count);
            $fatal(1, "Pipelined verification suite failed!");
        end
        $display("==========================================================================\n");

        $finish;
    end

    // Real-Time Hardware Event Monitor
    always @(posedge clk) begin
        if (rst) begin
            // 1. Monitor Register Writeback
            if (dut.reg_write_w && (dut.rd_w != 5'd0)) begin
                $display("  [WRITEBACK] Cycle %2d | Reg x%0d <= 0x%08h (%0d)", 
                         cycle_count, dut.rd_w, dut.result_w, $signed(dut.result_w));
            end

            // 2. Monitor Forwarding Events
            if (dut.hazard_unit.forward_a_e != 2'b00) begin
                $display("  [FORWARD-A] Cycle %2d | Forwarded to ALU Input A (Src: %s)",
                         cycle_count, (dut.hazard_unit.forward_a_e == 2'b10) ? "EX/MEM" : "MEM/WB");
            end
            if (dut.hazard_unit.forward_b_e != 2'b00) begin
                $display("  [FORWARD-B] Cycle %2d | Forwarded to ALU Input B (Src: %s)",
                         cycle_count, (dut.hazard_unit.forward_b_e == 2'b10) ? "EX/MEM" : "MEM/WB");
            end

            // 3. Monitor Load-Use Stalls
            if (dut.hazard_unit.stall_f) begin
                $display("  [HAZARD]    Cycle %2d | Load-Use Hazard! Pipeline stalled, 1-cycle bubble inserted into ID/EX", cycle_count);
            end

            // 4. Monitor Taken Branches and Jumps
            if (dut.pc_src_e) begin
                $display("  [BRANCH]    Cycle %2d | Control Flow Redirect -> Target PC = 0x%08h (Flushing IF/ID & ID/EX)", 
                         cycle_count, dut.pc_target_e);
            end
        end
    end

endmodule