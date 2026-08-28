clc;
clear;
close all;

filename = 'fft_output.csv';

if ~isfile(filename)
    error('fft_output.csv not found. Run the Verilog simulation first.');
end

data = readtable(filename);

bin = data.Bin;
X_rtl = data.Real + 1i * data.Imaginary;

x_hex = { ...
    '0CCD'
    '199A'
    'F333'
    '1333'
    'E666'
    '0666'
    '2000'
    'ECCD'
};

x_unsigned = hex2dec(x_hex);

x_signed = x_unsigned;

for k = 1:length(x_signed)
    if x_signed(k) >= 32768
        x_signed(k) = x_signed(k) - 65536;
    end
end

x = x_signed / 32768;

X_matlab = fft(x);

error_complex = X_rtl - X_matlab;

error_real = real(error_complex);
error_imag = imag(error_complex);
error_magnitude = abs(error_complex);

max_error = max(error_magnitude);
mean_error = mean(error_magnitude);

fprintf('\n');
fprintf('============================================\n');
fprintf('          INPUT SIGNAL\n');
fprintf('============================================\n');

fprintf('Bin        Input\n');
fprintf('--------------------------------------------\n');

for k = 1:length(x)
    fprintf('%2d       %+.8f\n', k-1, x(k));
end

fprintf('\n');
fprintf('============================================\n');
fprintf('       VEDIC FFT VS MATLAB FFT\n');
fprintf('============================================\n');

fprintf('Bin     RTL Real       MATLAB Real     RTL Imag       MATLAB Imag      Error\n');
fprintf('----------------------------------------------------------------------------\n');

for k = 1:length(X_matlab)

    fprintf('%2d    %+.8f    %+.8f    %+.8f    %+.8f    %.8f\n', ...
        k-1, ...
        real(X_rtl(k)), ...
        real(X_matlab(k)), ...
        imag(X_rtl(k)), ...
        imag(X_matlab(k)), ...
        error_magnitude(k));

end

fprintf('\n');
fprintf('============================================\n');
fprintf('           ERROR ANALYSIS\n');
fprintf('============================================\n');

fprintf('Maximum Absolute Error = %.10f\n', max_error);
fprintf('Mean Absolute Error    = %.10f\n', mean_error);

TOL = 0.001;

if max_error <= TOL
    fprintf('\nRESULT: PASS\n');
    fprintf('Vedic FFT matches MATLAB FFT within tolerance.\n');
else
    fprintf('\nRESULT: FAIL\n');
    fprintf('Vedic FFT does not match MATLAB FFT within tolerance.\n');
end

fprintf('============================================\n');

figure;

stem(bin, abs(X_matlab), 'filled');
hold on;
stem(bin, abs(X_rtl));

grid on;

xlabel('FFT Bin');
ylabel('Magnitude');
title('8-Point FFT Comparison');
legend('MATLAB FFT', 'Vedic RTL FFT');

figure;

stem(bin, error_magnitude, 'filled');

grid on;

xlabel('FFT Bin');
ylabel('Absolute Error');
title('Vedic FFT Absolute Error');

fprintf('\n');
fprintf('============================================\n');
fprintf('          COMPLEX FFT RESULTS\n');
fprintf('============================================\n');

for k = 1:length(X_matlab)

    fprintf('X(%d)\n', k-1);

    fprintf('  MATLAB = %+.8f %+.8fi\n', ...
        real(X_matlab(k)), imag(X_matlab(k)));

    fprintf('  RTL    = %+.8f %+.8fi\n', ...
        real(X_rtl(k)), imag(X_rtl(k)));

    fprintf('  Error  = %.8f\n\n', ...
        error_magnitude(k));

end