# DSP48A1 Project – Spartan-6 FPGA Implementation

This project implements and verifies the functionality of the DSP48A1 slice in Spartan-6 FPGAs, targeting mathematical-intensive operations like pre/post addition/subtraction and multiplication. The design includes RTL modeling, directed testbench, waveform analysis, and full design flow using Vivado and QuestaSim.

## 📁 Project Structure

-   RTL Verilog source code for the DSP48A1 module
-   Verilog testbench and QuestaSim `.do` script
-   Simulation output including waveforms and logs
-   XDC file with a 100 MHz clock constraint on pin W5
-   Synthesis, implementation, and linting reports
-   Synthesized schematic, implemented design views, and waveforms
-   PDF document describing the design and stimulus scenarios

## ✅ Features

- Pre-adder, multiplier, and post-adder/subtractor logic
- Full register/control signal support
- Directed stimulus with expected outputs for self-checking
- Full Vivado flow (elaboration → synthesis → implementation)
- QuestaSim simulation with `.do` file automation
- Linting validation with no critical warnings

## 🛠️ Tools Used

- Vivado (for synthesis/implementation)
- QuestaSim (for simulation and waveform analysis)
- Verilog HDL
- Spartan-6 FPGA (xc7a200tffg1156-3)

## 🚀 How to Run

### Simulation
```bash
# In QuestaSim:
vsim -do DSP48A1.do
