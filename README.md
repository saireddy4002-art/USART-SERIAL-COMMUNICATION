# Verilog USART Controller

A high-performance, synthesizable **USART (Universal Synchronous/Asynchronous Receiver Transmitter)** core written in Verilog HDL. This design provides a reliable serial interface for FPGAs to communicate with PCs, sensors, or other microcontrollers.



## 📌 Overview
This repository contains a full-duplex UART implementation. The design focuses on high timing closure reliability by using a **16x oversampling** technique on the receiver side to minimize bit-error rates caused by clock drift.

### Key Features
* **Full-Duplex:** Independent Transmitter (TX) and Receiver (RX) paths.
* **16x Oversampling:** Robust data recovery by sampling the middle of the bit period.
* **Configurable Parameters:** Easily change Clock Frequency and Baud Rate via Verilog `parameters`.
* **Status Flags:** Includes `tx_ready`, `rx_done`, and `buffer_full` signals for easy interfacing with external logic.

---

## 🛠 Hardware Architecture

The system is divided into three primary modules:

1.  **Baud Rate Generator:** A programmable counter that generates a tick pulse at $16 \times$ the target baud rate.
2.  **UART Receiver (RX):** Detects the start bit (falling edge) and uses a counter to sample data bits at the 8th tick of the 16-tick oversampling window.
3.  **UART Transmitter (TX):** A shift-register-based FSM that prepends a start bit and appends a stop bit to the input data byte.



---

## 📂 File Structure

```text
├── rtl/
│   ├── uart_top.v       # Top-level module (IO routing)
│   ├── uart_tx.v        # Transmitter FSM
│   ├── uart_rx.v        # Receiver FSM (Oversampling logic)
│   └── baud_gen.v       # Clock divider/Tick generator
├── bench/
│   └── uart_tb.v        # Full-duplex testbench
├── docs/                # Waveforms and diagrams
└── README.md# USART-SERIAL-COMMUNICATION
