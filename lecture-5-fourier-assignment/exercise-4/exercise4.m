%% Exercise 4 - Compare the DTFT, 4-point DFT and 64-point DFT
% Savonia Lecture 5 - Fourier Assignment
clear; clc; close all;

x = [1 1 1 1];
n = 0:length(x)-1;

% DTFT evaluated at 1000 frequencies from -pi to +pi.
w = linspace(-pi,pi,1000);
X = x*exp(-1j*(n.'*w));

% DFT magnitudes at 4 and 64 equally spaced frequency locations.
N4 = 4;
N64 = 64;
Y4 = fft(x,N4);
Y64 = fft(x,N64);
w4 = 2*pi*(0:N4-1)/N4;
w64 = 2*pi*(0:N64-1)/N64;

% Wrap FFT bins into [-pi,pi] so we can compare with the DTFT.
w4(w4 > pi) = w4(w4 > pi)-2*pi;
w64(w64 > pi) = w64(w64 > pi)-2*pi;
[w4,ord4] = sort(w4);
[w64,ord64] = sort(w64);
mag4 = abs(Y4(ord4));
mag64 = abs(Y64(ord64));

figure('Name','Exercise 4 - DTFT vs DFT','Color','w');
subplot(2,1,1);
plot(w,abs(X),'LineWidth',1.3); hold on;
stem(w4,mag4,'filled','MarkerSize',5);
grid on; xlim([-pi pi]);
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
title('DTFT curve and 4-point DFT');
legend('DTFT','4-point DFT','Location','best');

subplot(2,1,2);
plot(w,abs(X),'LineWidth',1.3); hold on;
stem(w64,mag64,'MarkerSize',2);
grid on; xlim([-pi pi]);
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
title('DTFT curve and 64-point DFT (zero-padded)');
legend('DTFT','64-point DFT','Location','best');

fprintf('Original sequence has %d samples.\n',length(x));
fprintf('fft(x,4) returns %d frequency values.\n',length(Y4));
fprintf('fft(x,64) returns %d frequency values.\n',length(Y64));
fprintf('Theoretical zeros are at w = -pi, -pi/2, pi/2 and pi in the plotted range.\n');

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
saveas(gcf,fullfile(scriptFolder,'dtft-dft-comparison.png'));
disp('Saved dtft-dft-comparison.png');
