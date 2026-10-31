# 8-Point Radix-2 DIT FFT: MATLAB Simulation Explained

**Project:** Comparative Analysis of FFT Multiplier Architectures on FPGA
**Phase:** 1 (MATLAB simulation), Step 1: floating-point algorithm baseline
**File:** `fft8_dit.m`

---

## 1. What this script does

The script takes a **time-domain signal** and converts it into a **frequency-domain spectrum** using our own implementation of the **8-point radix-2 decimation-in-time (DIT) FFT**. It does not call MATLAB's `fft` to produce the result. The built-in `fft` is used only at the end to **check** our answer.

Steps in order:

1. Generate a real signal (two sine waves, 1 kHz and 2 kHz) and take 8 samples at fs = 8 kHz.
2. Compute the twiddle factors.
3. Reorder the samples in bit-reversed order.
4. Run 3 stages of butterflies.
5. Convert the output into a frequency axis in Hz and an amplitude.
6. Verify against MATLAB's `fft`.
7. Plot the time-domain and frequency-domain views.

---

## 2. Theory in brief

### 2.1 DFT and why the FFT exists

The Discrete Fourier Transform of N samples x[n] is

```
X[k] = sum over n = 0..N-1 of  x[n] · W_N^(nk),     k = 0..N-1
```

with the twiddle factor `W_N = e^(-j2π/N)`.

Computing this directly needs N² complex multiplications (64 for N = 8). The FFT removes the repeated work by splitting the transform into smaller ones, which needs only (N/2)·log₂N complex multiplications (12 for N = 8).

### 2.2 Radix-2 DIT idea

Split the N-point sequence into its even-indexed and odd-indexed samples, transform each half, then combine:

```
X[k]       = E[k] + W_N^k · O[k]
X[k + N/2] = E[k] - W_N^k · O[k]
```

Repeating this split until only 2-point transforms remain gives log₂N stages. "Decimation in time" means the splitting is done on the **time-domain** samples, which is why the input must be reordered (see section 2.5).

### 2.3 Twiddle factors

```
W_N^k = e^(-j2πk/N) = cos(2πk/N) - j·sin(2πk/N)
```

For N = 8, only N/2 = 4 are needed, because `W^(k+N/2) = -W^k`:

| k | W_8^k (exact) | Decimal | Trivial? |
|---|---|---|---|
| 0 | 1 | 1 + 0j | Yes (multiply by 1) |
| 1 | (1 − j)/√2 | 0.7071 − 0.7071j | No |
| 2 | −j | 0 − 1j | Yes (swap real/imaginary, change a sign) |
| 3 | −(1 + j)/√2 | −0.7071 − 0.7071j | No |

For the later fixed-point (Q1.15) stage: 0.7071 is stored as 23170, and −0.7071 as −23170 (0xA57E in 16-bit two's complement).

### 2.4 The butterfly

Every butterfly takes two complex inputs `a` and `b` and one twiddle `W`:

```
 a ─────────────► (+) ──► top    = a + W·b
              ╲ ╱
               ╳
              ╱ ╲
 b ──[× W]───► (−) ──► bottom = a − W·b
```

One complex multiplication `W·b` is shared between the two outputs:

```
(c + jd)(e + jf) = (ce − df) + j(cf + de)      -> 4 real multiplications
```

### 2.5 Bit-reversed input order

For N = 8 the 3-bit index is reversed:

| Index | Binary | Reversed | New position |
|---|---|---|---|
| 0 | 000 | 000 | 0 |
| 1 | 001 | 100 | 4 |
| 2 | 010 | 010 | 2 |
| 3 | 011 | 110 | 6 |
| 4 | 100 | 001 | 1 |
| 5 | 101 | 101 | 5 |
| 6 | 110 | 011 | 3 |
| 7 | 111 | 111 | 7 |

The reordered input is `x[0], x[4], x[2], x[6], x[1], x[5], x[3], x[7]`. After this, the outputs come out in natural order X[0] … X[7].

### 2.6 Structure of the 8-point FFT

- Stages: log₂8 = **3**
- Butterflies per stage: N/2 = **4**
- Total butterflies: **12**

| Stage | Butterfly pairs (positions) | Twiddles used |
|---|---|---|
| 1 | (0,1) (2,3) (4,5) (6,7) | W⁰, W⁰, W⁰, W⁰ |
| 2 | (0,2) (1,3) (4,6) (5,7) | W⁰, W², W⁰, W² |
| 3 | (0,4) (1,5) (2,6) (3,7) | W⁰, W¹, W², W³ |

Only **two** butterflies (W¹ and W³ in stage 3) need a true complex multiplication. The others multiply by 1 or −j. A design that uses a general multiplier in every butterfly performs 12 complex multiplications, so how your RTL treats the trivial twiddles affects its multiplier count.

---

## 3. Code walkthrough

### Section 1: Signal in the time domain

```matlab
N  = 8;      fs = 8000;     Ts = 1/fs;
n  = 0:N-1;  t  = n*Ts;
x  = a1*sin(2*pi*f1*t) + a2*sin(2*pi*f2*t);
```

- `N = 8` is the FFT size, the same as the FPGA core.
- `fs = 8000` samples per second, so consecutive samples are `Ts = 0.125 ms` apart.
- `t = n*Ts` gives the time of each of the 8 samples (0 to 0.875 ms).
- `x` is the signal: a 1 kHz tone with amplitude 1.0 plus a 2 kHz tone with amplitude 0.5. These 8 numbers are the input to the FFT.
- `tc` and `xc` use 500 points and exist **only to draw the smooth curve**. The FFT never sees them.

**Why 1000 Hz and 2000 Hz?** The bin spacing is `fs/N = 1000 Hz`, so these two tones fall exactly on bins 1 and 2. This gives clean peaks with no leakage.

### Section 2: Twiddle factors

```matlab
k = 0:N/2-1;
W = exp(-1j*2*pi*k/N);
```

Computes `W_8^0` to `W_8^3`. Only four are needed because the other four are their negatives.

### Section 3: Bit-reversed input order

```matlab
idx = bin2dec(fliplr(dec2bin(0:N-1, stages)))';
y   = x(idx + 1);
```

- `dec2bin(0:N-1, 3)` writes the indices 0 to 7 as 3-bit binary strings.
- `fliplr` reverses the bits of each one.
- `bin2dec` converts back to numbers, giving `0 4 2 6 1 5 3 7`.
- `+ 1` is needed because MATLAB arrays start at 1, not 0.

### Section 4: Radix-2 DIT butterflies

```matlab
for s = 1:stages
    m = 2^s;  half = m/2;
    for g = 0:m:N-1
        for j = 0:half-1
            p = g + j + 1;   q = p + half;
            w = W(j*(N/m) + 1);
            a = y(p);        b = y(q) * w;
            y(p) = a + b;    y(q) = a - b;
        end
    end
end
```

| Variable | Meaning |
|---|---|
| `s` | Current stage (1 to 3) |
| `m` | Size of each group in this stage: 2, 4, 8 |
| `half` | Distance between the two inputs of a butterfly: 1, 2, 4 |
| `g` | Start of each group |
| `j` | Index of the butterfly inside its group |
| `p`, `q` | Positions of the upper and lower inputs |
| `w` | Twiddle: `W_8^(j·N/m)` |

Why `j*(N/m)`: a group of size `m` uses `W_m^j`, and `W_m^j = W_N^(j·N/m)`. That gives indices {0} in stage 1, {0, 2} in stage 2 and {0, 1, 2, 3} in stage 3, matching the table in section 2.6.

The update `y(p) = a + b; y(q) = a - b;` is done **in place**: the results overwrite the inputs, as in a hardware butterfly unit.

### Section 5: Frequency axis and amplitude

```matlab
df  = fs/N;
f   = (0:N-1)*df;
amp = abs(X)/N;
amp = amp(1:N/2+1);
amp(2:end-1) = 2*amp(2:end-1);
fh  = f(1:N/2+1);
```

- `df = fs/N` is the **frequency resolution**: bin k corresponds to k × 1000 Hz.
- `abs(X)` converts the complex output into a magnitude.
- Dividing by `N` gives the true amplitude of each sine.
- For a real input, the upper half of the spectrum mirrors the lower half (bin 7 is the same as −1000 Hz). Keeping only bins 0 to 4 (0 to 4000 Hz) and **doubling bins 1 to 3** restores the energy of the removed half. Bin 0 (DC) and bin 4 (Nyquist, fs/2) have no mirror, so they are not doubled.

### Section 6: Check against MATLAB's `fft`

```matlab
X_ref = fft(x);
err   = max(abs(X - X_ref));
```

The largest difference between our result and the built-in one. It should be around 1e-15 or smaller, which is floating-point rounding only.

The table prints k, the frequency in Hz, the real and imaginary parts, and the magnitude. Tiny values like 1e-16 may show as `0.0000` or `-0.0000`.

### Section 7: Plots

- **Top plot (time domain):** the smooth signal in blue with the 8 sampled points in red.
- **Bottom plot (frequency domain):** the spectrum as a stem plot, amplitude against frequency in Hz.

---

## 4. Worked example (actual numbers from this script)

**Input samples** (fs = 8 kHz, tones at 1 kHz and 2 kHz):

```
x[n] = [ 0   1.2071   1   0.2071   0   -0.2071   -1   -1.2071 ]
```

**After bit reversal** (order 0 4 2 6 1 5 3 7):

```
y = [ 0   0   1   -1   1.2071   -0.2071   0.2071   -1.2071 ]
```

**After stage 1** (all twiddles = W⁰):

```
[ 0   0   0   2   1.0   1.4142   -1.0   1.4142 ]
```

**After stage 2** (twiddles W⁰ and W²; multiplying by W² = −j):

```
[ 0   -2j   0   +2j   0   1.4142-1.4142j   2   1.4142+1.4142j ]
```

**After stage 3** (twiddles W⁰, W¹, W², W³), the final output X[k]:

| k | Frequency | X[k] | \|X[k]\| |
|---|---|---|---|
| 0 | 0 Hz | 0 | 0 |
| 1 | 1000 Hz | −4j | 4 |
| 2 | 2000 Hz | −2j | 2 |
| 3 | 3000 Hz | 0 | 0 |
| 4 | 4000 Hz | 0 | 0 |
| 5 | 5000 Hz (mirror) | 0 | 0 |
| 6 | 6000 Hz (mirror) | +2j | 2 |
| 7 | 7000 Hz (mirror) | +4j | 4 |

**Converting to amplitude:** `amp = 2·|X[k]|/N`

- Bin 1: 2 × 4 / 8 = **1.0** (the 1 kHz tone)
- Bin 2: 2 × 2 / 8 = **0.5** (the 2 kHz tone)

This matches the input amplitudes, so the transform is correct. A sine of amplitude A on bin k gives `|X[k]| = A·N/2`, and the output is `−j·A·N/2` at bin k and `+j·A·N/2` at bin N−k. That is exactly what the table shows.

---

## 5. What you should see when you run it

- **Command Window:** the 8-row table above, then `Max difference from fft() = ` a number around 1e-16 to 1e-15, then the detected tones (1000 Hz with amplitude 1.00, and 2000 Hz with amplitude 0.50).
- **Figure 1, top:** a smooth wave with 8 red dots.
- **Figure 1, bottom:** two stems, 1.0 at 1000 Hz and 0.5 at 2000 Hz, and zero at 0, 3000 and 4000 Hz.

---

## 6. Viva questions and answers

| Question | Answer |
|---|---|
| What does this code do? | It converts an 8-sample time-domain signal into its frequency spectrum using our own radix-2 DIT FFT and checks it against MATLAB's `fft`. |
| Why radix-2? | Each butterfly combines two inputs, so the structure is simple and regular. It is easy to map onto hardware. |
| Why DIT? | The time samples are split into even and odd parts. The input is bit-reversed and the output is in natural order. |
| Why bit reversal? | Repeated even/odd splitting reorders the samples, so the input must be arranged in advance for the in-place butterflies to give natural-order output. |
| How many stages, butterflies? | 3 stages, 4 per stage, 12 in total. |
| What is a twiddle factor? | `W_N^k = e^(-j2πk/N)`, a complex rotation applied to the lower butterfly input. |
| How many distinct twiddles for N = 8? | Four (W⁰ to W³), because `W^(k+N/2) = -W^k`. |
| Which twiddles need a real multiplier? | W¹ and W³ (0.7071 ∓ 0.7071j). W⁰ = 1 and W² = −j are trivial. |
| Why divide by N and double? | Division gives the true amplitude. Doubling accounts for the discarded mirror half of a real signal's spectrum. |
| Why only 1000 and 2000 Hz? | The bin spacing is fs/N = 1000 Hz, so these frequencies land exactly on bins. Other frequencies leak into neighbouring bins. |
| What is the frequency resolution? | fs/N = 1000 Hz. Finer resolution needs a larger N. |
| What is the highest frequency you can see? | fs/2 = 4000 Hz (Nyquist). Anything higher aliases. |
| How do you know your FFT is correct? | The difference from MATLAB's `fft` is about 1e-15, and the hand-computed result matches (bin 1 = −4j, bin 2 = −2j). |
| Does the multiplier architecture change the MATLAB result? | No. All four multipliers (Array, Booth, Vedic, Wallace) compute the same product. They differ in power, area and timing, which is what the FPGA comparison measures. One MATLAB reference therefore serves all four. |

---

## 7. Can this be shown as the "MATLAB simulation of an 8-point radix-2 DIT FFT"?

**Yes.** It is a genuine algorithm-level simulation:

- It uses our own bit-reversal, twiddle factors and butterfly stages, not just a call to `fft`.
- It starts from a real sampled time-domain signal and ends with a frequency-domain plot in Hz.
- It is verified against MATLAB's `fft`, and the results can be checked by hand.

**Be accurate about its scope when you present it.** Say:

> "This is the floating-point MATLAB model of our 8-point radix-2 DIT FFT. It is the golden reference for the algorithm. The next steps are a fixed-point (Q1.15) model that matches the hardware, and a comparison with the Verilog output."

What it **does not** do yet, so you don't over-claim:

- It uses double-precision floating point, whereas the FPGA core uses fixed-point (Q1.15). Quantization error is not modelled yet.
- It does not export test vectors, and it has not been compared with the RTL output.
- It does not model the four multiplier architectures (and it doesn't need to for correctness, see the last viva answer above).
- It uses one test signal. Run a few more (impulse, DC, a single tone at each bin, random input) before the final submission.

**Be ready to explain every line.** Run the script yourself, change a parameter, and see what happens. If an examiner asks you to modify it live, you should be able to.

---

## 8. Experiments to try (good for demonstrating understanding)

1. **Spectral leakage:** change `f1` to `1500`. The peak spreads across bins 1 and 2 and the amplitudes are no longer 1.0.
2. **Different sampling rate:** change `fs` to `800`. The tones should move to 100 Hz and 200 Hz so they stay on bins 1 and 2 (change `f1` and `f2` accordingly).
3. **Aliasing:** set `f1 = 5000` with `fs = 8000`. The 5 kHz tone appears at 3 kHz (8000 − 5000), because it is above Nyquist.
4. **Impulse input:** `x = [1 0 0 0 0 0 0 0]`. All eight outputs equal 1 (flat spectrum).
5. **DC input:** `x = ones(1,8)`. X[0] = 8, all others 0.

Note: the `Detected:` line and the `xlim` in the script assume the tones are on bins 1 and 2 and `fs = 8000`. If you change those, update those two lines.

---

## 9. How this fits the project

| Stage | Status |
|---|---|
| MATLAB 8-point radix-2 DIT FFT, floating point (this file) | Done |
| Q1.15 fixed-point MATLAB model and test-vector export | Next |
| Verilog RTL output vs MATLAB expected output | After that |
| Four multiplier variants compared on FPGA (power, area, timing) | Project core |
| WAV audio spectrum | Later |
| Hardware PCB demo | Later |

---

## Appendix: complete MATLAB code

```matlab
clc;                                           % clear the Command Window
clear;                                         % remove old variables
close all;                                     % close all figures

% ---------------- 1. SIGNAL IN THE TIME DOMAIN ----------------

N  = 8;                                        % FFT size = 8 points
fs = 8000;                                     % sampling frequency = 8000 Hz
Ts = 1/fs;                                     % sampling period = 0.125 ms
n  = 0:N-1;                                    % sample numbers 0 to 7
t  = n*Ts;                                     % time of each sample in seconds

f1 = 1000;                                     % first tone = 1000 Hz (lands exactly on bin 1)
f2 = 2000;                                     % second tone = 2000 Hz (lands exactly on bin 2)
a1 = 1.0;                                      % amplitude of the first tone
a2 = 0.5;                                      % amplitude of the second tone

x = a1*sin(2*pi*f1*t) + a2*sin(2*pi*f2*t);     % the 8 samples of the time-domain signal

tc = linspace(0, N*Ts, 500);                   % fine time axis, only to draw the smooth analog signal
xc = a1*sin(2*pi*f1*tc) + a2*sin(2*pi*f2*tc);  % smooth signal for the plot

% ---------------- 2. TWIDDLE FACTORS ----------------
% Formula: W_N^k = exp(-j*2*pi*k/N)

k = 0:N/2-1;                                   % only 4 twiddles are needed for N = 8
W = exp(-1j*2*pi*k/N);                         % W_8^0, W_8^1, W_8^2, W_8^3

% ---------------- 3. BIT-REVERSED INPUT ORDER ----------------

stages = log2(N);                              % number of stages = 3
idx = bin2dec(fliplr(dec2bin(0:N-1, stages)))';   % bit-reversed indices: 0 4 2 6 1 5 3 7
y = x(idx + 1);                                % reorder the samples (+1 for MATLAB indexing)

% ---------------- 4. RADIX-2 DIT BUTTERFLIES ----------------

for s = 1:stages                               % loop over the 3 stages
    m = 2^s;                                   % group size in this stage (2, 4, 8)
    half = m/2;                                % distance between butterfly inputs (1, 2, 4)
    for g = 0:m:N-1                            % loop over the groups
        for j = 0:half-1                       % loop over the butterflies in a group
            p = g + j + 1;                     % position of the upper input
            q = p + half;                      % position of the lower input
            w = W(j*(N/m) + 1);                % twiddle for this butterfly
            a = y(p);                          % upper input
            b = y(q) * w;                      % lower input times twiddle
            y(p) = a + b;                      % top output    = a + W*b
            y(q) = a - b;                      % bottom output = a - W*b
        end                                    % end of butterflies
    end                                        % end of groups
end                                            % end of stages

X = y;                                         % FFT output X[0] to X[7] in natural order

% ---------------- 5. FREQUENCY AXIS AND AMPLITUDE ----------------

df = fs/N;                                     % bin spacing = 1000 Hz (frequency resolution)
f  = (0:N-1)*df;                               % frequency of each bin in Hz

amp = abs(X)/N;                                % normalize by N
amp = amp(1:N/2+1);                            % keep bins 0 to N/2 (0 Hz to 4000 Hz = fs/2)
amp(2:end-1) = 2*amp(2:end-1);                 % double the values (negative half removed)
fh = f(1:N/2+1);                               % frequency axis for the single-sided spectrum

% ---------------- 6. CHECK AGAINST MATLAB fft ----------------

X_ref = fft(x);                                % built-in FFT as the reference
err = max(abs(X - X_ref));                     % largest difference

disp('  k   Freq(Hz)      Real       Imag     Magnitude');   % table heading
for i = 1:N                                    % loop over the 8 bins
    fprintf('%3d %9.0f %10.4f %10.4f %10.4f\n', i-1, f(i), real(X(i)), imag(X(i)), abs(X(i)));   % one row per bin
end                                            % end of loop
fprintf('\nMax difference from fft() = %.3e\n', err);          % verification
fprintf('Detected: %.0f Hz with amplitude %.2f, and %.0f Hz with amplitude %.2f\n', ...
        fh(2), amp(2), fh(3), amp(3));         % amplitudes of bins 1 and 2

% ---------------- 7. PLOTS ----------------

figure(1);                                     % open figure 1
subplot(2,1,1);                                % top plot: time domain
plot(tc*1000, xc, 'b'); hold on;               % smooth signal (time in ms)
stem(t*1000, x, 'r', 'filled');                % the 8 samples taken
title('Time Domain: signal and its 8 samples');   % title
xlabel('Time (ms)'); ylabel('Amplitude'); grid on;   % labels and grid
legend('Signal', 'Samples');                   % legend

subplot(2,1,2);                                % bottom plot: frequency domain
stem(fh, amp, 'filled');                       % amplitude at each bin frequency
title('Frequency Domain: spectrum from own 8-point FFT');   % title
xlabel('Frequency (Hz)'); ylabel('Amplitude'); grid on;     % labels and grid
xlim([-500 4500]);                             % show 0 to 4000 Hz with some margin
```