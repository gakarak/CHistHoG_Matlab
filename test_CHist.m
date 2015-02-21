close all;
clear all;


fimg='./data/lena.png';


imgC=imread(fimg);
img=imgC;
if ~ismatrix(img)
    img=rgb2gray(img);
end

imgd=im2double(img);

[Gmag, Gdir] = imgradient(img,'sobel');

% % Gmag=imgd;

rad=[1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31];
numRad=numel(rad);
lstFlt={};
lstImgFlt={};
lstImgFltDiff={};
figure,
for ii=1:numRad
    lstFlt{ii}=fspecial('disk', rad(ii));
    lstImgFlt{ii}=imfilter(Gmag,lstFlt{ii});
    subplot(2,numRad,ii), imshow(lstFlt{ii},[]);
    subplot(2,numRad,numRad+ii), imshow(lstImgFlt{ii},[]);
    if ii>1
        lstImgFltDiff{ii-1}=lstImgFlt{ii}-lstImgFlt{ii-1};
    end
end

numDiff=numel(lstImgFltDiff);
qq=zeros(size(img,1),size(img,2),numDiff);
figure,
for ii=1:numDiff
    qq(:,:,ii)=lstImgFltDiff{ii};
    subplot(1,numDiff,ii), imshow(lstImgFltDiff{ii},[]);
end

qqMax=max(qq(:));
qqMin=min(qq(:));
qq=(qq-qqMin)/(qqMax-qqMin);
qqu8=uint8(255*qq);


figure, imshow(qqu8(:,:,1:3));

%%
pxy=ginput;
% % pxy=[268.7158  266.5913];
pxy=round(pxy);

sizDsc=size(qq,3);
dscPXY=reshape(qq(pxy(2), pxy(1), :),1,[]);
dscIMG=reshape(qq,[],sizDsc);
dst=pdist2(dscIMG,dscPXY,'cityblock');
dstMap=2-reshape(dst,size(img,1),size(img,2));

dstMapMax=max(dstMap(:));
imgC(:,:,1)=uint8(255*(dstMap>(0.9*dstMapMax)));
figure,
subplot(1,2,1), imshow(dstMap,[]);
subplot(1,2,2), imshow(imgC);

