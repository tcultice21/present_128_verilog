//======================================================================
//
// Design Name:    PRESENT_Controller TB
// Module Name:    CONTROLLER_TB
//
// Description:    Testbench of PRESENT Hardware Test Apparatus
//
//
// Language: Verilog
// Author: Tyler Cultice
// Date:   March 2025
// URL: https://github.com/tcultice21
//
// Copyright Notice: Free use of this library is permitted under the
// guidelines and in accordance with the MIT License (MIT).
// http://opensource.org/licenses/MIT
//
//======================================================================

`timescale 1ns/1ps

module CONTROLLER_TB;
    reg [5:0] select;
    reg load;
    reg clk;
    wire valid;
    
     present_uut_hw_test #(128, 64, 64, 32) uut_1 (
     .seq_selected(select),
     .sig_mstr_clk(clk),
     .sig_in_load(load),
     .sig_out_valid(valid)
     );
    
    initial begin
       forever
        #1 clk = ~clk;
    end
    
    integer i;
    initial begin
        clk = 0;
        load = 0;
        select = 0;
        #2;
        for(i = 0; i < 32; i = i + 1) begin
            select = i;
            load = 1;
            #2 load = 0;
            #14;
        end
        $finish;
    end
endmodule


endmodule