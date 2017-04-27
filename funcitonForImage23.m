function [ output_args ] = funcitonForImage23( data )
tempGrayData = rgb2gray(data);
[x, y] = size(tempGrayData);
biBlueData = OTSU(tempGrayData);
biBlueData = uint8(biBlueData);
rChannel = data(:, :, 1);
gChannel = data(:, :, 2);
bChannel = data(:, :, 3);
[m, n, ~] = size(data);
cutMatrix = zeros(m, n);

se2 = strel('square', 10);
biBlueData = imclose(biBlueData, se2);

for i=1:m
    for j=1:n
        if (rChannel(i, j)>210 && rChannel(i, j)<255) && (gChannel(i, j)>200 && gChannel(i, j)<255) && (bChannel(i ,j)>200 && bChannel(i, j) <255)
            cutMatrix(i ,j) = 255;
        end
        if (rChannel(i, j)>190 && rChannel(i, j)<255) && (gChannel(i, j)>170 && gChannel(i, j)<255) && (bChannel(i ,j)>70 && bChannel(i, j) <150)
            cutMatrix(i ,j) = 255;
        end
        if (rChannel(i, j)>150 && rChannel(i, j)<190) && (gChannel(i, j)>160 && gChannel(i, j)<190) && (bChannel(i ,j)>140 && bChannel(i, j) <150)
            cutMatrix(i ,j) = 255;
        end
    end
end
se = strel('square', 4);
se2 = strel('disk', 2);
tempResult = imerode(cutMatrix, se);
for i=1:10
    tempResult = imdilate(tempResult,se);
end
[linkMatrix, n] = bwlabel(tempResult);
% imshow(linkMatrix);
for i=1:n
    [j, k, ~] = find(linkMatrix == i);
    if length(unique(j)) > 150
        [xLabel, yLabel, ~] = find(linkMatrix == i);
        linkMatrix(linkMatrix == i) = 0;
    end
end
linkMatrix(linkMatrix ~=0 ) = 1;
tempResult = tempResult.*linkMatrix;
imwrite(tempResult, '.\results\2-1.png');
tempResult(tempResult == 0) = 1;
tempResult(tempResult == 255) = 0;
tempResult = uint8(tempResult);
resultData = biBlueData.*tempResult;
imwrite(resultData, '.\results\2-2.png');
edgeData = edge(resultData, 'canny');
imwrite(edgeData, '.\results\2-3.png');
j = 1;
for i = y/2:(y/2+100)
    tempLineData = find(resultData(:, i) == 255);
    lineData(j, 1) = i;
    lineData(j, 2) = x - tempLineData(1);
    j = j+1;
end
imwrite(imfill(resultData, 'holes'), '.\results\2-back.png');
tanValue = polyfit(lineData(:, 1), lineData(:, 2), 1);
resultData(resultData == 0) = 1;
resultData(resultData == 255) = 0;
x1Max = max(xLabel); x1Min = min(xLabel); y1Max = max(yLabel); y1Min = min(yLabel);
for i=1:3
            labelData(:,:,i) = data(x1Min-30:x1Max, y1Min:y1Max, i);
end
imwrite(labelData, '.\results\3-5.png')
for i=1:3
    data(:, :, i) = data(:, :, i).*resultData;
end
roateData = imrotate(data, 360-atand(tanValue(1)),'crop');
cutMatrix2 = imfill(biBlueData, 'holes');
cutMatrix2 = imrotate(cutMatrix2, 360-atand(tanValue(1)),'crop');
[m, n, ~] = find(cutMatrix2 == 255);
xMax = max(m); xMin = min(m); yMax = max(n); yMin = min(n);
finalResult(:, :, 1) = roateData(xMin:xMax, yMin:yMax, 1);
finalResult(:, :, 2) = roateData(xMin:xMax, yMin:yMax, 2);
finalResult(:, :, 3) = roateData(xMin:xMax, yMin:yMax, 3);
for i=1:xMax-xMin
    for j=1:yMax-yMin
        if (~finalResult(i, j, 1) && ~finalResult(i, j, 2) && ~finalResult(i, j, 3))
            finalResult(i, j, :) = 255;
        end
    end
end
% figure();
% imshow(cutMatrix);
% figure();
% imshow(finalResult);
imwrite(finalResult, '.\results\2-4.png');
end

