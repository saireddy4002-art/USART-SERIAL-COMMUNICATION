`timescale 1ns / 1ps

module uart_tb;

    // Signals
    reg clk, rst;
    reg tx_start;
    reg [7:0] data_in;
    wire tx_line;
    wire [7:0] data_out;
    wire tx_done, rx_done;
    wire tick;

    // Instantiate Baud Rate Generator
    baud_rate_gen #(.DIVISOR(2)) baud_gen ( // Small divisor for faster simulation
        .clk(clk), 
        .rst(rst), 
        .tick(tick)
    );

    // Instantiate Transmitter
    uart_tx transmitter (
        .clk(clk), .rst(rst), .s_tick(tick), 
        .tx_start(tx_start), .tx_data_in(data_in), 
        .tx_done_tick(tx_done), .tx(tx_line)
    );

    // Instantiate Receiver (Loopback: tx_line goes into rx)
    uart_rx receiver (
        .clk(clk), .rst(rst), .s_tick(tick), 
        .rx(tx_line), .rx_done_tick(rx_done), 
        .rx_data_out(data_out)
    );

    // Clock Generation (50MHz -> Period 20ns)
    always #10 clk = ~clk;

    // Test Sequence
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        tx_start = 0;
        data_in = 0;

        // Reset
        #100;
        rst = 0;

        // Send 'A' (Binary 01000001, Hex 0x41)
        #100;
        data_in = 8'h41; 
        tx_start = 1;
        #20 tx_start = 0; // Pulse start signal

        // Wait for Tx to finish
        @(posedge tx_done);
        
        // Wait for Rx to finish
        @(posedge rx_done);
        
        // Check result
        if (data_out == 8'h41)
            $display("SUCCESS: Sent 0x41, Received 0x%h", data_out);
        else
            $display("FAILURE: Sent 0x41, Received 0x%h", data_out);

        // Send another byte: 'B' (0x42)
        #100;
        data_in = 8'h42;
        tx_start = 1;
        #20 tx_start = 0;
        
        @(posedge rx_done);
        if (data_out == 8'h42)
            $display("SUCCESS: Sent 0x42, Received 0x%h", data_out);
        
        $stop;
    end
endmodule
