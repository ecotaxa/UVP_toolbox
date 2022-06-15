function [data, meta, taxo] = Uvp6DatafileToArray(file_path)
% read data lines from data files
% file_path = [data_folder, data_filename];
%
% camille catalano 11/2021 LOV
% camille.catalano@imev-mer.fr
%
% MIT License
% 
% Copyright (c) 2021 CATALANO Camille

data_table = readtable(file_path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');

[a b] = size(data_table);
if b > 1
    data_raw = table2array(data_table(:,2));
    meta_raw = table2array(data_table(:,1));
    
    % Correction if contains TAXO data
    if any(strcmp(meta_raw,'TAXO'))
        data_indice = find(~ismember(meta_raw, 'TAXO'));
        data = data_raw(data_indice);
        meta = meta_raw(data_indice);
        taxo = data_raw;
        taxo(data_indice) = {'NaN'};
        taxo_indice = find(strcmp(meta_raw, 'TAXO'));
        taxo(taxo_indice-1) = [];
    %{
    if any(strcmp(meta_raw,'TAXO'))
        
        meta = cell(size(meta_raw,1)/2,1);
        data = cell(size(meta_raw,1)/2,1);
        taxo = cell(size(meta_raw,1)/2,1);
        
        index = 1;
        for i=1 :2: size(meta_raw,1)
            % remove 'TAXO' lines from meta
            meta(index) = meta_raw(i);
            
            % split data in data and taxo
            data(index) = data_raw(i);
            taxo(index) = data_raw(i+1);
            index = index+1;
        end
        %}
    else
        % no TAXO in data file
        data = data_raw;
        meta = meta_raw;
        taxo = {};
    end
else
    data = {};
    meta = {};
    taxo = {};
end

