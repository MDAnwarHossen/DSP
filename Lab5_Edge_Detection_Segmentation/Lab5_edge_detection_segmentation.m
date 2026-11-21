%% Lab 5: Edge Detection and Segmentation
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Outputs: five assignment figures, one optional histogram, and a text summary.
% Requirements: MATLAB with Image Processing Toolbox.
% Run this script, inspect the figures, and use your own results in README.md.

close all; clear; clc;

%% 0) Load image and prepare output directory
if exist('peppers.png','file') == 2
    sourceName = 'peppers.png';
elseif exist('cameraman.tif','file') == 2
    sourceName = 'cameraman.tif';
else
    error('Neither peppers.png nor cameraman.tif was found. Add a local image.');
end

I0 = imread(sourceName);
if size(I0,3) == 3
    I0 = rgb2gray(I0);
end
I = im2double(I0);

resultsDir = fullfile(pwd, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

fprintf('Lab 5 | Source: %s | Image: %d x %d pixels\n', ...
    sourceName, size(I,1), size(I,2));

%% 1) Gradient-based edge detection: Sobel and Prewitt
edges_sobel = edge(I, 'Sobel');
edges_prewitt = edge(I, 'Prewitt');

f1 = figure('Color','w', 'Position',[100 100 1080 490]);
tiledlayout(1,2, 'TileSpacing','compact','Padding','compact');
nexttile; imshow(edges_sobel); title('Sobel edges');
nexttile; imshow(edges_prewitt); title('Prewitt edges');
exportgraphics(f1, fullfile(resultsDir,'01_sobel_vs_prewitt.png'), 'Resolution',180);

%% 2) Canny edge detector (smoothing, gradient, thinning, hysteresis)
% Threshold pair [low high] is from the provided exercise.
edges_canny = edge(I, 'Canny', [0.05 0.2]);

f2 = figure('Color','w','Position',[100 100 780 575]);
imshow(edges_canny);
title('Canny edges (thresholds 0.05 and 0.20)');
exportgraphics(f2, fullfile(resultsDir,'02_canny_edges.png'), 'Resolution',180);

%% 3) Laplacian of Gaussian (LoG): smoothed zero-crossings
edges_log = edge(I, 'log');

f3 = figure('Color','w','Position',[100 100 780 575]);
imshow(edges_log);
title('Laplacian of Gaussian (LoG) edges');
exportgraphics(f3, fullfile(resultsDir,'03_log_edges.png'), 'Resolution',180);

%% 4) Otsu global intensity thresholding and segmentation
level = graythresh(I);
BW = imbinarize(I, level);

f4 = figure('Color','w','Position',[100 100 1080 490]);
tiledlayout(1,2, 'TileSpacing','compact','Padding','compact');
nexttile; imshow(I); title('Original grayscale image');
nexttile; imshow(BW); title(sprintf('Otsu binary mask (level %.4f)',level));
exportgraphics(f4, fullfile(resultsDir,'04_otsu_threshold.png'), 'Resolution',180);

%% 5) Connected-component labeling of the binary mask
% With 8-connectivity, diagonal neighbors count as connected.
[L, numRegions] = bwlabel(BW, 8);
RGB = label2rgb(L);

f5 = figure('Color','w','Position',[100 100 780 575]);
imshow(RGB);
title(sprintf('Otsu-mask connected regions (8-connected): %d',numRegions));
exportgraphics(f5, fullfile(resultsDir,'05_labeled_regions.png'), 'Resolution',180);

%% Optional evidence for explaining Otsu: grayscale histogram
f6 = figure('Color','w','Position',[100 100 900 520]);
imhist(I);
hold on;
xline(level, 'r--', sprintf('Otsu threshold = %.4f',level), ...
    'LineWidth',2, 'LabelVerticalAlignment','middle');
hold off;
title('Grayscale intensity histogram and Otsu threshold');
xlabel('Normalized intensity'); ylabel('Pixel count');
exportgraphics(f6, fullfile(resultsDir,'06_histogram_otsu.png'), 'Resolution',180);

%% Record actual numerical measurements for the GitHub README
pixels = numel(I);
sobelCount = nnz(edges_sobel);
prewittCount = nnz(edges_prewitt);
cannyCount = nnz(edges_canny);
logCount = nnz(edges_log);
foregroundCount = nnz(BW);

reportPath = fullfile(resultsDir, 'lab5_measurements.txt');
fid = fopen(reportPath, 'w');
if fid == -1
    error('Cannot create %s',reportPath);
end
fprintf(fid, 'LAB 5 - Edge Detection and Segmentation\n');
fprintf(fid, 'Image: %s\n',sourceName);
fprintf(fid, 'Dimensions: %d x %d\n',size(I,1),size(I,2));
fprintf(fid, 'Total pixels: %d\n',pixels);
fprintf(fid, 'Sobel edge pixels: %d (%.2f%%)\n',sobelCount,100*sobelCount/pixels);
fprintf(fid, 'Prewitt edge pixels: %d (%.2f%%)\n',prewittCount,100*prewittCount/pixels);
fprintf(fid, 'Canny edge pixels: %d (%.2f%%)\n',cannyCount,100*cannyCount/pixels);
fprintf(fid, 'LoG edge pixels: %d (%.2f%%)\n',logCount,100*logCount/pixels);
fprintf(fid, 'Otsu threshold (normalized): %.8f\n',level);
fprintf(fid, 'Foreground pixels in Otsu mask: %d (%.2f%%)\n', ...
    foregroundCount,100*foregroundCount/pixels);
fprintf(fid, '8-connected foreground regions: %d\n',numRegions);
fprintf(fid, 'Important: these intensity-based connected components are NOT necessarily distinct objects.\n');
fclose(fid);

fprintf('Sobel %d | Prewitt %d | Canny %d | LoG %d edge pixels\n', ...
    sobelCount,prewittCount,cannyCount,logCount);
fprintf('Otsu level: %.4f | 8-connected foreground regions: %d\n', ...
    level,numRegions);
fprintf('Saved 6 PNGs and lab5_measurements.txt in: %s\n',resultsDir);

%% 6) Short reflection prompts - answer using your actual outputs
% A) Which operator gives the thinnest, cleanest edges on your image?
%    Compare 01_sobel_vs_prewitt.png, 02_canny_edges.png, and 03_log_edges.png.
% B) Why can Canny outperform simple gradient filters?
%    Discuss smoothing, non-maximum suppression and dual-threshold hysteresis.
% C) How does Otsu relate to the intensity histogram?
%    Explain how it chooses a global threshold between intensity classes.
% D) Note: Otsu binarizes image intensities, NOT the Canny or Sobel edge maps.
