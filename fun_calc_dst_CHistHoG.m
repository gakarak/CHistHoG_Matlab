function [ mapDst, mapAng ] = fun_calc_dst_CHistHoG( CHist, HoG, dscCHist, dscHoG )
%FUN_CALC_DST_CHISTHOG Summary of this function goes here
%   Detailed explanation goes here
    assert(size(CHist,3)==numel(dscCHist));
    assert(size(HoG,  3)==numel(dscHoG  ));
    sizImg=[size(CHist,1), size(CHist,2)];
% Calc Distance for CHist
    sizDscCHist=size(CHist,3);
    arrDscCHist=reshape(CHist,[],sizDscCHist);
    dstCHist=pdist2(arrDscCHist, dscCHist, 'cityblock');
% %     dstCHist=pdist2(arrDscCHist, dscCHist, 'correlation');
    dstCHist=1-reshape(dstCHist, sizImg);
% Calc Distance for HoG
    sizDscHoG=size(HoG,3);
    arrDscHoG=reshape(HoG,[],sizDscHoG);
    dstHoGRot=zeros(sizImg(1), sizImg(2), sizDscHoG);
    for ii=1:sizDscHoG
        dscHoGtmp=dscHoG;
        dscHoGtmp=circshift(dscHoGtmp,[0,ii-1]);
        dstHoGRot(:,:,ii)=reshape(pdist2(arrDscHoG,dscHoGtmp,'cityblock'), sizImg);
% %         dstHoGRot(:,:,ii)=reshape(pdist2(arrDscHoG,dscHoGtmp,'correlation'), sizImg);
    end
    [BB,II]=sort(dstHoGRot,3);
    dstHoG=1-BB(:,:,1);
    mapAng=360*II(:,:,1)/size(HoG,3);
% Calc Total Map
    mapDst=fun_norm_MinMax(dstCHist).*fun_norm_MinMax(dstHoG);
% %     mapDst=dstCHist.*dstHoG;
% %     mapDst=dstHoG;
    mapDst=fun_norm_MinMax(mapDst);
end
