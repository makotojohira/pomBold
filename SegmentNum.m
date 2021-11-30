% 2019 11 05
% Repeat segment, apply label matrix color code, number cells, and return 
% image.
% 2019 11 12 remove the small area filter and solidity filter
function [CC,Area,BW1d] = SegmentNum(BW1c,FN1a)

CC      = bwconncomp(BW1c,4);
stats   = regionprops(CC,{'Area' 'Solidity'});
Area    = [stats.Area];
mask    = Area < 500 | Area > 100000;
CC.PixelIdxList(mask) = [];
CC.NumObjects   = length(CC.PixelIdxList);
Area(mask)      = [];
BW1d      = false(size(BW1c));
BW1d(vertcat(CC.PixelIdxList{:})) = true;

labeled = labelmatrix(CC);
RGB_label = label2rgb(labeled,'spring','c','shuffle');

s = regionprops(CC,'centroid');
centroid = cat(1,s.Centroid);
%label = CC.PixelIdxList{1:end};
n = CC.NumObjects;
figure('Numbertitle', 'off','Name','Function: SegmentNum.m');
imshow(RGB_label);
hold on;
%plot(centroid(:,1),centroid(:,2),'b*') % Confirm location of centroids
for n=1:n;
    text(centroid(n,1),centroid(n,2),sprintf('%d',n),'HorizontalAlignment','center');
end
title(FN1a, 'Interpreter', 'none');
hold off;

clearvars -except CC Area BW1d