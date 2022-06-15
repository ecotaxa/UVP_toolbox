function [latlon_dec] = ConvertLatLonSeaexplorer(latlon)
%ConvertLatLonSeaexplorer convert the lat or lon seaeplorer corrdinates
%into decimal degrees coordinates
%
% latlon is in DDMM.MMM
% latlon_dec is in DD.DDDDD
%
% inputs :
%   latlon : latitude or longitude float
%
% output :
%   latlon_dec : decimal latitude or longitude float
%
% camille catalano 2020 LOV
% camille.catalano@imev-mer.fr
%
% MIT License
% 
% Copyright (c) 2020 CATALANO Camille

latlon_dec = fix(latlon/100) + rem(latlon,100)/60;
end