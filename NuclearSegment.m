% 2019 12 28
% After binarizing now segment nuclei similar to how cells were segmented -
% but use different size filtering parameters

% Segment, apply label matrix color code, and return image for nuclei.

function [CC2, BW2a] = NuclearSegment(BW2,FN2a)
% This next block of code I believe is key to the functionality of
% detectnuc.m.
% 2019 10 22 - I modified stats.Solidity from <0.90 to <0.25 and that made
% a huge difference in picking up larger cells - but this picked up
% branched cells so I set it at <0.5 and this seemed to find a happy
% balance.  I also changed the mask to Area <150 and >a ratio (see below).
% 2019 11 12 remove the small area filter and solidity filter
% 2021 04 02 ratio nuc/cell filtering is already occuring in the
% NuclearCellFilter function - so don't filter for large size nuclei here
% - only for small nuclei (modify filter to only remove <155)

CC2      = bwconncomp(BW2,4);
stats   = regionprops(CC2,{'Area' 'Solidity'});
NucArea    = [stats.Area];
mask    = NucArea < 155;
CC2.PixelIdxList(mask) = [];
CC2.NumObjects   = length(CC2.PixelIdxList);
NucArea(mask)      = [];
BW2a      = false(size(BW2));
BW2a(vertcat(CC2.PixelIdxList{:})) = true;

% Now to visualize the segmenting step above:
labeled = labelmatrix(CC2);
RGB_label2 = label2rgb(labeled,'spring','c','shuffle');
figure('Numbertitle', 'off','Name','Function: NuclearSegment.m');
imshow(RGB_label2);
title(FN2a, 'Interpreter', 'none');

clearvars -except CC2 BW2a

% Use label2rgb to choose the colormap, the background color, and how 
% objects in the label matrix map to colors in the colormap. In the 
% pseudocolor image, the label identifying each object in the label matrix 
% maps to a different color in an associated colormap matrix.
