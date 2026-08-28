# MATLAB Integration for Vedic Multiplier Based 8-Point FFT

## Overview

This directory provides MATLAB integration for the **8-point FFT architecture using a Vedic multiplier**.

The purpose of the MATLAB integration is to verify the output of the Verilog RTL FFT against the standard MATLAB `fft()` function.

The verification flow is:

```text
Verilog RTL FFT
      |
      | Simulation
      v
fft_output.csv
      |
      | Read by MATLAB
      v
MATLAB FFT Comparison
      |
      v
Error Analysis
      |
      v
PASS / FAIL
```

The MATLAB FFT is used as the software reference, while the Verilog FFT represents the hardware implementation.

---

## 1. Requirements

The following software is required:

* MATLAB
* Verilog simulator such as:

  * Xilinx Vivado Simulator
  * ModelSim
  * QuestaSim
  * Icarus Verilog

For FPGA implementation, Xilinx Vivado can be used.

---

## 2. Folder Structure

Keep the Verilog files and MATLAB files organized as follows:

```text
Vedic_FFT/
|
+-- RTL/
|   +-- fft8_top.v
|   +-- butterfly.v
|   +-- complex_add_sub.v
|   +-- complex_mult_array.v
|   +-- vedic_multiplier.v
|
+-- Testbench/
|   +-- fft8_tb.v
|
+-- MATLAB/
|   +-- compare_fft.m
|
+-- fft_output.csv
|
+-- README.md
```

The exact folder names can be changed, but the MATLAB script and generated CSV file must be accessible from the same MATLAB working directory.

---

## 3. Verilog Testbench

The MATLAB integration uses the Verilog testbench:

```text
fft8_tb.v
```

The testbench performs the following operations:

1. Generates the clock.
2. Applies reset.
3. Applies the 8-point input data.
4. Starts the FFT.
5. Waits for the `valid` signal.
6. Reads the FFT output.
7. Converts the fixed-point output into floating-point values.
8. Creates `fft_output.csv`.
9. Stores the real and imaginary FFT components in the CSV file.

The Vedic multiplier is selected using:

```verilog
fft8_top #(.MULT_TYPE("VEDIC")) dut (
```

Therefore, the testbench is intended for the Vedic multiplier based FFT implementation.

---

## 4. Input Data Format

The FFT uses signed 16-bit fixed-point data in **Q1.15 format**.

The input values used by the testbench are:

```text
0CCD
199A
F333
1333
E666
0666
2000
ECCD
```

These hexadecimal values correspond approximately to:

```text
0.10000610
0.20001221
-0.10000610
0.14999390
-0.20001221
0.04998779
0.25000000
-0.14999390
```

The Q1.15 conversion is:

```text
Decimal Value = Signed Integer / 32768
```

For example:

```text
0x199A = 6554

6554 / 32768 = 0.20001221
```

---

## 5. CSV Output

After the Verilog simulation is completed, the testbench generates:

```text
fft_output.csv
```

The file has the following format:

```text
Bin,Real,Imaginary
0,0.29998779,0.00000000
1,0.19396973,0.03179932
2,-0.25000000,-0.25000000
3,0.40606689,-0.66821289
4,-0.20001221,0.00000000
5,0.40606689,0.66821289
6,-0.25000000,0.25000000
7,0.19396973,-0.03179932
```

The CSV file contains the FFT bin number, real component, and imaginary component.

---

## 6. Running the Verilog Simulation

First, compile all required RTL files and the testbench.

For example, the required files are:

```text
fft8_top.v
butterfly.v
complex_add_sub.v
complex_mult_array.v
vedic_multiplier.v
fft8_tb.v
```

Run the simulation.

The testbench waits for:

```verilog
valid == 1
```

After the FFT calculation is completed, the testbench generates:

```text
fft_output.csv
```

Make sure the CSV file is created successfully before running MATLAB.

---

## 7. MATLAB Script

The MATLAB comparison script is:

```text
compare_fft.m
```

The MATLAB script performs the following operations:

1. Reads `fft_output.csv`.
2. Extracts the RTL real and imaginary FFT outputs.
3. Reconstructs the same input signal used in Verilog.
4. Converts the Q1.15 input into floating-point values.
5. Calculates the MATLAB FFT using:

```matlab
X_matlab = fft(x);
```

6. Compares MATLAB FFT with the RTL FFT.
7. Calculates the complex error.
8. Calculates maximum absolute error.
9. Calculates mean absolute error.
10. Generates FFT comparison plots.
11. Generates an error plot.
12. Reports PASS or FAIL.

---

## 8. Running MATLAB

Open MATLAB and set the Current Folder to the directory containing:

```text
compare_fft.m
fft_output.csv
```

Run:

```matlab
compare_fft
```

Do not include `.m` when executing the script.

---

## 9. Error Calculation

The complex error is calculated as:

```matlab
error_complex = X_rtl - X_matlab;
```

The magnitude of the error is:

```matlab
error_magnitude = abs(error_complex);
```

The maximum error is:

```matlab
max_error = max(error_magnitude);
```

The mean error is:

```matlab
mean_error = mean(error_magnitude);
```

These values provide a numerical measurement of how closely the hardware FFT matches MATLAB.

---

## 10. PASS / FAIL Criterion

The MATLAB script currently uses:

```matlab
TOL = 0.001;
```

The verification is considered successful when:

```text
Maximum Absolute Error <= TOL
```

The result is reported as:

```text
RESULT: PASS
```

Otherwise:

```text
RESULT: FAIL
```

The tolerance should be selected according to the fixed-point precision and rounding/truncation used in the RTL implementation.

---

## 11. Example Verification Result

An example result obtained from the Vedic FFT implementation is:

```text
Maximum Absolute Error = 0.0000084624
Mean Absolute Error    = 0.0000042312

RESULT: PASS
Vedic FFT matches MATLAB FFT within tolerance.
```

The maximum error is:

```text
8.4624 x 10^-6
```

This small difference is expected because MATLAB performs the FFT using floating-point arithmetic, whereas the RTL implementation uses finite-precision fixed-point arithmetic.

---

## 12. Why MATLAB and RTL Results Are Slightly Different

The MATLAB implementation:

```matlab
fft(x)
```

uses floating-point numerical calculations.

The hardware FFT uses:

```text
16-bit Q1.15 fixed-point arithmetic
```

Therefore, intermediate calculations can introduce small:

* Quantization errors
* Rounding errors
* Truncation errors
* Fixed-point multiplication errors

For this reason, exact bit-for-bit equality with MATLAB floating-point FFT is not necessarily expected.

A very small numerical difference with a correct FFT spectrum is acceptable.

---

## 13. FFT Symmetry Verification

Since the current input is real-valued, the FFT should have conjugate symmetry:

```text
X[k] = conjugate(X[N-k])
```

For an 8-point FFT:

```text
X1 <-> X7
X2 <-> X6
X3 <-> X5
```

For example:

```text
X1 = 0.19396973 + j0.03179932

X7 = 0.19396973 - j0.03179932
```

and:

```text
X3 = 0.40606689 - j0.66821289

X5 = 0.40606689 + j0.66821289
```

This provides an additional check that the FFT output is structurally correct.

---

## 14. Generated MATLAB Plots

The MATLAB script generates two plots.

### FFT Magnitude Comparison

This plot compares:

```text
MATLAB FFT
vs
Vedic RTL FFT
```

The two spectra should closely overlap.

### Absolute Error

The second plot displays:

```text
|RTL FFT - MATLAB FFT|
```

for each FFT bin.

This makes it easy to identify bins where fixed-point error occurs.

---

## 15. Verification Flow

The complete verification process is:

```text
             Input Samples
                   |
                   v
          +----------------+
          |   Vedic FFT    |
          |      RTL       |
          +----------------+
                   |
                   v
          fft_output.csv
                   |
                   v
          +----------------+
          |     MATLAB     |
          |   readtable()  |
          +----------------+
                   |
                   v
          +----------------+
          |   MATLAB FFT   |
          |    fft(x)      |
          +----------------+
                   |
                   v
          +----------------+
          | Error Analysis |
          +----------------+
                   |
                   v
              PASS / FAIL
```

---

## 16. Important Notes

### Note 1: Run Verilog First

The MATLAB script requires:

```text
fft_output.csv
```

Therefore, the Verilog simulation must be executed before running MATLAB.

### Note 2: Keep the CSV Updated

Whenever the Verilog input or FFT architecture is changed, regenerate:

```text
fft_output.csv
```

before running MATLAB.

### Note 3: MATLAB Does Not Generate the RTL Output

MATLAB only acts as the software reference and comparison environment.

The RTL simulator generates:

```text
fft_output.csv
```

MATLAB reads and analyzes this file.

### Note 4: Fixed-Point Arithmetic

The RTL uses Q1.15 fixed-point representation. Therefore, small differences from MATLAB floating-point results are expected.

---

## 17. Recommended Future Verification

For more comprehensive verification, the FFT should be tested with multiple input vectors instead of only one test vector.

Recommended test cases include:

```text
1. Random input
2. Impulse input
3. Constant input
4. Sinusoidal input
5. Maximum positive values
6. Maximum negative values
7. Multiple random Q1.15 vectors
```

For each test vector, MATLAB can calculate:

```text
Maximum Absolute Error
Mean Absolute Error
RMSE
SNR
```

This provides stronger evidence that the Vedic FFT architecture is functionally correct.

---

## 18. Project Verification Statement

The MATLAB integration provides a software reference for functional verification of the proposed Vedic multiplier based FFT architecture.

The Verilog RTL output is compared against MATLAB's `fft()` function using the same Q1.15 input samples. The comparison includes real and imaginary components, complex absolute error, maximum error, mean error, and graphical spectrum comparison.

A maximum absolute error within the selected fixed-point tolerance indicates successful functional verification of the RTL FFT implementation.

```
```
