

%% matching
function [matchings] = feature_matching(featureArray1, descriptors1, ...
                                        featureArray2, descriptors2 )

%location1    = importdata('featureArray1.mat');
%location2    = importdata('featureArray2.mat');
%descriptors1 = importdata('descriptors1.mat');
%descriptors2 = importdata('descriptors2.mat');
%{
img = imread('girrafe01.png');
[featureArray1] = HarrisCorner(img);
img = rgb2gray(img);
descriptors1 = feature_descriptor ( img, featureArray1 );
img = imread('girrafe02.png');
[featureArray2] = HarrisCorner(img);
img = rgb2gray(img);
descriptors2 = feature_descriptor ( img, featureArray2 );
%}

% descriptors1, descriptors2
numOfFeatures1 = size(descriptors1,1);
numOfFeatures2 = size(descriptors2,1);

matching1 = zeros(numOfFeatures1,2);
matching2 = zeros(numOfFeatures1,2);
% output points (x1, y1, x2, y2)
matching  = zeros(max(numOfFeatures1, numOfFeatures2), 4);

%% matching 2 to 1
for i = 1:numOfFeatures1
    descript = descriptors1(i,:);
    descript = repmat(descript,numOfFeatures2,1);
    dist = sum ((descript - descriptors2).^2.');
    [ value l ] = min(dist);
    match1 (i) = l;
    %matching1(i) = location1(l);
end
%matching 1 to 2
for i = 1:numOfFeatures2
    descript = descriptors2(i,:);
    descript = repmat(descript,numOfFeatures1,1);
    dist = sum ((descript - descriptors1).^2.');
    [ value l ] = min(dist);
    match2 (i) = l;
    %matching1(i) = location1(l);
end
count = 0;
for i = 1:numOfFeatures1
    if( i == match2( match1(i) ) );
        count = count +1;
        matching(count,:) = [ featureArray1(i,:) featureArray2(match1(i),:) ];
    end
end

matching = matching(1:count,:);

end