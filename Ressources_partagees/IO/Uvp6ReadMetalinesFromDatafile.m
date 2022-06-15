function [hw_line, empty_line, acq_line, taxo_line] = Uvp6ReadMetalinesFromDatafile(file_path)
% read meta data lines from data files
% file_path = [data_folder, data_filename];
%
% Catalano, 2021/06/08, Picheral 2021/11/15, LOV
%
% MIT License
% 
% Copyright (c) 2021 CATALANO Camille

% open files
data_file = fopen(file_path,'r');
taxo_line = '';

disp(file_path);

% read HW and ACQ lines from data file
for j = 1:5
    tline = char(fgetl(data_file));
    if contains(tline,'HW_CONF')
        index_of_hwconf = strfind(tline,'HW_CONF');
        hw_line = tline(index_of_hwconf:end);
    elseif contains(tline,'ACQ_CONF')
        index_of_acqconf = strfind(tline,'ACQ_CONF');
        acq_line = tline(index_of_acqconf:end);
    elseif contains(tline,'TAXO_CONF')
        index_of_taxoconf = strfind(tline,'TAXO_CONF');
        taxo_line = tline(index_of_taxoconf:end);
    elseif isempty(tline)
        empty_line = tline;
    end
end

% % read HW and ACQ lines from data file
% hw_line = fgetl(data_file);
% acq_line = fgetl(data_file);
% if isempty(acq_line)
%     empty_line = acq_line;
%     acq_line = fgetl(data_file);
% else
%     empty_line = fgetl(data_file);
%     if ~isempty(empty_line)
%         disp('WARNING : no empty line found in dat file')
%     end
% end

% close files
fclose(data_file);

end

