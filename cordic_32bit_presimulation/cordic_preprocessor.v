module cordic_preprocessor #(
    parameter WIDTH = 32,
    parameter ANGLE_90 = 32'sd1073741824,
    parameter ANGLE_180 = 32'sd2147483647
)(
    input wire clk,
    input wire reset,
    input wire enable,

    input wire valid_i,
    input wire mode_i,

    input wire signed [WIDTH-1:0] x_i,
    input wire signed [WIDTH-1:0] y_i,
    input wire signed [WIDTH-1:0] z_i,

    output reg valid_o,           
    output reg mode_o,            
    output reg invert_flag_o,
    output reg signed [WIDTH-1:0] x_o, 
    output reg signed [WIDTH-1:0] y_o, 
    output reg signed [WIDTH-1:0] z_o
);

    reg signed [WIDTH-1:0] x_d;
    reg signed [WIDTH-1:0] y_d;
    reg signed [WIDTH-1:0] z_d;
    reg invert_flag_d;

    always @(*) begin
        x_d = x_i;
        y_d = y_i;
        z_d = z_i;
        invert_flag_d = 1'b0;

        if (mode_i == 1'b1) begin //Mode Rotation
            if (z_i > ANGLE_90) begin
                z_d = z_i - ANGLE_180;
                invert_flag_d = 1'b1;
            end else if (z_i < -ANGLE_90) begin
                z_d = z_i + ANGLE_180; 
                invert_flag_d = 1'b1;
            end
        end else begin //mode Vectoring
            if (x_i[WIDTH-1] == 1'b1) begin
                x_d = -x_i;
                y_d = -y_i;
                invert_flag_d = 1'b1;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_o <= 1'b0;
            mode_o <= 1'b0;
            invert_flag_o <= 1'b0;
            x_o <= {WIDTH{1'b0}};
            y_o <= {WIDTH{1'b0}};
            z_o <= {WIDTH{1'b0}};
        end else if (enable) begin
            valid_o <= valid_i;
            mode_o <= mode_i;
            invert_flag_o <= invert_flag_d;
            x_o <= x_d;
            y_o <= y_d;
            z_o <= z_d;
        end
    end

endmodule