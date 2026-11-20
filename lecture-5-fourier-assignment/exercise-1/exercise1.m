%% Exercise 1 - Build a square wave from odd harmonics
% Savonia Lecture 5 - Fourier Assignment
% Run this script and inspect all four subplots before describing them.
clear; clc; close all;

% Each value is the highest odd harmonic included in the approximation.
H_values = [1 3 9 25];
t = linspace(-1, 1, 4000);

figure('Name','Exercise 1 - Square Wave Comparisons','Color','w');
for i = 1:length(H_values)
    H = H_values(i);
    x = zeros(size(t));

    % Fourier-series approximation using odd harmonics only.
    for k = 1:2:H
        x = x + (4/pi)*sin(2*pi*k*t)/k;
    end

    subplot(2,2,i);
    plot(t, x, 'LineWidth', 1.2);
    grid on;
    xlim([-1 1]);
    ylim([-1.5 1.5]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Highest odd harmonic H = %d',H));
end

% Save next to this script, even when you launched it from another folder.
scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
saveas(gcf, fullfile(scriptFolder,'square-wave-comparison.png'));
disp('Saved square-wave-comparison.png');
