function [ output_args ] = functionForImage45( data )
[x, y, ~] = size(data);
tempGrayData = rgb2gray(data);
binGrayData = OTSU(tempGrayData);
se = strel('disk', 15);
tempResult = imclose(binGrayData, se);
edgeResult = edge(tempResult, 'canny');
j = 1;
for i = y/2:(y/2+100)
    tempLineData = find(tempResult(:, i) == 255);
    lineData(j, 1) = i;
    lineData(j, 2) = x - tempLineData(1);
    j = j+1;
end

tanValue = polyfit(lineData(:, 1), lineData(:, 2), 1);
roateData = imrotate(data, 360-atand(tanValue(1)),'crop');
roateCutMatrix = imrotate(tempResult, 360-atand(tanValue(1)),'crop');
roateData = uint8(roateData);
roateCutMatrix = uint8(roateCutMatrix);

[m, n, ~] = find(roateCutMatrix == 255);
xMax = max(m); xMin = min(m); yMax = max(n); yMin = min(n);
roateCutMatrix(roateCutMatrix == 0) = 1;
roateCutMatrix(roateCutMatrix == 255) = 0;
for i=1:3
    roateData(:, :, i) = roateData(:, :, i) .* roateCutMatrix;
end

for i=1:3
    finalData(:, :, i) = roateData(xMin:xMax, yMin:yMax,i);
end

for i=1:xMax-xMin
    for j=1:yMax-yMin
        if (~finalData(i, j, 1) && ~finalData(i, j, 2) && ~finalData(i, j, 3))
            finalData(i, j, :) = 255;
        end
    end
end
figure();
imshow(finalData);
imwrite(tempResult, '.\results\5-1.png');
imwrite(edgeResult, '.\results\5-2.png');
imwrite(finalData, '.\results\5-3.png');
imwrite(imfill(tempResult, 'holes'), '.\results\5-back.png');
% figure();
% imshow(data);
end

