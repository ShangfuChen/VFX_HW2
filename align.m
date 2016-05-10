function [rimg, translate] = align(img1, img2, featureArray, translatePre)
    % translate should be an argument
    %img1 = cast(img1,'uint8');
    %img2 = cast(img2,'uint8');
    Max_translate = 3000;
    translateArray = zeros(Max_translate * 2,2);
    % translate range: [-499,500]
    for i = 1:size(featureArray,1);
        trans(1) = featureArray(i,3) - featureArray(i,1);
        trans(2) = featureArray(i,4) - featureArray(i,2);
        translateArray(trans(1) + 3000,1) = translateArray(trans(1) + 3000,1) + 1;
        translateArray(trans(2) + 3000,2) = translateArray(trans(2) + 3000,2) + 1;
    end;
    [M translate] = max(translateArray);
    prev = translate(2) - 3000;
    
    % outputview, full : reserve all image pixels
    img2 = imtranslate(img2, -translatePre,'OutputView','full');
    % translate image 1 to ...
    img1 = imtranslate(img1,[0,prev],'OutputView','full');
    img2 = imtranslate(img2, -translate+3000,'OutputView','full');
    translate = translate - 3000 + translatePre;
    % u, v shift pixel (x, y);
    u = translate(1);
    v = translate(2);
   
    % build up rimg
    h = size(img1,1);
    w = size(img2,2);
    rimg = zeros(h,w,3,'uint8');
    %left part--> all image 1
    rimg (:,1:abs(u),:) = img1(:,1:abs(u),:);
    %{
    if v < 0;
        rimg (1:h+v,1:abs(u),:) = img1(:,1:abs(u),:);
    else
        rimg (v:h,1:abs(u),:) = img1(:,1:abs(u),:);
    end
    %}
    %right part--> all image 2
    rimg (:,size(img1,2)+1:w,:) = img2(:,size(img1,2)+1:w,:);

    blurLength = size(img1,2) - abs(u) + 1;
    for i = abs(u)+1 : size(img1,2);
        weight2 = (i - abs(u))/blurLength;
        weight1 = 1 - weight2;
        rimg (:,i,:) = img1(:,i,:).* weight1 + img2(:,i,:).* weight2;
    end;
end
