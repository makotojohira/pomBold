% 2019 11 05
% Delete cells contacting image border, repeat filtering, and return image.
function [BW1c] = ClearBorder(BW1b,FN1a)
% 2019 10 24
% See if I can remove objects touching the border
BW1c = imclearborder(BW1b,8);

% Now repeat the filtering of small bright spots within cells - but now I
% am seeing noise outside of cells.  I can filter sizes larger now so
% increase from 600 pixels in previous block... try double
BW1c = bwareaopen(BW1c,1200);

figure('Numbertitle', 'off','Name','Function: ClearBorder.m');
imshow(BW1c);
title(FN1a, 'Interpreter', 'none');

clearvars -except BW1c
