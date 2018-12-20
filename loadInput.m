function [areas, transports, params, areaOverhead, addLay, groupORs, posLay] = loadInput()
%% Specify Input files
areas = csvread('sample_areas.csv'); % nx1 matrix
transports = csvread('sample_transports.csv'); % nxn matrix
%% General settings
areaOverhead = 1.15; % factor to multiply biggest element in areas with to
% define constant floor size
addLay = 1; % constant integer that is added to the initial floor count. 
% Should be kept low for performance reasons, increase if errors occur.

params.outputflag = 1;

%% Define custom constraints: Group pairs of ORs
groupORs{1} = []; % dummy output - don't change
% --------------------------------------------
% Specify pairs of ORs that should be placed on the same floor, comment out
% otherwise. Make sure that the desired OR combinations don't exceed the
% floor capacity. Increase areaOverhead if necessary.
% --------------------------------------------

% groupORs{1} = [1,2]; 
% groupORs{2} = [1,3];
% groupORs{3} = [11,12];

%% Define custom constraints: Place floor at top or bottom
% ----------Syntax is as follows--------------
% --------------------------------------------
% posLay = [i,...
%           j];
% --------------------------------------------
% Floor containing OR i is placed at the top
% Floor containing OR j is placed at the bottom
% Set one or both entries 0 to omit constraint(s)
% --------------------------------------------

posLay = [0,...
          1];
groupORs{end+1} = posLay;

%% Check Input
% Check if Matrix dimensions agree
if length(areas)~=size(transports,1)
    err = ['areas should be a row vector of length n',...
        'and transports should be a matrix of size nxn.',...
        'Please check your input files'];
    error(err);
end

% Make sure combination of constraints is valid
for i = 1:length(groupORs)-1
    if all(posLay) == all(groupORs{i})
        error('Error: Contradicting constraint specifications.');
    end
end
end

