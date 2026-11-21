%% Lab 4: Noise and Filtering
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
%
% This script creates reproducible noisy images, applies mean, Gaussian,
% and median filters, computes reference-based MSE and SNR, and exports
% five figures plus a text file with the measured values.
%
% Requirement: MATLAB Image Processing Toolbox.
% This is a standalone script. Run from the folder containing this .m file.

close all; clear; clc;
rng(42,'twister');  % Reproducible noise for this MATLAB run

resultsDir = fullfile(pwd, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% 0) Load and inspect the grayscale image
if exist('peppers.png', 'file')
    originalRGB = imread('peppers.png');
    inputName = 'peppers.png';
elseif exist('cameraman.tif', 'file')
    originalRGB = imread('cameraman.tif');
    inputName = 'cameraman.tif (grayscale fallback)';
else
    error('No sample image found. Add peppers.png or cameraman.tif to the MATLAB folder.');
end

if size(originalRGB, 3) == 3
    I = im2double(rgb2gray(originalRGB));
else
    I = im2double(originalRGB);
end
fprintf('Input: %s | Image size: %d x %d | Data type: %s\n', ...
    inputName, size(I,1), size(I,2), class(I));

%% 1) Model common noise types
% Gaussian noise with mean 0 and variance 0.01
I_gauss = imnoise(I, 'gaussian', 0, 0.01);
% Salt-and-pepper noise corrupting approximately 5%% of pixels
I_sp = imnoise(I, 'salt & pepper', 0.05);

f = figure('Color','w','Position',[100 100 1400 480]);
tiledlayout(1,3,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I); title('Original grayscale image');
nexttile; imshow(I_gauss); title('Gaussian noise (variance = 0.01)');
nexttile; imshow(I_sp); title('Salt-and-pepper noise (density = 0.05)');
exportgraphics(f,fullfile(resultsDir,'01_noise_types.png'),'Resolution',170);

%% 2) Prepare mean, Gaussian, and median filters
h_mean = fspecial('average', [3 3]);
h_gaussian = fspecial('gaussian', [3 3], 0.7);

% Symmetric boundary extension is used consistently for fair comparison.
I_mean_gauss = imfilter(I_gauss, h_mean, 'symmetric', 'same');
I_mean_sp = imfilter(I_sp, h_mean, 'symmetric', 'same');
I_gaussian_gauss = imfilter(I_gauss, h_gaussian, 'symmetric', 'same');
I_gaussian_sp = imfilter(I_sp, h_gaussian, 'symmetric', 'same');
I_median_gauss = medfilt2(I_gauss, [3 3], 'symmetric');
I_median_sp = medfilt2(I_sp, [3 3], 'symmetric');

%% 3) Compare filter outputs for salt-and-pepper noise
f = figure('Color','w','Position',[100 100 1400 750]);
tiledlayout(2,3,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I); title('Clean reference');
nexttile; imshow(I_sp); title('Salt-and-pepper noisy');
nexttile; imshow(I_mean_sp); title('Mean 3x3');
nexttile; imshow(I_gaussian_sp); title('Gaussian 3x3, sigma 0.7');
nexttile; imshow(I_median_sp); title('Median 3x3');
nexttile; imshow(abs(I_median_sp - I),[]); title('Absolute median error (scaled)');
exportgraphics(f,fullfile(resultsDir,'02_salt_pepper_filter_comparison.png'),'Resolution',170);

%% 4) Compare filter outputs for Gaussian noise
f = figure('Color','w','Position',[100 100 1400 750]);
tiledlayout(2,3,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I); title('Clean reference');
nexttile; imshow(I_gauss); title('Gaussian noisy');
nexttile; imshow(I_mean_gauss); title('Mean 3x3');
nexttile; imshow(I_gaussian_gauss); title('Gaussian 3x3, sigma 0.7');
nexttile; imshow(I_median_gauss); title('Median 3x3');
nexttile; imshow(abs(I_gaussian_gauss - I),[]); title('Absolute Gaussian-filter error (scaled)');
exportgraphics(f,fullfile(resultsDir,'03_gaussian_filter_comparison.png'),'Resolution',170);

%% 5) Compute MSE and reference-based SNR for both noise types
% For an estimate J and clean image I:
%    MSE = mean((J(:) - I(:)).^2)
%    SNR (dB) = 10*log10(mean(I(:).^2) / MSE)
% Here SNR uses the known clean image as the desired signal.
% It is not peak signal-to-noise ratio (PSNR).

methods = {'No filter','Mean 3x3','Gaussian 3x3','Median 3x3'};
gaussOutputs = {I_gauss,I_mean_gauss,I_gaussian_gauss,I_median_gauss};
spOutputs = {I_sp,I_mean_sp,I_gaussian_sp,I_median_sp};
metrics = zeros(4,4);  % columns: Gaussian MSE, S&P MSE, Gaussian SNR, S&P SNR
referencePower = mean(I(:).^2);

for k = 1:4
    mseGauss = immse(gaussOutputs{k}, I);
    mseSP = immse(spOutputs{k}, I);
    metrics(k,:) = [mseGauss, mseSP, ...
        10*log10(referencePower / max(mseGauss,eps)), ...
        10*log10(referencePower / max(mseSP,eps))];
end

fprintf('\n%-16s | %13s | %13s | %14s | %14s\n', ...
    'Method','Gaussian MSE','S&P MSE','Gaussian SNR','S&P SNR');
fprintf('%s\n', repmat('-',1,85));
for k = 1:4
    fprintf('%-16s | %13.7f | %13.7f | %11.2f dB | %11.2f dB\n', ...
        methods{k},metrics(k,1),metrics(k,2),metrics(k,3),metrics(k,4));
end

%% 6) Plot numerical quality metrics
f = figure('Color','w','Position',[100 100 1450 610]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile;
bar(metrics(:,1:2));
set(gca,'XTick',1:4,'XTickLabel',{'None','Mean','Gaussian','Median'});
ylabel('MSE (lower is better)'); title('MSE compared with clean image');
legend('Gaussian noise','Salt-and-pepper noise','Location','best'); grid on;
nexttile;
bar(metrics(:,3:4));
set(gca,'XTick',1:4,'XTickLabel',{'None','Mean','Gaussian','Median'});
ylabel('SNR (dB; higher is better)'); title('Reference-based SNR');
legend('Gaussian noise','Salt-and-pepper noise','Location','best'); grid on;
exportgraphics(f,fullfile(resultsDir,'04_quality_metrics.png'),'Resolution',170);

%% 7) Zoom into a consistent image region to inspect detail preservation
[M,N] = size(I);
r = max(1,round(M*0.3)):min(M,round(M*0.65));
c = max(1,round(N*0.3)):min(N,round(N*0.65));
f = figure('Color','w','Position',[100 100 1350 610]);
tiledlayout(1,5,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I(r,c)); title('Clean detail');
nexttile; imshow(I_gauss(r,c)); title('Gaussian noise');
nexttile; imshow(I_mean_gauss(r,c)); title('Mean 3x3');
nexttile; imshow(I_gaussian_gauss(r,c)); title('Gaussian 3x3');
nexttile; imshow(I_median_gauss(r,c)); title('Median 3x3');
exportgraphics(f,fullfile(resultsDir,'05_detail_preservation.png'),'Resolution',170);

%% 8) Save actual measured numbers to a text file
measurementFile = fullfile(resultsDir,'lab4_measurements.txt');
fid = fopen(measurementFile,'w');
if fid < 0
    error('Unable to write results/lab4_measurements.txt.');
end
fprintf(fid,'Lab 4 - Noise and Filtering (MATLAB measurements)\n');
fprintf(fid,'Input image: %s\n',inputName);
fprintf(fid,'Image size: %d x %d\n',size(I,1),size(I,2));
fprintf(fid,'Random seed: 42 (twister)\n');
fprintf(fid,'Gaussian noise: mean=0, variance=0.01\n');
fprintf(fid,'Salt-and-pepper noise density: 0.05\n');
fprintf(fid,'Mean filter: 3x3; Gaussian filter: 3x3, sigma=0.7; Median filter: 3x3\n');
fprintf(fid,'All filters use symmetric boundary handling.\n');
fprintf(fid,'MSE = mean((estimate-clean).^2); SNR=10log10(mean(clean.^2)/MSE).\n\n');
fprintf(fid,'%-16s | %13s | %13s | %14s | %14s\n', ...
    'Method','Gaussian MSE','S&P MSE','Gaussian SNR','S&P SNR');
for k = 1:4
    fprintf(fid,'%-16s | %13.7f | %13.7f | %11.2f dB | %11.2f dB\n', ...
        methods{k},metrics(k,1),metrics(k,2),metrics(k,3),metrics(k,4));
end
fprintf(fid,'\nUse these values to update README.md after verifying plots.\n');
fclose(fid);

fprintf('\nSaved 5 PNG figures and measurements to: %s\n',resultsDir);
