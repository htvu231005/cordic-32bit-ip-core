module cordic_postprocessor #(
    parameter WIDTH = 32,
    parameter signed [WIDTH-1:0] ANGLE_180 = -32'sd2147483648  
)(
    input wire clk, 
    input wire reset, 
    input wire enable,
    
    input wire valid_i, 
    input wire mode_i, 
    input wire invert_i,
    input wire signed [WIDTH-1:0] x_i, 
    input wire signed [WIDTH-1:0] y_i, 
    input wire signed [WIDTH-1:0] z_i,

    output reg valid_o, 
    output reg signed [WIDTH-1:0] x_o, 
    output reg signed [WIDTH-1:0] y_o, 
    output reg signed [WIDTH-1:0] z_o
);

    reg signed [WIDTH-1:0] x_part1, x_part2;
    reg signed [WIDTH-1:0] y_part1, y_part2;
    reg signed [WIDTH-1:0] z_pipe1;
    reg valid_pipe1, mode_pipe1, invert_pipe1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_part1 <= {WIDTH{1'b0}}; x_part2 <= {WIDTH{1'b0}};
            y_part1 <= {WIDTH{1'b0}}; y_part2 <= {WIDTH{1'b0}};
            z_pipe1 <= {WIDTH{1'b0}};
            valid_pipe1 <= 1'b0; mode_pipe1 <= 1'b0; invert_pipe1 <= 1'b0;
        end else if (enable) begin //chia ra lam 2 chuoi
            x_part1 <= (x_i >>> 1) + (x_i >>> 3) - (x_i >>> 6) - (x_i >>> 9);
            y_part1 <= (y_i >>> 1) + (y_i >>> 3) - (y_i >>> 6) - (y_i >>> 9);
            
            x_part2 <= (x_i >>> 13) + (x_i >>> 15) + (x_i >>> 16);
            y_part2 <= (y_i >>> 13) + (y_i >>> 15) + (y_i >>> 16);

            z_pipe1 <= z_i;
            valid_pipe1 <= valid_i;
            mode_pipe1 <= mode_i;
            invert_pipe1 <= invert_i;
        end
    end

    reg signed [WIDTH-1:0] x_scaled_reg, y_scaled_reg;
    reg signed [WIDTH-1:0] z_pipe2;
    reg valid_pipe2, mode_pipe2, invert_pipe2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_scaled_reg <= {WIDTH{1'b0}};
            y_scaled_reg <= {WIDTH{1'b0}};
            z_pipe2 <= {WIDTH{1'b0}};
            valid_pipe2 <= 1'b0; mode_pipe2 <= 1'b0; invert_pipe2 <= 1'b0;
        end else if (enable) begin //tru 2 chuoi lai
            x_scaled_reg <= x_part1 - x_part2;
            y_scaled_reg <= y_part1 - y_part2;

            z_pipe2 <= z_pipe1;
            valid_pipe2 <= valid_pipe1;
            mode_pipe2 <= mode_pipe1;
            invert_pipe2 <= invert_pipe1;
        end
    end

    reg signed [WIDTH-1:0] x_final_d, y_final_d, z_final_d;

    always @(*) begin
        if (mode_pipe2 == 1'b0) begin //mode Vectoring
            x_final_d = x_scaled_reg;
            y_final_d = {WIDTH{1'b0}};
            
            if (invert_pipe2) begin
                if (z_pipe2 < 0) 
                    z_final_d = z_pipe2 + ANGLE_180;
                else 
                    z_final_d = z_pipe2 - ANGLE_180;
            end else begin
                z_final_d = z_pipe2;
            end

        end else begin //mode Rotation
            z_final_d = z_pipe2;
            
            if (invert_pipe2) begin
                x_final_d = -x_scaled_reg;
                y_final_d = -y_scaled_reg;
            end else begin
                x_final_d = x_scaled_reg;
                y_final_d = y_scaled_reg;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_o <= 1'b0;
            x_o     <= {WIDTH{1'b0}};
            y_o     <= {WIDTH{1'b0}};
            z_o     <= {WIDTH{1'b0}};
        end else if (enable) begin
            valid_o <= valid_pipe2;
            x_o     <= x_final_d;
            y_o     <= y_final_d;
            z_o     <= z_final_d;
        end
    end

endmodule