close all;
clear all;

fimg='../data/edge_test_mul2.png';

imgc=imread(fimg);

ang=+30;
theta=(pi/180)*ang;

A = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1];
T = maketform('affine', A);

imgcR=imtransform(imgc, T);
imshow(imgcR);

xy=ginput;

xyf=tforminv(T, xy(1), xy(2));

figure,
subplot(1,2,1), imshow(imgcR);
rectangle('Position', [xy(1)-10, xy(2)-10, 20,20]);
subplot(1,2,2), imshow(imgc);
rectangle('Position', [xyf(1)-10, xyf(2)-10, 20,20], 'FaceColor', 'r');