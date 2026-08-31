module datapath_top #(parameter WIDTH = 32, parameter STAGES = 20)
		     (input clk, input reset, input [STAGES-1:0] mode_bus, input enable,
		      input signed [WIDTH - 1 : 0] x_i, 
		      input signed [WIDTH - 1 : 0] y_i,
          input signed [WIDTH - 1 : 0] z_i, 
		      output signed [WIDTH - 1 : 0] x_o, 
		      output signed [WIDTH - 1 : 0] y_o, 
          output signed [WIDTH - 1 : 0] z_o);

wire signed [WIDTH - 1 : 0] x_pipe [0 : STAGES];
wire signed [WIDTH - 1 : 0] y_pipe [0 : STAGES];
wire signed [WIDTH - 1 : 0] z_pipe [0 : STAGES];

assign x_pipe[0] = x_i;
assign y_pipe[0] = y_i;
assign z_pipe[0] = z_i;

assign x_o = x_pipe[STAGES];
assign y_o = y_pipe[STAGES];
assign z_o = z_pipe[STAGES];

function signed [31:0] get_atan;
    input integer index;
    case (index)
        0:  get_atan = 32'sd536870912; // 45.00000 do
        1:  get_atan = 32'sd316933406; // 26.56505 do
        2:  get_atan = 32'sd167458907; // 14.03624 do
        3:  get_atan = 32'sd85004756;  // 7.12502 do
        4:  get_atan = 32'sd42667331;  // 3.57633 do
        5:  get_atan = 32'sd21354465;  // 1.78991 do
        6:  get_atan = 32'sd10682178;  // 0.89517 do
        7:  get_atan = 32'sd5341795;   // 0.44761 do
        8:  get_atan = 32'sd2671073;   // 0.22381 do
        9:  get_atan = 32'sd1335558;   // 0.11191 do
        10: get_atan = 32'sd667782;    // 0.05595 do
        11: get_atan = 32'sd333892;    // 0.02798 do
        12: get_atan = 32'sd166946;    // 0.01399 do
        13: get_atan = 32'sd83473;     // 0.00699 do
        14: get_atan = 32'sd41737;     // 0.00350 do
        15: get_atan = 32'sd20868;     // 0.00175 do
        16: get_atan = 32'sd10434;     // 0.00087 do
        17: get_atan = 32'sd5217;      // 0.00044 do
        18: get_atan = 32'sd2609;      // 0.00022 do
        19: get_atan = 32'sd1304;      // 0.00011 do
        default: get_atan = 32'sd0;
    endcase
endfunction

genvar i;

generate
	for (i = 0; i < STAGES; i = i + 1) begin : gen_datapath
	datapath #( .WIDTH(WIDTH), .SHIFT(i), .VAL_LUT(get_atan(i)))
	u_stage ( .clk(clk), .reset(reset), .enable(enable), .mode_i(mode_bus[i]), .x_i(x_pipe[i]), .y_i(y_pipe[i]), .z_i(z_pipe[i]), 
							     .x_o(x_pipe[i + 1]), .y_o(y_pipe[i + 1]), .z_o(z_pipe[i + 1]));
	end
endgenerate

endmodule
