% pombEye

% Each column label in the output is preceded by a number and a colon.

% 1: is data from channel 1 (which MUST be a brightfield image)
% 2: is data from channel 2 (which MUST be the main fluorescent image, preferably the experimental channel, often green)
% 3: is optional data from channel 3 (MUST be a fluorescent image, often an internal red control channel)
% 2/2: means channel 2 data masked by nuclei segmented on channel 2
% 2/3: means channel 2 data masked by nuclei segmented on channel 3
% 3/3: means channel 3 data masked by nuclei segmented on channel 3
% 3/2: means channel 3 data masked by nuclei segmented on channel 2


% **IMAGES
% PombeY.m works specifically with images taken on a Deltavision 
% fluorescence microscope imaging system and imports .dv image files with
% multiple channels.

% Furthermore, this program has been specifically developed and tested on
% S. pombe cells imaged in the bright field (BF) mode such that a distinct 
% bright halo defined each cell.  This halo obviously simplifies the 
% segmenting process.

% Image file 2019_09_03_yMO100_27C_1_R3D.dv is an example of a 2-channel
% image that pombEye can process well.

% **MATLAB
% PombeY extensively uses the Matlab image analysis toolbox for many of the
% image manipulation functions, as well as the Bio-Formats toolbox used
% primarily in the dvFileInputs.m function to import the .dv file and split
% them into each channel image and to extract metadata to convert pixel 
% measurements to real units such as micrometers.

% First step is to execute the import and splitting function from 
% dvFileInputs.m and then exporting the individual .tiff image files.

%%
clc        % Clear the command window
clear      % Clear the workspace
close all  % Close all figure windows

tic        % Start timer
[dvfile,R1,n,R] = dvFileInputs;  % Import Deltavision image file

% dvfile contains both image and metadata information from the Deltavision
% file.  Used bfopen function to extract data, image data assigned to R,
% where image data is then split out into R1. R will be used in
% NuclearCellFilter function, R1 will be used by ImportImage function.

dvFiletime = toc  % Output the time to complete the first function

%%
% Import images, sharpen contrast for BF, convert to grayscale, and return
% 2 or 3 images in a given .dv file.
[R1a, R2a, R3a FN1a FN2a FN3a] = ImportImage(dvfile,R1,n);
importImagetime = toc

%%
% Apply Otsu's thresholding method, binarize, and return resulting BW
% image for BF channel.
[BW1] = ThreshBinarize(R1a, FN1a);
threshbintime = toc

%%
% Filter out small regions of noise, invert so cell interiors are white,
% and return clean inverted image.
[BW1b] = InverseBW(BW1, FN1a);
invBWtime = toc

%%
% Delete cells contacting image border, repeat filtering, and return image.
[BW1c] = ClearBorder(BW1b,FN1a);
clearbordertime = toc

%%
% Repeat segment, apply label matrix color code, number cells, and return 
% image.
[CC,Area,BW1d] = SegmentNum(BW1c,FN1a);
segnumtime = toc

%%
% Use convex polygon and aspect ratio to filter out non-cell regions that 
% display significant concavity, and return image.
[CCstats,BW1e] = ConvexFilter(CC,BW1d,FN1a);
convfiltertime = toc

%%
% Repeat segment, apply label matrix color code, number cells, and return 
% image. 
%BW1d = BW1e;
[CC,Area,BW1f] = SegmentNum(BW1e,FN1a);
segnumtime3 = toc

%%
% End of bright field processing.  Now go on to importing and processing
% fluorescent channel(s).

%%
% First use segmented cells as masks to isolate cellular FITC signal and
% set background to zero - thus eliminating all extraneous signals. Then
% individually segment nuclei from threshold calculated for each cell.  

% NOTES - this works well for bright nuclei - but not so well with
% low-intensity nuclei (small cells).

[BW2,THD] = NuclearThreshBinarize(CC,BW1f,R2a,FN2a);
%[BW2, THD] = NuclearThreshBinarizeM(CC, BW1d, R2a, tiffFile2);

nucthreshtime = toc
%%
% Find the background intensity so user might do a background subtraction.
% Usually the intensity with the highest count is the background, so run a
% histogram function, and find the maximum count. The bin containing that
% max count should correspond to the background intensity.

% The function imhist is a specific MATLAB function which returns a
% histogram for images.  
[count2a, binloc2a] = imhist(R2a,65536);

% The function max returns the maximum count from that histogram, and the 
% index (which number) of that max count.
[maxCount2a,maxI2a] = max(imhist(R2a,65536));

% So to find the bin corresponding to the max count, I go to the maxI'th
% value in the variable binloc.
maxBin2a = binloc2a(maxI2a);

% The value in maxBin2a is the intensity of the background in image R2a.

%%
% Need to add MaxBin1 to the output spreadsheet
% NOTE - check that the returned maxBin1 is indeed similar to the
% background intensity (e.g., cheeck with FIJI).

%%
% After binarizing now segment nuclei similar to how cells were segmented -
% but use different size filtering parameters

[CC2, BW2a] = NuclearSegment(BW2,FN2a);
nucsegtime = toc

%%

% 2021 10 04 - repurpose this function, to form two images, one of cells
% with single segmented nuclei, and one with filtered cells that do not
% meet that requirement.  Also to take place of NuclearCellData, generating
% .csv data file from which the user will pick and choose what to analyze.
% No longer filtering out cells, but collecting data (such as number of
% nuclei or nuclear area).

[CC,cellNucCount] = NuclearCellFilter(BW1f,BW2a,CC,CC2,FN2a,R2a,R);
nucfiltertime = toc

CellNucTable = array2table(cellNucCount, 'VariableNames',{'1: Cell Index','2: Num Nuclei', '1: Cell Length', '2: Nuc Area', '1: Cell Area', '2/2: Mean Nuc Int'});
tablename2a = [FN2a(1:end),'_Data.csv'];
writetable(CellNucTable,tablename2a);


%%
% 2021-10-10 - get whole cell fluorescence in ch2:
% 2021-11-04 - get background intensity in ch2:

NucIntensity2 = regionprops(CC,R2a,'MeanIntensity'); % get mean intensity of image in R2a, within masked area in CC

numCells = length(CC.PixelIdxList);
WholeCell2 = [1,numCells];
WholeCell2 = [NucIntensity2.MeanIntensity];
WholeCell2 = WholeCell2';

name4 = '2: Whole Cell Int';
CellNucTable.(name4) = WholeCell2;

maxBinCol2a = [numCells,1];
maxBinCol2a(1:numCells,1) = maxBin2a(1,1);

name4a = '2: Background Int';
CellNucTable.(name4a) = maxBinCol2a;

writetable(CellNucTable,tablename2a);

%%
% End of 2nd channel fluorescent image processing.  This next section is
% optional, only if a 3rd channel fluorescent image is taken.

%%
% Import the TRITC image, convert to grayscale, and return image.
% Try to make this only occur if there is three channels of data in the .dv
% file.

if isempty(R3a)
    disp('No third channel data in this image file');
else   % everything after this is part of the else statement...


%%
% First use segmented cells as masks to isolate cellular TRITC signal and
% set background to zero - thus eliminating all extraneous signals. Then
% individually segment nuclei from threshold calculated for each cell.  

[BW3,THD] = NuclearThreshBinarize(CC,BW1f,R3a,FN3a);
nucthreshtime = toc

%%
% Find the background intensity so user might do a background subtraction.
% Usually the intensity with the highest count is the background, so run a
% histogram function, and find the maximum count. The bin containing that
% max count should correspond to the background intensity.

% The function imhist is a specific MATLAB function which returns a
% histogram for images.  
[count3a, binloc3a] = imhist(R3a,65536);

% The function max returns the maximum count from that histogram, and the 
% index (which number) of that max count.
[maxCount3a,maxI3a] = max(imhist(R3a,65536));

% So to find the bin corresponding to the max count, I go to the maxI'th
% value in the variable binloc.
maxBin3a = binloc3a(maxI3a);

% The value in maxBin2a is the intensity of the background in image R2a.

%%
% After binarizing now segment nuclei similar to how cells were segmented -
% but use different size filtering parameters

[CC3, BW3a] = NuclearSegment(BW3,FN3a);
nucsegtime = toc

%%
% Next is NuclearCellFilter as before for 2nd channel, but ch3 fluorescent
% data masked by segmented ch2 nuclei...
[CC,cellNucCount3] = NuclearCellFilter(BW1f,BW2a,CC,CC2,FN3a,R3a,R);
nucfiltertime = toc

name = '3/2: Mean Nuc Int';
CellNucTable.(name) = cellNucCount3(:,6);
%tablename3b = [FN3a(1:end),'_Data_1.csv'];
%writetable(CellNucTable,tablename3b);
writetable(CellNucTable,tablename2a);


%%
% 2021 10-09 - now get channel 3 data using nuclei segmented from
% ch3 (previous NuclearCellFilter just above analyzed ch3 fluorescence
% using nuclei segmented from ch2):

[CC,cellNucCount3a] = NuclearCellFilter(BW1f,BW3a,CC,CC3,FN3a,R3a,R);
nucfiltertime = toc

name1  = '3: Nuc Area';
CellNucTable.(name1) = cellNucCount3a(:,4);

name2 = '3/3: Mean Nuc Int';
CellNucTable.(name2) = cellNucCount3a(:,6);

writetable(CellNucTable,tablename2a);


%%
% 2021 10-09 - now get channel 2 data using nuclei segmented from
% ch3:

[CC,cellNucCount3a] = NuclearCellFilter(BW1f,BW3a,CC,CC3,FN3a,R2a,R);
nucfiltertime = toc

name3 = '2/3: Mean Nuc Int';
CellNucTable.(name3) = cellNucCount3a(:,6);

writetable(CellNucTable,tablename2a);


%%
% 2021-10-10 - now get whole cell fluorescence in ch3:
% 2021-11-04 - get background intensity in ch2:

NucIntensity3 = regionprops(CC,R3a,'MeanIntensity'); % get mean intensity of image in R3a, within masked area in CC


WholeCell3 = [1,numCells];
WholeCell3 = [NucIntensity3.MeanIntensity];
WholeCell3 = WholeCell3';

name5 = '3: Whole Cell Int';
CellNucTable.(name5) = WholeCell3;


maxBinCol3a = [numCells,1];
maxBinCol3a(1:numCells,1) = maxBin3a(1,1);

name5a = '3: Background Int';
CellNucTable.(name5a) = maxBinCol3a;


writetable(CellNucTable,tablename2a);




end


%%
% Revisions
% 2021 10 14
% Simplify program, delete all extraneous functions, fix decimal intensity
% and report 16-bit fluorescence data, move all analysis functions from
% NuclearCellData to NuclearCellFilter.  Report whole-cell fluorescence as
% well as nuclear signal.

% 2021 09 30
% Take 2021 04 02 version and restructure to ourput all data from every
% cell segmented in BF channel - discard all versions using the function
% Parameters.  Simplify the user interaction, simplify the output as a .csv
% file and let the user pick and choose which outputs to use for analysis.

% 2021 04 02
% Modify nuclear segmenting to include a ratio of nucleus to cell size -
% actually this was already done in NuclearCellFilter function - I had
% retained a filter function in NuclearSegment which caused some
% nuclei/cells to be removed early and incorrectly.  Removing the mask >800
% seems to have solved this problem - all else kept the same.

% 2020 02 15
% Restructure to let user pick which path of FITC and/or TRITC import and
% analyses.

% 2020 02 03
% Import a 3rd channel with TRITC data and similarly segment and quantify
% nuclear data

% 2020 01 26
% Implement modifications suggested by Amir (logical indexing, etc) and 
% Nick (filter by nuclear/cell ratio) and Thi (user selection of nuclear
% segments).

% 2019 12 29
% Add functions for drawing major axis lines and finding cell intensity
% profile along that line.  Also use cell segments as masks and do a
% multi-thresholding to zero cell background and determine nuclear
% intensity.  Found way to threshhold each cell using a for loop and label
% matrix to mask each cell.

% 2019 12 16
% Implement various thresholding options in the final aggregate plotting
% function AggregatePlots.m

% 2019 12 02
% Changes to ThreshBinarize to improve thresholding and to Segment and 
% SegmentNum to prevent previous data overwriting new data

% 2019 11 12
% Major changes here are to add a convexity/aspect ratio filter, and to
% further reduce the unnecessary code copied from PombeX.

