function [meta_data, data_table] = ReadMetaFloat(filepathnc)
%ReadMetaFloat read the metadata in the float netcdf file
%
% meta_data array is an num array (careful for <missing> values
% time, depth*0, latitude, longitude
% time is in num format
%
% inputs :
%   filepathnc : path/filename of nc file
%
% output :
%   meta_data : metadata array
%   data_table : fulldata array
%

depth = ncread(filepathnc, 'PRES_ADJUSTED');
juld = ncread(filepathnc, 'JULD');
juld = depth*0 + juld;
t0 = datenum('1950-01-01T00:00:00', 'yyyy-mm-ddTHH:MM:SS');
time = t0 + juld;

latitude = ncread(filepathnc, 'LATITUDE');
longitude = ncread(filepathnc, 'LONGITUDE');

latitude = depth*0 + latitude;
longitude = depth*0 + longitude;

meta_data = [time, depth, latitude, longitude];

% TEMP_ADJUSTED (°C)
temp = ncread(filepathnc, 'TEMP_ADJUSTED');
% CYCLE_NUMBER
cycle_nb = ncread(filepathnc, 'CYCLE_NUMBER');
cycle_nb = depth*0 + cycle_nb;
    
try
    % BBP700_ADJUSTED (m-1)
    bbp700 = ncread(filepathnc, 'BBP700_ADJUSTED');
catch
    bbp700 = depth*NaN;
end
try
    % CHLA_ADJUSTED (mg/m3)
    chla = ncread(filepathnc, 'CHLA_ADJUSTED');
catch
    chla = depth*NaN;
end
try
    % DOXY_ADJUSTED (µmol/kg)
    doxy = ncread(filepathnc, 'DOXY_ADJUSTED');
catch
    doxy = depth*NaN;
end
try
    % PSAL_ADJUSTED (psu)
    psal = ncread(filepathnc, 'PSAL_ADJUSTED');
catch
    psal = depth*NaN;
end

data_table = table(time, juld, depth, latitude, longitude, bbp700, chla, doxy, psal, temp, cycle_nb, 'VariableNames',...
    {'time (datenum)', 'JULD (days since 1950-01-01 00:00:00 UTC)', 'PRES_ADJUSTED (decibar)', 'LATITUDE (degree north)', 'LONGITUDE (degree east)',...
    'BBP700_ADJUSTED (m-1)', 'CHLA_ADJUSTED (mg/m3)', 'DOXY_ADJUSTED (µmol/kg)',...
    'PSAL_ADJUSTED (psu)', 'TEMP_ADJUSTED (degC)', 'CYCLE_NUMBER'});


end