%% Exercise 3 - Spectral leakage, recording length and zero padding
% Savonia Lecture 5 - Fourier Assignment
% Only enter the FINAL DIGIT of your student number, never the whole number.
clear; clc; close all;

d = input('Enter only the LAST digit of your student number (0-9): ');
validateattributes(d,{'numeric'},{'scalar','integer','>=',0,'<=',9});
f2 = 13.2 + 0.17*d;

fs = 200;                     % Keep sampling rate unchanged

% One-second recording
T1 = 1;
t1 = 0:1/fs:T1-1/fs;
x1 = 0.8*sin(2*pi*15*t1) + 0.4*sin(2*pi*f2*t1);
N1 = length(x1);
Y1 = fft(x1);
A1 = abs(Y1/N1);
A1 = A1(1:N1/2+1);
A1(2:end-1) = 2*A1(2:end-1);
f1 = fs*(0:N1/2)/N1;

% Four-second recording: SAME frequencies and same sampling rate
T4 = 4;
t4 = 0:1/fs:T4-1/fs;
x4 = 0.8*sin(2*pi*15*t4) + 0.4*sin(2*pi*f2*t4);
N4 = length(x4);
Y4 = fft(x4);
A4 = abs(Y4/N4);
A4 = A4(1:N4/2+1);
A4(2:end-1) = 2*A4(2:end-1);
f4 = fs*(0:N4/2)/N4;

% Zero-pad the ORIGINAL one-second signal to 4*N1 FFT points.
% IMPORTANT: divide by N1 (actual recorded samples), NOT by 4*N1.
Npad = 4*N1;
Ypad = fft(x1,Npad);
Apad = abs(Ypad/N1);
Apad = Apad(1:Npad/2+1);
Apad(2:end-1) = 2*Apad(2:end-1);
fpad = fs*(0:Npad/2)/Npad;

% Combined comparison required for GitHub submission.
figure('Name','Exercise 3 - Leakage Comparisons','Color','w');
subplot(3,1,1);
plot(f1,A1,'-o','MarkerSize',3); grid on; xlim([5 25]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('One-second recording (bin spacing %.2f Hz)',fs/N1));

subplot(3,1,2);
plot(f4,A4,'-','LineWidth',1.1); grid on; xlim([5 25]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('Four-second recording (bin spacing %.2f Hz)',fs/N4));

subplot(3,1,3);
plot(fpad,Apad,'-','LineWidth',1.1); grid on; xlim([5 25]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('Zero-padded ONE-second recording (plot spacing %.2f Hz)',fs/Npad));

fprintf('You entered d = %d\n',d);
fprintf('Calculated f2 = 13.2 + 0.17*%d = %.2f Hz\n',d,f2);
fprintf('One-second: N = %d, bin spacing = %.2f Hz\n',N1,fs/N1);
fprintf('Four-second: N = %d, bin spacing = %.2f Hz\n',N4,fs/N4);
fprintf('Zero-padded one-second: FFT points = %d, spacing = %.2f Hz\n',Npad,fs/Npad);

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
saveas(gcf,fullfile(scriptFolder,'leakage-comparison.png'));
disp('Saved leakage-comparison.png');
