%% Lab 3: Frequency-Domain Filtering with fft2
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Corrected and extended lab: matching Gaussian kernels for a fair
% spatial-domain vs FFT-domain convolution comparison.
% Requires: Image Processing Toolbox.
% Output: five PNG figures and results/lab3_measurements.txt.
%
% IMPORTANT: The analytic frequency Gaussian (sigmaFreq=20 frequency bins)
% is NOT the same filter as a 7x7 spatial Gaussian (sigmaSpatial=1.2 pixels).
% Section 5 compares the SAME discrete 7x7 kernel in both domains using
% circular boundaries and psf2otf, so the two outputs should agree.

close all; clear; clc;

resultsDir = 'results';
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% 0) Load an example image
if exist('peppers.png', 'file')
    I0 = imread('peppers.png');
    inputName = 'peppers.png';
elseif exist('cameraman.tif', 'file')
    I0 = imread('cameraman.tif');
    inputName = 'cameraman.tif';
else
    error('Neither peppers.png nor cameraman.tif was found. Add a local image.');
end

if size(I0, 3) == 3
    I = im2double(rgb2gray(I0));
else
    I = im2double(I0);
end
[M, N] = size(I);

%% 1) FFT and centered log-magnitude spectrum
F = fft2(I);
Fshift = fftshift(F);
S = log(1 + abs(Fshift));

figure('Name', 'Lab 3 - Magnitude spectrum', 'Color', 'w');
subplot(1,2,1);
imshow(I, [0 1]);
title('Original grayscale image');
subplot(1,2,2);
imshow(S, []);
title('Centered log-magnitude FFT spectrum');
colormap gray;
saveas(gcf, fullfile(resultsDir, '01_spectrum.png'));

%% 2) Create ideal and Gaussian low-pass masks
% D is the radial distance in FFT grid bins after fftshift.
[u, v] = meshgrid(-floor(N/2):(ceil(N/2)-1), ...
                  -floor(M/2):(ceil(M/2)-1));
D = hypot(u, v);
D0 = 40;             % Ideal low-pass cutoff radius (frequency-grid bins)
sigmaFreq = 20;     % Frequency-domain Gaussian width (frequency-grid bins)
H_ideal_LP = double(D <= D0);
H_gauss_LP = exp(-(D.^2) / (2 * sigmaFreq^2));

figure('Name', 'Lab 3 - Frequency-domain masks', 'Color', 'w');
subplot(1,2,1);
imshow(H_ideal_LP, [0 1]);
title(sprintf('Ideal low-pass mask (D0 = %d)', D0));
subplot(1,2,2);
imshow(H_gauss_LP, [0 1]);
title(sprintf('Gaussian mask (sigma = %g bins)', sigmaFreq));
colormap gray;
saveas(gcf, fullfile(resultsDir, '02_frequency_masks.png'));

%% 3) Apply low-pass filters by frequency-domain multiplication
% ifftshift moves zero-frequency components back before inverse FFT.
G_ideal = real(ifft2(ifftshift(H_ideal_LP .* Fshift)));
G_gauss = real(ifft2(ifftshift(H_gauss_LP .* Fshift)));

figure('Name', 'Lab 3 - Low-pass comparison', 'Color', 'w');
subplot(1,3,1);
imshow(I, [0 1]);
title('Original');
subplot(1,3,2);
imshow(G_ideal, [0 1]);
title('Ideal low-pass (ringing near edges)');
subplot(1,3,3);
imshow(G_gauss, [0 1]);
title('Gaussian low-pass (smooth cutoff)');
saveas(gcf, fullfile(resultsDir, '03_lowpass_comparison.png'));

%% 4) Gaussian high-pass filtering (frequency complement)
H_gauss_HP = 1 - H_gauss_LP;
G_hp = real(ifft2(ifftshift(H_gauss_HP .* Fshift)));

figure('Name', 'Lab 3 - High-pass result', 'Color', 'w');
subplot(1,2,1);
imshow(I, [0 1]);
title('Original image');
subplot(1,2,2);
imshow(G_hp, []);   % Scale signed response ONLY for viewing
colorbar;
title('Gaussian high-pass (display scaled)');
saveas(gcf, fullfile(resultsDir, '04_highpass_result.png'));

%% 5) Correct spatial vs frequency Gaussian comparison
% Use one IDENTICAL 7x7 discrete kernel in both methods.
% Use matching CIRCULAR boundaries.  The DFT product implements circular
% convolution; 'replicate' boundaries would not be an exact comparison.
sigmaSpatial = 1.2;                      % Pixels, not frequency-grid bins
h_spatial = fspecial('gaussian', [7 7], sigmaSpatial);
I_spatial = imfilter(I, h_spatial, 'circular', 'conv');
H_matched = psf2otf(h_spatial, [M N]);  % Correct FFT alignment/centering
I_fft_matched = real(ifft2(fft2(I) .* H_matched));
absDifference = abs(I_spatial - I_fft_matched);
maxAbsDifference = max(absDifference(:));
rmseDifference = sqrt(mean(absDifference(:).^2));

figure('Name', 'Lab 3 - Matched Gaussian comparison', 'Color', 'w');
subplot(1,3,1);
imshow(I_spatial, [0 1]);
title('Spatial 7x7 Gaussian (circular)');
subplot(1,3,2);
imshow(I_fft_matched, [0 1]);
title('FFT of SAME 7x7 Gaussian');
subplot(1,3,3);
imshow(absDifference, []);
title(sprintf('Abs. diff (max %.2e; scaled)', maxAbsDifference));
colorbar;
saveas(gcf, fullfile(resultsDir, '05_spatial_vs_fft_gaussian.png'));

%% 6) Save measurements for README verification
fileID = fopen(fullfile(resultsDir, 'lab3_measurements.txt'), 'w');
if fileID < 0
    error('Could not create lab3_measurements.txt in the results folder.');
end
fprintf(fileID, 'Lab 3: Frequency-Domain Filtering with fft2\n');
fprintf(fileID, 'Input: %s\n', inputName);
fprintf(fileID, 'Image dimensions: %d rows x %d columns\n', M, N);
fprintf(fileID, 'Ideal low-pass cutoff radius: %g bins\n', D0);
fprintf(fileID, 'Analytic frequency Gaussian sigma: %g bins\n', sigmaFreq);
fprintf(fileID, 'Matched spatial/FFT Gaussian kernel: 7x7; sigma=%g pixels\n', sigmaSpatial);
fprintf(fileID, 'Boundary condition for matched comparison: circular\n');
fprintf(fileID, 'Maximum absolute difference (matched methods): %.15g\n', maxAbsDifference);
fprintf(fileID, 'RMSE difference (matched methods): %.15g\n', rmseDifference);
fprintf(fileID, 'NOTE: frequency sigma in bins and spatial sigma in pixels are not interchangeable.\n');
fprintf(fileID, 'NOTE: all FFT filters in Sections 2-4 use implicit periodic boundaries.\n');
fclose(fileID);

fprintf('Lab 3 finished. Five PNG figures saved to: %s\n', resultsDir);
fprintf('Image: %s (%d x %d)\n', inputName, M, N);
fprintf('Matched Gaussian maximum absolute difference: %.3e\n', maxAbsDifference);
fprintf('Matched Gaussian RMSE difference: %.3e\n', rmseDifference);
