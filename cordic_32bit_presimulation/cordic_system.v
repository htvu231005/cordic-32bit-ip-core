module cordic_system #(
    parameter WIDTH  = 32,
    parameter STAGES = 20
)(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire valid_i,
    input wire mode_i,
    input wire signed [WIDTH-1:0] x_i,
    input wire signed [WIDTH-1:0] y_i,
    input wire signed [WIDTH-1:0] z_i,
    
    output wire valid_o,
    output wire signed [WIDTH-1:0] x_o,
    output wire signed [WIDTH-1:0] y_o,
    output wire signed [WIDTH-1:0] z_o
);

    wire valid_pre_core, mode_pre_core, invert_pre_core;
    wire signed [WIDTH-1:0] x_pre_core, y_pre_core, z_pre_core;

    cordic_preprocessor #(.WIDTH(WIDTH)) pre_inst (
        .clk(clk), .reset(reset), .enable(enable),
        .valid_i(valid_i), .mode_i(mode_i),
        .x_i(x_i), .y_i(y_i), .z_i(z_i),
        
        .valid_o(valid_pre_core), 
        .mode_o(mode_pre_core), 
        .invert_flag_o(invert_pre_core),
        .x_o(x_pre_core), .y_o(y_pre_core), .z_o(z_pre_core)
    );

    wire valid_core_post, mode_core_post, invert_core_post;
    wire signed [WIDTH-1:0] x_core_post, y_core_post, z_core_post;

    cordic_core #(.WIDTH(WIDTH), .STAGES(STAGES)) core_inst (
        .clk(clk), .reset(reset), .enable(enable),
        .valid_i(valid_pre_core), 
        .mode_i(mode_pre_core), 
        .invert_i(invert_pre_core),
        .x_i(x_pre_core), .y_i(y_pre_core), .z_i(z_pre_core),
        
        .valid_o(valid_core_post), 
        .invert_o(invert_core_post), 
        .mode_o(mode_core_post),
        .x_o(x_core_post), .y_o(y_core_post), .z_o(z_core_post)
    );

    cordic_postprocessor #(.WIDTH(WIDTH)) post_inst (
        .clk(clk), .reset(reset), .enable(enable),
        .valid_i(valid_core_post), 
        .mode_i(mode_core_post), 
        .invert_i(invert_core_post),
        .x_i(x_core_post), .y_i(y_core_post), .z_i(z_core_post),
        
        .valid_o(valid_o),
        .x_o(x_o), .y_o(y_o), .z_o(z_o)
    );

endmodule