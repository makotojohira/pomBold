% 2019 11 05
% Filter out small regions of noise, invert so cell interiors are white,
% and return clean inverted image.
function [BW1b] = InverseBW(BW1, FN1a)
% 2019 10 22 - remove small areas less than 600 pixels in area in the cells
bwstart = tic
BW1a = bwareaopen(BW1,600);
bw1time = toc(bwstart)

% 2019 10 22 - now I want to reverse the image so cells are white
BW1b = imcomplement(BW1a);
bw2time = toc(bwstart)

figure('Numbertitle', 'off','Name','Function: InverseBW.m');
imshow(BW1b);
title(FN1a, 'Interpreter', 'none');
bw3time = toc(bwstart)

% 2019 11 12 - remove small areas again with a similar filtering size as
% before - but this should eliminate small background regions or other
% regions that are not cells
BW1b = bwareaopen(BW1b,600);

figure('Numbertitle', 'off','Name','Function: InverseBW.m and bwareaopen');
imshow(BW1b);
title(FN1a, 'Interpreter', 'none');

clearvars -except BW1a BW1b
