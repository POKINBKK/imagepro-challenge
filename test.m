clear all;
close all;
%load image
f = im2double(imread('239.jpg'));
figure, imshow(f), title('OG img');
PSF  = fspecial('motion', 11, 45);

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
% %restore with NSR = 0
% wnr2 = deconvwnr(mb_gn,PSF);
% figure, imshow(wnr2)
% title('Restoration of Blurred Noisy Image (NSR = 0)');
% %restore with (Estimated NSR)
% signal_var = var(double(f(:)));
% NSR = noise_var/signal_var;
% wnr3 = deconvwnr(mb_gn, PSF, NSR)
% figure, imshow(wnr3)
% title('Restoration of Blurred Noisy Image (Estimated NSR)')
%Restore with Autocorrelation
noise = imnoise(zeros(size(f)), 'gaussian', noise_mean, noise_var);
nps = abs(fft2(noise).^2)%noise power spectum
ips = abs(fft2(f).^2);%image power spectum
NCORR = fftshift(real(ifft2(nps)))
ICORR = fftshift(real(ifft2(ips)))
fr_cor = deconvwnr(mb_gn, PSF, NCORR, ICORR); 
figure, imshow(fr_cor)
title('Restoration with Autocorrelation');

%adaptive median filter
ad_fr_cor = adpmedian(rgb2gray(fr_cor), 5)
figure, imshow(ad_fr_cor)
title('Restoration with Autocorrelation with adpmedian');

%adjust contrast
adhist_fr_cor = adapthisteq(ad_fr_cor);
figure, imshow(adhist_fr_cor)
title('Restoration with Autocorrelation with adpmedian and adpt hist equalization');
% 
% %contrast with log
% c = 10;
% con_ad_fr_cor = c*log(1+double(ad_fr_cor));
% figure, imshow(imcomplement(con_ad_fr_cor))
% title('Restoration with Autocorrelation with adpmedian and edit cont with log');

%adjust intensity
adint = imadjust(adhist_fr_cor, [],[], 1)
figure, imshow(adint)
title('adjust intensity');

figure, imshow(adint)
title('adjust intensity and im2bw');

%morphology
adint_obr = imreconstruct(imerode(adint, ones(1, 40)), adint);
figure, imshow(adint_obr)
title('reconstruct');
%tophat
tophat = medfilt2(adint-adint_obr);
figure, imshow(tophat)
title('tophat');

%add noise => now its blur and noisy
% bAndN = imnoise(gb,'salt & pepper',0.10);
% figure(4), imshow(im2uint8(mat2gray(bAndN)))
% title('gaussian blur and S&P noisy');
% %fix motion blur with adaptive median filter
% adgb = deconvlucy(f, PSF);
% figure(3), imshow(im2uint8(mat2gray(adgb)));
reExImage = imcomplement(tophat);
% % =================================================
% %normal blur
% I = imgaussfilt(f,2);
% figure(10), imshow(im2uint8(mat2gray(I)));


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
Iocr = insertObjectAnnotation(reExImage, 'rectangle', ...
       boxVal, label_str);

figure(2); imshow(Iocr);
