clear all;
close all;
%load image
exImage = imread('240.jpg');
%resize image cause image is so big
reExImage = imresize(exImage, 0.5);

%Convert image to bw
grayExImage = rgb2gray(reExImage);
grayExImage = im2bw(grayExImage, 0.51);
figure; imshow(grayExImage);

%Add motion blur
PSF = fspecial('motion',21,11);
Idouble = im2double(grayExImage);
blurred = imfilter(Idouble,PSF,'conv','circular');
figure; imshow(blurred)

%Add Noise
noise_mean = 0;
noise_var = 0.0001;
blurred_noisy = imnoise(blurred,'gaussian',noise_mean,noise_var);
figure; imshow(blurred_noisy)
title('Blurred and Noisy Image')

%Restore from Blur and Noise with NSR = 0
wnr2 = deconvwnr(blurred_noisy,PSF);
figure; imshow(wnr2)
title('Restoration of Blurred Noisy Image (NSR = 0)')

%Restore from Blur and Noise with NSR = Estimated
signal_var = var(Idouble(:));
NSR = noise_var / signal_var;
wnr3 = deconvwnr(blurred_noisy,PSF,NSR);
figure; imshow(wnr3)
title('Restoration of Blurred Noisy Image (Estimated NSR)')

%Intensity Tranformation (Brighter)
grayExImage = imadjust(wnr3, [], [0.4 0.8]);
figure; imshow(grayExImage);

%========================ocr function=====================================
%for tell ocr 
character = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
%use ocr with image
ocrResult = ocr(grayExImage, 'Characterset', character, 'TextLayout', 'Block');

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