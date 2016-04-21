clear;
close all;
img = imread('grail/grail00.jpg');
focalLength = 569;
import vision.*;
t = cputime;
[featureArray] = HarrisCorner(img);
'finish Harris Corner...'
time_cost = cputime - t
t = cputime;
[rfeatureArray, rimg] = cylinProject(featureArray, img, focalLength);
'finish cylindrical projection...'
time_cost = cputime - t
t = cputime;



