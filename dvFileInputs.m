% 2019 11 05
% This is the final version of this small function which lets the user
% select a Deltavision multi-layered .dv image file, split that original
% file into the individual image planes, visualize them, and save them as
% separate .ome.tiff files.

% The indexing of the new .ome.tiff files follows the indexing of the .dv
% file - when imaging the sample channel 1 = bright field, 2 = FITC, 3 =
% TRITC.

% dvfile contains both image and metadata information from the Deltavision
% file.  Used bfopen function to extract data, image data assigned to R,
% where image data is then split out into R1.

function [dvfile,R1,n,R] = dvFileInputs;
% Matlab's imread function does not work with .dv files.  Therefore
% importing the bio-formats toolbox was required - see documentation here:
% https://docs.openmicroscopy.org/bio-formats/6.2.1/users/matlab/
% https://docs.openmicroscopy.org/bio-formats/6.2.1/developers/matlab-dev.html
% https://github.com/mcianfrocco/Matlab/blob/master/u-track-2.1.1/software/bioformats/bfopen.m
[dvfile, dvpath] = uigetfile('*.*');
R = bfopen(dvfile);   % bfopen is a function from the bio-formats toolbox
%whos R
%%
% That bfopen worked great to open the .dv file!  Now things get hung up on
% Matlab's imshow function.  In order to open up the .dv file, we need to
% unwrap the image planes.  The documentation above details how this works.
RCount = size(R,1);
n = size(R{1,1},1);
R1 = R{1,1};
metadataList = R{1,2};
%%
% The variable n is the index number and represents the number of image
% planes in the .dv file.  The var dvfile is a string which is assigned the
% file name via the uigetfile function.  I subtract 3 chars to remove the
% .dv extension, and then add the index number in its place.

% Is it necessary to print images and save tiff files of images?

for n=1:n;
    R1plane = R1{n,1};
    R1label = R1{n,2};
    figure('Name',R1label(:,:));
    imshow(R1plane,[]);
    dvfilename = [dvfile(1:end - 3) '_' num2str(n,'%d') '.ome.tiff'];
    bfsave(R1plane,dvfilename);
end

clearvars -except dvfile R1 n R

%%
% The following is the original way I unwrapped image planes.  I am
% commenting them out since I am instead automating this extraction along
% with generating the filename
% R1planeCount = size(R1,1)
% R1plane1 = R1{1,1}
% R1label1 = R1{1,2}
% R1plane2 = R1{2,1}
% R1label2 = R1{2,2}
% R1plane3 = R1{3,1}
% R1label3 = R1{3,2}

% The next few lines displays the images stored in each plane of the .dv
% file - and I append the labels for each plane in the .dv file to the
% header of each figure
% figure('Name',R1label1(:,:))
% imshow(R1plane1,[])

% figure('Name',R1label2(:,:))
% imshow(R1plane2,[])

% figure('Name',R1label3(:,:))
% imshow(R1plane3,[])


% The following is a more convoluted method described in the openmicroscopy
% doc and I am instead using the imshow function from the image analysis
% package. I am commenting them out and using the imshow function above
% instead...
%R1colorMap1 = R{1,3}{1,1}
%figure('Name',R1label1)
%if isempty(R1colorMap1)
%    colormap(gray)
%else
%    colormap(R1colorMap1)
%end
%imagesc(R1plane1)


% Now let's see if the first step in the background subtraction will work
% so that code was copied here and appeared to work - but I think I need to 
% figure out what kind of images I now have.

% Now instead let's figure out how to save the image file R1plane1 thru 3
% back into the current folder and enable them to be selected individually
% by the user for subsequent processing... the following is a comprehensive
% answer to how to save multi-channel images - but I will use the ":low
% level work-around: https://www.mathworks.com/matlabcentral/answers/389765-how-can-i-save-an-image-with-four-channels-or-more-into-an-imagej-compatible-tiff-format
%imwrite(R1{1:1},'r1.png')
%imwrite(R1plane1,'R1plane1','bmp')
%imwrite(R1plane2,'R1plane2','bmp')
%imwrite(R1plane3,'R1plane3','bmp')

% I am having trouble using imwrite - so let's try bfsave based on the
% following: https://docs.openmicroscopy.org/bio-formats/5.7.0/developers/matlab-dev.html
%bfsave(R1plane1, 'R1plane1.ome.tiff')
%bfsave(R1plane2, 'R1plane2.ome.tiff')
%bfsave(R1plane3, 'R1plane3.ome.tiff')


end

