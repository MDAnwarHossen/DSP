%% Lecture 6 - Practical Digital Filtering Assignment
% Savonia - Parts A and B (one runnable MATLAB script)
% Requires: MATLAB + Signal Processing Toolbox (fir1, butter, freqz, filtfilt)
% Generates figures and numerical results in the 'results' folder.
% IMPORTANT: Run this file yourself, inspect figures, and report actual results.

clear; clc; close all;
outDir = fullfile(pwd, 'results');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Part A - Filter a synthetic sensor signal
FsSensor = 1000;                         % Sampling rate in Hz
t = (0:1/FsSensor:2-1/FsSensor)';      % 2 seconds, column vector
rng(7);                                 % Reproducible random noise
clean = sin(2*pi*5*t) + 0.35*sin(2*pi*12*t);
noise = 0.35*sin(2*pi*50*t) + 0.20*sin(2*pi*137*t) ...
      + 0.25*randn(size(t));
x = clean + noise;

fc = 20;                                % Low-pass cutoff in Hz
bFIR = fir1(60, fc/(FsSensor/2), 'low'); % 60th order, 61 taps
[bIIR, aIIR] = butter(4, fc/(FsSensor/2), 'low');
yFIR = filtfilt(bFIR, 1, x);           % Offline, zero-phase filtering
yIIR = filtfilt(bIIR, aIIR, x);

rmseNoisy = sqrt(mean((x-clean).^2));
rmseFIR   = sqrt(mean((yFIR-clean).^2));
rmseIIR   = sqrt(mean((yIIR-clean).^2));

fprintf('\nPART A - SENSOR FILTERING\n');
fprintf('Sample rate = %.0f Hz, cutoff = %.0f Hz\n', FsSensor, fc);
fprintf('FIR order = 60, FIR taps = %d; IIR Butterworth order = 4\n', numel(bFIR));
fprintf('RMSE, noisy signal: %.6f\n', rmseNoisy);
fprintf('RMSE, FIR output:  %.6f\n', rmseFIR);
fprintf('RMSE, IIR output:  %.6f\n', rmseIIR);

% Figure A1 - 0.2 seconds on identical time and amplitude axes.
idxShort = t >= 0 & t <= 0.2;
partsA = {clean, x, yFIR, yIIR};
titlesA = {'Clean sensor signal', 'Noisy sensor signal', ...
           'FIR output (filtfilt)', 'IIR output (filtfilt)'};
fig = figure('Color', 'w', 'Name', 'A1 Sensor time-domain comparison');
for k = 1:4
    subplot(2,2,k);
    thisSignal = partsA{k};
    plot(t(idxShort), thisSignal(idxShort), 'LineWidth', 1.1);
    grid on; title(titlesA{k});
    xlabel('Time (s)'); ylabel('Amplitude');
    xlim([0 0.2]); ylim([-2.5 2.5]);
end
saveas(fig, fullfile(outDir, 'sensor_time_comparison.png'));

% Figure A2 - one-pass frequency responses of the two designs.
% filtfilt applies the filter forward and backward, so its net magnitude
% response is approximately the SQUARE of the one-pass magnitude response.
[HFIR, fResp] = freqz(bFIR, 1, 8192, FsSensor);
[HIIR, ~] = freqz(bIIR, aIIR, 8192, FsSensor);
fig = figure('Color', 'w', 'Name', 'A2 Low-pass filter responses');
plot(fResp, 20*log10(max(abs(HFIR), 1e-10)), 'LineWidth', 1.3);
hold on;
plot(fResp, 20*log10(max(abs(HIIR), 1e-10)), 'LineWidth', 1.3);
xline(fc, '--k', '20 Hz cutoff');
grid on; xlim([0 200]); ylim([-120 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Single-pass frequency response (freqz)');
legend('FIR order 60', 'Butterworth IIR order 4', 'Location', 'southwest');
saveas(fig, fullfile(outDir, 'sensor_filter_responses.png'));

% Figure A3 - single-sided amplitude spectra (same axis for fair comparison).
[fSpec, Pnoisy] = oneSidedSpectrum(x, FsSensor);
[~, PFIR] = oneSidedSpectrum(yFIR, FsSensor);
[~, PIIR] = oneSidedSpectrum(yIIR, FsSensor);
fig = figure('Color', 'w', 'Name', 'A3 Sensor spectra');
plot(fSpec, Pnoisy, 'LineWidth', 1.1); hold on;
plot(fSpec, PFIR, 'LineWidth', 1.1);
plot(fSpec, PIIR, 'LineWidth', 1.1);
for fMark = [5 12 50 137]
    xline(fMark, ':', sprintf('%g Hz', fMark));
end
grid on; xlim([0 170]);
xlabel('Frequency (Hz)'); ylabel('Single-sided amplitude');
title('Noisy, FIR and IIR sensor spectra');
legend('Noisy', 'FIR', 'IIR', 'Location', 'northeast');
saveas(fig, fullfile(outDir, 'sensor_spectra.png'));

% Figure A4 - RMSE as a directly comparable numerical summary.
fig = figure('Color', 'w', 'Name', 'A4 Sensor RMSE');
bar([rmseNoisy, rmseFIR, rmseIIR]); grid on;
set(gca, 'XTick', 1:3, 'XTickLabel', {'Noisy', 'FIR', 'IIR'});
ylabel('RMSE (signal amplitude units)');
title('RMSE relative to the known clean sensor signal');
saveas(fig, fullfile(outDir, 'sensor_rmse.png'));

%% Part B - Remove controlled 50 Hz hum from the Handel audio example
% load handel provides variables y (audio samples) and Fs (sample rate).
% If MATLAB reports that handel is missing, consult your course instructor
% about an approved audio recording before substituting other data.
load handel;
xClean = y(:);
FsAudio = Fs;
clear y Fs;
tAudio = (0:numel(xClean)-1)'/FsAudio;

% Add exactly the controlled hum specified in the assignment.
hum = 0.15*sin(2*pi*50*tAudio);
xHum = xClean + hum;

% Compare two second-order Butterworth band-stop filter designs.
[bNarrow, aNarrow] = butter(2, [49 51]/(FsAudio/2), 'stop');
[bWide, aWide] = butter(2, [45 55]/(FsAudio/2), 'stop');
yNarrow = filtfilt(bNarrow, aNarrow, xHum);
yWide = filtfilt(bWide, aWide, xHum);

% Because the injected hum is known, its residual can be measured by
% filtering the known hum alone. This avoids confusing natural audio
% energy at ~50 Hz with the injected interference.
humNarrow = filtfilt(bNarrow, aNarrow, hum);
humWide   = filtfilt(bWide, aWide, hum);
complex50 = exp(-1i*2*pi*50*tAudio);
Naudio = numel(tAudio);
ampBefore = 2/Naudio * abs(sum(hum .* complex50));
ampAfterNarrow = 2/Naudio * abs(sum(humNarrow .* complex50));
ampAfterWide   = 2/Naudio * abs(sum(humWide .* complex50));
attNarrow = 20*log10(max(ampAfterNarrow,eps)/max(ampBefore,eps));
attWide = 20*log10(max(ampAfterWide,eps)/max(ampBefore,eps));

% A separate distortion measure relative to the known unmodified audio.
% Do not treat this metric alone as a perceptual audio-quality score.
rmseAudioNarrow = sqrt(mean((yNarrow-xClean).^2));
rmseAudioWide = sqrt(mean((yWide-xClean).^2));

fprintf('\nPART B - AUDIO HUM REDUCTION\n');
fprintf('Handel audio sample rate = %.0f Hz, duration = %.2f seconds\n', ...
        FsAudio, numel(xClean)/FsAudio);
fprintf('Injected hum amplitude estimate at 50 Hz: %.6f\n',ampBefore);
fprintf('Residual injected hum, narrow 49-51 Hz: %.8f (%.2f dB)\n', ...
        ampAfterNarrow, attNarrow);
fprintf('Residual injected hum, wide 45-55 Hz:   %.8f (%.2f dB)\n', ...
        ampAfterWide, attWide);
fprintf('Audio RMSE vs clean, narrow: %.6f\n',rmseAudioNarrow);
fprintf('Audio RMSE vs clean, wide:   %.6f\n',rmseAudioWide);

% Figure B1 - same time and amplitude axes for all four waveforms.
tStart = 0.5;
idxAudio = tAudio >= tStart & tAudio <= tStart + 0.12;
partsB = {xClean, xHum, yNarrow, yWide};
titlesB = {'Clean audio', 'Audio with 50 Hz hum', ...
           'Filtered: narrow 49-51 Hz', 'Filtered: wide 45-55 Hz'};
maxY = max(abs([xClean(idxAudio); xHum(idxAudio); ...
                yNarrow(idxAudio); yWide(idxAudio)]));
fig = figure('Color', 'w', 'Name', 'B1 Audio waveform comparison');
for k = 1:4
    subplot(2,2,k);
    thisSignal = partsB{k};
    plot(tAudio(idxAudio), thisSignal(idxAudio), 'LineWidth', 0.9);
    grid on; title(titlesB{k});
    xlabel('Time (s)'); ylabel('Amplitude');
    xlim([tStart tStart+0.12]); ylim(1.05*[-maxY maxY]);
end
saveas(fig, fullfile(outDir, 'audio_waveform_comparison.png'));

% Figure B2 - low-frequency spectra before/after hum reduction.
[fAudio, PClean] = oneSidedSpectrum(xClean, FsAudio);
[~, PHum] = oneSidedSpectrum(xHum, FsAudio);
[~, PNarrow] = oneSidedSpectrum(yNarrow, FsAudio);
[~, PWide] = oneSidedSpectrum(yWide, FsAudio);
fig = figure('Color', 'w', 'Name', 'B2 Audio low-frequency spectra');
plot(fAudio, PClean, 'LineWidth', 1.1); hold on;
plot(fAudio, PHum, 'LineWidth', 1.1);
plot(fAudio, PNarrow, 'LineWidth', 1.1);
plot(fAudio, PWide, 'LineWidth', 1.1);
xline(50, '--k', '50 Hz hum');
grid on; xlim([0 150]);
xlabel('Frequency (Hz)'); ylabel('Single-sided amplitude');
title('Audio spectra near the 50 Hz hum');
legend('Clean audio','Hum added','Narrow filter','Wide filter', ...
       'Location','northeast');
saveas(fig, fullfile(outDir, 'audio_spectrum.png'));

% Figure B3 - band-stop filter comparison, one-pass magnitudes.
[HNarrow, fNotch] = freqz(bNarrow, aNarrow, 16384, FsAudio);
[HWide, ~] = freqz(bWide, aWide, 16384, FsAudio);
fig = figure('Color', 'w', 'Name', 'B3 Notch frequency responses');
plot(fNotch,20*log10(max(abs(HNarrow),1e-10)),'LineWidth',1.2); hold on;
plot(fNotch,20*log10(max(abs(HWide),1e-10)),'LineWidth',1.2);
xline(50,'--k','50 Hz');
grid on; xlim([30 70]); ylim([-90 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Single-pass narrow and wide stop-band responses');
legend('49-51 Hz notch','45-55 Hz notch','Location','southwest');
saveas(fig, fullfile(outDir, 'audio_notch_responses.png'));

%% Write measurements to a file for the report
summaryPath = fullfile(outDir, 'measured_results.txt');
fid = fopen(summaryPath, 'w');
assert(fid~=-1, 'Could not create results file in the working directory.');
fprintf(fid, 'LECTURE 6 - MATLAB MEASUREMENTS\n');
fprintf(fid, 'Generated when lecture6_filtering.m was run in MATLAB.\n\n');
fprintf(fid, 'PART A (sensor; Fs=%.0f Hz, cutoff=%.0f Hz)\n',FsSensor,fc);
fprintf(fid, 'FIR taps: %d; IIR order: 4\n', numel(bFIR));
fprintf(fid, 'RMSE noisy: %.8f\nRMSE FIR: %.8f\nRMSE IIR: %.8f\n\n', ...
        rmseNoisy,rmseFIR,rmseIIR);
fprintf(fid, 'PART B (audio; Fs=%.0f Hz)\n',FsAudio);
fprintf(fid, 'Added 50 Hz hum amplitude estimate: %.8f\n',ampBefore);
fprintf(fid, 'Residual narrow notch: %.8f; attenuation: %.2f dB\n', ...
        ampAfterNarrow,attNarrow);
fprintf(fid, 'Residual wide notch: %.8f; attenuation: %.2f dB\n', ...
        ampAfterWide,attWide);
fprintf(fid, 'Audio RMSE narrow vs clean: %.8f\n',rmseAudioNarrow);
fprintf(fid, 'Audio RMSE wide vs clean: %.8f\n',rmseAudioWide);
fprintf(fid, '\nCaution: Listening results must be entered from your own comparison.\n');
fclose(fid);

fprintf('\nSaved seven PNG files and measured_results.txt in:\n%s\n',outDir);
fprintf('NEXT: Inspect each figure; listen to hum-added and filtered audio\n');
fprintf('at the SAME playback gain; fill report with actual results.\n');

% OPTIONAL, run these commands separately in the Command Window if sound
% playback is supported by your MATLAB setup. Same gain for every sample:
% commonGain = 0.9/max(abs([xHum; yNarrow; yWide]));
% sound(xHum*commonGain, FsAudio);       % hum-added version
% sound(yNarrow*commonGain, FsAudio);    % narrow filter version
% sound(yWide*commonGain, FsAudio);      % wider filter version
% Play the examples ONE AT A TIME, not simultaneously.

%% Local helper - one-sided Fourier amplitude spectrum
function [freq, P1] = oneSidedSpectrum(signal, fs)
    signal = signal(:);
    N = numel(signal);
    P2 = abs(fft(signal))/N;
    nPositive = floor(N/2) + 1;
    P1 = P2(1:nPositive);
    if rem(N,2) == 0
        if nPositive > 2
            P1(2:end-1) = 2*P1(2:end-1);
        end
    else
        if nPositive > 1
            P1(2:end) = 2*P1(2:end);
        end
    end
    freq = (0:nPositive-1)'*(fs/N);
end
