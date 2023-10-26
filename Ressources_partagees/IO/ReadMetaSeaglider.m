function [meta_data, data_table] = ReadMetaSeaglider(filepathnc)
%ReadMetaSeaglider read the metadata in the seaglider netcdf file
%
% meta_data array is an num array (careful for <missing> values
% time, depth, latitude, longitude
% time is in num format
%
% inputs :
%   filepathnc : path/filename of nc file
%
% output :
%   meta_data : metadata array
%   data_table : fulldata array from glider
%

time = ncread(filepathnc, 'time');
time = datenum(datetime(double(time), 'ConvertFrom', 'posixtime'));
depth = ncread(filepathnc, 'depth');
try
    latitude = ncread(filepathnc, 'latitude');
    longitude = ncread(filepathnc, 'longitude');
catch
    warning(['No lat-lon in file ' filepathnc]);
    latitude = time*0;
    longitude = time*0;
end

meta_data = [time, double(depth), double(latitude), double(longitude)];


data_table = table(time, ncread(filepathnc, 'pressure'), depth, ncread(filepathnc, 'temperature'),...
    ncread(filepathnc, 'conductivity'), ncread(filepathnc, 'salinity'), ncread(filepathnc, 'sound_velocity'),...
    latitude, longitude, 'VariableNames', {'time (datenum)', 'pressure (dbar)',...
    'depth (meters)', 'temperature (degrees_Celsius)', 'conductivity (S/m)', 'salinity (1e-3)',...
    'sound_velocity (m/s)', 'latitude (degrees_north)', 'longitude (degrees_east)'});

end