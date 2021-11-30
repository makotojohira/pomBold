% 2019 11 05
% Apply Otsu's thresholding method, binarize, and return resulting BW
% image.
% 2019 12 02
% Test alternate thresholding and segmenting functions

function [BW1] = ThreshBinarize(R1a, FN1a)

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
THD = adaptthresh(R1a, 0.55, 'NeighborhoodSize', [15 15]);
BW1 = imbinarize(R1a, THD);
% So far this performs best on cells with side illumination improving with 
% neighborhoodsize of 21,21 -> 19,19 -> 17,17 -> 15,15 - improvememnt stops
% at 13,13 - so use 15,15



% Now I want to see what this looks like...

figure('Numbertitle', 'off','Name','Function: ThreshBinarize.m');
imshow(BW1);
title(FN1a, 'Interpreter', 'none');

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


clearvars -except BW1
