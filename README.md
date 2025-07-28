# 🔁 Reconfigurable Systolic Array for Matrix Multiplication

This project implements a **reconfigurable systolic array** in Verilog capable of performing:

- Four parallel 4×4 matrix multiplications  
- Single 8×8 matrix multiplication  

It is designed for accelerating **CNN/DNN operations**, with modularity and scalability toward larger arrays (e.g., 16×16, 32×32).

---

## 📌 Features

- ✅ **Dual-mode operation**: 4×4×4 parallel mode and 8×8 full array mode  
- ✅ **Output-stationary dataflow** for efficient MAC accumulation  
- ✅ **Internal cache & scratchpad memory** to reduce data wait cycles  
- ✅ **Instruction-based control interface** to switch between modes and load data  
- ✅ **Sub-block targeting** via internal counters and custom instruction fields  
- ✅ **Scalable design** tested up to 32×32 configurations  
- ✅ **Testbench-ready** with instruction simulation and waveform verification

---

## 🧠 Architecture Overview

The 8×8 array is divided into four 4×4 subarrays, each with:

- Local caches: `3×4×4×8` structure (Inputs, Weights, Outputs)
- Shared scratchpad memory
- Data pipeline for output-stationary flow
- Internal PE control with multiply, accumulate, and activation support

---

## 🔧 Verilog Modules

- `top_level_array.v` – Top module for 8×8 systolic array
- `pe.v` – Processing Element with MAC logic
- `array_controller.v` – Control logic for instruction decoding and mode switching
- `cache_mem.v` – Local cache handling inputs/weights
- `instruction_decoder.v` – Fixed-format instruction parser
- `testbench.v` – Simulation and mode verification testbench
- `config_pkg.vh` – Parameter definitions for scalability (4x4, 8x8, etc.)

---

## 🛠️ How It Works

1. **Instruction Format** (example: 32-bit)
    - Mode bit (4x4 / 8x8)
    - Sub-block selector
    - Data location (cache or scratchpad)
    - Matrix indices (row/col)
    - Operation trigger

2. **Modes**
    - `Mode = 0` → Four independent 4×4 matrix multiplications  
    - `Mode = 1` → One full 8×8 operation with inter-block data flow

3. **Control**
    - A RISC-V or custom coprocessor feeds instructions
    - Counters track sub-blocks for data routing
    - PEs operate in 2D pipelined wavefront

---

## 🚀 Simulation & Testing

- Simulated using **ModelSim/VCS**  
- Waveforms verified for both modes  
- Memory init files used to load input and weight matrices  
- Final result stored in local output buffer

---

## 🧩 Future Work

- [ ] Integrate AXI4-Lite for processor memory access  
- [ ] Add pooling layer support  
- [ ] Extend to 16×16 and 32×32 with tiling  
- [ ] Interface with real CNN layers via GEMM preprocessor  
- [ ] FPGA Deployment (Zynq or Artix-7)

---

## 📁 Directory Structure


