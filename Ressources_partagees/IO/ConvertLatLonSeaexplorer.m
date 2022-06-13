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
latlon_dec = fix(latlon/100) + rem(latlon,100)/60;
end