% 2020 01 26
% Added filtering for nuclear/cell area - used 0.2 as cuttoff - this cutoff
% will likely be modified.

% 2020 01 01
% Next step is to filter out cells with either < or > than 1 nuclei per
% cell.  There must be a way to compare the segmented cell matrix, and the
% segmented nuclei matrix, and set the cells to zero if it overlaps with
% either 0 or >1 nuclei...

function [CC,cellNucCount] = NuclearCellFilter(BW1f,BW2a,CC,CC2,FN2a,R2a,R);

nucfilterstart = tic

% First let's superimpose the images of previous fully filtered cells and
% segmented nuclei

CC = bwconncomp(BW1f,4);
s = regionprops(CC,'centroid');
centroid = cat(1,s.Centroid);
n = CC.NumObjects;

overlay = imfuse(BW1f, BW2a);
figure('Numbertitle', 'off','Name','Function: NuclearFilter.m Overlay');;
imshow(overlay);
nucfilter1 = toc(nucfilterstart)

for n=1:n;
    text(centroid(n,1),centroid(n,2),sprintf('%d',n),'HorizontalAlignment','center');
end

drawnow
hold off


% Now count nuclear segments in each cell.

% First, how many cells?  Another way to do this
numCells = length(CC.PixelIdxList);

% Do a for loop, and for each cell see if I can count the number of nuclear
% segments
labeled2 = labelmatrix(CC2);
labeled2 = double(labeled2);
cellNucCount = [numCells,2];
nucfilter2 = toc(nucfilterstart)

blank = 0;

for n = 1:numCells
    cell = false(size(BW1f));   % each time blank the image area
    cell(CC.PixelIdxList{n}) = true;   % each time display a new cell by index
    %cell = double(cell);   % change type so we can multiply
    %cellNuc = cell.* labeled2;   % overlap each cell with the associated nuclei that fall within its area
    cellNuc = labeled2;  % start filtering by assigning labeled2 to new working var cellNuc
    cellNuc(~cell) = 0;  % now remove any nuclear signal not associated with indexed cells
    %figure;
    %imshow(cellNuc);
    count = unique(cellNuc);   % find the unique values which will always include 0 for background, and a value for each nuclei
    nNuc = length(count) - 1;
    cellNucCount(n,1) = n;   % create a table and assign each cell index
    cellNucCount(n,2) = nNuc;   % and associated with each cell index is the number of nuclei
    Nindex = cellNucCount(n,2) < 1 | cellNucCount(n,2) > 1;  % logical index true if < or > 1, false if 1
    % Add length of individual cell to table cellNucCount
    Length = regionprops(cell, 'MajorAxisLength');
    cellNucCount(n,3) = [Length.MajorAxisLength];
    % Now add nuclear intensity to same table if only a single nucleus
    % otherwise enter "N/A".  Also, only if area ratio <0.2
    NucArea = regionprops(cellNuc, 'Area');  % Get the mean nuclear area from the filtered set of nuclei
    NucArea = [NucArea.Area];
    CellArea = []; % blank this variable each iteration
    CellArea = regionprops(cell, 'Area');  % Get mean cell area
    CellArea = [CellArea.Area];
    cellNucCount(n,4) = NucArea(end);
    cellNucCount(n,5) = CellArea;
    NCRatioIndex = NucArea(end) / CellArea > 0.2;  % Index of cells with excessive nuclear size
    if NCRatioIndex == 1 %| nNuc ~= 1
        cellNucCount(n,6) = 0;
    else
        NucIntensity = regionprops(cellNuc,R2a,'MeanIntensity'); % get mean intensity of image in R2a, within masked area in cellNuc
        cellNucCount(n,6) = [NucIntensity(end).MeanIntensity];
    end
    clear NucArea; % blank this variable each iteration
end
nucfilter3 = toc(nucfilterstart)


%%
% Here is code copied from NuclearCellData (2021-04-02):

omeMeta = R{1,4};
stackSizeX = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
stackSizeY = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels

voxelSizeX = omeMeta.getPixelsPhysicalSizeX(0).value;
voxelSizeY = omeMeta.getPixelsPhysicalSizeY(0).value;

% need to convert a java data type to a Matlab type
voxelSizeX = double(voxelSizeX);

cellNucCount(:,3) = cellNucCount(:,3) * voxelSizeX;
cellNucCount(:,4) = cellNucCount(:,4) * (voxelSizeX)^2;
cellNucCount(:,5) = cellNucCount(:,5) * (voxelSizeX)^2;


%%

% 
% CellNucTable = array2table(cellNucCount, 'VariableNames',{'Cell Index','Num Nuclei', 'Cell Length', 'Nuc Area', 'Cell Area', 'Mean Nuc Int'});
% tablename2a = [FN2a(1:end-9),'_Data.csv'];
% writetable(CellNucTable,tablename2a);


% Now see if I can use this information to retain only cells that contain 1
% nucleus and delete cells that do not (either < or > 1 nucleus).
% Moved the following two lines into the for loop
% index = cellNucCount(:,2) < 1 | cellNucCount(:,2) > 1;  % logical index true if < or > 1, false if 1
% index = index';

% 2021 10 04 - instead of deleting these cells, I want to assign them to a
% separate image variable which contains cells which do not meet the
% nuclear filtering criteria, and keep the cells which meet the nuclear
% filtering in the original variable.

% 2021 10 07 - found out that the nuclear indexing does NOT match cellular
% indexing.  Use the above for loop to ensure that each nucleus is assigned
% to each cell.

% CC.PixelIdxList(index) = [];   % delete all cells associated with either < or > 1 nuclei
% BW1g      = false(size(BW1f));
% BW1g(vertcat(CC.PixelIdxList{:})) = true;   % display new set of filtered cells


%figure;
%imshow(BW1d)
% CC = bwconncomp(BW1g,4);
% s = regionprops(CC,'centroid');
% centroid = cat(1,s.Centroid);
% n = CC.NumObjects;
% nucfilter4 = toc(nucfilterstart)
% 
% labeled = labelmatrix(CC);
% RGB_label = label2rgb(labeled,'spring','c','shuffle');
% figure('Numbertitle', 'off','Name','Function: NuclearFilter.m - number of nuclei');
% imshow(RGB_label);
% title(FN2a, 'Interpreter', 'none');
% for n=1:n;
%     text(centroid(n,1),centroid(n,2),sprintf('%d',n),'HorizontalAlignment','center');
% end
% 
% drawnow
% 
% hold off;
% nucfilter5 = toc(nucfilterstart)    


% Now try to eliminate cells in which the nuclear area, NucArea, is greater
% than 20% of the cellular area, Area, based on the Neumann & Nurse 2007.
% paper showing regulation of N/C ratio... Fig 5D shows values of N/C as
% high has 0.16 - so use 0.16 as a cutoff.

% cellNuc = labeled & BW2a;   % Select nuclei from the filtered set of cells - this will filter the quantification of the FITC nuclear image
% 
% % NOW image the nuclei and number them to see if they align with the cell's
% % indices:
% CC1 = bwconncomp(cellNuc,4);
% s1 = regionprops(CC1,'centroid');
% centroid = cat(1,s1.Centroid);
% n = CC1.NumObjects;
% 
% figure('Numbertitle', 'off','Name','Function: NuclearFilter.m - indices of nuclei');
% imshow(cellNuc);
% title('BW2a', 'Interpreter', 'none');
% for n=1:n;
%     text(centroid(n,1),centroid(n,2),sprintf('%d',n),'HorizontalAlignment','center');
% end

% Now calculate areas of nuclei and cells, and then calculate ratio in
% order to filter:

% NucArea = regionprops(cellNuc, BW2a, 'Area');  % Get the mean nuclear area from the filtered set of nuclei
% NucArea = [NucArea.Area];
% CellArea = regionprops(CC, 'Area');  % Get mean cell area
% CellArea = [CellArea.Area];
% CellNum = [1:n];
% NCRatioIndex = NucArea ./ CellArea > 0.2  % Index of cells to delete
% 
% CC.PixelIdxList(NCRatioIndex') = [];   % delete all cells associated with either < or > 1 nuclei
% BW1h      = false(size(BW1g));
% BW1h(vertcat(CC.PixelIdxList{:})) = true;   % display new set of filtered cells
% 
% AreaFilterTable = table(CellNum',NucArea',CellArea',NCRatioIndex')
% writetable(AreaFilterTable, 'AreaFilterTable.csv');
%  
% 
% %figure;
% %imshow(BW1d)
% CC = bwconncomp(BW1h,4);
% s = regionprops(CC,'centroid');
% centroid = cat(1,s.Centroid);
% n = CC.NumObjects;
% nucfilter4 = toc(nucfilterstart)
% 
% labeled = labelmatrix(CC);
% RGB_label = label2rgb(labeled,'spring','c','shuffle');
% figure('Numbertitle', 'off','Name','Function: NuclearFilter.m - area of nuclei');
% imshow(RGB_label);
% %title(tiffFilename, 'Interpreter', 'none');
% for n=1:n;
%     text(centroid(n,1),centroid(n,2),sprintf('%d',n),'HorizontalAlignment','center');
% end
% 
% drawnow
% 
% hold off;
% nucfilter5 = toc(nucfilterstart)    

clearvars -except CC cellNucCount

% We also need to delete the double nuclei for those cells that were
% deleted in the previous step - either that or make sure that only the
% single nuclei associated with the fully filtered cells are measured and
% plotted









