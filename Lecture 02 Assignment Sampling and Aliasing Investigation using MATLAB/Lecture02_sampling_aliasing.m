%% Lecture 02 - Sampling and Aliasing Investigation
% Savonia / Digital Signal Processing
% Tasks 1 and 2: 10 Hz sine wave and five sampling frequencies.
%
% Run this entire script in MATLAB. It saves the required six PNG figures
% next to this .m file. No additional toolboxes are needed.
%
% IMPORTANT: Review the graphs yourself, including the unusual 20 Hz case.

clear; clc; close all;

%% Settings
signalFrequency = 10;             % Hz: original signal frequency
signalDuration = 1;               % seconds
referenceFrequency = 10000;      % dense reference points per second
samplingFrequencies = [15 20 25 50 100]; % Hz, required in Task 2

% Save the images in the folder containing this script.
scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder)
    scriptFolder = pwd;
end

%% Task 1: Create a dense approximation of a continuous 10 Hz sine wave
% Include t = 1 s in the drawn reference curve; actual sampled records
% below use the one-second interval 0 <= t < 1 s.
tReference = 0:1/referenceFrequency:signalDuration;
xReference = sin(2*pi*signalFrequency*tReference);

figure('Name','Original 10 Hz Sine Signal','Color','w', ...
       'Position',[100 100 950 420]);
plot(tReference,xReference,'b-','LineWidth',1.6);
title('Original 10 Hz sine wave (1 second)');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 signalDuration]);
ylim([-1.2 1.2]);
grid on;
legend('10 Hz reference sine','Location','northeast');
saveas(gcf,fullfile(scriptFolder,'original_signal.png'));

%% Task 2: Sample the same signal at five sampling frequencies
fprintf('\nLECTURE 02 - SAMPLING AND ALIASING\n');
fprintf('Original signal frequency: %.0f Hz\n',signalFrequency);
fprintf('Duration: %.0f second\n',signalDuration);
fprintf('Nyquist rate: %.0f Hz\n\n',2*signalFrequency);
fprintf('%9s %12s %14s %16s\n', ...
        'Fs (Hz)','Period (ms)','Sample count','Samples/cycle');

for k = 1:numel(samplingFrequencies)
    fs = samplingFrequencies(k);
    sampleIndices = 0:(round(fs*signalDuration)-1);
    tSamples = sampleIndices/fs;
    xSamples = sin(2*pi*signalFrequency*tSamples);

    % Treat floating-point roundoff at exact zero crossings as zero.
    xSamples(abs(xSamples) < 1e-12) = 0;

    fprintf('%9.0f %12.3f %14d %16.2f\n', ...
             fs,1000/fs,numel(xSamples),fs/signalFrequency);

    figure('Name',sprintf('Sampling at %d Hz',fs),'Color','w', ...
           'Position',[100 100 950 420]);
    plot(tReference,xReference,'b-','LineWidth',1.4);
    hold on;
    stem(tSamples,xSamples,'r','filled','LineWidth',1.0,'MarkerSize',5);
    hold off;
    title(sprintf('10 Hz sine wave sampled at %d Hz',fs));
    xlabel('Time (s)');
    ylabel('Amplitude');
    xlim([0 signalDuration]);
    ylim([-1.2 1.2]);
    grid on;
    legend('Reference 10 Hz sine','Sample points','Location','northeast');
    saveas(gcf,fullfile(scriptFolder,sprintf('sampling_%dHz.png',fs)));
end

%% Task 3: Nyquist calculation and observations
nyquistRate = 2*signalFrequency;
fprintf('\nTask 3: fs >= 2*f_max = 2*%.0f = %.0f Hz (theoretical boundary).\n', ...
        signalFrequency,nyquistRate);
fprintf('15 Hz: under-sampling; 10 Hz appears as a 5 Hz alias.\n');
fprintf('20 Hz: exactly at the boundary; this zero-phase sine samples to zero.\n');
fprintf('25, 50, 100 Hz: above the Nyquist rate for this 10 Hz component.\n');
fprintf('Review your graphs before copying observations into README.md.\n');
fprintf('\nFiles were saved in:\n%s\n',scriptFolder);
