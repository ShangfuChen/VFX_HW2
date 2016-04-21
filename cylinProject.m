function [rfeatureArray, rimg] = cylinProject(featureArray, img, focalLength)

% get focal length from autostitch
bitmap = zeros(size(img,1),size(img,2));
for i = 1:size(featureArray,1);
    bitmap(featureArray(i,2),featureArray(i,1)) = 1;
end;

height = size(img,1);
width = size(img,2);

midwidth = width / 2;
midheight = height / 2;

luimg = img(1:floor(midheight),1:floor(midwidth),:);
ruimg = img(1:floor(midheight),floor(midwidth+1):width,:);
ldimg = img(floor(midheight+1):height,1:floor(midwidth),:);
rdimg = img(floor(midheight+1):height,floor(midwidth+1):width,:);

luBitmap = bitmap(1:floor(midheight),1:floor(midwidth),:);
ruBitmap = bitmap(1:floor(midheight),floor(midwidth+1):width,:);
ldBitmap = bitmap(floor(midheight+1):height,1:floor(midwidth),:);
rdBitmap = bitmap(floor(midheight+1):height,floor(midwidth+1):width,:);


for x = 1:width - floor(midwidth+1) +1;
    for y = 1:midheight;
        cx = ceil(focalLength * atan(x/focalLength));
        cy = ceil(focalLength * y / sqrt(x^2 + focalLength^2));
        ru(cy,cx,:) = ruimg(midheight-y+1,x,:);
        rub(cy,cx) = ruBitmap(midheight-y+1,x);
    end;
end;
for x = 1:midwidth;
    for y = 1:midheight;
        cx = ceil(focalLength * atan(x/focalLength));
        cy = ceil(focalLength * y / sqrt(x^2 + focalLength^2));
        lu(cy,cx,:) = luimg(midheight-y+1,midwidth-x+1,:);
        lub(cy,cx) = luBitmap(midheight-y+1,midwidth-x+1);
    end;
end;
for x = 1:width - floor(midwidth+1) +1;
    for y = 1:height - floor(midheight+1) +1;
        cx = ceil(focalLength * atan(x/focalLength));
        cy = ceil(focalLength * y / sqrt(x^2 + focalLength^2));
        rd(cy,cx,:) = rdimg(y,x,:);
        rdb(cy,cx) = rdBitmap(y,x);
    end;
end;
for x = 1:midwidth;
    for y = 1:height - floor(midheight+1) +1;
        cx = ceil(focalLength * atan(x/focalLength));
        cy = ceil(focalLength * y / sqrt(x^2 + focalLength^2));
        ld(cy,cx,:) = ldimg(y,midwidth-x+1,:);
        ldb(cy,cx,:) = ldBitmap(y,midwidth-x+1,:);
    end;
end;
ld = fliplr(ld);
ru = flipud(ru);
lu = fliplr(flipud(lu));
rimg = [lu ru;ld rd];

ldb = fliplr(ldb);
rub = flipud(rub);
lub = fliplr(flipud(lub));
rbitmap = [lub rub;ldb rdb];

rfeatureArray = int32.empty(0,2);
for h = 1:size(rbitmap,1);
    for w = 1:size(rbitmap,2);
        if(rbitmap(h,w) == 1);
            rfeatureArray = [rfeatureArray; [w h]];
        end;
    end;
end;

rfeatureArray
red = uint8([255 0 0]);
shapeInserter = vision.ShapeInserter('Shape','Circles','Fill',true,...
                            'FillColor','Custom','CustomFillColor',red);

% note:featureArray(i,1) -> y (i,2) -> x. Because dim 1 is height, dim 2 is width 
for i = 1:size(rfeatureArray,1);
    circle = int32([rfeatureArray(i,:),2]);
    rimg = step(shapeInserter, rimg, circle);
end;

figure;
imshow(rimg);

end
