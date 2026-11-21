%% Tire Stud Detector - MATLAB Image Processing Assignment
% Input images (download from the assignment page):
%   studded_tire.jpeg
%   summer_tire.jpg
%
% Requires Image Processing Toolbox. The thresholds below are starting
% values; calibrate them after inspecting the two supplied images.

clear; clc; close all;

%% Settings to adjust after viewing the images
imageFiles = {'studded_tire.jpeg', 'summer_tire.jpg'};
resizeFactor         = 0.50;
brightThreshold      = 0.42;   % grayscale intensity on 0...1 scale
localContrastMinimum = 0.07;   % bright spot relative to local background
minA                 = 4;      % smallest accepted component (pixels)
maxA                 = 120;    % largest accepted component (pixels)
minCirc              = 0.60;   % 4*pi*area/perimeter^2
maxEcc               = 0.85;   % 0: circular, near 1: elongated
studCountThreshold   = 10;     % more than 10 -> STUDDED TIRE

% Use script folder for inputs and saved outputs when possible.
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
outputDir = fullfile(scriptDir, 'results');
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

reportPath = fullfile(outputDir, 'tire_stud_measurements.txt');
reportID = fopen(reportPath, 'w');
if reportID < 0, error('Could not create %s', reportPath); end
fprintf(reportID, 'Tire stud detection (heuristic, uncalibrated)\n');
fprintf(reportID, 'Image | Candidates | Accepted studs | Tire pixels | Studs/10000 pixels | Classification\n');

%% Process both images
for i = 1:numel(imageFiles)
    fileName = imageFiles{i};
    inputPath = fullfile(scriptDir, fileName);
    if ~isfile(inputPath)
        inputPath = fileName; % also search current MATLAB folder
    end
    if ~isfile(inputPath)
        fclose(reportID);
        error(['Image not found: %s. Download it from Moodle and upload it ' ...
               'to the folder containing tire_stud_detector.m.'], fileName);
    end

    %% 1) Read and resize
    I = imread(inputPath);
    I = imresize(I, resizeFactor);

    %% 2) Convert to grayscale
    if size(I, 3) == 3
        Igray = im2double(rgb2gray(I));
    else
        Igray = im2double(I);
    end

    %% 3) Isolate dark tire region
    % Otsu plus a small margin provides a starting threshold when the
    % tire is dark and the background is bright. Inspect this mask.
    smoothed = imgaussfilt(Igray, 0.65);
    tireThreshold = min(0.88, max(0.50, graythresh(smoothed) + 0.10));
    tireMask = smoothed < tireThreshold;
    tireMask = imclose(tireMask, strel('disk', 7, 0));
    tireMask = imfill(tireMask, 'holes');
    tireMask = bwareaopen(tireMask, max(50, round(numel(tireMask) * 0.003)));
    if any(tireMask(:))
        tireMask = bwareafilt(tireMask, 1); % largest dark region
    else
        warning('No dark tire region was detected in %s.', fileName);
    end
    % Remove a narrow edge band to reduce false detections at its outline.
    innerTireMask = imerode(tireMask, strel('disk', 2, 0));

    %% 4) Candidate bright spots inside the tire
    % White top-hat highlights bright details smaller than the disk.
    localBrightSpots = imtophat(smoothed, strel('disk', 7, 0));
    cand = (smoothed > brightThreshold) & ...
           (localBrightSpots > localContrastMinimum) & innerTireMask;
    cand = bwareaopen(cand, 2);
    cand = imclose(cand, strel('disk', 1, 0));

    %% 5) Connected components and shape measurements
    CC = bwconncomp(cand, 8);
    stats = regionprops(CC, 'Area', 'Perimeter', 'Eccentricity', ...
                       'PixelIdxList', 'Centroid');

    %% 6) Keep small round objects
    studMask = false(size(cand));
    studCount = 0;
    for k = 1:numel(stats)
        area = stats(k).Area;
        perimeter = stats(k).Perimeter;
        circularity = (4 * pi * area) / max(perimeter^2, eps);
        eccentricity = stats(k).Eccentricity;

        if area >= minA && area <= maxA && ...
           circularity >= minCirc && eccentricity <= maxEcc
            studMask(stats(k).PixelIdxList) = true;
            studCount = studCount + 1;
        end
    end

    %% 7) Heuristic decision
    tireArea = nnz(tireMask);
    studDensity = 1e4 * studCount / max(tireArea, 1);
    isStudded = studCount > studCountThreshold;
    if isStudded
        decision = 'STUDDED TIRE';
    else
        decision = 'NON-STUDDED TIRE';
    end

    %% 8) Display required results and save to PNG
    fig = figure('Name', fileName, 'Color', 'w', ...
                 'Position', [100 100 1300 450]);

    subplot(1, 3, 1);
    imshow(I);
    title(sprintf('Original: %s', fileName), 'Interpreter', 'none');

    subplot(1, 3, 2);
    imshow(cand);
    title(sprintf('Candidate bright spots: %d', CC.NumObjects));

    subplot(1, 3, 3);
    imshow(I);
    hold on;
    visboundaries(studMask, 'Color', 'g', 'LineWidth', 0.7);
    title(sprintf('%s (count = %d)', decision, studCount));
    hold off;

    [~, baseName] = fileparts(fileName);
    saveas(fig, fullfile(outputDir, [baseName '_detection.png']));

    % Additional mask image helps verify the tire-only region.
    imwrite(tireMask, fullfile(outputDir, [baseName '_tire_mask.png']));
    fprintf('%s: %s; candidates = %d; studs = %d; density = %.2f per 10k pixels\n', ...
        fileName, decision, CC.NumObjects, studCount, studDensity);
    fprintf(reportID, '%s | %d | %d | %d | %.2f | %s\n', ...
        fileName, CC.NumObjects, studCount, tireArea, studDensity, decision);
end

fclose(reportID);
fprintf('Results saved to: %s\n', outputDir);
fprintf(['Check candidate masks and accepted detections in both images. ' ...
         'Adjust the thresholds before treating the labels as reliable.\n']);
