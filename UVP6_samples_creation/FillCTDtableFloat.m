function [ctd_table] = FillCTDtableFloat(ctd_table, data_table)
%FillCTDtableFloat Fill a ctd_table from data from float
%
% inputs :
%   ctd_table : nan table with variables names
%   data_table : data_table from the float
%
% output :
%   ctd_table : filled ctd_table
%

%% creation of the ctd table

ctd_table.("qc flag") = zeros(height(data_table),1);
ctd_table.("time [yyyymmddhhmmssmmm]") = datestr(data_table{:,1}, 'yyyymmddHHMMSSFFF');
ctd_table.("chloro fluo [mg chl m-3]") = data_table.("CHLA_ADJUSTED (mg/m3)");
ctd_table.("oxygen [umol kg-1]") =  data_table.("DOXY_ADJUSTED (µmol/kg)");
ctd_table.("temperature [degc]") = data_table.("TEMP_ADJUSTED (degC)");
ctd_table.("pressure [db]") = data_table.("PRES_ADJUSTED (decibar)");
ctd_table.("practical salinity [psu]") = data_table.("PSAL_ADJUSTED (psu)");


ctd_table = [ctd_table, data_table(:,2:end)];


end