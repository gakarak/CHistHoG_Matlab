function [ CHist, HoG ] = fun_calc_CHistHoG( img, arrRad, nbinHoG )
%FUN_CALC_CHISTHOG Summary of this function goes here
%   Detailed explanation goes here
    assert(ismatrix(img));
    [Gmag, Gdir] = imgradient(img,'sobel');
    sizImg=size(img);
% Calculate local-averaged Gmag    
    numRad=numel(arrRad);
% % % %
%     GmagMean1=imfilter(Gmag,    fspecial('disk', arrRad(numRad)));
%     GmagMean2=imfilter(Gmag.^2, fspecial('disk', arrRad(numRad)));
%     GmagSigma=sqrt(GmagMean2 - GmagMean1.^2);
%     GmagSigma(GmagSigma<0.002)=0.002;
%     Gmag=(Gmag - GmagMean1)./GmagSigma;
% % % %
% Calculate CHist Feature-Map
    lstFlt={};
    lstImgFlt={};
    lstImgFltDiff={};
    for ii=1:numRad
        lstFlt{ii}=fspecial('disk', arrRad(ii));
        lstImgFlt{ii}=imfilter(Gmag,lstFlt{ii});
        if ii>1
            lstImgFltDiff{ii-1}=lstImgFlt{ii}-lstImgFlt{ii-1};
        end
    end
    numDiff=numel(lstImgFltDiff);
    CHist=zeros(sizImg(1),sizImg(2),numDiff);
    for ii=1:numDiff
        CHist(:,:,ii)=lstImgFltDiff{ii};
    end
% Calculate HoG Feature-Map
    GdirBin=floor(nbinHoG*(Gdir+180)/360);
    GdirBin(GdirBin>=nbinHoG)=nbinHoG-1;
    HoG=zeros(sizImg(1), sizImg(2), nbinHoG);
    fltHoG=lstFlt{numRad}; % max radius - size HoG
    for aa=0:nbinHoG-1
% %         HoG(:,:,aa+1)=imfilter(double(GdirBin==aa), fltHoG);
        HoG(:,:,aa+1)=imfilter(double(GdirBin==aa).*Gmag, fltHoG);
    end
end

