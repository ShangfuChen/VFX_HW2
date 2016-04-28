%{
create a bigger image
1. for every feature points
open a window of 16*16 (with its orientations(2 times))
//[ rotation, also the point ]
for a window,
we should calculate the 8 dimentions, 4*4 --> into 128 dimentions
2. 
%}

%%
function [ descriptors ] = feature_descriptor ( img, features )


%
%features = importdata('featureArray1.mat');
%img = imread('girrafe01.png');
%img = rgb2gray(img);
%radius = 5;
%windowSize = 2*radius + 1;
%[numOfFeatures x ]= size( features );


%[GX, GY] = imgradientxy(img);
%[Gmag, Gdir] = imgradient(GX, GY);
%%
radius = 8;

numOfFeatures= size( features,1 );
%initialization
descriptors = zeros(numOfFeatures,16*radius);

%bigger image
[ height width ] = size(img);
imgBig = zeros(height+2*radius,width+2*radius);
imgBig(radius+1:radius+height, radius+1:radius+width) = img;
%calculate gradient
[GX, GY] = imgradientxy(imgBig);
[Gmag, Gdir] = imgradient(GX, GY);
%get Gaussian filter
windowSize = 2*radius;
gauFilter = fspecial('gaussian', windowSize, 1.5);
%shift feature point by(radius, radius);
featuresShift = features + radius;
% 8 bins / 1 bin = 45 degree
orient_bin_spacing = 180/4;
orient_angles = [-180:orient_bin_spacing:(180-orient_bin_spacing)].';
%1d - 3d vectors
B = repmat(orient_angles, 1, windowSize, windowSize); %// use repmat to create a 3x10x10 copy
window3d = permute(B,[3 2 1]); %// permute to the correct order
%
for i = 1:numOfFeatures
    X = featuresShift(i,1);
    Y = featuresShift(i,2);

    %fill in the window
    %2dwindow = zeros(16);
    windowMag = Gmag( Y-radius:Y+radius-1, X-radius:X+radius-1 );
    windowDir = Gdir( Y-radius:Y+radius-1, X-radius:X+radius-1 );
    %fill in the direction of window(:,:,...)

    %get orientation of each pixel
    windowDir = repmat( windowDir, 1, 8);
    windowDir = reshape( windowDir, windowSize, windowSize, 8); % 16x16x8 matrix
    %windowDir3d = windowDir - windowDir3d;
    %get major orientation of each pixel
    windowDir3d = round( (windowDir - window3d)/orient_bin_spacing ) -1;
    X = ones(windowSize, windowSize, 8);
    windowDir3d = xor(windowDir3d, X);
    % put on weighting
    Fil = gauFilter.*windowMag;
    Fil = reshape( repmat(Fil, 1, 8), windowSize, windowSize, 8);
    windowDir3d = windowDir3d.*Fil;
    %get 128 dimention descriptor
    descript = zeros(16,8);
    for j = 1:4  % row
        for k = 1:4  % column
            row = 4*(j-1) + k;
            desc = squeeze(sum(sum(windowDir3d(4*j-3:4*j,4*k-3:4*k,:))));
            descript(row,:) = desc.';
        end
    end
    descript = descript(:);
    descriptors(i,:) = descript;
end

end
