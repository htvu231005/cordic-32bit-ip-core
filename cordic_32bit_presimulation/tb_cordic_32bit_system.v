`timescale 1ns / 1ps

module tb_cordic_32bit_system();
    parameter WIDTH = 32;

    reg clk;
    reg reset;
    reg enable;
    reg valid_i;
    reg mode_i;
    reg signed [WIDTH-1:0] x_i;
    reg signed [WIDTH-1:0] y_i;
    reg signed [WIDTH-1:0] z_i;

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

    //Chu ki 10ns
    always #5 clk = ~clk;

    //task nap du lieu
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
        repeat(2) @(negedge clk);


        // mode Rotation: nap X=1.0, Y=0, Z=60 do
        send_input(1'b1, 32'sd536870912, 32'sd0, 32'sd715827882);
        
        //mode Vectoring: nap X=1.0 , Y=1.0, Z=0
        send_input(1'b0, 32'sd536870912, 32'sd536870912, 32'sd0);

        //mode Rotation voi goc 150 do
        send_input(1'b1, 32'sd536870912, 32'sd0, 32'sd1789569706);

        //mode Vectoring am
        send_input(1'b0, -32'sd536870912, 32'sd536870912, 32'sd0);

        @(negedge clk);
        valid_i <= 1'b0; 
        repeat(50) @(posedge clk);
        $stop;
    end

    //in ket qua ra log
    integer case_num = 1;
    always @(posedge clk) begin
        if (valid_o) begin
            $display("[THOI DIEM: %0t] - KET QUA CASE %0d:", $time, case_num);
            if (case_num == 1 || case_num == 3) begin
                $display("   Che do : ROTATION");
                $display("   X_out (Cos) = %11d", x_o);
                $display("   Y_out (Sin) = %11d", y_o);
            end else begin
                $display("   Che do : VECTORING");
                $display("   X_out (Radius) = %11d", x_o);
                $display("   Z_out (Angle)  = %11d", z_o);
            end
            case_num = case_num + 1;
        end
    end

endmodule