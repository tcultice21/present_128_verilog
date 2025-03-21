//======================================================================
//
// Design Name:    PRESENT Hardware Testing Apparatus/Controller
// Module Name:    present_uut_hw_test
//
// Description:    Implementation for RAM-based Testing Apparatus
//                 for PRESENT-128 Algorithm
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

// Generates Validation Testing RAM blocks with Checksum
module verify_tst_blk #(parameter RESP_SIZE = 64, TEST_CASE_SIZE = 32)(
    input [RESP_SIZE-1:0] vec_in_response,
    input [$clog2(TEST_CASE_SIZE)-1:0] vec_in_sel_addr,
    input sig_in_rdy,
    input sig_in_clk,
    output sig_out_valid
   );
   
   reg [RESP_SIZE:0] bench_resp_vec;
   reg [RESP_SIZE:0] ram_test [TEST_CASE_SIZE-1:0];
   wire SIG_INT_CHK;
   
   localparam MEM_VALIDATION_FILE = "benchmarks.mem";
   initial begin
       if (MEM_VALIDATION_FILE != "") begin
            $readmemh(MEM_VALIDATION_FILE,ram_test);
       end
   end
   
   always@(posedge sig_in_clk) begin
        //Async Read
        bench_resp_vec <= ram_test[vec_in_sel_addr];
   end
   
   //wire test = (~^bench_resp_vec[RESP_SIZE-1:0]);
   assign SIG_INT_CHK = ~(bench_resp_vec[RESP_SIZE] ^ (~^bench_resp_vec[RESP_SIZE-1:0]));
   assign sig_out_valid = SIG_INT_CHK & (sig_in_rdy & (bench_resp_vec[RESP_SIZE-1:0] == vec_in_response));
   
endmodule

//-----------------------------------------------------------------------------

// Generates sequences from RAM block for test vectors/keys.
module test_vec_ram #(parameter KEY_VEC_SIZE = 128, PLAIN_VEC_SIZE = 64, TEST_CASE_SIZE = 32)(
    sig_in_clk,
    vec_in_sel_addr,
    vec_out_pln,
    vec_out_key
);

    input sig_in_clk;
    input [$clog2(TEST_CASE_SIZE)-1:0] vec_in_sel_addr;
    output [KEY_VEC_SIZE-1:0] vec_out_key;
    output [PLAIN_VEC_SIZE-1:0] vec_out_pln;
    
    reg [KEY_VEC_SIZE+PLAIN_VEC_SIZE-1:0] ram_read_buf;
    reg [KEY_VEC_SIZE+PLAIN_VEC_SIZE-1:0] test_case_ram [TEST_CASE_SIZE-1:0];
    
    localparam MEM_FILE = "inputs.mem";
   initial begin
       if (MEM_FILE != "") begin
            $readmemh(MEM_FILE,test_case_ram);
       end
   end
   
    always@(negedge sig_in_clk) begin
        ram_read_buf <= test_case_ram[vec_in_sel_addr];
    end
    
    assign vec_out_key = ram_read_buf[KEY_VEC_SIZE-1:0];
    assign vec_out_pln = ram_read_buf[KEY_VEC_SIZE+PLAIN_VEC_SIZE-1:KEY_VEC_SIZE];
    
endmodule

//-----------------------------------------------------------------------------

// Top Module
module present_uut_hw_test #(parameter KEY_VEC_SIZE = 128, parameter RESP_SIZE = 64, PLAIN_VEC_SIZE = 64, TEST_CASE_SIZE = 32) (
    input [$clog2(TEST_CASE_SIZE)-1:0] seq_selected,
    input sig_mstr_clk,
    input sig_in_load,
    output sig_out_valid
    );
    
    wire [PLAIN_VEC_SIZE-1:0] pln_test_case;
    wire [KEY_VEC_SIZE-1:0] key_test_case;
    wire [RESP_SIZE-1:0] cphr_test_resp;
    wire sig_done_wait;
    
    test_vec_ram #(KEY_VEC_SIZE,PLAIN_VEC_SIZE,TEST_CASE_SIZE) vec_t (
        .sig_in_clk(sig_mstr_clk),
    .vec_in_sel_addr(seq_selected),
    .vec_out_pln(pln_test_case),
    .vec_out_key(key_test_case)
    );
    
    PRESENT_ENCRYPT dut(cphr_test_resp,pln_test_case,key_test_case,sig_in_load,sig_mstr_clk,sig_done_wait);
    
    verify_tst_blk #(RESP_SIZE, TEST_CASE_SIZE) verify_uut (
    .vec_in_response(cphr_test_resp),
    .vec_in_sel_addr(seq_selected),
    .sig_in_rdy(sig_done_wait),
    .sig_in_clk(sig_mstr_clk),
    .sig_out_valid(sig_out_valid)
    );
endmodule