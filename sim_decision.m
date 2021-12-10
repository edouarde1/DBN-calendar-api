
function bestAction = sim_decision(dbn, ex, isNightOwl, startTime, travel, priority)
% function prNeedPrepTime = sim_decision(dbn, ex, isNightOwl,
% startTime, travel, priority)
% ARGS: dbn = dynamic bayes net model specified by BNT syntax
%       ex = setting used to generate evidence
%            (1=random, 2=fixed observable evidence)
%       isNightOwl = if user is nightowl (1=false, 2=true)
%       startTime = time of day the event begins (1=morn, 2=day, 3=night)
%       travel = if user must travel to event (1=false, 2=true)
%       priority = if event is a high priority (1=false, 2=true)

engine = bk_inf_engine(dbn); % set up inference engine
T = 50; % number of time steps to simulate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a series of evidence in advance
% To change the fixed variables, look for !! in comments below !!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ex == 1 % For flag 1, create random evidence
    disp('Creating random evidence...')
    ev = sample_dbn( dbn, T ); % similar to randi
    evidence = cell(7,T); % 3 nodes per slice, 50 time steps
    onodes = dbn.observed;
    evidence(onodes,:) = ev( onodes, : ); % all cells besides onodes are empty
elseif ex == 2 % For flag 2, create fixed observable evidence
    fprintf(['Creating evidence with isNightOwl=%d, StartTime=%d, ' ...
        'Travel=%d, Priority=%d\n'], ...
        isNightOwl, startTime, travel, priority)
    evidence = cell(7,T); % 7 nodes, T time steps
    for ii = 1:T % Iterate through evidence and fix values to event info
        evidence{1,ii} = isNightOwl;
        evidence{2,ii} = startTime;
        evidence{5,ii} = travel;
        evidence{6,ii} = priority;
    end
%%%%% Feature not implemented %%%%%
%else % For flag 3, randomness is restricted by fixing the hidden variable
%    NPT_fixed = 1;
%    F_fixed = 1;
%    disp(['Creating restricted evidence where NeedPrepTime=%d and ' ...
%        'Forgetfulness=%d'], NPT_fixed, F_fixed)
%    evidence = sampleHelp_seq( dbn, NPT_fixed, F_fixed, T );
end

%disp(evidence) % print out evidence that gets generated for debugging

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inference process: infer if user needs help over T time steps
% keep track of results and plot as we go
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup results to be stored
belief = []; % will concatenate and plot this variable
exputil = [];
subplot(1, 2, 1); % setup plot for graph

% At t=0, probability of forgetful is same as prior encoded in DBN
%prForgetful = get_field(dbn.CPD{dbn.names('Forgetfulness')},'cpt');

% get a value for it depending on its probability
%F = get_forgetfulness(prForgetful(2));

% get the prAlertness given nightOwl and starttime
%prAlertness = get_field(dbn.CPD{dbn.names('Alertness')},'cpt');
%A = get_alertness(prAlertness, isNightOwl, startTime);

% get the probability of need prep time at t=0
prNeedPrepTime = get_field(dbn.CPD{dbn.names('NeedPrepTime')},'cpt');
%prNeedPrepTime = prNeedPrepTime(A, F, priority, travel, 2);

% Start plotting prNeedPrepTime
belief = [belief, prNeedPrepTime(2)];
subplot(1, 2, 1);
plot(belief, 'o-', LineWidth=1)

% log & plot best action
[bestA, eu] = get_meu(prNeedPrepTime(2));
exputil = [exputil, eu];
fprintf('\tAt t=%d: best action = set %d reminder(s), EU = %f\n', ...
         0, bestA, eu);
subplot( 1, 2, 2 );
plot( exputil, '*-', LineWidth=1);

% At t=1, initialize the belief state 
[engine, ll(1)] = dbn_update_bel1(engine, evidence(:,1));

% get the probability of NeedPrepTime for this time step
marg = dbn_marginal_from_bel(engine, 7);
prNeedPrepTime = marg.T;

% plot prNeedPrepTime
belief = [belief, prNeedPrepTime(2)];
subplot( 1, 2, 1 );
plot( belief, 'o-', LineWidth=1);

% log best decision
[bestA, eu] = get_meu(prNeedPrepTime(2));
exputil = [exputil, eu];
fprintf('\tAt t=%d: best action = set %d reminder(s), EU = %f\n', ...
        1, bestA, eu);
subplot( 1, 2, 2 );
plot( exputil, '*-' );
 
% Repeat inference steps for each time step
for t=2:T
  % update belief with evidence at current time step
  [engine, ll(t)] = dbn_update_bel(engine, evidence(:,t-1:t));

  % extract marginals for 'needPrepTime' in current belief state
  marg = dbn_marginal_from_bel(engine, 7);
  prNeedPrepTime = marg.T;

  % log best decision
  [bestA, eu] = get_meu( prNeedPrepTime(2) );
  exputil = [exputil, eu]; 
  fprintf('\tAt t=%d: best action = set %d reminder(s), EU = %f\n', ...
           t, bestA, eu);
  subplot( 1, 2, 2 );
  plot( exputil, '*-', LineWidth=1);
  xlabel( 'Time Steps' );
  ylabel( 'EU(setReminder)' );
  axis( [ 0 T -5 5] );

  % keep track of results and plot
  belief = [belief, prNeedPrepTime(2)];
  subplot( 1, 2, 1 );
  plot( belief, 'o-' );
  xlabel( 'Time Steps' );
  ylabel( 'Pr(NeedPrepTime)' );
  axis( [ 0 T 0 1] );
  pause(0.01);
end

% Return the best Action from the last simulated time step
bestAction = bestA; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function forgetful = get_forgetfulness(prForgetful)
% forgetful = get_forgetfullness(prForgetful)
%   ! ONLY use for t=0 !
%   Determines level of forgetfulness depending on the probability of
%   forgetfulness.
if prForgetful > 0.5
    forgetful = 2;

% If probability is 0.5, then take a random number
elseif prForgetful == 0.5
    forgetful = get_forgetfulness(rand(1));

% If probability is less than 0.5, then return false: 1
else
    forgetful = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function alertness = get_alertness(prAlertness, isNightOwl, startTime)
% alertness =  get_alertness(prAlertness, isNightOwl, startTime)
%   ! ONLY use for t=0 !
%   Determines the level of alertness depending on the probability
prLow = prAlertness(isNightOwl, startTime, 1);
prMed = prAlertness(isNightOwl, startTime, 2);
prHigh= prAlertness(isNightOwl, startTime, 3);
if (prLow > prMed) && (prLow > prHigh)
    alertness = 1;
elseif (prMed > prLow) && (prMed > prHigh)
    alertness = 2;
else
    alertness = 3;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%