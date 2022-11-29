function [meta_data, data_table] = ReadDataSeaexplorer(filepathgz)
%ReadDataSeaexplorer read the metadata and data in the seaeplorer ccu file
%
% meta_data array is an num array (careful for <missing> values
% PLD_REALTIMECLOCK, NAV_DEPTH, NAV_LATITUDE, NAV_LONGITUDE
% PLD_REALTIMECLOCK is in num format
%
% inputs :
%   filepathgz : path/filename of gz file
%
% output :
%   meta_data : metadata array
%   data_table : fulldata array
%
filepath = gunzip(filepathgz);
data_table = readtable(filepath{1}, 'FileType', 'text', 'Format', '%{dd/MM/uuuu HH:mm:ss.SSS}D %f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
meta_data = [datenum(data_table.PLD_REALTIMECLOCK) data_table.NAV_DEPTH data_table.NAV_LATITUDE data_table.NAV_LONGITUDE];
delete(filepath{1});
end