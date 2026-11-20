%% Lecture 03 - Discrete-Time Signal Operations and Convolution
% Savonia - Digital Signal Processing
% Assignment source: Lecture 03 Moodle instructions
% Run the entire script. It saves the required PNG figures beside this file.
% Built from the starter code provided in the assignment.

clear;
close all;
clc;

% Fixed random seed so the same noise is used when the script is rerun.
rng(1);

% Save PNGs next to the MATLAB script (not in an unrelated working folder).
scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder)
    scriptFolder = pwd;
end

%% Starter code - create clean and noisy signals
n = 0:100;
clean = sin(0.1*pi*n);
noise = 0.4*randn(size(n));
measured = clean + noise;

figure('Name','Starter - Clean and noisy signals','Color','w');
plot(n,clean,'b-','LineWidth',1.5);
hold on;
plot(n,measured,'Color',[0.6 0.6 0.6],'LineWidth',0.9);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Clean and Noisy Signals');
legend('Clean signal','Noisy signal','Location','best');
hold off;

%% Task 1 - Amplitude scaling
% Doubling the noisy signal doubles every sample value, not its frequency.
scaled = 2*measured;

fig1 = figure('Name','Task 1 - Amplitude scaling','Color','w');
plot(n,measured,'Color',[0.45 0.45 0.45],'LineWidth',1.1);
hold on;
plot(n,scaled,'r-','LineWidth',1.1);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 1: Noisy Signal and Signal Scaled by 2');
legend('Noisy signal','Scaled noisy signal (x2)','Location','best');
hold off;
saveas(fig1,fullfile(scriptFolder,'signal_operations.png'));

%% Task 2 - Signal delay by 5 samples
% Leading zeros keep the original amplitude values and shift their indices.
delay = 5;
delayed = [zeros(1,delay), measured];
n_measured = 0:length(measured)-1;
n_delayed = 0:length(delayed)-1;

fig2 = figure('Name','Task 2 - Signal delay','Color','w');
plot(n_measured,measured,'Color',[0.35 0.35 0.35],'LineWidth',1.1);
hold on;
plot(n_delayed,delayed,'m-','LineWidth',1.1);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 2: Original Noisy Signal and 5-Sample Delay');
legend('Original noisy signal','Delayed noisy signal (5 samples)','Location','best');
hold off;
% Supporting plot for Task 2 (in addition to the three required figures).
saveas(fig2,fullfile(scriptFolder,'signal_delay.png'));

%% Task 3 - Five-point moving-average filter using convolution
% h5 is the impulse response of the five-point averaging filter.
h5 = ones(1,5)/5;
filtered5 = conv(measured,h5,'same');

fig3 = figure('Name','Task 3 - Five-point moving average','Color','w');
plot(n,clean,'b-','LineWidth',1.6);
hold on;
plot(n,measured,'Color',[0.65 0.65 0.65],'LineWidth',0.8);
plot(n,filtered5,'Color',[0 0.55 0.15],'LineWidth',1.5);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 3: Five-Point Moving-Average Filtering');
legend('Clean signal','Noisy signal','Five-point filtered signal', ...
       'Location','best');
hold off;
saveas(fig3,fullfile(scriptFolder,'noise_filtering.png'));

%% Task 4 - Compare five-point and fifteen-point moving averages
h15 = ones(1,15)/15;
filtered15 = conv(measured,h15,'same');

fig4 = figure('Name','Task 4 - Filter comparison','Color','w');
plot(n,clean,'b-','LineWidth',1.6);
hold on;
plot(n,measured,'Color',[0.65 0.65 0.65],'LineWidth',0.8);
plot(n,filtered5,'Color',[0 0.55 0.15],'LineWidth',1.5);
plot(n,filtered15,'m--','LineWidth',1.7);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 4: Comparing 5-Point and 15-Point Moving-Average Filters');
legend('Clean signal','Noisy signal','Five-point filtered', ...
       'Fifteen-point filtered','Location','best');
hold off;
saveas(fig4,fullfile(scriptFolder,'filter_comparison.png'));

%% Numerical checks (additional verification information)
rmseNoisy = sqrt(mean((measured-clean).^2));
rmse5 = sqrt(mean((filtered5-clean).^2));
rmse15 = sqrt(mean((filtered15-clean).^2));

fprintf('\nLecture 03: Script completed.\n');
fprintf('Clean/noisy samples: %d | delayed samples: %d\n', ...
    length(measured),length(delayed));
fprintf('RMSE to clean sine (noisy):    %.5f\n',rmseNoisy);
fprintf('RMSE to clean sine (5-point):  %.5f\n',rmse5);
fprintf('RMSE to clean sine (15-point): %.5f\n',rmse15);
fprintf('Saved in folder: %s\n',scriptFolder);
fprintf('  signal_operations.png\n');
fprintf('  signal_delay.png (extra supporting plot)\n');
fprintf('  noise_filtering.png\n');
fprintf('  filter_comparison.png\n');
