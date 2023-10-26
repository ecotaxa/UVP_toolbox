function [ctd_table] = FillCTDtableSeaglider(ctd_table, data_table)
%FillCTDtableSeaglider Fill a ctd_table from data from Seaglider
%
% inputs :
%   ctd_table : nan table with variables names in ecopart ctd format
%   data_table : data_table from the Seaglider with various data
%
% output :
%   ctd_table : filled ctd_table
%

%% creation of the ctd table

ctd_table.("qc flag") = zeros(height(data_table),1);
ctd_table.("time [yyyymmddhhmmssmmm]") = datestr(data_table{:,1}, 'yyyymmddHHMMSSFFF');
ctd_table.("conductivity [ms cm-1]") = data_table.('conductivity (S/m)')*10;
ctd_table.("temperature [degc]") = data_table.('temperature (degrees_Celsius)');
ctd_table.("pressure [db]") = data_table.('pressure (dbar)');
ctd_table.("practical salinity [psu]") = data_table.('salinity (1e-3)')/1000;
ctd_table.("depth [m]") = data_table.('depth (meters)');



ctd_table = [ctd_table, data_table(:,2:end)];


end