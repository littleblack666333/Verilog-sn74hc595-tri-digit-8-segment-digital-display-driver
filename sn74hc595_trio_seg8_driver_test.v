`timescale 1ns/1ns

module sn74hc595_trio_seg8_driver_test;

    reg clk;
    reg rst_n;
    reg trigger;
    reg [3:0] num0;
    reg [3:0] num1;
    reg [3:0] num2;
    wire clk_serial;
    wire data;
    wire load;

    initial begin
        clk = 1'b0;
        rst_n = 1'b1;
        trigger = 1'b0;
        num0 = 4'd3;
        num1 = 4'd4;
        num2 = 4'd5;
        #1 rst_n = 0;
        #1 rst_n = 1;
        #1 trigger = 1;
        #100 trigger = 0;
    end

    always
        #10 clk = ~clk;

    sn74hc595_trio_seg8_driver u_test(
        .clk(clk),
        .rst_n(rst_n),
        .trigger(trigger),
        .num0(num0),
        .num1(num1),
        .num2(num2),
        .clk_serial(clk_serial),
        .data(data),
        .load(load)
    );

endmodule