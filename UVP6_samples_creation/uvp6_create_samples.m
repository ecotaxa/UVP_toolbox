%% Create the sample file of a project
% Create the sample file for all sequences
% For SeaExplorer, for SeaGlider and for BGC-argo float
%
% !!! WARNINGS !!!
% !!! the code is case sensitive !!!
% !!! Close UVPapp before using the code !!!
%
% ------ ALL platforms ----------
% MERGE the sequences first using UVPapp (if necessary).
% For floats, the profiles must be merged first and the parking then
% For gliders, there is no parking and there might not be any merging need
%
%
% ----- SeaExplorer project -----
% The project must contain "sea" in the name.
% The meta data are extracted from the sequence and a nav file located in
% the doc folder of the project.
% The meta data folder must start with "SEA" and the sn of the glider,
% "SEA###*".
% The files must be located directly in ccu/logs/*raw*.#.gz, with # the nb of the
% yo.
% example:
% uvp6_sn000003lp_2021_sea002_m495\doc\SEA002_m495_full\ccu\logs\sea002.495.pld1.raw.7.gz
%
%
% ----- SeaGlider project -----
% The project must contain "SG" in the name.
% The meta data are extracted from the sequence and a nav file located in
% the doc folder of the project.
% The meta data folder must be called "SG###_nc_files", with ### the sn of
% the glider.
% The files in it are called "p[sn]####.nc", with #### the nb of the yo.
% There must be placed in an other folder (called nc_files for example).
% The only file remaining that will be used is a unique summary nc file of
% type : sg644_SG644_20230817_PF_timeseries.nc
% example:
% uvp6_sn000006lp_2021_SG150_PolarFront\doc\SG150_PolarFront_arctos\sg150_20210516_150_019_timeseries.nc
%
%
% ----- BGC-Argo float project -----
% For recovered BGC float uvp6 data.
% The project name must contain the WMO number in the name 
% (uvp6_sn000110lp_YYYY_WMO6904139_recovery). YYYY is the year of the
% deployment of the float. Recovery indicates that the project contains
% recovered data.
% The metadata are extraceted from the sequence and netcdf argo files (one
% per profile) present in a folder starting by float and ending by the 
% WMOnumber "float_*_#######"
% This folder must be placed in the doc folder of the project.
% The synthetic profile files must be located directly in it. The filenames are S*6904139_###.nc where 
% 6904139 is the WMO number and ### the number of the profile. The S prefix indicates that they are synthetic files. 
% The files used are the individual profile files 
% from https://dataselection.euro-argo.eu/ NetCDF Argo original
% Merge sequences rules : one sequence per ascent, one parking sequence
% between two ascent
% example:
% uvp6_sn000110lp_2021_WMO6904139_recovery\doc\float_meta_WMO6904139\SD6904139_007.nc
%
%
% -- CTD files --
% The CTD files for EcoPART are created using the data from the vector
% Due to a bug from EcoPART, after the process, move those files into a new ctd_data_cnv folder in
% the project in order to import them
% For SeaGlider, the ctd files are all the same
%
%
% -- Noise detection --
% Noise detection is done on the black 2pix
%
% 
% use Mapping Toolbox 
%
% camille catalano 11/2020

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('------------- uvp6 sample creator --------------------')
disp('------------------------------------------------------')
disp('')
disp('WARNING : Work only for seaexplorer project, seaglider project and BGC project')
disp('Read the help of the script for information about the needed project structure')
disp('')


%% inputs and its QC
% process params
%parking_pressure_diff : pressure difference to identify parkings
parking_pressure_diff = 70; % with margins
%deep_black_limit : depth where the black is considered only from the instrument
deep_black_limit = 60; %80m to be sure


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
elseif contains(project_folder, 'WMO')
    disp('BGC float project')
    vector_type = 'float';
else
    warning('Only seaexplorer, seaglider and float project are supported')
    vector_type = input('Is it a SeaExplorer (se), a SeaGlider (sg) or a float (fl) project ? ([se]/sg/fl) ','s');
    if isempty(vector_type) || strcmp(vector_type,'se')
        vector_type = 'SeaExplorer';
    elseif strcmp(vector_type, 'sg')
        vector_type = 'SeaGlider';
    elseif strcmp(vector_type, 'fl')
        vector_type = 'float';
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
disp(['The instrumental noise is evaluated under ' num2str(deep_black_limit) 'm'])
seq_nb_max = length(list_of_sequences);
aa_list = zeros(1, seq_nb_max);
exp_list = zeros(1, seq_nb_max);
volimage_list = zeros(1, seq_nb_max);
pixelsize_list = zeros(1, seq_nb_max);
start_idx_list = zeros(1, seq_nb_max);
end_idx_list = zeros(1, seq_nb_max);
start_time_list = zeros(1, seq_nb_max);
stop_time_list = zeros(1, seq_nb_max);
profile_type_list = strings(1, seq_nb_max);
sample_type_list = strings(1, seq_nb_max);
integration_time_list = NaN(1, seq_nb_max);
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
    
    % detection of ascent profile (or descent or parking)
    if strcmp(vector_type, 'float') && (abs(depth_data(end) - depth_data(1)) < parking_pressure_diff)
        profile_type = 'p';
        sample_type = 'T';
        integration_time_list(seq_nb) = 1;
    elseif depth_data(end) < depth_data(1)
        profile_type = 'a';
        black_nb = flip(black_nb);
        sample_type = 'P';
    else
        profile_type = 'd';
        sample_type = 'P';
    end
    profile_type_list(seq_nb) = profile_type;
    sample_type_list(seq_nb) = sample_type;
    
    % detection auto first image by using default method
    %{
    % code for using 1pix black
    % test if black 1pix is all 0
    if any(black_nb(:,3))
        first_black = black_nb(:,3);
    else
        first_black = black_nb(:,4);
    end
    %}
    % Use black 2pix instead
    first_black = black_nb(:,4);
    % detection auto first image by using default method
    [Zusable] = UsableDepthLimit(black_nb(:,1), first_black, deep_black_limit);

    % datetime first image
    if isnan(Zusable)
        start_idx_list(seq_nb) = nan; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = nan;
        start_time_list(seq_nb) = time_data(1);
        stop_time_list(seq_nb) = time_data(end);
    else
        Zusable_idx = find(depth_data>=Zusable);
        start_idx_list(seq_nb) = Zusable_idx(1) - 1; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = Zusable_idx(end) - 1;
        start_time_list(seq_nb) = time_data(Zusable_idx(1));
        stop_time_list(seq_nb) = time_data(Zusable_idx(end));
    end
    
    
    disp(['Sequence ' list_of_sequences(seq_nb).name ' done.'])
end
disp('---------------------------------------------------------------')




%% get lat-lon from vector meta data
% seaeplorer/seaglider dependant
% go through meta files and look for start time of sequences
% assume that sequences AND meta files are chronologicaly ordered
disp('Process the vector meta data....')
if strcmp(vector_type, 'float')
    ref_time_list = stop_time_list;
else
    ref_time_list = start_time_list;
end
[lon_list, lat_list, yo_list, samples_names_list, vector_filenames_list] = GetMetaFromVectorMetaFile(vector_type, meta_data_folder, ref_time_list, list_of_sequences, profile_type_list, cruise);
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
    % signe = sign(lat_list(seq_nb));
    % lat_deg = fix(lat_list(seq_nb) * signe);
    % lat_min = fix(rem(lat_list(seq_nb) * signe,1)*60);
    % lat_sec = round(rem(rem(lat_list(seq_nb) * signe,1)*60,1)*60);
    % if lat_sec == 60
    %     lat_sec = 0;
    %     lat_min = lat_min + 1;
    % end
    % if lat_min == 60
    %     lat_min = 0;
    %     lat_deg = lat_deg + 1;
    % end
    % if signe == -1
    %     lat = ['-' num2str(lat_deg) '°' num2str(lat_min, '%02.f') ' ' num2str(lat_sec, '%02.f')];
    % else
    %     lat = [num2str(lat_deg) '°' num2str(lat_min, '%02.f') ' ' num2str(lat_sec, '%02.f')];
    % end
    % % lon format
    % signe = sign(lon_list(seq_nb));
    % lon_deg = fix(lon_list(seq_nb) * signe);
    % lon_min = fix(rem(lon_list(seq_nb) * signe,1)*60);
    % lon_sec = round(rem(rem(lon_list(seq_nb) * signe,1)*60,1)*60);
    % if lon_sec == 60
    %     lon_sec = 0;
    %     lon_min = lon_min + 1;
    % end
    % if lon_min == 60
    %     lon_min = 0;
    %     lon_deg = lon_deg + 1;
    % end
    % if signe == -1
    %     lon = ['-' num2str(lon_deg) '°' num2str(lon_min, '%02.f') ' ' num2str(lon_sec, '%02.f')];
    % else
    %     lon = [num2str(lon_deg) '°' num2str(lon_min, '%02.f') ' ' num2str(lon_sec, '%02.f')];
    % end
    
    % ctd files names
    ctd_filesnames = [char(samples_names_list(seq_nb)) '.ctd'];
    % line to write
    seq_line = [cruise ';' vector_sn ';' list_of_sequences(seq_nb).name ';' char(samples_names_list(seq_nb)) ';'...
        'nan' ';' ctd_filesnames ';' num2str(lat_list(seq_nb)) ';' num2str(lon_list(seq_nb)) ';'...
        num2str(start_idx_list(seq_nb)) ';' num2str(volimage_list(seq_nb)) ';' num2str(aa_list(seq_nb)) ';' num2str(exp_list(seq_nb)) ';'...
        '' ';' 'nan' ';' 'nan' ';' 'nan' ';'...
        'nan' ';' '' ';' num2str(end_idx_list(seq_nb)) ';' '' ';' ...
        num2str(yo_list(seq_nb)) ';' char(sample_type_list(seq_nb)) ';' num2str(integration_time_list(seq_nb)) ';' char(vector_filenames_list(seq_nb)) ';'...
        num2str(pixelsize_list(seq_nb)) ';' datestr(start_time_list(seq_nb), 'yyyymmdd-HHMMss')];
    fprintf(sample_file, '%s\n', seq_line);
end
fclose(sample_file);

disp(['Sample file created : ' sample_filename])
disp('------------------------------------------------------')
disp('end of process')
disp('------------------------------------------------------')

