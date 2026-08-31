module controller #(
    parameter WIDTH = 32, 
    parameter STAGES = 20
)(
    input clk, 
    input reset, 
    input valid_i, 
    input enable,
    input mode_i, 
    input invert_i,

    output valid_o,
    output [STAGES-1:0] mode_bus,
    output invert_o,
    output mode_o
);

    reg [STAGES-1:0] valid_pipe;
    reg [STAGES-1:0] invert_pipe;
    reg [STAGES-1:0] mode_pipe;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_pipe <= {STAGES{1'b0}};
            invert_pipe <= {STAGES{1'b0}};
            mode_pipe <= {STAGES{1'b0}};
        end else if (enable) begin
            valid_pipe[STAGES-1:1] <= valid_pipe[STAGES-2:0];
            valid_pipe[0] <= valid_i;

            invert_pipe[STAGES-1:1] <= invert_pipe[STAGES-2:0];
            invert_pipe[0] <= invert_i;

            mode_pipe[STAGES-1:1] <= mode_pipe[STAGES-2:0];
            mode_pipe[0] <= mode_i;
        end
    end 

    assign valid_o = valid_pipe[STAGES-1];
    assign invert_o = invert_pipe[STAGES-1];
    assign mode_bus = {mode_pipe[STAGES-2:0], mode_i};
    assign mode_o = mode_pipe[STAGES-1];

endmodule
