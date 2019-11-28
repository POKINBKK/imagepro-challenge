clear all;
close all;
%load image
f = imread('240.jpg');
imshow(f)
show = f;
f = im2double(f);
figure, imshow(f), title('OG img');

PSF  = fspecial('motion', 11, 45);

f = rgb2gray(f);
figure, imshow(f);
title('RGB to gray');

%motion blur
mb = imfilter(f, PSF,'conv', 'circular');
figure, imshow(im2uint8(mat2gray(mb)))
title('motion  blur');

%%restore Restore Motion Blur and Gaussian Noise
noise_mean = 0;
noise_var = 0.00000001;
%Motion Blur and Gaussian Noise
mb_gn = imnoise(mb, 'gaussian', noise_mean, noise_var);
figure, imshow(im2uint8(mat2gray(mb_gn)))
title('gaussian noise & motion  blur');

noise = imnoise(zeros(size(f)), 'gaussian', noise_mean, noise_var);
nps = abs(fft2(noise).^2)%noise power spectum
ips = abs(fft2(f).^2);%image power spectum
NCORR = fftshift(real(ifft2(nps)))
ICORR = fftshift(real(ifft2(ips)))
fr_cor = deconvwnr(mb_gn, PSF, NCORR, ICORR); 
figure, imshow(fr_cor)
title('Restoration with Autocorrelation');


ee = imnoise(imadjust(fr_cor , [0.3 0.7], []), 'salt & pepper', 0.2);
figure, imshow(ee);
title('intensity transformation and adding salt&pepper noise');


ee = adpmedian(ee, 5);
figure, imshow(ee);
title('median filter');


ee = ordfilt2(ee, 44, ones(13));
figure, imshow(ee);
title('order');







reExImage = ee;
%========================ocr function=====================================
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
Iocr = insertObjectAnnotation(show, 'rectangle', ...
       boxVal, label_str);

figure(); imshow(Iocr);