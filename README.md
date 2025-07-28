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
- Internal PE control with multiply, accumulate support

---

## 🔧 Verilog Modules

- `Coprocessor.v` – Top module for 8×8 systolic array
- `PE.v` – Processing Element with MAC logic
- `reconfigurable_scheduler.v` – Control logic for instruction decoding and mode switching
- `sa_shift_register.v` – Local memory handling inputs/weights
- `ctrl_unit_main.v` – Fixed-format instruction parser
- `SA_tb.v` – Simulation and mode verification testbench

---

## 🛠️ How It Works

1. **Instruction Format** (example: 32-bit)
    - Mode bit (4x4 / 8x8)
    - Sub-block selector
    - Data location (cache or scratchpad)
    - Store and Load data
    - Reset sub block

2. **Modes**
    - `Mode = 0` → Four independent 4×4 matrix multiplications by selecting sub blocks 
    - `Mode = 1` → One full 8×8 operation with inter-block data flow

3. **Control**
    - A RISC-V or custom coprocessor feeds instructions
    - Counters track sub-blocks for data routing
    - PEs operate in 2D pipelined wavefront

---

## 🚀 Simulation & Testing
 
- Waveforms verified for both modes  
- Memory init files used to load input and weight matrices  
- Final result stored in scratchpad memory

---

## 🧩 Future Work

- [ ] Integrate AXI4-Lite for processor memory access  
- [ ] Add pooling layer support (average/max pooling)  
- [ ] Implement custom RISC-V instruction format for control  
- [ ] Extend to 16×16 and 32×32 arrays with tiling support  
- [ ] Interface with real CNN workloads via GEMM mapper  
- [ ] FPGA Deployment (Zynq or Artix-7 board)

---

## 📁 Directory Structure


