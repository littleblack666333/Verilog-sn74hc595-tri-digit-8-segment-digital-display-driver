module sn74hc595_trio_seg8_driver(
    clk,
    rst_n,
    trigger,
    num0,
    num1,
    num2,
    clk_serial,
    data,
    load
);

    input clk;  // system clock
    input rst_n;  // system reset, active low
    input trigger;  // trigger signal, posedge-effective
    input [3:0] num0;  // 8421-BCD code of the first number
    input [3:0] num1;  // 8421-BCD code of the second number
    input [3:0] num2;  // 8421-BCD code of the third number
    output clk_serial;  // output clock
    output data;  // serial data output
    output load;  // load signal, at its posedge the numbers of LEDs will be refreshed

    // user-defined parameter
    parameter STEP_LENGTH = 8'd250;  // for 50MHz clk, the freq of clk_serial is 100KHz
    parameter PIONT_POS = 2'd2;  // position of decimal point, after the number of corresponding index, if 0, discard

    // character code
    localparam CHAR_0 = 8'b1100_0000;
    localparam CHAR_1 = 8'b1111_1001;
    localparam CHAR_2 = 8'b1010_0100;
    localparam CHAR_3 = 8'b1011_0000;
    localparam CHAR_4 = 8'b1001_1001;
    localparam CHAR_5 = 8'b1001_0010;
    localparam CHAR_6 = 8'b1000_0000;
    localparam CHAR_7 = 8'b1111_1000;
    localparam CHAR_8 = 8'b1000_0000;
    localparam CHAR_9 = 8'b1001_0000;
    localparam CHAR_POINT = 8'b0111_1111;  // decimal point
    localparam CHAR_ON = 8'b1111_1111;  // turn on all LEDs
    localparam CHAR_OFF = 8'b0000_0000;  // turn off all LEDs

    wire clk;
    wire rst_n;
    wire trigger;
    wire [3:0] num0;
    wire [3:0] num1;
    wire [3:0] num2;
    reg clk_serial;
    reg load;
    reg data;

    reg [7:0] dec_temp [2:0];  // temporary varible of dec
    reg [7:0] dec [2:0];  // decoded number character code
    reg trigger_d0;
    reg trigger_d1;
    reg [7:0] buff [2:0];  // buffer
    reg [13:0] cnt;

    // deocder of 8421-BCD
    always @(num0, num1, num2) begin
        // direct decoding
        case (num0)
            4'd1: dec_temp[0] = CHAR_1;
            4'd2: dec_temp[0] = CHAR_2;
            4'd3: dec_temp[0] = CHAR_3;
            4'd4: dec_temp[0] = CHAR_4;
            4'd5: dec_temp[0] = CHAR_5;
            4'd6: dec_temp[0] = CHAR_6;
            4'd7: dec_temp[0] = CHAR_7;
            4'd8: dec_temp[0] = CHAR_8;
            4'd9: dec_temp[0] = CHAR_9;
            default: dec_temp[0] = CHAR_0;
        endcase
        case (num1)
            4'd1: dec_temp[0] = CHAR_1;
            4'd2: dec_temp[1] = CHAR_2;
            4'd3: dec_temp[1] = CHAR_3;
            4'd4: dec_temp[1] = CHAR_4;
            4'd5: dec_temp[1] = CHAR_5;
            4'd6: dec_temp[1] = CHAR_6;
            4'd7: dec_temp[1] = CHAR_7;
            4'd8: dec_temp[1] = CHAR_8;
            4'd9: dec_temp[1] = CHAR_9;
            default: dec_temp[1] = CHAR_0;
        endcase
        case (num2)
            4'd1: dec_temp[2] = CHAR_1;
            4'd2: dec_temp[2] = CHAR_2;
            4'd3: dec_temp[2] = CHAR_3;
            4'd4: dec_temp[2] = CHAR_4;
            4'd5: dec_temp[2] = CHAR_5;
            4'd6: dec_temp[2] = CHAR_6;
            4'd7: dec_temp[2] = CHAR_7;
            4'd8: dec_temp[2] = CHAR_8;
            4'd9: dec_temp[2] = CHAR_9;
            default: dec_temp[2] = CHAR_0;
        endcase
        // concatenate info of decimal point
        case (PIONT_POS)
            2'd1: begin
                dec[0] <= dec_temp[0] & CHAR_POINT;
                dec[1] <= dec_temp[1];
                dec[2] <= dec_temp[2];
            end
            2'd2: begin
                dec[0] <= dec_temp[0];
                dec[1] <= dec_temp[1] & CHAR_POINT;
                dec[2] <= dec_temp[2];
            end
            2'd3: begin
                dec[0] <= dec_temp[0];
                dec[1] <= dec_temp[1];
                dec[2] <= dec_temp[2] & CHAR_POINT;
            end
            default: begin
                dec[0] <= dec_temp[0];
                dec[1] <= dec_temp[1];
                dec[2] <= dec_temp[2];
            end
        endcase
    end

    // sampling of trigger
    always @(negedge rst_n or posedge clk) begin
        if (~rst_n) begin
            trigger_d0 <= 1'b0;
            trigger_d1 <= 1'b0;
        end
        else begin
            trigger_d0 <= trigger;
            trigger_d1 <= trigger_d0;
        end
    end

    // transfer number character code into buffer
    always @(negedge rst_n or posedge clk) begin
        if (~rst_n) begin
            buff[0] <= 8'b0;
            buff[1] <= 8'b0;
            buff[2] <= 8'b0;
        end
        else if (trigger_d0 & (~trigger_d1)) begin
            buff[0] <= dec[0];
            buff[1] <= dec[1];
            buff[2] <= dec[2];
        end
        else begin
            buff[0] <= buff[0];
            buff[1] <= buff[1];
            buff[2] <= buff[2];
        end
    end

    // def of internal main counter
    always @(negedge rst_n or posedge clk) begin
        if (~rst_n)
            cnt <= 14'b0;
        else if (trigger_d0 & (~trigger_d1))
            cnt <= 14'b0;
        else begin
            if (cnt < STEP_LENGTH * 48)
                cnt <= cnt + 1;
            else
                cnt <= cnt;
        end
    end

    // def of clk_serial
    always @(negedge rst_n or posedge clk) begin
        if (~rst_n)
            clk_serial <= 1'b0;
        else begin
            case (cnt)
                14'b0: clk_serial <= 1'b0;
                STEP_LENGTH * 1 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 2 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 3 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 4 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 5 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 6 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 7 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 8 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 9 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 10 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 11 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 12 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 13 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 14 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 15 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 16 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 17 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 18 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 19 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 20 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 21 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 22 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 23 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 24 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 25 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 26 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 27 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 28 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 29 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 30 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 31 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 32 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 33 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 34 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 35 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 36 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 37 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 38 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 39 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 40 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 41 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 42 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 43 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 44 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 45 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 46 - 1: clk_serial <= 1'b0;
                STEP_LENGTH * 47 - 1: clk_serial <= 1'b1;
                STEP_LENGTH * 48 - 1: clk_serial <= 1'b0;
                default: clk_serial <= clk_serial;
            endcase
        end
    end

    // def of data
    always @(negedge rst_n or posedge clk) begin
        if (~rst_n)
            data <= 1'b0;
        else begin
            case (cnt)
                // 3rd number
                14'b0: data <= buff[2][7];
                STEP_LENGTH * 2 - 1: data <= buff[2][6];
                STEP_LENGTH * 4 - 1: data <= buff[2][5];
                STEP_LENGTH * 6 - 1: data <= buff[2][4];
                STEP_LENGTH * 8 - 1: data <= buff[2][3];
                STEP_LENGTH * 10 - 1: data <= buff[2][2];
                STEP_LENGTH * 12 - 1: data <= buff[2][1];
                STEP_LENGTH * 14 - 1: data <= buff[2][0];
                // 2nd number
                STEP_LENGTH * 16 - 1: data <= buff[1][7];
                STEP_LENGTH * 18 - 1: data <= buff[1][6];
                STEP_LENGTH * 20 - 1: data <= buff[1][5];
                STEP_LENGTH * 22 - 1: data <= buff[1][4];
                STEP_LENGTH * 24 - 1: data <= buff[1][3];
                STEP_LENGTH * 26 - 1: data <= buff[1][2];
                STEP_LENGTH * 28 - 1: data <= buff[1][1];
                STEP_LENGTH * 30 - 1: data <= buff[1][0];
                // 1st number
                STEP_LENGTH * 32 - 1: data <= buff[0][7];
                STEP_LENGTH * 34 - 1: data <= buff[0][6];
                STEP_LENGTH * 36 - 1: data <= buff[0][5];
                STEP_LENGTH * 38 - 1: data <= buff[0][4];
                STEP_LENGTH * 40 - 1: data <= buff[0][3];
                STEP_LENGTH * 42 - 1: data <= buff[0][2];
                STEP_LENGTH * 44 - 1: data <= buff[0][1];
                STEP_LENGTH * 46 - 1: data <= buff[0][0];
                // hold
                default: data <= data;
            endcase
        end
    end

    // def of load
    always @(negedge rst_n or posedge clk) begin
        if (~rst_n)
            load <= 1'b0;
        else if (cnt == STEP_LENGTH * 48 - 1)
            load <= 1'b1;
        else
            load <= 1'b0;
    end

endmodule