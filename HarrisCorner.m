function [featureArray] = HarrisCorner(img)
grayImg = rgb2gray(img);
grayImg = cast(grayImg, 'double');
[height width] = size(grayImg);
Ix = diff(grayImg,1,2);
Ix(:,width) = zeros(height,1);
Iy = diff(grayImg,1,1);
Iy(height,:) = zeros(1,width);

Gwin = gausswin(5);

for h = 1:height;
    Gvector = conv(Ix(h,:), Gwin);
    Ix(h,:) = Gvector(3:width+2);
end;
for w = 1:width;
    Gvector = conv(Iy(:,w), Gwin);
    Iy(:,w) = Gvector(3:height+2);
end;

Ixx = Ix.*Ix;
Iyy = Iy.*Iy;
Ixy = Ix.*Iy;

% create a 2-D filter, can adjust it's parameter later.
filter = fspecial('gaussian');
Sxx = imfilter(Ixx,filter);
Syy = imfilter(Iyy,filter);
Sxy = imfilter(Ixy,filter);

% impirical constant k
k = 0.05;
R = zeros(size(grayImg));

count = 0;
for h = 1:height;
    for w = 1:width;
        M = [Sxx(h,w) Sxy(h,w);Sxy(h,w) Syy(h,w)];
        R(h,w) = det(M) - k*trace(M)*trace(M);
    end;
end;
local_max = imregionalmax(R);
hLocalMax = vision.LocalMaximaFinder;
hLocalMax.MaximumNumLocalMaxima = 500;
hLocalMax.Threshold = 1E4;
hLocalMax.NeighborhoodSize = [11 11];
featureArray = step(hLocalMax, R);

red = uint8([255 0 0]);
shapeInserter = vision.ShapeInserter('Shape','Circles','Fill',true,...
                            'FillColor','Custom','CustomFillColor',red);

for i = 1:size(featureArray,1);
    circle = int32([featureArray(i,:),2]);
    img = step(shapeInserter, img, circle);
end;

figure;
imshow(img);

end
