clear all;
close all;
%load image
exImage = imread('239.jpg');
%resize image cause image is so big
reExImage = imresize(exImage, 0.5);

%i think restore algorithm will be use here

grayExImage = rgb2gray(reExImage);
imshow(grayExImage);

%use ocr with image
ocrResult = ocr(reExImage);
%get confidence value set from ocr
confidenceSet = ocrResult.WordConfidences;
%get all detected text  from ocr
textSet = ocrResult.Words;
%for loop size
textMatSize = size(confidenceSet, 1);
%formatted text for show
label_str = cell(textMatSize, 1);
%loop for value to show
for i=1:textMatSize
    label_str{i} = ['"' textSet{i} '"' ' Confidence: ' num2str(confidenceSet(i)*100,'%0.2f') '%'];
end

%show yellow box i think it cool
Iocr = insertObjectAnnotation(reExImage, 'rectangle', ...
       ocrResult.WordBoundingBoxes, ...
       label_str);

figure; imshow(Iocr);