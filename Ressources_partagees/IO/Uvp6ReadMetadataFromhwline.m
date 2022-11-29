function [sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp,classes_limits] = Uvp6ReadMetadataFromhwline(hw_line)
% read metadata from a hwline of a uvp6 data file
% Picheral, 2020/04/17
%
% hw_line entries must be from Uvp6ReadMetalinesFromDatafile
%
%   input:
%       hw_line : cell of string of the hw line
%
%   outputs:
%       sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp,classes_limits
%

%% splited hw line
splited_hwline = strsplit(hw_line,{',',';'}, 'CollapseDelimiters', false);


%% check the hwline version (older than 2022 ?)
if isnan(str2double(splited_hwline{15}))
    % if nan, (=not double), it is the IP adress (version older than 2022)
    Y = 0;
else
    % if not nan, (= double), it is not the IP adress (from version 2022)
    Y = 1;
end

%% ---- get all the metadata from the hardware line of the text file --
sn = splited_hwline{2};
day = splited_hwline{25-2*Y};
light =  splited_hwline{6};
shutter = str2double(splited_hwline{17-2*Y});
threshold = str2double(splited_hwline{19-2*Y});
volume = str2double(splited_hwline{23-2*Y});
gain = str2double(splited_hwline{18-2*Y});
pixel = str2double(splited_hwline{22-2*Y})/1000;
Aa = str2double(splited_hwline{20-2*Y});
Exp = str2double(splited_hwline{21-2*Y});
classes_limits = str2double(splited_hwline(27-2*Y:end-1));


end

