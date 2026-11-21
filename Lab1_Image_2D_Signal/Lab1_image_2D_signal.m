%% Lab 1: Image as a 2D Signal
% Sampling, Quantization, Histograms, and Enhancement
% -----------------------------------------------------
% This script follows the supplied Lab 1 sections (0-6).
% It creates figures in the results/ folder and prints basic measurements.
% Requires the Image Processing Toolbox.
% Tested conceptually; please run and verify the figures in MATLAB.

close all; clear; clc;

% Save all exported figures alongside the script when possible.
scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder)
    scriptFolder = pwd;
end
resultsFolder = fullfile(scriptFolder, 'results');
if ~exist(resultsFolder, 'dir')
    mkdir(resultsFolder);
end

%% 0) Load and inspect an image
if exist('peppers.png', 'file')
    sourceName = 'peppers.png';
    I_rgb = imread(sourceName);
elseif exist('cameraman.tif', 'file')
    sourceName = 'cameraman.tif (grayscale replicated as RGB)';
    grayFallback = imread('cameraman.tif');
    I_rgb = repmat(grayFallback, 1, 1, 3);
else
    error(['Neither peppers.png nor cameraman.tif was found. ', ...
           'Add one to the Current Folder or to the MATLAB path.']);
end

fig0a = figure('Name','Original RGB image');
imshow(I_rgb); title('Original RGB image');
saveas(fig0a, fullfile(resultsFolder, '00_original_rgb.png'));

% Convert to grayscale.
if size(I_rgb, 3) == 3
    I = rgb2gray(I_rgb);
else
    I = I_rgb;
end
fig0b = figure('Name','Grayscale image');
imshow(I); title('Grayscale image');
saveas(fig0b, fullfile(resultsFolder, '00_grayscale.png'));

% Use I(:) to inspect *all* pixel values.
fprintf('Image: %s\n', sourceName);
fprintf('Class: %s | Range: [%g, %g] | Size: %d x %d\n', ...
    class(I), double(min(I(:))), double(max(I(:))), size(I,1), size(I,2));

%% 1) Quantization and dynamic range
% Original 8-bit representation (assuming uint8 sample images).
I8 = I;
I6 = uint8(floor(double(I) / 4) * 4);    % 64 possible levels (~6-bit)
I4 = uint8(floor(double(I) / 16) * 16);  % 16 possible levels (~4-bit)

fig1 = figure('Name','Quantization');
montage({I8, I6, I4}, 'Size', [1 3]);
title('Quantization: 8-bit | ~6-bit | ~4-bit');
saveas(fig1, fullfile(resultsFolder, '01_quantization.png'));

fprintf('Levels present: original=%d, ~6-bit=%d, ~4-bit=%d\n', ...
    numel(unique(I8(:))), numel(unique(I6(:))), numel(unique(I4(:))));

%% 2) Histogram and contrast stretching
I_norm = mat2gray(I);                        % Map min and max to [0,1]
I_stretch = imadjust(I, [0.2 0.8], [0 1]);  % Piecewise linear with clipping

fig2a = figure('Name','Histograms');
subplot(1,2,1); imhist(I); title('Histogram: original');
subplot(1,2,2); imhist(I_stretch); title('Histogram: stretched');
saveas(fig2a, fullfile(resultsFolder, '02_histograms.png'));

fig2b = figure('Name','Contrast comparison');
montage({I, im2uint8(I_norm), im2uint8(I_stretch)}, 'Size', [1 3]);
title('Original | Normalized | Contrast-stretched');
saveas(fig2b, fullfile(resultsFolder, '02_contrast_stretching.png'));

%% 3) Gamma correction: nonlinear intensity transformation
I_gamma_low  = imadjust(I, [], [], 0.6);  % gamma < 1 brightens
I_gamma_high = imadjust(I, [], [], 1.6);  % gamma > 1 darkens

fig3 = figure('Name','Gamma comparison');
montage({I, I_gamma_low, I_gamma_high}, 'Size', [1 3]);
title('Original | Gamma = 0.6 (brighter) | Gamma = 1.6 (darker)');
saveas(fig3, fullfile(resultsFolder, '03_gamma_correction.png'));

%% 4) Sampling and aliasing: downsample then upsample
scale = 0.1;
I_small = imresize(I, scale, 'nearest');
I_back  = imresize(I_small, size(I), 'nearest');

fig4 = figure('Name','Sampling and resizing');
montage({I, I_small, I_back}, 'Size', [1 3]);
title('Original | 10% nearest-neighbor | Upscaled with nearest-neighbor');
saveas(fig4, fullfile(resultsFolder, '04_sampling_and_resizing.png'));
fprintf('Image size: original=%dx%d, downsampled=%dx%d, restored=%dx%d\n', ...
    size(I,1), size(I,2), size(I_small,1), size(I_small,2), size(I_back,1), size(I_back,2));

%% 5) OPTIONAL: Moire demonstration
% If you have a striped or other high-frequency texture image, repeat
% Section 4 with that image and compare it to a properly anti-aliased resize.
% Note: pixelation from nearest-neighbor upscaling alone is not proof of
% aliasing; false patterns or frequencies are stronger evidence.

%% 6) Short reflections: answer using your MATLAB outputs
% 1) Bit-depth: ~6-bit yields at most 64 possible values and ~4-bit yields
%    at most 16, so reduced bit-depth may introduce banding/posterization.
% 2) Contrast stretching maps the interval 0.2 to 0.8 across the output
%    range, clipping lower/higher values. Check the histograms for changes.
% 3) Downsampling without proper low-pass prefiltering can fold spatial
%    high frequencies into lower frequencies (aliasing, per Nyquist).
%    Nearest-neighbor upscaling also makes pixels visibly blocky.

fprintf('\nFinished: inspect PNG files in %s\n', resultsFolder);
