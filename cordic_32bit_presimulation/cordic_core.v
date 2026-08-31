
module cordic_core #(parameter WIDTH = 32, parameter STAGES = 20)
		(input clk, input reset, input enable, input valid_i, input mode_i, input invert_i,
		input signed [WIDTH-1:0] x_i,
  		input signed [WIDTH-1:0] y_i,
  		input signed [WIDTH-1:0] z_i,
		output valid_o, output invert_o,output mode_o,
  		output signed [WIDTH-1:0] x_o,
  		output signed [WIDTH-1:0] y_o,
  		output signed [WIDTH-1:0] z_o);

wire [STAGES-1:0] mode_bus;
//Controller
controller #(.STAGES(STAGES)) 
	ctrl_inst ( .clk(clk), .reset(reset), .enable(enable), .valid_i(valid_i), .invert_i(invert_i), .valid_o(valid_o), .mode_i(mode_i), .invert_o(invert_o), .mode_bus(mode_bus), .mode_o(mode_o));

//Datapath_top
datapath_top #(.WIDTH(WIDTH), .STAGES(STAGES)) datapath_inst ( .clk(clk), .reset(reset), .enable(enable), .mode_bus(mode_bus), 
	.x_i(x_i),
  .y_i(y_i),
  .z_i(z_i),
  .x_o(x_o),
  .y_o(y_o),
  .z_o(z_o));

endmodule