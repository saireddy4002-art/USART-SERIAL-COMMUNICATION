module uart_top (
    input wire clk,           // Board Clock
    input wire btnC,          // Board Button (Reset)
    input wire RsRx,          // USB-UART Receive Pin
    output wire RsTx          // USB-UART Transmit Pin
);

    wire tick;                // Connection between Baud Gen and Tx/Rx
    wire rx_done_tick;        // Pulse when a byte is received
    wire [7:0] data_bus;      // The byte moving from Rx to Tx

    // 1. Baud Rate Generator
    baud_rate_gen baud_gen_unit (
        .clk(clk), .rst(btnC), .tick(tick)
    );

    // 2. Receiver
    uart_rx rx_unit (
        .clk(clk), .rst(btnC), .s_tick(tick), 
        .rx(RsRx), 
        .rx_done_tick(rx_done_tick), // When data is ready...
        .rx_data_out(data_bus)       // ...put it on the bus
    );

    // 3. Transmitter
    uart_tx tx_unit (
        .clk(clk), .rst(btnC), .s_tick(tick), 
        .tx_start(rx_done_tick),     // ...start sending immediately!
        .tx_data_in(data_bus),       // Send the same data back
        .tx_done_tick(),             // Unused
        .tx(RsTx)
    );

endmodule
