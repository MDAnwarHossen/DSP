%% Hybrid Traditional + AI Image Classification Pipeline
% Course: Digital Signal Processing - Image Processing
% Traditional segmentation: L*a*b* color space + K-means (2 clusters)
% AI classification: pretrained SqueezeNet
% Run the full script, inspect both predictions, and upload the saved
% screenshots with short explanations to GitHub.
%
% Requirements: Image Processing Toolbox, Deep Learning Toolbox,
% and a pretrained SqueezeNet model accessible in MATLAB.

close all; clear; clc;

%% 1) Load image and pretrained model
imageFile = 'mountain-landscape.jpg';
if ~isfile(imageFile)
    error('Image not found: %s. Upload peppers.png or edit imageFile.', imageFile);
end

I = imread(imageFile);
if size(I,3) ~= 3
    error('An RGB image is required for L*a*b* color segmentation.');
end

outputFolder = 'results';
if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

fprintf('Loading pretrained SqueezeNet...\n');
% imagePretrainedNetwork is recommended for recent MATLAB releases.
% The original squeezenet function is supported as a legacy fallback.
if exist('imagePretrainedNetwork','file') == 2
    [net,classNames] = imagePretrainedNetwork('squeezenet');
    isModern = true;
elseif exist('squeezenet','file') == 2
    net = squeezenet;
    isModern = false;
else
    error(['SqueezeNet is not available. Install/enable Deep Learning ', ...
           'Toolbox and its pretrained SqueezeNet model.']);
end
fprintf('Network loaded.\n');

%% 2) Traditional image segmentation using K-means
fprintf('Segmenting colors with two K-means clusters...\n');
rng(42,'twister');
labImage = rgb2lab(I);
ab = im2single(labImage(:,:,2:3));
labels = imsegkmeans(ab,2);

% For peppers.png, select the cluster whose pixels have the larger mean
% a* channel (red-versus-green axis). Cluster numbers alone have no
% semantic meaning, so we do not assume that label 2 is the desired one.
aChannel = labImage(:,:,2);
meanA = [mean(aChannel(labels==1)), mean(aChannel(labels==2))];
[~,selectedCluster] = max(meanA);
mask = labels == selectedCluster;

isolatedObject = I;
isolatedObject(repmat(~mask,[1 1 3])) = 0;
foregroundPercent = 100*nnz(mask)/numel(mask);

%% 3) Classify original and segmented images using the SAME network
% SqueezeNet expects a 227-by-227 RGB image.
inputHW = [227 227];
originalResized = imresize(I,inputHW);
isolatedResized = imresize(isolatedObject,inputHW);

fprintf('Classifying original and segmented images...\n');
if isModern
    originalScores = predict(net,single(originalResized));
    isolatedScores = predict(net,single(isolatedResized));
    [originalLabel,originalConfidence] = scores2label(originalScores,classNames);
    [isolatedLabel,isolatedConfidence] = scores2label(isolatedScores,classNames);
else
    [originalLabel,originalScores] = classify(net,originalResized);
    [isolatedLabel,isolatedScores] = classify(net,isolatedResized);
    originalConfidence = max(originalScores(:));
    isolatedConfidence = max(isolatedScores(:));
end

originalName = char(string(originalLabel));
isolatedName = char(string(isolatedLabel));
originalPct = 100*double(originalConfidence);
isolatedPct = 100*double(isolatedConfidence);

%% 4) Visualize and save figures
fig1 = figure('Name','Hybrid Traditional and AI Pipeline','Color','w');
subplot(2,2,1); imshow(I); title('1. Original RGB');
subplot(2,2,2); imshow(mask); title(sprintf('2. K-means mask (cluster %d)',selectedCluster));
subplot(2,2,3); imshow(isolatedObject); title('3. Segmented color region');
subplot(2,2,4); imshow(isolatedResized); title('4. Input to AI (227 x 227)');
exportgraphics(fig1,fullfile(outputFolder,'01_hybrid_pipeline.png'),'Resolution',160);

fig2 = figure('Name','Original vs Segmented Classification','Color','w');
subplot(1,2,1); imshow(originalResized);
title(sprintf('Original: %s (%.2f%%)',originalName,originalPct),'Interpreter','none');
subplot(1,2,2); imshow(isolatedResized);
title(sprintf('Segmented: %s (%.2f%%)',isolatedName,isolatedPct),'Interpreter','none');
exportgraphics(fig2,fullfile(outputFolder,'02_classification_comparison.png'),'Resolution',160);

%% 5) Save actual results (never assume segmentation improves accuracy)
fid = fopen(fullfile(outputFolder,'hybrid_measurements.txt'),'w');
if fid == -1
    error('Could not create results/hybrid_measurements.txt');
end
fprintf(fid,'HYBRID TRADITIONAL + AI PIPELINE\n');
fprintf(fid,'Input image: %s\n',imageFile);
fprintf(fid,'Original image size: %d x %d x %d\n',size(I,1),size(I,2),size(I,3));
fprintf(fid,'K-means clusters: 2\n');
fprintf(fid,'Selected color cluster: %d (higher mean Lab a*)\n',selectedCluster);
fprintf(fid,'Selected mask area: %.2f%% of pixels\n',foregroundPercent);
fprintf(fid,'AI model: SqueezeNet, input size 227 x 227\n');
fprintf(fid,'Original image prediction: %s\n',originalName);
fprintf(fid,'Original prediction score: %.4f%%\n',originalPct);
fprintf(fid,'Segmented image prediction: %s\n',isolatedName);
fprintf(fid,'Segmented prediction score: %.4f%%\n',isolatedPct);
fprintf(fid,'Prediction changed: %s\n',mat2str(~strcmp(originalName,isolatedName)));
fprintf(fid,'NOTE: Classification scores are not ground-truth accuracy.\n');
fprintf(fid,'NOTE: A higher score alone does not prove the hybrid method is better.\n');
fclose(fid);

fprintf('\n--- CLASSIFICATION RESULTS ---\n');
fprintf('Original image: %s (%.2f%%)\n',originalName,originalPct);
fprintf('Segmented image: %s (%.2f%%)\n',isolatedName,isolatedPct);
fprintf('Segmentation mask: %.2f%% of pixels\n',foregroundPercent);
fprintf('Saved two figures and measurements in results/.\n');
