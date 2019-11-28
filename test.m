clear all;
close all;
businessCard   = imread('215.jpg');
ocrResults     = ocr(businessCard);
recognizedText = ocrResults.Text;    
figure;imshow(businessCard);
text(600, 150, recognizedText, 'BackgroundColor', [1 1 1]);
h1 = rgb2gray(figure);
imshow('215.jpg');
h2 = figure;
imshow('215.jpg');
imcontrast(h1)