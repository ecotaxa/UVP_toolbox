function [ctd_table] = FillCTDtableSeaexplorer(ctd_table, data_table)
%FillCTDtableSeaexplorer Fill a ctd_table from data from seaexplorer
%
% inputs :
%   ctd_table : nan table with variables names
%   data_table : data_table from the seaexplorer
%
% output :
%   ctd_table : filled ctd_table
%

%% creation of the ctd table

ctd_table.("qc flag") = zeros(height(data_table),1);
ctd_table.("time [yyyymmddhhmmssmmm]") = datestr(data_table{:,1}, 'yyyymmddHHMMSSFFF');
ctd_table.("chloro fluo [mg chl m-3]") = data_table.FLBBCD_CHL_SCALED; %%%%% µg/L pas verifie mais a priori ok
ctd_table.("fcdom [ppb qse]") = data_table.FLBBCD_CDOM_SCALED; %%%%%%%%%%%%% ppb ok
try
    oxy = 0.001 * data_table.AROD_FT_DO' / sw_dens(data_table.LEGATO_SALINITY', data_table.LEGATO_TEMPERATURE', data_table.LEGATO_PRESSURE');
    %ctd_table.("oxygen [umol kg-1]") =  oxy'; %%%%%%%%%% AROD_FT_DO in µmol/L conversion faite, mais correction à faire !!!!
    ctd_table.("conductivity [ms cm-1]") = data_table.LEGATO_CONDUCTIVITY; %%%%%%%% mS/cm ok
    ctd_table.("temperature [degc]") = data_table.LEGATO_TEMPERATURE; %%%%%%%%% °C ok
    ctd_table.("pressure [db]") = data_table.LEGATO_PRESSURE; %%%%%%%%%%%%%%% db ok
    ctd_table.("practical salinity [psu]") = data_table.LEGATO_SALINITY; %%%%%%% ups a priori ok, peut etre a verifier
catch
    ctd_table.("pressure [db]") = data_table.NAV_DEPTH;
end

data_table(:,14:21) = [];
ctd_table = [ctd_table, data_table(:,3:end-1)];


end