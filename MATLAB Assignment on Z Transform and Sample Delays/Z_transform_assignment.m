%% Parts 1 and 2: A signal, its Z-transform, and a one-sample-delay system
% Run this complete script in MATLAB. Four PNG figures are saved in the
% current MATLAB folder. No Symbolic Math Toolbox is needed.

clear; clc; close all;

%% Part 1: Original signal and a one-sample delay
x = [1 2 1];
n = 0:length(x)-1;

% A one-sample delay inserts a zero at n = 0.
xDelayed = [0 x];
nDelayed = 0:length(xDelayed)-1;

figure(1);
stem(n, x, 'filled');
title('Original Signal x[n]');
xlabel('Sample n'); ylabel('Amplitude');
xticks(n); grid on;
saveas(gcf, 'original_signal.png');

figure(2);
stem(nDelayed, xDelayed, 'filled');
title('One-Sample Delayed Signal x[n-1]');
xlabel('Sample n'); ylabel('Amplitude');
xticks(nDelayed); grid on;
saveas(gcf, 'delayed_signal.png');

fprintf('Part 1: original samples x = ');
disp(x);
fprintf('Part 1: delayed samples xDelayed = ');
disp(xDelayed);

%% Part 2: System y[n] = 0.5*x[n] + 0.5*x[n-1]
b = [0.5 0.5];
a = 1;

% The appended zero allows the final nonzero output at n = 3 to be shown.
xInput = [x 0];
y = filter(b, a, xInput);
nOutput = 0:length(y)-1;

figure(3);
subplot(2,1,1);
stem(nOutput, xInput, 'filled');
title('Input x[n] (with final zero)');
xlabel('Sample n'); ylabel('Amplitude');
xticks(nOutput); grid on;

subplot(2,1,2);
stem(nOutput, y, 'filled');
title('Output y[n] for H(z) = 0.5 + 0.5z^{-1}');
xlabel('Sample n'); ylabel('Amplitude');
xticks(nOutput); grid on;
saveas(gcf, 'output_signal.png');

fprintf('Part 2: output samples for b = [0.5 0.5] = ');
disp(y);

%% Task 6: Change the system to H(z) = 0.8 + 0.2z^(-1)
bNew = [0.8 0.2];
yNew = filter(bNew, a, xInput);

figure(4);
subplot(2,1,1);
stem(nOutput, y, 'filled');
title('Original System: H(z) = 0.5 + 0.5z^{-1}');
xlabel('Sample n'); ylabel('Amplitude');
xticks(nOutput); ylim([0 2]); grid on;

subplot(2,1,2);
stem(nOutput, yNew, 'filled');
title('Modified System: H(z) = 0.8 + 0.2z^{-1}');
xlabel('Sample n'); ylabel('Amplitude');
xticks(nOutput); ylim([0 2]); grid on;
saveas(gcf, 'modified_output_comparison.png');

fprintf('Task 6: output samples for b = [0.8 0.2] = ');
disp(yNew);

fprintf('\nPNG figures saved in the current MATLAB folder.\n');
