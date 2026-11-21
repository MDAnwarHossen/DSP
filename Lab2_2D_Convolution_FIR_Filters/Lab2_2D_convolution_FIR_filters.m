%% Lab 2: 2D Convolution & FIR Filters (Blur, Sharpen, Edges)
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% This script saves seven figures and a measurements file to results/.
% Requires MATLAB Image Processing Toolbox.
% The figures and results must be checked in MATLAB before submission.

close all; clear; clc;

%% 0) Read the image and prepare the output directory
if exist('peppers.png', 'file') == 2
    I0 = imread('peppers.png');
    imageName = 'peppers.png';
elseif exist('cameraman.tif', 'file') == 2
    I0 = imread('cameraman.tif');
    imageName = 'cameraman.tif';
else
    error('No sample image found. Add peppers.png or cameraman.tif to the MATLAB folder.');
end

if size(I0, 3) == 3
    I = im2double(rgb2gray(I0));
else
    I = im2double(I0);
end

resultsDir = fullfile(pwd, 'results');
if exist(resultsDir, 'dir') ~= 7
    mkdir(resultsDir);
end
fprintf('Image: %s | Grayscale size: %d x %d\n', imageName, size(I,1), size(I,2));

%% 1) Delta image and impulse response
% An impulse at the center exposes the filter's spatial impulse response.
delta = zeros(101, 101);
delta(51, 51) = 1;
h_avg = ones(3, 3) / 9;
H_vis = conv2(delta, h_avg, 'same');

f1 = figure('Name', '01: Impulse Response');
imagesc(H_vis);
axis image off;
colorbar;
title('Impulse response of a 3x3 averaging filter');
saveas(f1, fullfile(resultsDir, '01_impulse_response.png'));

%% 2) Low-pass filtering: box vs Gaussian and separability
h_box3 = ones(3, 3) / 9;
h_box7 = ones(7, 7) / 49;
sigma = 1.2;
g1d = fspecial('gaussian', [1 7], sigma);
h_gauss = g1d' * g1d;         % Outer product yields a 7x7 kernel

I_box3 = imfilter(I, h_box3, 'replicate');
I_box7 = imfilter(I, h_box7, 'replicate');
I_gauss = imfilter(I, h_gauss, 'replicate');

% Two one-dimensional passes give the same result to numerical precision.
I_gauss_2pass = imfilter(imfilter(I, g1d, 'replicate'), g1d', 'replicate');
sepDiff = max(abs(I_gauss(:) - I_gauss_2pass(:)));

f2 = figure('Name', '02: Low-Pass Comparison');
montage({I, I_box3, I_box7, I_gauss}, 'Size', [1 4]);
title('Original | Box 3x3 | Box 7x7 | Gaussian 7x7, sigma=1.2');
saveas(f2, fullfile(resultsDir, '02_blur_box_vs_gaussian.png'));

%% 3) Unsharp masking: sharpen by restoring high-frequency detail
I_blur = I_gauss;
mask = I - I_blur;             % Signed residual (high-frequency component)
gain = 1.0;
I_sharp = max(min(I + gain * mask, 1), 0);

f3 = figure('Name', '03: Unsharp Masking');
% mat2gray(mask) is ONLY for display; the signed mask is used for sharpening.
montage({I, I_blur, mat2gray(mask), I_sharp}, 'Size', [1 4]);
title('Original | Gaussian blur | High-frequency mask (display scaled) | Sharpened');
saveas(f3, fullfile(resultsDir, '03_unsharp_masking.png'));

%% 4) Sobel and Laplacian edge operators
% The Sobel kernel from fspecial is the y-direction derivative kernel.
h_sobel_y = fspecial('sobel');
h_sobel_x = h_sobel_y';
Gx = imfilter(I, h_sobel_x, 'replicate');
Gy = imfilter(I, h_sobel_y, 'replicate');
Gmag = hypot(Gx, Gy);
h_lap = fspecial('laplacian', 0.2);
I_lap = imfilter(I, h_lap, 'replicate');

f4 = figure('Name', '04: Edge Detection');
montage({mat2gray(Gx), mat2gray(Gy), mat2gray(Gmag), mat2gray(I_lap)}, 'Size', [1 4]);
title('Sobel Gx | Sobel Gy | Gradient magnitude | Laplacian (each display scaled)');
saveas(f4, fullfile(resultsDir, '04_edge_detection.png'));

%% 5) Convolution vs correlation: kernel flipping
% conv2 and imfilter(...,'conv') should agree under zero padding.
C1 = conv2(I, h_box3, 'same');
C2 = imfilter(I, h_box3, 'conv', 'same');
diffVal = max(abs(C1(:) - C2(:)));

% The symmetric average kernel looks the same after a 180-degree flip.
% Use an asymmetric kernel to visibly distinguish convolution/correlation.
h_asym = [0 0 0; 0 0 0; 1 2 0] / 3;
C_asym = imfilter(I, h_asym, 'conv', 'same');
R_asym = imfilter(I, h_asym, 'corr', 'same');
asymDiff = max(abs(C_asym(:) - R_asym(:)));

f5 = figure('Name', '05: Convolution vs Correlation');
montage({mat2gray(C_asym), mat2gray(R_asym), ...
         mat2gray(abs(C_asym - R_asym))}, 'Size', [1 3]);
title('Asymmetric kernel: Convolution | Correlation | Absolute difference (scaled)');
saveas(f5, fullfile(resultsDir, '05_correlation_vs_convolution.png'));

fprintf('Max |conv2 - imfilter conv| for 3x3 average: %.12g\n', diffVal);
fprintf('Max |convolution - correlation| for asymmetric kernel: %.12g\n', asymDiff);
fprintf('Max |Gaussian 2D - two 1D passes|: %.12g\n', sepDiff);

%% 6) Boundary handling: replicate, symmetric, circular
I_rep = imfilter(I, h_box7, 'replicate');
I_sym = imfilter(I, h_box7, 'symmetric');
I_cir = imfilter(I, h_box7, 'circular');

f6 = figure('Name', '06: Boundary Handling');
montage({I_rep, I_sym, I_cir}, 'Size', [1 3]);
title('Box 7x7 boundaries: replicate | symmetric | circular');
saveas(f6, fullfile(resultsDir, '06_boundary_handling.png'));

% Zoom into upper-left image corner to make border differences easier to see.
cornerSize = min([64, size(I,1), size(I,2)]);
f7 = figure('Name', '07: Boundary Corner Zoom');
montage({I_rep(1:cornerSize,1:cornerSize), ...
         I_sym(1:cornerSize,1:cornerSize), ...
         I_cir(1:cornerSize,1:cornerSize)}, 'Size', [1 3]);
title('Upper-left corner (replicate | symmetric | circular)');
saveas(f7, fullfile(resultsDir, '07_boundary_corner_zoom.png'));

%% 7) Save measured values for the README
reportFile = fullfile(resultsDir, 'lab2_measurements.txt');
fid = fopen(reportFile, 'w');
if fid == -1
    error('Cannot open %s for writing.', reportFile);
end
fprintf(fid, 'Lab 2: 2D Convolution & FIR Filters\n');
fprintf(fid, 'Image: %s\n', imageName);
fprintf(fid, 'Grayscale dimensions: %d x %d\n', size(I,1), size(I,2));
fprintf(fid, 'Gaussian kernel: 7x7, sigma=%.2f\n', sigma);
fprintf(fid, 'Difference: conv2 vs imfilter conv (symmetric 3x3 box): %.12g\n', diffVal);
fprintf(fid, 'Difference: convolution vs correlation (asymmetric kernel): %.12g\n', asymDiff);
fprintf(fid, 'Difference: 2D Gaussian vs two 1D passes: %.12g\n', sepDiff);
fprintf(fid, 'Gaussian arithmetic comparison (naive per pixel): 7x7=49 versus 7+7=14 multiplications.\n');
fclose(fid);

fprintf('\nFinished. Seven PNG figures and lab2_measurements.txt saved in:\n%s\n', resultsDir);
