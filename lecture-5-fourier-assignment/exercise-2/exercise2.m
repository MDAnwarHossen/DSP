%% Exercise 2 - Identify two frequencies using the FFT
% Savonia Lecture 5 - Fourier Assignment
clear; clc; close all;

fs = 200;                    % Sampling frequency (Hz)
T = 1;                       % Recording duration (s)
t = 0:1/fs:T-1/fs;           % 200 sample times: 0 to 0.995 s
x = 0.8*sin(2*pi*15*t) + 0.4*sin(2*pi*40*t);

N = length(x);
Y = fft(x);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);  % Single-sided amplitudes
f = fs*(0:N/2)/N;

figure('Name','Exercise 2 - Two Frequencies','Color','w');
subplot(2,1,1);
plot(t,x,'LineWidth',1.1);
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Signal in time domain (15 Hz and 40 Hz)');

subplot(2,1,2);
stem(f,P1,'filled','MarkerSize',3);
grid on;
xlim([0 100]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('Single-sided FFT amplitude spectrum');

fprintf('Sampling rate fs = %.0f Hz\n',fs);
fprintf('Samples N = %d\n',N);
fprintf('Frequency bin spacing fs/N = %.2f Hz\n',fs/N);
fprintf('Amplitude near 15 Hz: %.4f\n',P1(f == 15));
fprintf('Amplitude near 40 Hz: %.4f\n',P1(f == 40));

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
saveas(gcf,fullfile(scriptFolder,'two-frequency-spectrum.png'));
disp('Saved two-frequency-spectrum.png');
