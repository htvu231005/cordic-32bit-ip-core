`timescale 1ns / 1ps

module tb_cordic_32bit_system();
    parameter WIDTH = 32;
    reg clk;
    reg reset;
    reg enable;
    reg valid_i;
    reg mode_i;
    reg  signed [WIDTH-1:0] x_i;
    reg  signed [WIDTH-1:0] y_i;
    reg  signed [WIDTH-1:0] z_i;

    wire valid_o;
    wire signed [WIDTH-1:0] x_o;
    wire signed [WIDTH-1:0] y_o;
    wire signed [WIDTH-1:0] z_o;

    cordic_system uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .valid_i(valid_i),
        .mode_i(mode_i),
        .x_i(x_i),
        .y_i(y_i),
        .z_i(z_i),
        .valid_o(valid_o),
        .x_o(x_o),
        .y_o(y_o),
        .z_o(z_o)
    );

    always #5 clk = ~clk;
    
    //task input
    task send_input(
        input mode,
        input signed [WIDTH-1:0] x,
        input signed [WIDTH-1:0] y,
        input signed [WIDTH-1:0] z
    );
        begin
            @(negedge clk); 
            valid_i <= 1'b1;
            mode_i <= mode;
            x_i <= x;
            y_i <= y;
            z_i <= z;
            
            @(negedge clk);
            valid_i <= 1'b0;
        end
    endtask

    initial begin
        clk     = 0;
        reset   = 1;
        enable  = 0;
        valid_i = 0;
        mode_i  = 0;
        x_i     = 0;
        y_i     = 0;
        z_i     = 0;

        #20;
        reset  = 0;
        enable = 1;
        repeat(3) @(negedge clk);

        // Test case 1: ROTATION 60 DO (X = 1.0, Y = 0, Z = 60 do)
        send_input(1'b1, 32'd536870912, 32'd0, 32'd715827882);
        repeat(5) @(negedge clk);

        // Test case 2: VECTORING GOC PHAN TU 1 (X = 1.0, Y = 1.0, Z = 0)
        send_input(1'b0, 32'd536870912, 32'd536870912, 32'd0);
        repeat(5) @(negedge clk);

        // Test case 3: ROTATION 150 DO - GOC PHAN TU 2 (X = 1.0, Y = 0, Z = 150 do)
        send_input(1'b1, 32'd536870912, 32'd0, 32'd1789569706);
        repeat(5) @(negedge clk);

        // Test case 4: VECTORING GOC PHAN TU 2 (X = -1.0, Y = 1.0, Z = 0)
        send_input(1'b0, -32'sd536870912, 32'd536870912, 32'd0);

    end

    integer case_num = 1;

    always @(negedge clk) begin
        if (valid_o == 1'b1) begin
            
            if (case_num == 1 || case_num == 3) begin
                $display("\n[THOI DIEM: %0t] -> KET QUA TEST CASE %0d:", $time, case_num);
                $display("CHE DO: ROTATION");
                $display("X_out (Cos) = %11d", $signed(x_o));
                $display("Y_out (Sin) = %11d", $signed(y_o));
            end else if (case_num == 2) begin
                $display("\n[THOI DIEM: %0t] -> KET QUA TEST CASE %0d:", $time, case_num);
                $display("CHE DO: VECTORING");
                $display("X_out (Do lon) = %11d", $signed(x_o));
                $display("Z_out (Goc)    = %11d", $signed(z_o));
            end else begin
                #15;
                $display("\n[THOI DIEM: %0t] -> KET QUA TEST CASE %0d:", $time, case_num);
                $display("CHE DO: VECTORING");
                $display("X_out (Do lon) = %11d", $signed(x_o));
                $display("Z_out (Goc)    = %11d", $signed(z_o));
            end
            
            case_num = case_num + 1;
            
            if (case_num > 4) begin
                #50;
                $finish;
            end
        end
    end

endmodule