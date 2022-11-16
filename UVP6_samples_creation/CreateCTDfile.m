function [pathfilename] = CreateCTDfile(project_folder, data_table, filename, vector_type)
%CreateCTDfiler Write a CTD file in the CTD folder of a project with
%information from the vector
%
%
% inputs :
%   project_folder : full path of the project
%   data_table : data_table from the vector
%   filename : name of the ctd file to write (str)
%   vector_type : 'SeaExplorer' or 'float'
%
% output :
%   pathfilename : full path to the new CTD file(s)
%

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

if strcmp(vector_type, 'float')
    ctd_table = FillCTDtableFloat(ctd_table, data_table);
elseif strcmp(vector_type, 'SeaExplorer')
    ctd_table = FillCTDtableSeaexplorer(ctd_table, data_table);
end
    
    
    
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