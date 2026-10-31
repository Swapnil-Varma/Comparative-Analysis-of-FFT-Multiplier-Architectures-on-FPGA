%% fft8_dit.m
% 8-point Radix-2 Decimation-in-Time (DIT) FFT implemented in MATLAB
% Project : Comparative Analysis of FFT Multiplier Architectures on FPGA
%
% What it does:
%   1. Generates a two-tone signal and takes 8 samples (time domain)
%   2. Computes twiddle factors and bit-reversed input order
%   3. Runs 3 stages of radix-2 butterflies (own implementation, not fft())
%   4. Plots the spectrum in Hz (frequency domain)
%   5. Checks the result against MATLAB's built-in fft()
%
% How to run: open this file in MATLAB and press Run (no toolbox needed).
% Output    : Command Window table + figure saved in the results folder.

clc;                                           % clear the Command Window
clear;                                         % remove old variables
close all;                                     % close all figures

%% 1. SIGNAL IN THE TIME DOMAIN

N  = 8;                                        % FFT size = 8 points
fs = 8000;                                     % sampling frequency = 8000 Hz
Ts = 1/fs;                                     % sampling period = 0.125 ms
n  = 0:N-1;                                    % sample numbers 0 to 7
t  = n*Ts;                                     % time of each sample in seconds
df = fs/N;                                     % bin spacing = 1000 Hz (frequency resolution)

f1 = 1000;                                     % first tone = 1000 Hz (lands exactly on bin 1)
f2 = 2000;                                     % second tone = 2000 Hz (lands exactly on bin 2)
a1 = 1.0;                                      % amplitude of the first tone
a2 = 0.5;                                      % amplitude of the second tone

x = a1*sin(2*pi*f1*t) + a2*sin(2*pi*f2*t);     % the 8 samples of the time-domain signal

tc = linspace(0, N*Ts, 500);                   % fine time axis, only to draw the smooth signal
xc = a1*sin(2*pi*f1*tc) + a2*sin(2*pi*f2*tc);  % smooth signal for the plot

%% 2. TWIDDLE FACTORS
% Formula: W_N^k = exp(-j*2*pi*k/N) = cos(2*pi*k/N) - j*sin(2*pi*k/N)

k = 0:N/2-1;                                   % only 4 twiddles are needed for N = 8
W = exp(-1j*2*pi*k/N);                         % W_8^0, W_8^1, W_8^2, W_8^3

disp('Twiddle factors W_8^k:');                % heading
for i = 1:N/2                                  % loop over the 4 twiddles
    fprintf('W^%d = %7.4f %+7.4fj\n', k(i), real(W(i)), imag(W(i)));   % print real and imaginary parts
end                                            % end of loop

%% 3. BIT-REVERSED INPUT ORDER

stages = log2(N);                              % number of stages = 3
idx = bin2dec(fliplr(dec2bin(0:N-1, stages)))';   % bit-reversed indices: 0 4 2 6 1 5 3 7
y = x(idx + 1);                                % reorder the samples (+1 for MATLAB indexing)

disp(' ');                                     % blank line
disp('Bit-reversed index order:');             % heading
disp(idx);                                     % show 0 4 2 6 1 5 3 7

%% 4. RADIX-2 DIT BUTTERFLIES

for s = 1:stages                               % loop over the 3 stages
    m = 2^s;                                   % group size in this stage (2, 4, 8)
    half = m/2;                                % distance between butterfly inputs (1, 2, 4)
    for g = 0:m:N-1                            % loop over the groups
        for j = 0:half-1                       % loop over the butterflies in a group
            p = g + j + 1;                     % position of the upper input
            q = p + half;                      % position of the lower input
            w = W(j*(N/m) + 1);                % twiddle for this butterfly: W_8^(j*N/m)
            a = y(p);                          % upper input
            b = y(q) * w;                      % lower input times twiddle
            y(p) = a + b;                      % top output    = a + W*b
            y(q) = a - b;                      % bottom output = a - W*b
        end                                    % end of butterflies
    end                                        % end of groups
    fprintf('\nAfter stage %d:\n', s);          % heading for this stage
    disp(round(y, 4));                         % values after this stage (rounded for display)
end                                            % end of stages

X = y;                                         % FFT output X[0] to X[7] in natural order

%% 5. FREQUENCY AXIS AND AMPLITUDE

f = (0:N-1)*df;                                % frequency of each bin in Hz

amp = abs(X)/N;                                % normalize by N
amp = amp(1:N/2+1);                            % keep bins 0 to N/2 (0 Hz to 4000 Hz = fs/2)
amp(2:end-1) = 2*amp(2:end-1);                 % double bins 1..N/2-1 (negative half removed)
fh = f(1:N/2+1);                               % frequency axis for the single-sided spectrum

%% 6. CHECK AGAINST MATLAB fft

X_ref = fft(x);                                % built-in FFT used only as the reference
err = max(abs(X - X_ref));                     % largest difference between the two results

disp(' ');                                     % blank line
disp('  k   Freq(Hz)      Real       Imag     Magnitude');   % table heading
for i = 1:N                                    % loop over the 8 bins
    fprintf('%3d %9.0f %10.4f %10.4f %10.4f\n', i-1, f(i), real(X(i)), imag(X(i)), abs(X(i)));   % one row per bin
end                                            % end of loop

fprintf('\nMax difference from fft() = %.3e\n', err);   % verification value
if err < 1e-10                                 % tolerance for floating-point rounding
    disp('RESULT: PASS (own FFT matches MATLAB fft)');   % own FFT is correct
else                                           % otherwise
    disp('RESULT: FAIL (check the code)');     % something is wrong
end                                            % end of check

[~, b1] = min(abs(fh - f1));                   % bin closest to the first tone
[~, b2] = min(abs(fh - f2));                   % bin closest to the second tone
fprintf('Detected: %.0f Hz with amplitude %.2f, and %.0f Hz with amplitude %.2f\n', ...
        fh(b1), amp(b1), fh(b2), amp(b2));     % frequency and amplitude of both tones

%% 7. PLOTS

figure(1);                                     % open figure 1
subplot(2,1,1);                                % top plot: time domain
plot(tc*1000, xc, 'b'); hold on;               % smooth signal (time in ms)
stem(t*1000, x, 'r', 'filled');                % the 8 samples taken
title('Time Domain: signal and its 8 samples');   % title
xlabel('Time (ms)'); ylabel('Amplitude'); grid on;   % labels and grid
legend('Signal', 'Samples');                   % legend

subplot(2,1,2);                                % bottom plot: frequency domain
stem(fh, amp, 'filled');                       % amplitude at each bin frequency
title('Frequency Domain: spectrum from own 8-point radix-2 DIT FFT');   % title
xlabel('Frequency (Hz)'); ylabel('Amplitude'); grid on;     % labels and grid
xlim([-df/2, fs/2 + df/2]);                    % show 0 to fs/2 with half a bin of margin

%% 8. SAVE THE FIGURE (for GitHub)

outDir = fullfile(fileparts(mfilename('fullpath')), 'results');   % results folder next to this script
if ~exist(outDir, 'dir')                       % if the folder does not exist yet
    mkdir(outDir);                             % create it
end                                            % end of if
saveas(figure(1), fullfile(outDir, 'fft8_dit_plot.png'));   % save the plot as PNG
disp(['Figure saved in: ' outDir]);            % tell the user where it went