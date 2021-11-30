% 2020 01 26
% Tried tophat filtering and single-threshold methods - but went back to
% the for loop.  I did implement post-treshold morphological operators like
% imfill and imopen.

% 2019 12 28
% First use segmented cells as masks to isolate cellular FITC signal and
% set background to zero - thus eliminating all extraneous signals. Then
% use multithresholding to set cell background to zero and thus isolate
% nuclear signal above background.

% First use segmented cells as masks to isolate cellular FITC signal and
% set background to zero - thus eliminating all extraneous signals. Then
% use multithresholding to set cell background to zero and thus isolate
% nuclear signal above background.  But found a way to individually segment
% nuclei from threshold calculated for each cell.  Probably not most
% efficient way to do this but used a for loop to do this cell by cell.

% NOTES - this works well for bright nuclei - but not so well with
% low-intensity nuclei (small cells).

function [BW2,THD] = NuclearThreshBinarize(CC,BW1e,R2a,FN2a)

nucthreshstart = tic

figure;
imshow(mat2gray(R2a));

nuc1time = toc(nucthreshstart)

numCells = length(CC.PixelIdxList);

R2a = mat2gray(R2a);  % Convert R2a to grayscale from 0 to 1 range

% Create a matrix of threshold values for each cell
BW1 = zeros(size(R2a));
BW2 = zeros(size(R2a));
centroidlist1(1:numCells,2) = zeros;

for n = 1:numCells;
    cell = false(size(BW1e));  % each time blank the image area
    cell(CC.PixelIdxList{n}) = true;  % each time display a new cell by index
    R2maskN = R2a;  % assign FITC image to a working variable
    R2maskN(~cell) = 0;  % keep only the FITC data within the indexed cell
    R2maskN1 = R2maskN(R2maskN > 0); % Only consider individual masked cell area for thresholding
    THD = graythresh(R2maskN1);  % Use Otsu's method to threshold the nuclei within the cell perimeter
    BW2 = imbinarize(R2maskN, THD);  % Now apply threshold to the FITC image of the cell - this should identify the nuclei within the cell
    BW2 = imfill(BW2, 'holes');
    BW2 = imopen(BW2, ones(5,5));
    BW2 = bwareaopen(BW2, 200);
    BW1 = BW1 + BW2;  % Build up the BW image of all the nuclei one by one
    s2 = regionprops(BW2,'centroid');  % Obtain region properties (centroid) for the nuclear BW thresholded image
    centroidlist1(n,:) = s2.Centroid;  % Build list of centroid X,Y locations
end
nuc2time = toc(nucthreshstart)

BW2 = BW1;

% Now I want to see what this looks like...
%figure('Numbertitle', 'off','Name','Function: NuclearThreshBinarize.m');
%imshow(BW2);
%title(FN2a, 'Interpreter', 'none');
%nuc3time = toc(nucthreshstart)

% BW2 = imfill(BW2, 'holes');
% BW2 = imopen(BW2, ones(5,5));
% BW2 = bwareaopen(BW2, 200);
figure('Numbertitle', 'off','Name','Function: NuclearThreshBinarize.m - cleanup');
imshow(BW2);
hold on;
for n=1:numCells;
    text(centroidlist1(n,1),centroidlist1(n,2),sprintf('%d',n),'HorizontalAlignment','center');
end
title(FN2a, 'Interpreter', 'none');
drawnow;
hold off;
nuc4time = toc(nucthreshstart)


BWones = ones(size(R2a));
figure('Numbertitle', 'off','Name','Function: NuclearThreshBinarize.m - cleanup');
imshow(BWones);
hold on;
for n=1:numCells;
    text(centroidlist1(n,1),centroidlist1(n,2),sprintf('%d',n),'HorizontalAlignment','center');
end
title(FN2a, 'Interpreter', 'none');
drawnow;
hold off;
nuc5time = toc(nucthreshstart)

clearvars -except BW2 THD

% This is the original threshold and binarize code:
%THD = 0.9*graythresh(R1a);

%BW1 = im2bw(R1a,THD);


%THD = 1
% Try active contour from here: https://www.mathworks.com/help/images/ref/activecontour.html
%mask = zeros(size(R1a));
%mask(25:end-25,25:end-25) = 1;
%figure
%imshow(mask)
%title('Initial Contour Location')
%BW1 = activecontour(R1a, mask, 500, 'edge');

% Try adaptthresh from here: https://www.mathworks.com/help/images/ref/adaptthresh.html
%THD = adaptthresh(R1a, 0.35);
%BW1 = imbinarize(R1a,THD);

% Try averagefilter.m from here:
% https://www.mathworks.com/matlabcentral/fileexchange/40854-bradley-local-image-thresholding
% BW1 = averagefilter(R1a, [3 3])

% Try bradley thresholding from here:
% https://www.mathworks.com/matlabcentral/fileexchange/40854-bradley-local-image-thresholding
%BW1 = bradley(R1a, [50 50], 0)
% larger value of window in bradley appears to work better - but stalls
% when I put in values of [20000 20000]
% Also smaller values approaching 0 of T work better - appears equivalent
% to Otsu's method

% Try imbinarize with adaptive thresholding per: https://www.mathworks.com/help/images/ref/imbinarize.html
%BW1 = imbinarize(R1a, 'adaptive', 'Sensitivity', 0.55)
% A tiny bit better on cells with more side illumination - adding
% sensitivity of 0.55 makes it a tiny bit better still on cells with side
% illumination - note this adaptive thresholding is the bradley method

% Try adaptivethresh from here: https://www.mathworks.com/help/images/ref/adaptthresh.html
%THD = adaptthresh(R1a, 0.55, 'NeighborhoodSize', [15 15])
%BW1 = imbinarize(R1a, THD)
% So far this performs best on cells with side illumination improving with 
% neighborhoodsize of 21,21 -> 19,19 -> 17,17 -> 15,15 - improvememnt stops
% at 13,13 - so use 15,15


% Try a k-means segmenting method from here:
% https://www.mathworks.com/help/images/ref/imsegkmeans.html
%THD = 1
%k = 2
%wavelength = 2.^(0:5) * 3;
%orientation = 0:45:135;
%g = gabor(wavelength,orientation);
%R1b = mat2gray(R1a);
%gabormag = imgaborfilt(R1b,g);
%montage(gabormag,'Size',[4 6])

%for i = 1:length(g)
%    sigma = 0.5*g(i).Wavelength;
%    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),3*sigma); 
%end
%montage(gabormag,'Size',[4 6])

%nrows = size(R1a,1);
%ncols = size(R1a,2);
%[X,Y] = meshgrid(1:ncols,1:nrows);

%featureSet = cat(3,R1a,gabormag,X,Y);

%L2 = imsegkmeans(featureSet,2,'NormalizeInput',true);
%C = labeloverlay(R1a,L2);
%imshow(C)
%title('Labeled Image with Additional Pixel Information')

%L = imsegkmeans(R1a,k)
%BW1 = labeloverlay(R1a,L)


% Try some of the other segmenting methods from here:
% https://www.mathworks.com/help/images/image-segmentation.html?s_tid=CRUX_lftnav

% Try watershed method from here: https://www.mathworks.com/help/images/ref/watershed.html
%L = watershed(R1a)
%BW1 = labeloverlay(R1a,L)




% 2019 10 24
% To try and assign background and halo to the same bright background, play
% with THD = min(0.9*graythresh(R1c),prctile(R1c(:),99.5)).  Start with the 
% graythresh multiplier.  I'm not happy with how noise in the cell 
% increases even tho I am able to get the background and halo to both be
% assigned as white and cells as mostly black (but with increased white
% noise inside.  This is with a multiplier of 0.75.  When I use a
% multiplier of 0.99, the cells are mostly black with much reduced noise
% which I can remove with the filtering step in the next block of code.
% Try to use concavity as a filter.  When I execute the next couple blocks
% I find that some cells are removed since the thresholding is too high at
% 0.99.  At 0.99 I lose a background area assigned as cell - but I lose
% cells where the halo is not robust and continuous.  Stick with 0.9
% multiplier for graythresh.

