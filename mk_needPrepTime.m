function DBN = mk_needPrepTime()
% function DBN = mk_needPrepTime
% creates the dbn model
% parameter isNightOwl (remove if converted to node)

% Define names for variables
names = { 'NeedPrepTime', 'Priority', 'Travel', 'Forgetfulness', ...
          'Alertness', 'StartTime' , 'NightOwl'};
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
names
% inter-stage dependencies (across time steps)
intercons = { ...
    'Forgetfulness', 'Forgetfulness' 
   };
inter = mk_adj_mat( intercons, names, 0);

% observation nodes for 1 time step (Priority, Travel, StartTime)
% technically also (Forgetful, NightOwl)
onodes = [ 1 2 5 6 ];

% discretize nodes
NPT     = 2;    % two states NPT = {false,true}
P       = 2;    % two states P = {false, true}
T       = 2;    % two states T = {false, true}
F       = 2;    % three states F = {false, true}
A       = 3;    % three states A = {low, med, high}
ST      = 3;    % three states ST = {morning, day, night}
NO      = 2;    % two states NO = {false, true}
ns      = [ NO ST A F T P NPT ]; % run mk_adj_mat( intracons, names, 1) without ';'
dnodes = 1:ss;  % vector of discrete nodes

% define equivalence classes
ecl1 = [1 2 3 4 5 6 7];
ecl2 = [1 2 3 8 5 6 7];

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
NightOwl = 1;
StartTime = 2;
Alertness = 3;
Forgetfulness0 = 4;
Travel = 5;
Priority = 6;
NeedPrepTime = 7;
Forgetfulness1 = 11;

% Prior Distribution: Pr( Forgetfulness0 )
% Forgetfulness  F=low  F=med  F=high
%                0.33     0.33     0.33
cpt = [0.5 0.5];
%cpt = [1/3 1/3 1/3]; % if it had three values
bnet.CPD{Forgetfulness0} = tabular_CPD( bnet, Forgetfulness0, 'CPT', cpt );

% Transition Function: Pr( Forgetfulness_t | Forgetfulness_t-1 )
% F0    F1=low  F1=med  F1=high
% low   0.90    0.09    0.01        F = low, so you remember a lot
% med   0.05    0.90    0.05        
% high  0.01    0.09    0.90        F = high, so you forget everything

% F0    F1=false F1=true
% false 0.90     0.10
% true  0.02     0.98
cpt = [.90 .02 .10 .98];
% CPT if forgetfulness has three values
%cpt = [0.90 0.05 0.01 ...
%       0.09 0.90 0.09 ...
%       0.01 0.05 0.90];
bnet.CPD{8} = tabular_CPD( bnet, Forgetfulness1, 'CPT', cpt );

% Prior distribution: Pr(Priority)
% Priorit  P=false P=true
%          0.5     0.5
cpt = [.5 .5];
bnet.CPD{Priority} = tabular_CPD(bnet, Priority, 'CPT', cpt ); 

% Prior distribution: Pr(Travel)
% Travel P=false P=true
%        0.5     0.5
cpt = [.5 .5];
bnet.CPD{Travel} = tabular_CPD(bnet, Travel, 'CPT', cpt);

% Prior distribution: Pr(StartTime)
% StartTime ST=morning ST=day ST=night
%           0.33       0.33   0.33
cpt = [1/3 1/3 1/3];
bnet.CPD{StartTime} = tabular_CPD(bnet, StartTime, 'CPT', cpt);

% Prior distribution: Pr(NightOwl)
% NighOwl NO=false NO=true
%         0.5      0.5
cpt = [.5 .5];
bnet.CPD{NightOwl} = tabular_CPD(bnet, NightOwl, 'CPT', cpt);

% Observation Function: Pr(Alertness | StartTime, NightOwl)
% NO ST     A=low   A=med   A=high
% F  morn   0.05    0.15    0.8
% F  day    0.10    0.65    0.25
% F  nght   0.70    0.20    0.10
% T  morn   0.90    0.08    0.02
% T  day    0.25    0.55    0.20
% T  nght   0.05    0.15    0.80
cpt = [.05 .10 .70 .90 .25 .05 ...
       .15 .65 .20 .08 .55 .15 ...
       .80 .25 .10 .02 .20 .80];
bnet.CPD{Alertness} = tabular_CPD(bnet, Alertness, 'CPT', cpt);

% Observation Function: NeedPrepTime 
% Pr( NeedPrepTime | Travel, Priority, Forgetfullness, Alertness)
% Table too large to include in comments
% Please read intuition section in report
cpt = [0.68 0.78 0.85 0.45 0.55 0.62 0.53 0.63 0.7 0.3 0.4 0.47 0.43 0.53 0.6 0.2 0.3 0.37 0.28 0.38 0.45 0.05 0.15 0.22 0.32 0.22 0.15 0.55 0.45 0.38 0.47 0.37 0.3 0.7 0.6 0.53 0.57 0.47 0.4 0.8 0.7 0.63 0.72 0.62 0.55 0.95 0.85 0.78];
%cpt =[0.68 0.78 0.85 0.55 0.65 0.72 0.45 0.55 0.62 ...
%      0.53 0.63 0.70 0.40 0.50 0.57 0.30 0.40 0.47 ...
%      0.43 0.53 0.60 0.30 0.40 0.47 0.20 0.30 0.37 ...
%      0.28 0.38 0.45 0.15 0.25 0.32 0.05 0.15 0.22 ...
%      0.32 0.22 0.15 0.45 0.35 0.28 0.55 0.45 0.38 ...
%      0.47 0.37 0.30 0.60 0.50 0.43 0.70 0.60 0.53 ...
%      0.57 0.47 0.40 0.70 0.60 0.53 0.80 0.70 0.63 ...
%      0.72 0.62 0.55 0.85 0.75 0.68 0.95 0.85 0.78];
bnet.CPD{NeedPrepTime} = tabular_CPD(bnet, NeedPrepTime, 'CPT', cpt);
DBN = bnet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test and Check CPTs - DEBUGGING PURPOSES ONLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('Prior distribution: Pr( Forgetfullness0 )')
%disp(get_field(DBN.CPD{Forgetfulness0}, 'cpt'))
%disp('Transition Function: Pr( Forgetfulness_t | Forgetfulness_t-1 )')
%disp(get_field(DBN.CPD{Forgetfulness1}, 'cpt'))
%disp('Observation #1: Pr( NeedPrepTime | Priority )')
%disp(get_field(DBN.CPD{Priority}, 'cpt'))
%disp('Observation #2: Pr( NeedPrepTime | Travel )')
%disp(get_field(DBN.CPD{Travel}, 'cpt'))
%disp('Obervation #3: Pr( NeedPrepTime | Alertness )')
%disp(get_field(DBN.CPD{Alertness}, 'cpt'))
%disp('Observation #4: Pr( Alertness | StartTime ) and NightOwl')
%disp(get_field(DBN.CPD{StartTime}, 'cpt'))
%disp('Pr( NeedPrepTime | Travel, Priority, Forgetfullness, Alertness)')
%disp(get_field(DBN.CPD{NeedPrepTime}, 'cpt'))