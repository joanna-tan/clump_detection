IM_DIRECTORY= 'C:\Users\joannatan\Desktop\SEM_images';
addpath (IM_DIRECTORY);

inputImage = imread('1.jpg');
imshow(inputImage)
title('Original Image')

Igray = rgb2gray(inputImage);

gmag = imgradient(Igray);
Icm = imcomplement(Igray);
imshow(Icm)
title('Gray Image')

% rgbImage = cat(3, Icm, Icm, Icm);
rgbImage=Igray(:,:,[1 1 1]);
imshow(rgbImage)
title('RGB Image')

% create a structuring element se as disk with a size of 5 units
se = strel('disk', 5);

% erode Icm according to the structuring element se
Ie = imerode(Icm, se);
imshow(Ie)

% Istr = imdilate(Icm, se);
% imshow(Istr)
Iobr = imreconstruct(Ie,Icm);
imshow(Iobr)
title('Opening-by-Reconstruction')
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
imshow(Iobrcbr)
title('Opening-Closing by Reconstruction')

fgm = imregionalmax(Iobrcbr);
imshow(fgm)
title('Regional Maxima of Opening-Closing by Reconstruction')

bw = imbinarize(Iobrcbr);
imshow(bw)
title('Thresholded Opening-Closing by Reconstruction')

D = bwdist(bw);
D = -D;
D(~bw) = Inf;
L = watershed(D);

L(~bw) = 0;
Lrgb = label2rgb(L,'jet',[.5 .5 .5]);
imshow(Lrgb)

[~, numRegions] = bwlabel(L)

[centers,radii] = imfindcircles(Icm,[15 44],'Sensitivity', .94,...
     "EdgeThreshold", 0.1)

hold on;
viscircles(centers, radii);

numel(radii)

bw = L;
D = -bwdist(~bw);
figure

Ld = watershed(D);
Ld(~bw) = 0;
bw2 = bw;
bw2(L == 0) = 0;

% mask = imextendedmin(D,2) computes the extended-minima transform, which 
% is the regional minima of the 2-minima transform. Regional minima are 
% connected components of pixels with a constant intensity value, and 
% whose external boundary pixels all have a higher value.
mask = imextendedmin(D,2);
imshowpair(bw,mask,'blend')

%i modifies the grayscale mask image 'D' so it only has regional minima 
% wherever binary marker image 'mask' is nonzero.
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);

% label watershed image to rgb
Lrgb2 = label2rgb(Ld2,'jet',[.5 .5 .5]);
imshow(Lrgb2)
bw3 = bw;

bw3(Ld2 == 0) = 0;
Lrgb3 = label2rgb(bw3,'jet',[.5 .5 .5]);
imshow(Lrgb3)

% return the number of clumps counted by the algorithm
[~, num_clumps] = bwlabel(bw3) 

%Return the area, major axis and minor axis length of each region in bw3
s = regionprops(L, 'Area', 'MajoraxisLength', 'MinoraxisLength');
clumpAreas = cat(1, s.Area)
majorAxes = cat(1,s.MajorAxisLength)
minorAxes = cat(1,s.MinorAxisLength)


%Display histogram of clumps based on their area in pixels
% bin_width: divisions of area per bar
bin_width = 500;
h = histogram(clumpAreas, 'BinWidth', bin_width)
