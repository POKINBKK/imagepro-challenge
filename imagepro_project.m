clear all;
close all;
%load image
exImage = imread('215.jpg');
%resize image cause image is so big
reExImage = imresize(exImage, 0.5);

reExImage = im2double(reExImage);

figure(1); imshow(reExImage);
title('Original Image');

%i think restore algorithm will be use here

%for tell ocr 
character = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
%use ocr with image
ocrResult = ocr(reExImage, 'Characterset', character, 'TextLayout', 'Block');

%Remove whitespace from detect by logical solution
bestText = ocrResult.CharacterConfidences > 0.5;
%Get text From bestText Logical 
textVal = num2cell(ocrResult.Text(bestText));
%Get Confidences From bestText Logical 
confVal = ocrResult.CharacterConfidences(bestText);
%Get Bounding From bestText Logical 
boxVal = ocrResult.CharacterBoundingBoxes(bestText, :);
%init final cell to show in pics
label_str = cell(size(textVal, 2), 1);
%loop for value to show
for i=1:size(textVal, 2)
    label_str{i} = [ '"' textVal{i} '"' num2str(confVal(i)*100,'%0.2f') '%'];
end

%show yellow box
Iocr = insertObjectAnnotation(reExImage, 'rectangle', ...
       boxVal, label_str);

figure(2); imshow(Iocr);