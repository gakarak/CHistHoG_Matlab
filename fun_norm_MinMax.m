function [ imgNorm ] = fun_norm_MinMax( img )
%FUN_NORM_MINMAX Summary of this function goes here
%   Detailed explanation goes here
    imgMin=min(img(:));
    imgMax=max(img(:));
    imgNorm=(img-imgMin)/(imgMax-imgMin);
end
