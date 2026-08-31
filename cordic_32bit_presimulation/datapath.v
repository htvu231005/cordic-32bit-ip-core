module datapath #( parameter WIDTH = 32, parameter SHIFT = 0, parameter signed [WIDTH-1 : 0] VAL_LUT = 0)	
		 ( input clk, input reset, input enable, input mode_i, 
					  input signed [WIDTH - 1 : 0] x_i, 
					  input signed [WIDTH - 1 : 0] y_i, 
					  input signed [WIDTH - 1 : 0] z_i, 	
					  output reg signed [WIDTH - 1 : 0] x_o, 
					  output reg signed [WIDTH - 1 : 0] y_o, 
					  output reg signed [WIDTH - 1 : 0] z_o);

reg signed [WIDTH - 1 : 0] x_new_d, y_new_d, z_new_d;
wire msb_z, msb_y;
assign msb_y = y_i[WIDTH - 1];
assign msb_z = z_i[WIDTH - 1];

always @(*) begin
if(mode_i == 1'b1) begin  // Rotation
	if(msb_z == 0) begin // z >= 0
	x_new_d = x_i - (y_i >>> SHIFT);
	y_new_d = y_i + (x_i >>> SHIFT);
	z_new_d = z_i - VAL_LUT;
	end else begin // z < 0
	x_new_d = x_i + (y_i >>> SHIFT);
	y_new_d = y_i - (x_i >>> SHIFT);
	z_new_d = z_i + VAL_LUT;
	end
	end else begin //Vectoring
	if(msb_y == 1) begin // y < 0
	x_new_d = x_i - (y_i >>> SHIFT);
	y_new_d = y_i + (x_i >>> SHIFT);
	z_new_d = z_i - VAL_LUT;
	end else begin // y >= 0
	x_new_d = x_i + (y_i >>> SHIFT);
	y_new_d = y_i - (x_i >>> SHIFT);
	z_new_d = z_i + VAL_LUT;
	end
end
end

always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_o <= 0;
            y_o <= 0;
            z_o <= 0;
        end else if(enable) begin
            x_o <= x_new_d;
            y_o <= y_new_d;
            z_o <= z_new_d;
        end
    end

endmodule


















































