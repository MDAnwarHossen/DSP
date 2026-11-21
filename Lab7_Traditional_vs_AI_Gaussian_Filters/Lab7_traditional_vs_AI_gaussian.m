%% Lab 7 - Traditional vs AI Gaussian Filters
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Image Processing Toolbox required.
% Deep Learning Toolbox and pretrained DnCNN required for the AI stage.
% Outputs are saved to the 'results' folder in the current directory.

close all; clear; clc;
rng(42, 'twister');            % Repeatable noise for a fair comparison

resultsDir = fullfile(pwd, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% 1. Load image and add Gaussian noise
originalImage = im2double(imread('cameraman.tif'));
if size(originalImage, 3) == 3
    originalImage = rgb2gray(originalImage);
end
noiseSigma = 0.04;
noiseVariance = noiseSigma^2;
noisyImage = imnoise(originalImage, 'gaussian', 0, noiseVariance);

%% 2. Traditional filters: mean, median, Gaussian, adaptive Wiener
meanFiltered = imfilter(noisyImage, fspecial('average', [3 3]), 'replicate');
medianFiltered = medfilt2(noisyImage, [3 3], 'symmetric');
gaussianFiltered = imgaussfilt(noisyImage, 0.7, 'FilterSize', 3, ...
    'Padding', 'replicate');
wienerFiltered = wiener2(noisyImage, [5 5], noiseVariance);

fig1 = figure('Name', 'Traditional filters', 'Color', 'w');
subplot(2, 3, 1); imshow(originalImage);   title('Original');
subplot(2, 3, 2); imshow(noisyImage);      title('Gaussian noise');
subplot(2, 3, 3); imshow(meanFiltered);    title('Mean 3x3');
subplot(2, 3, 4); imshow(medianFiltered);  title('Median 3x3');
subplot(2, 3, 5); imshow(gaussianFiltered);title('Gaussian 3x3');
subplot(2, 3, 6); imshow(wienerFiltered);  title('Wiener 5x5');
saveas(fig1, fullfile(resultsDir, '01_traditional_filters.png'));

%% 3. AI filter: pretrained DnCNN
% If DnCNN cannot be loaded, the script saves traditional results and
% clearly reports the AI comparison as unavailable; no AI numbers are faked.
hasDnCNN = false;
dncnnStatus = 'Not available';
try
    net = denoisingNetwork('DnCNN');
    aiFiltered = im2double(denoiseImage(noisyImage, net));
    aiFiltered = min(max(aiFiltered, 0), 1);
    hasDnCNN = true;
    dncnnStatus = 'Completed';
catch ME
    fprintf(2, '\nDnCNN could not run: %s\n', ME.message);
    fprintf(2, 'Check Deep Learning Toolbox and pretrained DnCNN access.\n');
    dncnnStatus = ['Unavailable: ' ME.message];
end

fig2 = figure('Name', 'Wiener vs DnCNN', 'Color', 'w');
subplot(1, 4, 1); imshow(originalImage); title('Original');
subplot(1, 4, 2); imshow(noisyImage);    title('Gaussian noise');
subplot(1, 4, 3); imshow(wienerFiltered);title('Wiener');
subplot(1, 4, 4);
if hasDnCNN
    imshow(aiFiltered); title('AI - DnCNN');
else
    axis off;
    text(0.5, 0.5, 'DnCNN not available', 'HorizontalAlignment', 'center', ...
        'Units', 'normalized', 'FontSize', 11);
    title('AI - not completed');
end
saveas(fig2, fullfile(resultsDir, '02_wiener_vs_dncnn.png'));

%% 4. Measure MSE, PSNR, and SSIM against the same original image
methodNames = {'Noisy'; 'Mean 3x3'; 'Median 3x3'; 'Gaussian 3x3'; 'Wiener 5x5'};
filteredImages = {noisyImage, meanFiltered, medianFiltered, ...
    gaussianFiltered, wienerFiltered};
if hasDnCNN
    methodNames{end+1, 1} = 'AI DnCNN';
    filteredImages{end+1} = aiFiltered;
end

numMethods = numel(methodNames);
MSE = zeros(numMethods, 1);
PSNR = zeros(numMethods, 1);
SSIM = zeros(numMethods, 1);
for k = 1:numMethods
    currentImage = filteredImages{k};
    MSE(k) = immse(currentImage, originalImage);
    PSNR(k) = psnr(currentImage, originalImage);
    SSIM(k) = ssim(currentImage, originalImage);
end

resultsTable = table(methodNames, MSE, PSNR, SSIM, ...
    'VariableNames', {'Method', 'MSE', 'PSNR_dB', 'SSIM'});
disp('--- Image Quality Metrics Comparison ---');
disp(resultsTable);

fid = fopen(fullfile(resultsDir, 'lab7_measurements.txt'), 'w');
if fid == -1
    error('Could not create results/lab7_measurements.txt');
end
fprintf(fid, 'Lab 7 - Traditional vs AI Gaussian Filters\n');
fprintf(fid, 'Image: cameraman.tif\n');
fprintf(fid, 'Gaussian noise sigma: %.4f; variance: %.6f\n', ...
    noiseSigma, noiseVariance);
fprintf(fid, 'Random seed: 42 (twister)\n');
fprintf(fid, 'DnCNN status: %s\n\n', dncnnStatus);
fprintf(fid, '%-15s  %12s  %12s  %10s\n', 'Method', 'MSE', 'PSNR (dB)', 'SSIM');
for k = 1:numMethods
    fprintf(fid, '%-15s  %12.7f  %12.4f  %10.5f\n', ...
        methodNames{k}, MSE(k), PSNR(k), SSIM(k));
end
fclose(fid);

%% 5. Visualize PSNR and SSIM comparisons
fig3 = figure('Name', 'Quality metrics', 'Color', 'w');
subplot(1, 2, 1);
bar(PSNR);
set(gca, 'XTick', 1:numMethods, 'XTickLabel', methodNames);
xtickangle(35); ylabel('PSNR (dB)'); title('Higher PSNR is better'); grid on;
subplot(1, 2, 2);
bar(SSIM);
set(gca, 'XTick', 1:numMethods, 'XTickLabel', methodNames);
xtickangle(35); ylabel('SSIM'); title('Higher SSIM is better'); grid on;
saveas(fig3, fullfile(resultsDir, '03_quality_metrics.png'));

fprintf('\nSaved three PNG figures and lab7_measurements.txt in:\n%s\n', resultsDir);
if ~hasDnCNN
    fprintf('AI result is NOT complete until DnCNN runs successfully.\n');
end
