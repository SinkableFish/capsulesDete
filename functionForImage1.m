function [ output_args ] = functionForImage1( data )
tempGrayData = rgb2gray(data);
[x, y] = size(tempGrayData);
tempData = 255-data;
negTempGrayData = 255 - tempGrayData;
biBlueData = OTSU(tempGrayData);
biBlueData = uint8(biBlueData);
negTempGrayData(negTempGrayData < 50) = 0;
negTempGrayData(negTempGrayData >= 50) = 1;

se = strel('disk', 3);
tempWhiteData = imdilate(negTempGrayData, se);
for i=1:6
    tempWhiteData = imerode(tempWhiteData, se);
end

se2 = strel('square', 10);
tempBlueData = imclose(biBlueData, se2);
% tempBlueData = imopen(tempBlueData, se2);

resultData = tempBlueData.*tempWhiteData;
resultData = imclose(resultData, se2);

cutMatrix = resultData;
cutMatrix(cutMatrix == 0) = 1;
cutMatrix(cutMatrix == 255) = 0;

data(:, :, 1) = data(:, :, 1).*cutMatrix;
data(:, :, 2) = data(:, :, 2).*cutMatrix;
data(:, :, 3) = data(:, :, 3).*cutMatrix;

edgeResult = edge(resultData,'canny');  %canny±ßÔµ¼ì²â

%¼ÆËãÇãÐ±½Ç¶È
j = 1;
for i = y/2:(y/2+100)
    tempLineData = find(resultData(:, i) == 255);
    lineData(j, 1) = i;
    lineData(j, 2) = x - tempLineData(1);
    j = j+1;
end
tanValue = polyfit(lineData(:, 1), lineData(:, 2), 1);
%Ðý×ªÔ­Í¼£¬¿Û³öÒ©Íè
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
imwrite(resultData, '.\results\1-2.png');
imwrite(edgeResult, '.\results\1-3.png');
imwrite(roateData, '.\results\1-4.png');
imwrite(finalResult, '.\results\1-5.png');
imwrite(tempBlueData, '.\results\1-1.png');
imwrite(imfill(resultData, 'holes'), '.\results\1-back.png');
% figure();
% imshow(resultData);
% figure();
% imshow(edgeResult);
% figure();
% imshow(finalResult);
end

