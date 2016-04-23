function [rimg] = align(img1, img2, featureArray)
    % translate should be an argument
    close all;
    img1 = cast(img1,'uint8');
    img2 = cast(img2,'uint8');
    Max_translate = 500;
    translateArray = zeros(Max_translate * 2,2);
    % translate range: [-499,500]
    for i = 1:size(featureArray,1);
        trans(1) = featureArray(i,3) - featureArray(i,1);
        trans(2) = featureArray(i,4) - featureArray(i,2);
        translateArray(trans(1) + 500,1) = translateArray(trans(1) + 500,1) + 1;
        translateArray(trans(2) + 500,2) = translateArray(trans(2) + 500,2) + 1;
    end;
    [M translate] = max(translateArray);
    u = translate(1) - 500;
    v = translate(2) - 500;
    h = max(size(img1,1), abs(v)+size(img2,1));
    w = max(size(img1,2), abs(u)+size(img2,2));
    rimg = zeros(h,w,3,'uint8');
    img2 = imtranslate(img2,[-u,-v],'OutputView','full');
    img1 = imtranslate(img1,[0,v],'OutputView','full');
    rimg (:,1:abs(u),:) = img1(:,1:abs(u),:);
    rimg (:,size(img1,2)+1:w,:) = img2(:,size(img1,2)+1:w,:);

    blurLength = size(img1,2) - abs(u) + 1;
    for i = abs(u)+1 : size(img1,2);
        weight2 = (i - abs(u))/blurLength;
        weight1 = 1 - weight2;
        rimg (:,i,:) = img1(:,i,:).* weight1 + img2(:,i,:).* weight2;
    end;
    
    figure;
    imshow(img1);
    figure;
    imshow(img2);
    figure;
    imshow(rimg);

end
