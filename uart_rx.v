
module uart_rx (
    input wire clk,
    input wire rst,
    input wire rx,           // The physical wire (Serial Input)
    input wire s_tick,       // 16x Sampling Tick
    output reg rx_done_tick, // Pulse when a byte is received
    output reg [7:0] rx_data_out // The received byte
);

    localparam [1:0] 
        idle  = 2'b00,
        start = 2'b01,
        data  = 2'b10,
        stop  = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next; // Tick counter
    reg [2:0] n_reg, n_next; // Bit counter
    reg [7:0] b_reg, b_next; // Data storage

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= idle;
            s_reg <= 0; n_reg <= 0; b_reg <= 0;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end

    always @* begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done_tick = 1'b0;

        case (state_reg)
            idle: begin
                if (~rx) begin // Detect falling edge (Start Bit)
                    state_next = start;
                    s_next = 0;
                end
            end
            start: begin
                if (s_tick) begin
                    if (s_reg == 7) begin // Wait half a bit (middle of start bit)
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                    end else
                        s_next = s_reg + 1;
                end
            end
            data: begin
                if (s_tick) begin
                    if (s_reg == 15) begin // Sample in the middle of the bit
                        s_next = 0;
                        b_next = {rx, b_reg[7:1]}; // Shift in bit
                        if (n_reg == 7)
                            state_next = stop;
                        else
                            n_next = n_reg + 1;
                    end else
                        s_next = s_reg + 1;
                end
            end
            stop: begin
                if (s_tick) begin
                    if (s_reg == 15) begin
                        state_next = idle;
                        rx_done_tick = 1'b1; // Byte received!
                    end else
                        s_next = s_reg + 1;
                end
            end
        endcase
    end
    
    assign rx_data_out = b_reg;
endmodule