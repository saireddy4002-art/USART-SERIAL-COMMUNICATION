# 📡 UART Serial Communication Module (Verilog)

![Language](https://img.shields.io/badge/language-Verilog-blue)
![Tools](https://img.shields.io/badge/tools-ModelSim%20%7C%20Vivado%20%7C%20Quartus-orange)
![Status](https://img.shields.io/badge/status-Verified-brightgreen)

## 📖 Overview
This repository contains a synthesizable **Universal Asynchronous Receiver-Transmitter (UART)** designed in Verilog HDL. The project implements a robust serial communication interface capable of full-duplex data transmission between an FPGA and external devices (PC, Sensors, Microcontrollers).

The design follows a modular approach with a dedicated **Baud Rate Generator**, **Transmitter (Tx)**, and **Receiver (Rx)** with 16x oversampling for noise immunity.

## 🛠️ Features
* **Configurable Baud Rate:** Parameterized clock divider to support standard baud rates (9600, 115200, etc.).
* **Robust Receiver:** Uses **16x oversampling** to detect the center of data bits, ensuring accurate data recovery.
* **Finite State Machine (FSM):** Efficient and clean state machine implementation for both Tx and Rx modules.
* **Simulation Ready:** Includes a self-checking testbench verified in **ModelSim**.

## 📂 File Structure

| File Name | Function |
| :--- | :--- |
| `baud_rate_gen.v` | **Clock Divider:** Generates the "tick" pulse for synchronization. |
| `uart_tx.v` | **Transmitter:** Converts parallel data bytes into serial bitstreams. |
| `uart_rx.v` | **Receiver:** Detects start bits and converts serial streams to parallel bytes. |
| `uart_top.v` | **Top Module:** Implements a "Loopback/Echo" system for hardware testing. |
| `uart_tb.v` | **Testbench:** Simulation file to verify logic (Loopback test). |

---

## 💻 How to Run Simulation (ModelSim)

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YourUsername/verilog-uart-design.git](https://github.com/YourUsername/verilog-uart-design.git)
    ```
2.  Open **ModelSim** and create a new project.
3.  Add all `.v` files to the project.
4.  **Compile All** files.
5.  Start simulation on `work.uart_tb`.
6.  Add `data_in`, `data_out`, and `tx` signals to the **Wave** window.
7.  Run the simulation:
    ```tcl
    run -all
    ```
8.  **Result:** You should see `data_out` matching `data_in` in the waveform.

### 📸 Simulation Result
<img width="932" height="566" alt="image" src="https://github.com/user-attachments/assets/c864953b-d050-4ceb-a95f-04c96371fef7" />
<img width="932" height="566" alt="image" src="https://github.com/user-attachments/assets/eadf61a3-1cde-48ae-8604-8ee79e1daf71" />


---

## ⚙️ Hardware Implementation (FPGA)

To deploy this on a physical board (e.g., Basys 3, Arty A7, DE10-Lite):

### 1. Calculate the Divisor
Before synthesis, update the `DIVISOR` parameter in `baud_rate_gen.v` to match your board's clock.

$$ \text{Divisor} = \frac{\text{System Clock Frequency}}{\text{Baud Rate} \times 16} $$

| Board Clock | Target Baud | Divisor Value |
| :--- | :--- | :--- |
| 50 MHz | 9600 | **325** |
| 100 MHz | 9600 | **651** |

### 2. Pin Constraints
Map the following ports in your `.xdc` (Xilinx) or `.qsf` (Intel) file:
* `clk` → System Clock
* `rst` → Push Button
* `RsRx` → USB-UART RX Pin
* `RsTx` → USB-UART TX Pin

### 3. Verify
Open a Serial Terminal (Tera Term / PuTTY) with **9600 Baud, 8 Data bits, No Parity, 1 Stop bit**. Typing characters on the keyboard should "echo" them back to the screen.

---

## 📝 Future Improvements
* [ ] Implement Parity Bit (Odd/Even) logic.
* [ ] Add FIFO buffers for high-speed buffering.
* [ ] Create an AXI4-Lite wrapper for processor integration.

## 👤 Author
* G SAI ANAND REDDY
* ECE Student | VLSI Enthusiast
