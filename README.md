# Power and Area Optimized FFT Architecture Through Multiplier-Level Hardware Design

## Overview

This project presents the design and FPGA implementation of a **power- and area-optimized Fast Fourier Transform (FFT) architecture** by improving the hardware efficiency of the multipliers used in butterfly computation. Since multiplication is one of the most resource-intensive operations in FFT processors, different multiplier architectures are implemented and analyzed to determine their impact on FPGA resource utilization, power consumption, and timing performance.

The project is developed using **Verilog** and implemented on the **Basys 3 FPGA (Artix-7 XC7A35T)** using **Xilinx Vivado**.

---

## Project Objective

The main objective of this project is to optimize FFT hardware by replacing conventional multipliers with efficient multiplier architectures and comparing their performance based on:

- FPGA Area (LUTs, Flip-Flops)
- Power Consumption
- Propagation Delay
- Maximum Operating Frequency
- Hardware Complexity

---

## Motivation

FFT is a fundamental building block in modern Digital Signal Processing (DSP) applications such as:

- Wireless Communication
- OFDM Systems
- Image Processing
- Audio Signal Processing
- Radar Systems
- Biomedical Signal Processing

Since multipliers occupy a significant portion of FFT hardware, optimizing multiplier architecture can substantially improve overall FFT efficiency.

---

## Multiplier Architectures Implemented

The project includes the following multiplier designs:

- Array Multiplier
- Vedic Multiplier (Urdhva Tiryagbhyam)
- Wallace Tree Multiplier
- Modified Booth Multiplier

Each architecture is individually designed, simulated, synthesized, and analyzed before integration into the FFT datapath.

---

## Development Tools

| Tool | Version |
|------|---------|
| Xilinx Vivado | 2025.2 |
| Language | Verilog |
| FPGA Board | Basys 3 |
| FPGA Device | Artix-7 XC7A35T |

---

## Project Structure

```
Power_Area_Optimized_FFT/
│
├── Array_Multiplier/
│   ├── Source
│   └── Testbench
│
├── Vedic_Multiplier/
│   ├── Source
│   └── Testbench
│
├── Wallace_Tree_Multiplier/
│   ├── Source
│   └── Testbench
│
├── Modified_Booth_Multiplier/
│   ├── Source
│   └── Testbench
│
├── FFT/
│   ├── Butterfly
│   ├── Twiddle_Factor
│   ├── FFT_Top
│   └── Testbench
│
├── Constraints
│
├── Simulation
│
├── Reports
│   ├── RTL
│   ├── Schematic
│   ├── Timing
│   ├── Utilization
│   └── Power
│
└── README.md
```

---

## Design Flow

```
Algorithm Design
        │
        ▼
Multiplier Architecture Design
        │
        ▼
VHDL Coding
        │
        ▼
Functional Simulation
        │
        ▼
RTL Analysis
        │
        ▼
Synthesis
        │
        ▼
Implementation
        │
        ▼
Timing Analysis
        │
        ▼
Power Analysis
        │
        ▼
FFT Integration
```

---

## Performance Parameters

The following metrics are evaluated for each multiplier architecture:

- Logic Utilization (LUTs)
- Flip-Flop Count
- Critical Path Delay
- Maximum Frequency (Fmax)
- Dynamic Power
- Static Power
- Total On-Chip Power

---

## Expected Outcomes

- Reduced FPGA resource utilization
- Lower power consumption
- Higher operating frequency
- Improved FFT hardware efficiency
- Scalable architecture for larger FFT implementations

---

## Applications

- Digital Signal Processing (DSP)
- Software Defined Radio (SDR)
- OFDM Communication Systems
- Wireless Networks
- Image and Video Processing
- Biomedical Signal Analysis
- Embedded FPGA Systems

---

## Repository Contents

- VHDL Source Code
- Testbenches
- Vivado Project Files
- Simulation Waveforms
- RTL Schematics
- Synthesized Schematics
- Timing Reports
- Power Reports
- Resource Utilization Reports
- Project Documentation

---

## Future Work

- 8×8 and 16×16 Multiplier Architectures
- Pipelined FFT Processor
- Higher-Order FFT (16-point / 32-point / 64-point)
- Fixed-Point and Floating-Point FFT
- ASIC Implementation
- Performance Comparison with DSP Slice-Based Multipliers

---

## Author

**Swapnil Varma**

Bachelor of Engineering (Electronics)

The Maharaja Sayajirao University of Baroda

---

## License

This project is licensed under the MIT License.

Feel free to use, modify, and distribute this project for educational and research purposes.

---

## Keywords

FPGA, Verilog, FFT, Fast Fourier Transform, Array Multiplier, Vedic Multiplier, Wallace Tree Multiplier, Modified Booth Multiplier, DSP, Vivado, Basys 3, Artix-7, Hardware Optimization, Low Power Design, Area Optimization, Digital Signal Processing.