//======================================================================
//
// Design Name:    PRESENT-128 Block Cipher
// Module Name:    PRESENT_128
//
// Description:  Substitution Box (s-box) of Present Encryption
//
// Dependencies: none
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

module present_sbox (
   output reg [3:0] out_data,
   input      [3:0] in_data
);

always @(in_data)
    case (in_data)
        4'h0 : out_data = 4'hC;
        4'h1 : out_data = 4'h5;
        4'h2 : out_data = 4'h6;
        4'h3 : out_data = 4'hB;
        4'h4 : out_data = 4'h9;
        4'h5 : out_data = 4'h0;
        4'h6 : out_data = 4'hA;
        4'h7 : out_data = 4'hD;
        4'h8 : out_data = 4'h3;
        4'h9 : out_data = 4'hE;
        4'hA : out_data = 4'hF;
        4'hB : out_data = 4'h8;
        4'hC : out_data = 4'h4;
        4'hD : out_data = 4'h7;
        4'hE : out_data = 4'h1;
        4'hF : out_data = 4'h2;
    endcase

endmodule

module present_pbox(
   input  [63:0] in_data,
   output [63:0] out_data
);

genvar i,k;
generate
    for(i = 0; i < 16; i = i + 1) begin
        for(k = 0; k < 4; k = k + 1) begin
            assign out_data[16*k+i] = in_data[4*i+k];
        end
    end
endgenerate

endmodule



`timescale 1ns/1ps

module PRESENT_ENCRYPT
    #(parameter BLKSIZE = 64, 
      parameter KEYSIZE = 128, 
      parameter ROUNDS = 32) 
      (
        output reg [63:0] out_data, //output data
        input  [63:0] in_data,   // input data
        input  [127:0] key,    // input key
        input         load,   // "load" aka cycle start
        input         clk,     // clock
        output reg    done    // "done" aka cycle end
    );

reg  [127:0] key_reg;               // key register
reg  [63:0] data;               // data register
reg  [$clog2(ROUNDS):0]  round;              // round counter
wire [63:0] dat_rkey,dat_sub,dat_perm;     // intermediate data
wire [127:0] key_rot,key_nxt;        // subkey stage data
wire [63:0] odat_buf;           // Grabs final xor'ed value for output

//---- key scheduler -------//
assign key_rot        = {key_reg[66:0], key_reg[127:67]}; // rotate key
assign key_nxt[61:0] = key_rot[61:0];
assign key_nxt[66:62] = key_rot[66:62] ^ round;  // xor round into key
assign key_nxt[119:67] = key_rot[119:67];

present_sbox u_key_sbox_1( .out_data(key_nxt[123:120]), .in_data(key_rot[123:120]) );
present_sbox u_key_sbox_2( .out_data(key_nxt[127:124]), .in_data(key_rot[127:124]) );

//----- Data stages --------//
assign dat_rkey = data ^ key_reg[127:64];        // add round key
assign odat_buf = dat_rkey;                      // output ciphertext

genvar i;
generate
    for (i=0; i<64; i=i+4) begin: s_boxes
       present_sbox u_sbox( .out_data(dat_sub[i+3:i]), .in_data(dat_rkey[i+3:i]) );
    end
endgenerate

present_pbox u_pbox( .out_data(dat_perm), .in_data(dat_sub) );

// Data sequential
always @(posedge clk)
begin
   if (load)
      data <= in_data;
   else
      data <= dat_perm;
end

// Key sequential
always @(posedge clk)
begin
   if (load)
      key_reg <= key;
   else
      key_reg <= key_nxt;
end

// Round counter & done logic
always @(posedge clk)
begin
   if (load) begin
      round <= 1;
      done <= 1'b0;
      out_data <= 0;
   end
   else begin
      if(round == ROUNDS) begin
        out_data <= odat_buf;
        done <= 1'b1;
      end
      else begin
          out_data <= out_data;
          done <= done;
      end
      if(round <= ROUNDS) begin
        round <= round + 1;
      end
  end
end

endmodule