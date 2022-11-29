function [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,Exp,black_ratio] = Uvp6ReadMetadataFromDatafile(folder,path)
% Lecture des metadata à partir du fichier data
% Picheral, 2020/04/17


[hwline, empty_line, acqline] = Uvp6ReadMetalinesFromDatafile(path);

% ----------------- Ligne HW -----------------
%hw_line is the first line of the text folder in which the parameters of the sequence are stored : shutter, threshold, gain, .....
hw_line = strsplit(hwline,{',',';'}, 'CollapseDelimiters', false);


% ---- get all the metadata from the hardware line of the text file --
% ---- premiere sequence ---------
[sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromhwline(hwline);
cruise = folder(4:end);
base_name = ['base',folder(4:end)];
pvmtype = ['uvp6_sn' sn];
soft = 'uvp6';

% ------------ LIgne ACQ ----------------------------------
acq_line = strsplit(acqline,{',',';'});
% check the hwline version (older than 2022 ?)
if isnan(str2double(hw_line{15}))
    % if nan, (=not double), it is the IP adress (version older than 2022)
    Y = 0;
else
    % if not nan, (= double), it is not the IP adress (from version 2022)
    Y = 1;
end
black_ratio = str2double(acq_line{15-2*Y});


end

