% detection of the limit of the usable depth
% Camille Catalano, LOV, 2020/11

function [Zusable] = UsableDepthLimit(depth, noise, deep_black_limit, optional_method)
% UsableDepthLimitDIFF compute the depth limit for usable data 
%
% Two methods :
%   - by looking for the min of differentiation of the noise
%   - by looking for the max of second differentiation of the noise
%   - by looking for the first depth bellow a 5*std of deep noise
%
% The noise is smoothed by a moving mean
% The noise is max closed to the surface, decreasing with the depth until a
% plateau
% The depth goes bellow 100m (if not, return NaN)
%   
%
%   inputs:
%       depth : depth vector
%       noise : noise vector
%       deep_black_limit : depth where the black is only from the
%       instrument
%       optional_method = 'diff', 'diff2' or 'thres', default='thres'
%
%   outputs:
%       Zusable
%

%% parameters

aa = find(depth <= deep_black_limit);
if isempty(aa)
    warning('WARNING : only deep data. Zlim is set to 0m');
    Zusable = 0;
    return;
end
mean_noise_surf = mean(noise(aa));

aa = find(depth > deep_black_limit);
if isempty(aa) || length(aa)<2
    warning(['WARNING : no data under ' num2str(deep_black_limit) 'm ! Zlim can not be computed']);
    Zusable = nan;
    return;
end
mean_noise_deep = mean(noise(aa));
std_noise_deep = std(noise(aa));

movmean_noise = movmean(noise,10);

%% methods
if nargin > 3
    method = optional_method;
else
    method = 'thres';
end
    
%% finding Zusable
if strcmp(method, 'diff')
    Zusable = UsableDepthLimitDIFF(depth, movmean_noise, mean_noise_surf, mean_noise_deep, std_noise_deep, deep_black_limit);
elseif strcmp(method, 'diff2')
    Zusable = UsableDepthLimitDIFF2(depth, movmean_noise, mean_noise_surf, mean_noise_deep, std_noise_deep, deep_black_limit);
elseif strcmp(method, 'thres')
    Zusable = UsableDepthLimitTHRES(depth, movmean_noise, mean_noise_deep, std_noise_deep);
else
    disp('ERROR : usable depth limit method not reconized !')
end


end



function [Zusable] = UsableDepthLimitDIFF(depth, noise, mean_noise_surf, mean_noise_deep, std_noise_deep, Zlim)
% UsableDepthLimitDIFF compute the depth limit for usable data based on the
% differentiation of the noise
%   
%   look for the min of diff(noise) (max slope)
%   depth goes bellow 100m 
%
%   inputs:
%       depth : depth vector
%       noise : noise vector
%       mean_noise_surf : mean of noise above 100m
%       mean_noise_deep : mean of noise under 100m
%       std_noise_deep : std of noise under 100m
%       Zlim : limit between surface and deep depth
%
%   outputs:
%       Zusable
%
    
%% finding Zusable
% Methode pente max
% Recherche de la Zutile_diff si la moyenne est très supérieure à celle < 100m 

if mean_noise_surf > mean_noise_deep + std_noise_deep * 5
    aa = find(diff(noise) == min(diff(noise)));
    % Recherche premier pente maximum dans la couche de surface
    if depth(aa(1)) < Zlim% && min(diff_noise) < -3
        Zusable = depth(aa(1));
    else
        Zusable = depth(aa(1));
        %disp('WARNING : not reliable usable depth limit')
    end        
else
    %disp('WARNING : surface noise is closed to deep noise. Zusable = 0')
    Zusable = 0;
end


end

function [Zusable] = UsableDepthLimitDIFF2(depth, noise, mean_noise_surf, mean_noise_deep, std_noise_deep, Zlim)
% UsableDepthLimitDIFF compute the depth limit for usable data based on the
% second differentiation of the noise
%   
%   look for max of diff(noise,2) (inflection point)
%   depth goes bellow 100m 
%
%   inputs:
%       depth : depth vector
%       diff_noise : derieved noise vector
%       mean_noise_surf : mean of noise above 100m
%       mean_noise_deep : mean of noise under 100m
%       std_noise_deep : std of noise under 100m
%       Zlim : limit between surface and deep depth
%
%   outputs:
%       Zusable
%
    
%% finding Zusable
% Methode pente max
% Recherche de la Zutile_diff si la moyenne est très supérieure à celle < 100m 

if mean_noise_surf > mean_noise_deep + std_noise_deep * 5
    aa = find(diff(noise,2) == max(diff(noise,2)));
    % Recherche premier pente maximum dans la couche de surface
    if depth(aa(1)) < Zlim% && min(diff_noise) < -3
        Zusable = depth(aa(1));
    else
        Zusable = depth(aa(1));
        %disp('WARNING : not reliable usable depth limit')
    end        
else
    %disp('WARNING : surface noise is closed to deep noise. Zusable = 0')
    Zusable = 0;
end


end


function [Zusable] = UsableDepthLimitTHRES(depth, movmean_noise, mean_noise_deep, std_noise_deep)
% UsableDepthLimitTHRES compute the depth limit for usable data based on a
% threshold
%   
%   threshold = mean_noise_deep + 5 * std_mean_noise_deep
%   depth goes bellow 100m 
%
%   inputs:
%       depth : depth vector
%       movemean_noise : moving average of noise
%       mean_noise_deep : mean of noise under 100m
%       std_noise_deep : std of noise under 100m
%
%   outputs:
%       Zusable
%
    
%% finding Zusable
% Methode seuil bruit
aa = find(movmean_noise > mean_noise_deep + std_noise_deep * 5);
if ~isempty(aa)
    Zusable = depth(aa(end));   
else
    Zusable = 0;
    %disp('WARNING : surface noise is closed to deep noise. Zusable = 0')
end

end