close all;
clear all;


fimg1='./data/edge_test_amul2.png';
fimg2='./data/edge_test_mul2.png';

imgc1=imread(fimg1);
% % imgc2=imrotate(imread(fimg2), 45, 'crop');
imgc2=imread(fimg2);
img1=imgc1;
img2=imgc2;
if ~ismatrix(img1)
    img1=rgb2gray(img1);
end
if ~ismatrix(img2)
    img2=rgb2gray(img2);
end

imgd1=im2double(img1);
imgd2=im2double(img2);

nbinHoG=16;
% % rad=[1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31];
rad=[3,7,11,15,19,23,27,31];

disp('Calc CHistHoG descriptor #1'); tic;
[CHist1, HoG1] = fun_calc_CHistHoG(imgd1, rad, nbinHoG);
toc;
disp('Calc CHistHoG descriptor #2'); tic;
[CHist2, HoG2] = fun_calc_CHistHoG(imgd2, rad, nbinHoG);
toc;

figure,
subplot(1,2,1), imshow(imgc1);
subplot(1,2,2), imshow(imgc2);

%%
pxy=ginput;
% % pxy=[268.7158  266.5913];
pxy=round(pxy);

dscPxyCHist=reshape(CHist2(pxy(2), pxy(1), :), 1, []);
dscPxyHoG  =reshape(HoG2  (pxy(2), pxy(1), :), 1, []);


[mapDst, mapAng] = fun_calc_dst_CHistHoG(CHist1, HoG1, dscPxyCHist, dscPxyHoG);


RR0=pxy(2);
CC0=pxy(1);
% Find Angle peak
[RR,CC]=find(mapDst==max(mapDst(:)));
angHoG=mapAng(RR,CC);

Thresh=0.92;
mapDstBW = (mapDst>(Thresh*max(mapDst(:))));

% % % % % % % % % % 
CCC=bwconncomp(mapDstBW);
numCCObj=CCC.NumObjects;
CCpeaksIdx=zeros(CCC.NumObjects,1);
fprintf('** Postprocess peaks...\n');
for ii=1:numCCObj
    tmpIdx=CCC.PixelIdxList{ii};
    if(numel(tmpIdx)>1)
        tmpVal = mapDst(tmpIdx);
        [~,II] = min(tmpVal);
        CCpeaksIdx(ii)=tmpIdx(II(1));
    else
        CCpeaksIdx(ii)=tmpIdx;
    end
    if mod(ii,100)==0
        fprintf('%d/%d\n', ii, numCCObj);
    end
end
disp('... [done]');
% % % % % % % % % %


imgMapDst=imgc1;
for ii=1:3
    tmp=imgMapDst(:,:,ii);
    if ii==1
        tmp(CCpeaksIdx)=255;
    else
        tmp(CCpeaksIdx)=0;
    end
    imgMapDst(:,:,ii)=tmp;
end

% % imgMapDst=imgc1;
% % for ii=1:3
% %     tmp=imgMapDst(:,:,ii);
% %     if ii==1
% %         tmp(mapDstBW>0)=255;
% %     else
% %         tmp(mapDstBW>0)=0;
% %     end
% %     imgMapDst(:,:,ii)=tmp;
% % end

radHoG=rad(numel(rad));

figure,
subplot(1,2,1), imshow(mapDst,[]);
rectangle('Position', [CC-5,RR-5,10,10], 'Curvature',[1,1], 'EdgeColor', 'b');
rectangle('Position', [CC0-radHoG,RR0-radHoG,2*radHoG,2*radHoG], 'Curvature',[1,1], 'EdgeColor', 'r');
title('Distance-Map L1');
subplot(1,2,2), imshow(imgMapDst);
rectangle('Position', [CC-5,RR-5,10,10], 'Curvature',[1,1], 'EdgeColor', 'b');
rectangle('Position', [CC0-radHoG,RR0-radHoG,2*radHoG,2*radHoG], 'Curvature',[1,1], 'EdgeColor', 'r');
title(sprintf('HoG Angle = %f, dxy=%f', angHoG, sqrt((RR-RR0)^2+(CC-CC0)^2)));




