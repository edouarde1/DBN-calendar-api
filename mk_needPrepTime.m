function DBN = mk_needPrepTime
% function DBN = mk_needPrepTime
% creates the dbn model

% Define names for variables
names = { 'NeedPrepTime', 'Priority', 'Travel', 'Forgetfulness', ...
    'Alertness', 'StartTime', 'NightOwl' };
ss = length( names ); % slice size (# nodes in one time step)
DBN = names;

% intra-stage dependencies (within one time step)
intracons = {...
    'Forgetfulness', 'NeedPrepTime' ; ...   % F -> NPT
    'NeedPrepTime', 'Priority' ; ...        % NPT -> P
    'NeedPrepTime', 'Travel' ; ...          % NTP -> T
    'Alertness', 'NeedPrepTime' ; ...       % A -> NPT
    'Alertness', 'StartTime' ; ...          % A -> ST
    'Alertness', 'NightOwl'};               % A -> NO
[intra, names] = mk_adj_mat( intracons, names, 1);
DBN = names;

% inter-stage dependencies (across time steps)
intercons = { ...
    'Forgetfulness', 'Forgetfulness' ; ...
    'NightOwl', 'NightOwl' };
inter = mk_adj_mat( intercons, names, 0);

% observation nodes for 1 time step (Priority, Travel, StartTime)
onodes = [ 2 3 6 ];

% discretize nodes
NPT     = 3;    % three states NPT = {low, med, high}
P       = 2;    % two states P = {false, true}
T       = 2;    % two states T = {false, true}
F       = 3;    % three states F = {low, med, high}
A       = 3;    % three states A = {low, med, high}
ST      = 3;    % three states ST = {morning, day, night}
NO      = 2;    % two states NO = {false, true}
ns      = [ A NO ST F NPT T P ]; % run mk_adj_mat( intracons, names, 1) without ';'
dnodes = 1:ss;  % vector of discrete nodes

% define equivalence classes !!! TODO: MAKE THIS WORK !!!
ecl1 = [[1 2 3] [4 1] [5 1 6 7]];
ecl2 = [[8 2 3] [11 1] [12 1 6 7]];
%ecl1 = [1 2 3; 4 1; 5 1 6 7];
%ecl2 = [8 2 3; 11 1; 12 1 6 7];

% create the dbn structure based on the components defined above
bnet = mk_dbn( intra, inter, ns, ...
    'discrete', dnodes, ...
    'eclass1', ecl1, ...
    'eclass2', ecl2, ...
    'observed', onodes, ...
    'names', names );
DBN = bnet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define CPTs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variable node indices

% Prior Distribution: Pr( needPrepTime0 )

% Transition Function: Pr( needPrepTime_t | needPrepTime_t-1 )

% Observation Function #1: Pr( needPrepTime | priority )

% Observation Function #2: Pr( needPrepTime | travelRequired )


% Display CPTs
%disp( get_field( DBN.CPD{} ))
