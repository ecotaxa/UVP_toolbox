function [pathfilename] = CreateCTDfileSeaexplorer(project_folder, data_table, filename)
%CreateCTDfileSeaexplorer Write a CTD file in the CTD folder of a project with
%information from the vector
%
%
% inputs :
%   project_folder : full path of the project
%   data_table : data_table from the seaexplorer
%   filename : name of the ctd file to write (str)
%
% output :
%   pathfilename : full path to the new CTD file(s)
%
% camille catalano 11/2020 LOV
% camille.catalano@imev-mer.fr
%
% MIT License
% 
% Copyright (c) 2020 CATALANO Camille

%% creation of the ctd table
column_names = {'chloro fluo [mg chl m-3]', 'conductivity [ms cm-1]',...
    'cpar [%]' ,'depth [m]' ,'fcdom [ppb qse]' ,...
    'in situ density anomaly [kg m-3]' ,'nitrate [umol l-1]',...
    'oxygen [umol kg-1]', 'oxygen [ml l-1]', 'par [umol m-2 s-1]',...
    'potential density anomaly [kg m-3]', 'potential temperature [degc]',...
    'practical salinity [psu]', 'pressure [db]', 'qc flag',...
    'spar [umol m-2 s-1]', 'temperature [degc]', 'time [yyyymmddhhmmssmmm]'};

ctd_table = array2table(NaN(height(data_table), length(column_names)));
ctd_table.Properties.VariableNames = column_names;

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

%% write ctd file
pathfilename = fullfile(project_folder, 'CTDdata', filename);
pathfolder = fullfile(project_folder, 'CTDdata');
% write in Latin1
feature('DefaultCharacterSet', 'Latin1');
writetable(ctd_table, pathfilename, 'Delimiter', 'tab');
feature('DefaultCharacterSet', 'UTF8');
% renaming
pathfilename_ctd = char(pathfilename);
pathfilename_ctd = strcat(pathfilename_ctd(1:end-3), "ctd");
movefile(pathfilename, pathfilename_ctd);


end