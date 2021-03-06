%% Create the sample file of a project
% Create the sample file for all sequences
% For SeaExplorer and for SeaGlider
%
% ----- SeaExplorer project -----
% The project must contain "sea" in the name.
% The meta data are extracted from the sequence and a nav file located in
% the doc folder of the project.
% The meta data folder must start with "SEA" and the sn of the glider,
% "SEA###*".
% The files must be located directly in ccu/logs/*raw*.#.gz, with # the nb of the
% yo.
%
% ----- SeaGlider project -----
% The project must contain "SG" in the name.
% The meta data are extracted from the sequence and a nav file located in
% the CTD folder of the project.
% The meta data folder must be called "SG###_nc_files", with ### the sn of
% the glider.
% The files in it are called "p[sn]####.nc", with #### the nb of the yo.
% 
% 
% use Mapping Toolbox 
%
% camille catalano 11/2020 LOV
% camille.catalano@imev-mer.fr
%
% MIT License
% 
% Copyright (c) 2020 CATALANO Camille
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('------------- uvp6 sample creator --------------------')
disp('------------------------------------------------------')
disp('')
disp('WARNING : Work only for seaexplorer project and seaglider project')
disp('Read the help of the script for information about the needed project structure')
disp('')


%% inputs and its QC
% select the project
disp('Select UVP project folder ')
project_folder = uigetdir('',['Select UVP project folder']);
disp('---------------------------------------------------------------')
disp(['Project folder : ', project_folder])
disp('---------------------------------------------------------------')

% detection seaexplorer or seaglider in name
if contains(project_folder, 'sea')
    disp('SeaExplorer project')
    vector_type = 'SeaExplorer';
elseif contains(project_folder, 'SG')
    disp('SeaGlider project')
    vector_type = 'SeaGlider';
else
    warning('Only seaexplorer or seaglider project are supported')
    vector_type = input('Is it a SeaExplorer (se) or a SeaGlider (sg) project ? ([se]/sg) ','s');
    if isempty(vector_type) || strcmp(vector_type,'se')
        vector_type = 'SeaExplorer';
    elseif strcmp(vector_type, 'sg')
        vector_type = 'SeaGlider';
    else
        error('ERROR : the project is not a seaexplorer or seaglider project')
    end
    
end

% detection meta in doc
[meta_data_folder, vector_sn] = DetectionVectorMetaFile(project_folder, vector_type);

% detection if sample file already exist
samples_filename = regexp(project_folder, filesep, 'split');
samples_filename = [samples_filename{1,end}(1:5) 'header' samples_filename{1,end}(5:end) '.txt'];
sample_filename = fullfile(project_folder, 'meta', samples_filename);
list_in_meta = dir(fullfile(project_folder, 'meta', '*.txt'));
idx = find(strcmp({list_in_meta.name}, samples_filename) ==1);
if ~isempty(idx)
    warning('There is already a meta data file in \meta. IT WILL BE ARCHIVED')
    archived_old_meta = input('Continue ? ([n]/y) ','s');
    if isempty(archived_old_meta) || archived_old_meta == 'n'
        error('ERROR : Process has been aborted')
    end
    old_name = fullfile(list_in_meta(idx).folder, list_in_meta(idx).name);
    new_name = [old_name(1:end-4) '_' datestr(now, 'YYYYmmDD-hhMMss') old_name(end-3:end)];
    movefile(old_name, new_name);
end
disp('---------------------------------------------------------------')


%% get cruise info
try
    cruise_file = fullfile(project_folder, 'config', 'cruise_info.txt');
    fid = fopen(cruise_file);
    tline = fgetl(fid);
    tline = fgetl(fid);
    cruise = tline(7:end);
    fclose(fid);
catch
    cruise = 'unkown';
end


%% get meta data from dat file
% list of sequences: without "UsedForMerged"
list_of_sequences = dir(fullfile(project_folder, 'raw', '20*'));
idx = cellfun('isempty',regexp({list_of_sequences.name}, 'UsedForMerge'));
list_of_sequences = list_of_sequences(idx);

% get metadata from each sequence data file
disp('Get data from all sequences...')
seq_nb_max = length(list_of_sequences);
aa_list = zeros(1, seq_nb_max);
exp_list = zeros(1, seq_nb_max);
volimage_list = zeros(1, seq_nb_max);
pixelsize_list = zeros(1, seq_nb_max);
start_idx_list = zeros(1, seq_nb_max);
end_idx_list = zeros(1, seq_nb_max);
start_time_list = zeros(1, seq_nb_max);
profile_type_list = strings(1, seq_nb_max);
for seq_nb = 1:seq_nb_max
    % get hw conf data
    seq_dat_file = fullfile(list_of_sequences(seq_nb).folder, list_of_sequences(seq_nb).name, [list_of_sequences(seq_nb).name, '_data.txt']);
    [hw_line, ~, ~] = Uvp6ReadMetalinesFromDatafile(seq_dat_file);
    [sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromhwline(hw_line);
    
    % volimage;aa;exp,pixelsize
    aa_list(seq_nb) = Aa/1000000;
    exp_list(seq_nb) = Exp;
    volimage_list(seq_nb) = volume;
    pixelsize_list(seq_nb) = pixel;
    
    % read data from dat file
    [data, meta] = Uvp6DatafileToArray(seq_dat_file);
    [time_data, depth_data, raw_nb, black_nb, ~, image_status] = Uvp6ReadDataFromDattable(meta, data);
    black_nb = [depth_data time_data black_nb];
    I = isnan(black_nb(:,3));
    black_nb(I,:) = [];
    
    % detection of ascent profile
    if depth_data(end) < depth_data(1)
        profile_type = 'a';
        black_nb = flip(black_nb);
    else
        profile_type = 'd';
    end
    profile_type_list(seq_nb) = profile_type;
    
    % detection auto first image by using default method
    % test if black 1pix is all 0
    if any(black_nb(:,3))
        first_black = black_nb(:,3);
    else
        first_black = black_nb(:,4);
    end
    % detection auto first image by using default method
    [Zusable] = UsableDepthLimit(black_nb(:,1), first_black);

    % datetime first image
    if isnan(Zusable)
        start_idx_list(seq_nb) = nan; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = nan;
        start_time_list(seq_nb) = time_data(1);
    else
        Zusable_idx = find(depth_data>=Zusable);
        start_idx_list(seq_nb) = Zusable_idx(1) - 1; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = Zusable_idx(end) - 1;
        start_time_list(seq_nb) = time_data(Zusable_idx(1));
    end
    
    
    disp(['Sequence ' list_of_sequences(seq_nb).name ' done.'])
end
disp('---------------------------------------------------------------')




%% get lat-lon from vector meta data
% seaeplorer/seaglider dependant
% go through meta files and look for start time of sequences
% assume that sequences AND meta files are chronologicaly ordered
disp('Process the vector meta data....')
[lon_list, lat_list, yo_list, samples_names_list, glider_filenames_list] = GetMetaFromVectorMetaFile(vector_type, meta_data_folder, start_time_list, list_of_sequences, profile_type_list, cruise);
disp('---------------------------------------------------------------')


%% sample file writing
disp('Creating the sample file...')
% file creation

sample_file = fopen(sample_filename,'w','n','windows-1252');
    
% add header
line = ['cruise;ship;filename;profileid;'...
    'bottomdepth;ctdrosettefilename;latitude;longitude;'...
    'firstimage;volimage;aa;exp;'...
    'dn;winddir;windspeed;seastate;'...
    'nebuloussness;comment;endimg;yoyo;'...
    'stationid;sampletype;integrationtime;argoid;'...
    'pixelsize;sampledatetime'];
fprintf(sample_file,'%s\n',line);

% write samples lines
% one sample by sequence
for seq_nb = 1:seq_nb_max
    % lat format
    signe = sign(lat_list(seq_nb));
    lat_deg = fix(lat_list(seq_nb) * signe);
    lat_min = fix(rem(lat_list(seq_nb) * signe,1)*60);
    lat_sec = round(rem(rem(lat_list(seq_nb) * signe,1)*60,1)*60);
    if lat_sec == 60
        lat_sec = 0;
        lat_min = lat_min + 1;
    end
    if lat_min == 60
        lat_min = 0;
        lat_deg = lat_deg + 1;
    end
    lat = [num2str(lat_deg * signe) '?' num2str(lat_min, '%02.f') ' ' num2str(lat_sec, '%02.f')];
    % lon format
    signe = sign(lon_list(seq_nb));
    lon_deg = fix(lon_list(seq_nb) * signe);
    lon_min = fix(rem(lon_list(seq_nb) * signe,1)*60);
    lon_sec = round(rem(rem(lon_list(seq_nb) * signe,1)*60,1)*60);
    if lon_sec == 60
        lon_sec = 0;
        lon_min = lon_min + 1;
    end
    if lon_min == 60
        lon_min = 0;
        lon_deg = lon_deg + 1;
    end
    lon = [num2str(lon_deg * signe) '?' num2str(lon_min, '%02.f') ' ' num2str(lon_sec, '%02.f')];
    % ctd files names
    if strcmp(vector_type, 'SeaExplorer')
        ctd_filesnames = [char(samples_names_list(seq_nb)) '.ctd'];
    else
        ctd_filesnames = '';
    end
    % line to write
    seq_line = [cruise ';' vector_sn ';' list_of_sequences(seq_nb).name ';' char(samples_names_list(seq_nb)) ';'...
        'nan' ';' ctd_filesnames ';' lat ';' lon ';'...
        num2str(start_idx_list(seq_nb)) ';' num2str(volimage_list(seq_nb)) ';' num2str(aa_list(seq_nb)) ';' num2str(exp_list(seq_nb)) ';'...
        '' ';' 'nan' ';' 'nan' ';' 'nan' ';'...
        'nan' ';' '' ';' num2str(end_idx_list(seq_nb)) ';' num2str(yo_list(seq_nb)) ';' ...
        '' ';' 'P' ';' 'nan' ';' char(glider_filenames_list(seq_nb)) ';'...
        num2str(pixelsize_list(seq_nb)) ';' datestr(start_time_list(seq_nb), 'yyyymmdd-HHMMss')];
    fprintf(sample_file, '%s\n', seq_line);
end
fclose(sample_file);

disp(['Sample file created : ' sample_filename])
disp('------------------------------------------------------')
disp('end of process')
disp('------------------------------------------------------')

