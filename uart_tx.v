module uart_tx (
    input wire clk,
    input wire rst,
    input wire s_tick,       // 16x Sampling Tick from generator
    input wire tx_start,     // Signal to start transmission
    input wire [7:0] tx_data_in, // Byte to transmit
    output reg tx_done_tick, // Pulse when transmission is done
    output reg tx            // The physical wire (Serial Output)
);

    // State definitions
    localparam [1:0] 
        idle  = 2'b00,
        start = 2'b01,
        data  = 2'b10,
        stop  = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next; // Counter for 16 ticks (1 bit period)
    reg [2:0] n_reg, n_next; // Counter for 8 data bits
    reg [7:0] b_reg, b_next; // Register to hold data
    reg tx_reg, tx_next;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= idle;
            s_reg <= 0; n_reg <= 0; b_reg <= 0; tx_reg <= 1'b1;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end

    // Next-state logic and datapath
    always @* begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;
        tx_done_tick = 1'b0;

        case (state_reg)
            idle: begin
                tx_next = 1'b1; // Idle line is High
                if (tx_start) begin
                    state_next = start;
                    s_next = 0;
                    b_next = tx_data_in;
                end
            end
            start: begin
                tx_next = 1'b0; // Start bit is Low
                if (s_tick) begin
                    if (s_reg == 15) begin // Wait 16 ticks (1 bit period)
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                    end else
                        s_next = s_reg + 1;
                end
            end
            data: begin
                tx_next = b_reg[0]; // Send LSB first
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1; // Shift data
                        if (n_reg == 7)
                            state_next = stop;
                        else
                            n_next = n_reg + 1;
                    end else
                        s_next = s_reg + 1;
                end
            end
            stop: begin
                tx_next = 1'b1; // Stop bit is High
                if (s_tick) begin
                    if (s_reg == 15) begin
                        state_next = idle;
                        tx_done_tick = 1'b1;
                    end else
                        s_next = s_reg + 1;
                end
            end
        endcase
    end
    
    assign tx = tx_reg;
endmodule
