function [R1a R2a R3a FN1a FN2a FN3a] = ImportImage(dvfile,R1,n)

% Import BF image, convert to grayscale, and return/save image.
% The 1st image must be BF.  The 2nd and 3rd must be fluorescent images.  
% Segment on the BF image, specifically using the halo around each cell.

% Since we are specifying microscopy images in which cells are reliably
% surrounded by a bright halo, we will sharpen the image to emphasize that
% halo which we will use in later steps to segment each cell.  Will not do
% that for the fluorescent images.

R1a = imsharpen(R1{1,1});
R1a = mat2gray(R1a);
FN1a = [dvfile(1:end-3) '_1'];
figure('Numbertitle', 'off','Name','Function: ImportImage');
imshow(R1a);
title(FN1a, 'Interpreter', 'none');


%R2a = mat2gray(R1{2,1});
R2a = R1{2,1};
FN2a = [dvfile(1:end-3) '_2'];
figure('Numbertitle', 'off','Name','Function: ImportImage');
imshow(mat2gray(R2a));
title(FN2a, 'Interpreter', 'none');


FN3a = [];
R3a = [];
if n == 3
    R3a = R1{3,1};
    FN3a = [dvfile(1:end-3) '_3'];
    figure('Numbertitle', 'off','Name','Function: ImportImage');
    imshow(mat2gray(R3a));
    title(FN3a, 'Interpreter', 'none');
end


clearvars -except R1 R1a R2a R3a FN1a FN2a FN3a
