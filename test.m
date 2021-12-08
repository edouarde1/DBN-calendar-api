function DBN = mk_needPrepTime(isNightOwl)
% function DBN = mk_needPrepTime
% creates the dbn model
% parameter isNightOwl (remove if converted to node)

% Define names for variables
names = { 'NeedPrepTime', 'Priority', 'Travel', 'Forgetfulness', ...
    'Alertness', 'StartTime' }; % NightOwl node removed
ss = length( names ); % slice size (# nodes in one time step)
DBN = names;

% intra-stage dependencies (within one time step)
intracons = {...
    'Forgetfulness', 'NeedPrepTime' ; ...   % F -> NPT
    'Priority', 'NeedPrepTime' ; ...        % P -> NPT
    'Travel', 'NeedPrepTime' ; ...          % T -> NPT
    'Alertness', 'NeedPrepTime' ; ...       % A -> NPT
    'StartTime', 'Alertness' };             % ST -> A
 %   'NightOwl', 'Alertness'};               % NO -> A % Removed node
[intra, names] = mk_adj_mat( intracons, names, 1)
DBN = names;

% inter-stage dependencies (across time steps)
intercons = { ...
    'Forgetfulness', 'Forgetfulness' };
inter = mk_adj_mat( intercons, names, 0);


% observation nodes for 1 time step (Priority, Travel, StartTime)
onodes = [ 1 4 5 ];

% discretize nodes
NPT     = 3;    % three states NPT = {low, med, high}
P       = 2;    % two states P = {false, true}
T       = 2;    % two states T = {false, true}
F       = 3;    % three states F = {low, med, high}
A       = 3;    % three states A = {low, med, high}
ST      = 3;    % three states ST = {morning, day, night}
%NO      = 2;    % two states NO = {false, true} % NightOwl node removed
ns      = [ ST A F T P NPT ]; % run mk_adj_mat( intracons, names, 1) without ';'
dnodes = 1:ss;  % vector of discrete nodes

% define equivalence classes !!! TODO: Understand this and possibly change
ecl1 = [1 2 3 4 5 6]; % Updated after removing NightOwl
ecl2 = [7 8 9 10 5 12]; %
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

DBN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define CPTs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variable node indices
StartTime = 1;
Alertness = 2;
Forgetfulness0 = 3;
Travel = 4;
Priority = 5;
NeedPrepTime = 6;
Forgetfulness1 = 9;

% Prior Distribution: Pr( Forgetfulness0 )
% Forgetfulness  F=low  F=med  F=high
%                0.33     0.33     0.33
cpt = [1/3 1/3 1/3]
bnet.CPD{Forgetfulness0} = tabular_CPD( bnet, Forgetfulness0, 'CPT', cpt );

% Transition Function: Pr( Forgetfulness_t | Forgetfulness_t-1 )
% F0    F1=low  F1=med  F1=high
% low   0.90    0.09    0.01        F = low, so you remember a lot
% med   0.05    0.90    0.05        
% high  0.01    0.09    0.90        F = high, so you forget everything

cpt = [.90 .05 .01 .09 .90 .09 0.01 0.05 0.90]
bnet.CPD{Forgetfulness1} = tabular_CPD( bnet, Forgetfulness1, 'CPT', cpt );

% Observation Function #1: Pr( NeedPrepTime | Priority )
% Pr( NeedPrepTime | Priority )
% Priority NPT=low  NPT=med  NPT=high
% false   0.55     0.40     0.05
% true    0.01     0.04     0.95

cpt = [.55 .01 .40 .04 .05 .95];

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

bnet.CPD{Alertness} = tabular_CPD(bnet, Alertness, 'CPT', cpt ); 

%Observation Function #4: Pr( Alertness | StartTime ) and NightOwl

if isNightOwl
    cpt = [.02 .20 .80 .08 .55 .15 .90 .25 .05]
else
    cpt = [.80 .25 .10 .15 .65 .20 .05 .10 .70]
end

bnet.CPD{StartTime} = tabular_CPD(bnet, StartTime, 'CPT', cpt);

DBN = bnet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test and Check DBN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display CPTs
%disp( get_field( DBN.CPD{} ))