`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: control_unit
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module control_unit(
                    input reset,                    // reset signal from top module
                    input [6:0] funct7,             // function 7 field from instruction_out[31:25]
                    input [2:0] funct3,             // function 3 field from instruction_out[14:12]
                    input [6:0] opcode,             // opcode field from instruction_out[6:0]
                    output reg [5:0] alu_control,   // 6-bit control code sent to alu
                    output reg lb,                  // load enable sent to register_file and datapath
                    output reg mem_to_reg,          // memory to register signal (for load writeback)
                    output reg bneq_control,        // bne instruction enable sent to datapath
                    output reg beq_control,         // beq instruction enable sent to datapath
                    output reg bgeq_control,        // bge instruction enable sent to datapath
                    output reg blt_control,         // blt instruction enable sent to datapath
                    output reg jump,                // jump instruction enable sent to ifu and datapath
                    output reg sw,                  // store enable sent to register_file and data_memory
                    output reg lui_control          // lui instruction enable sent to register_file and datapath
                   );
 
    ////////////////////////////////////////// Logic for reset operation ///////////////////////////////////////////////////////////////////////
    
        always@(reset)
            begin
                if(reset)
                    alu_control = 0;
            end

    ///////////////////////////////////////////Logic for analyzing the type of the instruction /////////////////////////////////////////////////////////
        always@(funct7 or funct3 or opcode)
            begin
            
            ///////////////////////////////////////////// R - TYPE INSTRUCTIONS (opcode: 0110011) //////////////////////////////////////////////////////          
             
                if(opcode == 7'b0110011)
                    begin
                    mem_to_reg = 0;
                    beq_control = 0;
                    bneq_control = 0;
                    bgeq_control = 0;
                    blt_control = 0;
                    jump = 0;
                    lui_control = 0;
                    lb = 0;
                    sw = 0;

                case(funct3)
                    3'b000:
                        begin
                            // addition (funct7 == 0)
                            if(funct7 == 0)
                                alu_control = 6'b000001;
                                                     
                            // subtraction (funct7 == 64 -> 7'b0100000)
                            else if(funct7 == 64)
                                alu_control = 6'b000010; 
                        end
                        
                    3'b001: // shift left logical
                          begin
                             if(funct7 == 0)
                                alu_control = 6'b000011;                           
                           end
                           
                    3'b010: // set less than (signed)
                         begin
                              if(funct7 == 0)
                                  alu_control = 6'b000100; 
                           end
                            
                    3'b011: // set less than unsigned
                            begin
                                if(funct7 == 0)
                                    alu_control = 6'b000101; 
                             end
                             
                    3'b100: // xor operation
                            begin
                                if(funct7 == 0)
                                    alu_control = 6'b000110; 
                                end

                    3'b101:
                            begin
                                // shift right logical
                                if(funct7 == 0)
                                    alu_control = 6'b000111; 
                                // shift right arithmetic
                                else if(funct7 == 64)
                                    alu_control = 6'b001000;
                             end

                    3'b110: // or operation
                            begin
                                if(funct7 == 0)
                                   alu_control = 6'b001001;
                             end

                    3'b111: // and operation
                            begin
                                if(funct7 == 0)
                                    alu_control = 6'b001010;
                             end
                  endcase
                  end
                  
            /////////////////////////////////////////// I - TYPE ARITHMETIC INSTRUCTIONS (opcode: 0010011) /////////////////////////////////////////////
                  
                  else if(opcode == 7'b001_0011)
                  begin
                      mem_to_reg = 0;
                      beq_control = 0;
                      bneq_control = 0;
                      jump = 0;
                      lb = 0;
                      sw = 0;
                      lui_control = 0;
                        
                       case(funct3)
                            3'b000: // add immediate (addi)
                                alu_control = 6'b001011;

                            3'b001: // shift left logical immediate (slli)
                                alu_control = 6'b001100;
                                        
                            3'b010: // set less than immediate (slti)
                                alu_control = 6'b001101;
                                         
                            3'b011: // set less than immediate unsigned (sltiu)
                                alu_control = 6'b001110;
                                         
                            3'b100: // xor immediate (xori)
                                alu_control = 6'b001111;
                                        
                            3'b101: // shift right logical immediate (srli)
                                alu_control = 6'b010000;
                                         
                            3'b110: // or immediate (ori)
                                alu_control = 6'b010001;
                                   
                            3'b111: // and immediate (andi)
                                alu_control = 6'b010010;
                       endcase
                  end
                        
            /////////////////////////////////////////// I - TYPE LOAD INSTRUCTIONS (opcode: 0000011) //////////////////////////////////////////////////
                  
                  else if(opcode == 7'b000_0011)
                  begin
                      mem_to_reg = 1;           
                      beq_control = 0;                  
                      bneq_control = 0;                 
                      jump = 0;  
                      lb = 1;               
                      sw = 0;
                      lui_control = 0;
                        
                      case(funct3)
                          3'b000: // load byte (lb)
                              alu_control = 6'b010011;
                                         
                          3'b001: // load halfword (lh)
                              alu_control = 6'b010100;
                                     
                          3'b010: // load word (lw)
                              alu_control = 6'b010101;
                                        
                          3'b011: // load byte unsigned (lbu)
                              alu_control = 6'b010110;
                                                                                
                          3'b100: // load halfword unsigned (lhu)
                              alu_control = 6'b010111;
                      endcase
                  end
                                    
            /////////////////////////////////////////// S - TYPE STORE INSTRUCTIONS (opcode: 0100011) /////////////////////////////////////////////////
                  
                  else if(opcode == 7'b010_0011)
                  begin
                      mem_to_reg = 0;        
                      beq_control = 0;               
                      bneq_control = 0;              
                      jump = 0;
                      lb = 0;
                      sw = 1;
                      lui_control = 0;
                      
                      case(funct3)
                          3'b000: // store byte (sb)
                              alu_control = 6'b011000;
                                        
                          3'b001: // store halfword (sh)
                              alu_control = 6'b011001;
                                        
                          3'b010: // store word (sw)
                              alu_control = 6'b011010;
                              
                          default:
                              alu_control = 6'b011010;
                      endcase
                  end
                       
            /////////////////////////////////////////// B - TYPE BRANCH INSTRUCTIONS (opcode: 1100011) ////////////////////////////////////////////////
                  
                  else if(opcode == 7'b110_0011)
                  begin
                      mem_to_reg = 0;
                      jump = 0;
                      lb = 0;
                      sw = 0;
                      lui_control = 0;
                      
                      case(funct3)
                          3'b000: // branch equal (beq)
                              begin
                                  alu_control = 6'b011011; 
                                  beq_control = 1;
                                  bneq_control = 0;
                                  blt_control = 0;
                                  bgeq_control = 0;
                              end
                                    
                          3'b001: // branch not equal (bne)
                              begin
                                  alu_control = 6'b011100;
                                  bneq_control = 1;
                                  beq_control = 0;
                                  blt_control = 0;
                                  bgeq_control = 0;
                              end
                                    
                          3'b100: // branch less than (blt)
                              begin
                                  alu_control = 6'b100000;
                                  blt_control = 1;
                                  beq_control = 0;
                                  bneq_control = 0;
                                  bgeq_control = 0;
                              end
                                    
                          3'b101: // branch greater than or equal (bge)
                              begin
                                  alu_control = 6'b011111;
                                  bgeq_control = 1;
                                  blt_control = 0;
                                  beq_control = 0;
                                  bneq_control = 0;
                              end
                      endcase
                  end
                       
            /////////////////////////////////////////// U - TYPE LUI INSTRUCTION (opcode: 0110111) ////////////////////////////////////////////////////
                       
                  else if(opcode == 7'b011_0111)
                  begin
                      alu_control = 6'b100001;
                      lui_control = 1;
                      sw = 0;
                      lb = 0;
                      beq_control = 0;
                      blt_control = 0;
                      bneq_control = 0;
                      bgeq_control = 0;
                      jump = 0;
                      mem_to_reg = 0;
                  end
                             
            /////////////////////////////////////////// J - TYPE JAL INSTRUCTION (opcode: 1101111) ////////////////////////////////////////////////////
                      
                  else if(opcode == 7'b110_1111)
                  begin
                      alu_control = 6'b100010;
                      jump = 1;
                      lui_control = 0;
                      sw = 0;
                      lb = 0;
                      beq_control = 0;
                      blt_control = 0;
                      bneq_control = 0;
                      bgeq_control = 0;
                      mem_to_reg = 0;
                  end
                  
            end 
        
endmodule