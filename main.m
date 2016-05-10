
%% Input image
clear
close all
%input variables
numPics = 17;
file_name = 'artifact_2/';
zmin = 1;
zmax = 256;
imgCell = cell( numPics, 1 );
imgGray = cell( numPics, 1 );
t = cputime;
B = zeros(numPics,1);
%img = [ width, height, 3, 13];
%count time comsuming
t = cputime;

for i=1:numPics;
 s1 = '';
 s2 = [ int2str(i) ];
 if( i < 10 )
     s2 = [ '0' s2 ];
 end
 s3 = '.jpg';
 s = [ file_name s1 s2 s3 ];
 imgCell{i} = imresize(imrotate(imread(s),90),0.1);
 imgGray{i} = rgb2gray(imgCell{i});
 %imgCell{i} = imresize(imgCell{i},0.3);
 %info = imfinfo(s);
 %B(i) = info.DigitalCamera.ExposureTime;
end

%%

focalLength = 768.067; % grail
import vision.*;
t = cputime;
featureArray = cell( numPics, 1 );
descriptors  = cell( numPics, 1 );
matchings    = cell( numPics-1, 1 );
rfeatureArray = cell(numPics, 1);
rimg = cell(numPics, 1);
for i = 1:numPics;
    [featureArray{i}] = HarrisCorner(imgGray{i});
end
%[featureArray] = HarrisCorner(img);
'finish Harris Corner...'
time_cost = cputime - t
t = cputime;

% feature descriptor
%imgGray = rgb2gray(img);
for i = 1:numPics;
    descriptors{i} = feature_descriptor ( imgGray{i}, featureArray{i} );
end
'finish feature descriptor...'
time_cost = cputime - t
t = cputime;


%% projection
for i = 1:numPics
    [rfeatureArray{i}, rimg{i}] = cylinProject(featureArray{i}, imgCell{i}, focalLength);
end
'finish cylindrical projection...'
time_cost = cputime - t
t = cputime;

%% feature matching
for i = 1:numPics-1;
    matchings{i} = feature_matching(featureArray{i}, descriptors{i}, ...
                                        featureArray{i+1}, descriptors{i+1} );
end
'finish feature matching...'
time_cost = cputime - t
t = cputime;

%% blending -- align
rimg = imgCell{1};
translate = [ 0, 0 ];
for i = 1:numPics-1;
    [ rimg, translate ] = ...
            align(rimg, imgCell{i+1}, matchings{i}, translate);
end
figure;
imshow(rimg);

'finish image align & blending...'
time_cost = cputime - t
t = cputime;



