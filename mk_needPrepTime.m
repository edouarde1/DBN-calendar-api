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
    'Priority', 'NeedPrepTime' ; ...        % P -> NPT
    'Travel', 'NeedPrepTime' ; ...          % T -> NPT
    'Alertness', 'NeedPrepTime' ; ...       % A -> NPT
    'StartTime', 'Alertness' ; ...          % ST -> A
    'NightOwl', 'Alertness'};               % NO -> A
[intra, names] = mk_adj_mat( intracons, names, 1);
DBN = names;

% inter-stage dependencies (across time steps)
intercons = { ...
    'Forgetfulness', 'Forgetfulness' };
inter = mk_adj_mat( intercons, names, 0);

% observation nodes for 1 time step (Priority, Travel, StartTime)
onodes = [ 2 5 6 ];

% discretize nodes
NPT     = 3;    % three states NPT = {low, med, high}
P       = 2;    % two states P = {false, true}
T       = 2;    % two states T = {false, true}
F       = 3;    % three states F = {low, med, high}
A       = 3;    % three states A = {low, med, high}
ST      = 3;    % three states ST = {morning, day, night}
NO      = 2;    % two states NO = {false, true}
ns      = [ NO ST A F T P NPT ]; % run mk_adj_mat( intracons, names, 1) without ';'
dnodes = 1:ss  % vector of discrete nodes

% define equivalence classes !!! TODO: Understand this and possibly change
ecl1 = [1 2 3 4 5 6 7];
ecl2 = [8 2 3 4 5 6 7];
%ecl2 = [8 2 3 9 10 6 11]; 
%ecl2 = [8 9 10 11 12 13 14]
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
NightOwl0 = 1;
StartTime = 2;
Alertness = 3;
Forgetfulness0 = 4;
Travel = 5;
Priority = 6;
NeedPrepTime = 7;

% Prior Distribution: Pr(  )

% Transition Function: Pr( needPrepTime_t | needPrepTime_t-1 )

% Observation Function #1: Pr( needPrepTime | Priority )
% Pr( NeedPrepTime | Priority )
% Priority NPT=low  NPT=med  NPT=high
% false   0.55     0.40     0.05
% true    0.01     0.04     0.95

cpt = [.55 .01 .40 .04 .05 .95 ];

bnet.CPD{Priority} = tabular_CPD(bnet, Priority, 'CPT', cpt ); 

% Observation Function #2: Pr( needPrepTime | Travel )
% Pr( NeedPrepTime | Travel )
% Travel  NPT=low  NPT=med  NPT=high
% false   0.70     0.25     0.05
% true    0.01     0.80     0.19

cpt = [.70 .01 .25 .80 .05 .19];

bnet.CPD{Travel} = tabular_CPD(bnet, Travel, 'CPT', cpt);

%Obervation Function #3: Pr(NeedPrepTime| Alertness) 
% Pr( NeedPrepTime | Alertness )
% Alert  NPT=low  NPT=med  NPT=high
% low    0.02     0.80     0.18
% med    0.35     0.55     0.10
% high   0.90     0.09     0.01

cpt = [.02 .35 .90 .80 .55 .09 .18 .10 .01];

bnet.CPD{Alertness} = tabular_CPD(bnet, Priority, 'CPT', cpt ); 






% Display CPTs
%disp( get_field( DBN.CPD{} ))
