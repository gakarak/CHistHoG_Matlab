close all;
clear all;


fimg='./data/lena.png';

imgc=imread(fimg);
img=imgc;
if ~ismatrix(img)
    img=rgb2gray(img);
end

imgd=im2double(img);
sizImg=size(img);

[Gmag, Gdir] = imgradient(img,'sobel');

% % Gmag=imgd;

rad=[1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31];
numRad=numel(rad);

% % % % % % % % % % % % % % % % % % 
% Calculate Circular-Descriptor Feature-Map
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

% % % % % % % % % % 
% Calculate HoG Feature-Map
nbinHoG=12;
GdirBin=floor(nbinHoG*(Gdir+180)/360);
GdirBin(GdirBin>=nbinHoG)=nbinHoG-1;
HoG=zeros(size(img,1), size(img,2), nbinHoG);
fltHoG=lstFlt{numRad}; % max radius - size HoG
for aa=0:nbinHoG-1
   HoG(:,:,aa+1)=imfilter(double(GdirBin==aa),fltHoG);
end

hogMin=min(HoG(:));
hogMax=max(HoG(:));
HoG=(HoG-hogMin)/(hogMax-hogMin);
HoGU8=uint8(255*HoG);

% % % % % % % % % % 
numDiff=numel(lstImgFltDiff);
CHist=zeros(size(img,1),size(img,2),numDiff);
figure,
for ii=1:numDiff
    CHist(:,:,ii)=lstImgFltDiff{ii};
    subplot(1,numDiff,ii), imshow(lstImgFltDiff{ii},[]);
end

CHistMax=max(CHist(:));
CHistMin=min(CHist(:));
CHist=(CHist-CHistMin)/(CHistMax-CHistMin);
CHistU8=uint8(255*CHist);


figure,
subplot(1,2,1), imshow(HoGU8  (:,:,1:3)), title('HoG   Feature-Map');
subplot(1,2,2), imshow(CHistU8(:,:,1:3)), title('cHist Feature-Map');

%%
pxy=ginput;
% % pxy=[268.7158  266.5913];
pxy=round(pxy);

% CHist distance calculation
sizDscCHist=size(CHist,3);
dscPXYCHist=reshape(CHist(pxy(2), pxy(1), :),1,[]);
dscImgCHist=reshape(CHist,[],sizDscCHist);
dstCHist=pdist2(dscImgCHist,dscPXYCHist,'cityblock');
dstMapCHist=2-reshape(dstCHist,size(img,1),size(img,2));

% HoG distance calculation (with rotation)
sizDscHoG=size(HoG,3);
dscImgHoG=reshape(HoG,[],sizDscHoG);
dstHoGRot=zeros(sizImg(1), sizImg(2), sizDscHoG);
for ii=1:sizDscHoG
    dscPXYHoG=reshape(HoG(pxy(2), pxy(1), :),1,[]);
    dscPXYHoG=circshift(dscPXYHoG,[0,ii-1]);
    dstHoGRot(:,:,ii)=reshape(pdist2(dscImgHoG,dscPXYHoG,'cityblock'),sizImg(1),sizImg(2));
end
[BB,II]=sort(dstHoGRot,3);
dstHoG=BB(:,:,1);

% % % %
dstMapHoG=2-dstHoG; % reshape(dstHoG,size(img,1),size(img,2));
dstMapAll = dstMapCHist.*dstMapHoG;

% Find Angle peak
[RR,CC]=find(dstMapAll==max(dstMapAll(:)));
angHoG=(II(RR,CC)*360/nbinHoG);

% % % % 
dstMapMaxCHist=max(dstMapCHist(:));
dstMapMaxHoG  =max(dstMapHoG(:));
dstMapMaxAll  =max(dstMapAll(:));

% % % %
Thresh=0.9;
imgCHist=imgc;
imgHoG  =imgc;
imgAll  =imgc;
imgCHist(:,:,1)=uint8(255*(dstMapCHist>(Thresh*dstMapMaxCHist)));
imgHoG  (:,:,1)=uint8(255*(dstMapHoG  >(Thresh*dstMapMaxHoG  )));
imgAll  (:,:,1)=uint8(255*(dstMapAll  >(Thresh*dstMapMaxAll  )));

% % % % 
figure,
subplot(2,3,1  ), imshow(dstMapCHist,[]), title('dst-map: CHist');
subplot(2,3,3+1), imshow(imgCHist),       title('dst-map: CHist-Thresh');
% 
subplot(2,3,2  ), imshow(dstMapHoG,[]),   title(sprintf('dst-map: HoG, angle=%f', angHoG));
subplot(2,3,3+2), imshow(imgHoG),         title('dst-map: HoG-Thresh');
% 
subplot(2,3,3  ), imshow(dstMapAll,[]),   title('dst-map: All');
subplot(2,3,3+3), imshow(imgAll),         title('dst-map: All-Thresh');

