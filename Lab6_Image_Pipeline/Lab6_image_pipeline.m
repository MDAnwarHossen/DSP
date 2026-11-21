%% Lab 6: Mini Project - Your Image Pipeline
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Goal: Denoise, enhance, detect edges and inspect low-pass filtering.
% Requirement: Put your own image beside this script and update imageFile.

close all; clear; clc;

%% 1) Select an image and define the processing problem
imageFile = 'mountain-landscape.jpg';
if ~isfile(imageFile)
    error(['Image not found: ', imageFile, newline, ...
        'Upload your own JPG or PNG to the same MATLAB folder, ', ...
        'then update imageFile near the top of this script.']);
end

I0 = imread(imageFile);
if size(I0,3) == 3
    I = im2double(rgb2gray(I0));
else
    I = im2double(I0);
end
[M,N] = size(I);
if min(M,N) < 7
    error('Choose an image of at least 7 x 7 pixels.');
end

outDir = 'results';
if ~exist(outDir,'dir')
    mkdir(outDir);
end

%% 2) Noise removal (nonlinear median filtering)
I_filt = medfilt2(I,[3 3],'symmetric');

%% 3) Contrast enhancement (intensity remapping)
I_enh = imadjust(I_filt,[0.2 0.8],[0 1]);

%% 4) Feature extraction (Canny edges)
edgeMap = edge(I_enh,'Canny',[0.1 0.25]);

%% 5) Optional frequency-domain ideal low-pass filter
% Cutoff is a radius measured in FFT frequency bins.
Fshift = fftshift(fft2(I_enh));
u = -floor(N/2):ceil(N/2)-1;
v = -floor(M/2):ceil(M/2)-1;
[U,V] = meshgrid(u,v);
D = hypot(U,V);
D0 = 60;
H = double(D < D0);
I_lp = real(ifft2(ifftshift(Fshift .* H)));
% Clip only for display/image saving, not for frequency computation.
I_lp_view = max(0,min(1,I_lp));

%% 6) Save screenshots/figures for README
imwrite(I,fullfile(outDir,'01_original.png'));
imwrite(max(0,min(1,I_filt)),fullfile(outDir,'02_denoised.png'));
imwrite(max(0,min(1,I_enh)),fullfile(outDir,'03_enhanced.png'));
imwrite(edgeMap,fullfile(outDir,'04_canny_edges.png'));
imwrite(I_lp_view,fullfile(outDir,'05_frequency_lowpass.png'));

figure('Name','Lab 6 - Image Pipeline','Color','white','Position',[80 120 1450 350]);
tiledlayout(1,5,'Padding','compact','TileSpacing','compact');
imgSet = {I,I_filt,I_enh,edgeMap,I_lp_view};
titles = {'Original','Median 3x3','Contrast enhanced','Canny edges','Ideal FFT low-pass'};
for k = 1:5
    nexttile;
    imshow(imgSet{k},[]);
    title(titles{k},'Interpreter','none','FontSize',11);
end
exportgraphics(gcf,fullfile(outDir,'06_pipeline_comparison.png'),'Resolution',150);

figure('Name','Lab 6 - Frequency Spectrum','Color','white','Position',[100 100 1000 420]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; imagesc(log(1+abs(Fshift))); axis image off; colormap gray;
title('Centered log-magnitude FFT'); colorbar;
nexttile; imshow(H,[]); title(sprintf('Ideal low-pass mask: D0 = %d bins',D0));
exportgraphics(gcf,fullfile(outDir,'07_fft_spectrum_mask.png'),'Resolution',150);

fprintf('Lab 6 complete. Image: %s (%d x %d pixels)\n',imageFile,M,N);
fprintf('Canny edge pixels: %d (%.2f%%)\n', nnz(edgeMap), 100*nnz(edgeMap)/numel(edgeMap));
fprintf('Frequency low-pass cutoff radius: %d bins\n',D0);
fprintf('Figures saved to: %s\n',outDir);
