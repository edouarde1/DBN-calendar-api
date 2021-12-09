
function prNeedPrepTime = sim_decision(dbn, ex, isNightOwl, startTime, travel, priority)
% function prNeedPrepTime = sim_decision(dbn, forgetful, isNightOwl)
% ARGS: dbn = dynamic bayes net model specified by BNT syntax
%       ex = setting used to generate evidence
%            (1=random, 2=fixed observable, 3=fixed hidden)
%       forgetful = forgetfulness of the user (1=low, 2=med, 3=high)
%       isNightOwl = if user is nightowl (1=false, 2=true)
% Note: The user values forgetful and isNightOwl fix the evidence

engine = bk_inf_engine(dbn); % set up inference engine
T = 70;

% sim_decision(dbn, 2, 1, 1, 1, 1)
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
else % For flag 3, randomness is restricted by fixing the hidden variable
    NPT_fixed = 1;
    F_fixed = 1;
    disp('Creating restricted evidence where NeedPrepTime=%d and Forgetfulness=%d', ...
        NPT_fixed, F_fixed)
    evidence = sampleHelp_seq( dbn, NPT_fixed, F_fixed, T );
end

%disp(evidence) % print out evidence that gets generated (not pretty)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inference process: infer if user needs help over T time steps
% keep track of results and plot as we go
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup results to be stored
belief = []; % will concatenate and plot this variable
exputil = [];
subplot(1, 2, 1); % setup plot for graph

% At t=0, probability of forgetful is same as prior encoded in DBN
prForgetful = get_field(dbn.CPD{dbn.names('Forgetfulness')},'cpt');

% get a value for it depending on its probability
F = get_forgetfulness(prForgetful(2));

% get the prAlertness given nightOwl and starttime
prAlertness = get_field(dbn.CPD{dbn.names('Alertness')},'cpt');
A = get_alertness(prAlertness, isNightOwl, startTime);

% get the probability of need prep time at t=0
prNeedPrepTime = get_field(dbn.CPD{dbn.names('NeedPrepTime')},'cpt');


belief = [belief, prNeedPrepTime(2)];
subplot(1, 2, 1);
%plot(belief1, 'o-', LineWidth=1)
plot(belief, 'o-', LineWidth=1)

% log best decision
[bestA, eu] = get_meu(prNeedPrepTime(2));
exputil = [exputil, eu];
fprintf('At t=%d: best action = %s, eu = %f\n', 0, bestA, eu);
subplot( 1, 2, 2 );
plot( exputil, '*-', LineWidth=1);

% At t=1, initialize the belief state 
[engine, ll(1)] = dbn_update_bel1(engine, evidence(:,1));

% get the probability of NeedPrepTime for this time step
marg = dbn_marginal_from_bel(engine, 7);
prNeedPrepTime = marg.T;
prNeedPrepTime;

% plot it
belief = [belief, prNeedPrepTime(2)];
subplot( 1, 2, 1 );
plot( belief, 'o-', LineWidth=1);

% log best decision
[bestA, eu] = get_meu(prNeedPrepTime(2));
exputil = [exputil, eu];
fprintf('At t=%d: best action = %s, eu = %f\n', 0, bestA, eu);
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
  fprintf('At t=%d: best action = %s, eu = %f\n', t, bestA, eu);
  subplot( 1, 2, 2 );
  plot( exputil, '*-', LineWidth=1);
  xlabel( 'Time Steps' );
  ylabel( 'EU(Reminder)' );
  axis( [ 0 T -5 5] );

  % keep track of results and plot it
  belief = [belief, prNeedPrepTime(2)];
  subplot( 1, 2, 1 );
  plot( belief, 'o-' );
  xlabel( 'Time Steps' );
  ylabel( 'Pr(NeedPrepTime)' );
  axis( [ 0 T 0 1] );
  pause(0.01);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function forgetful = get_forgetfulness(prForgetful)
%forgetful = get_forgetfullness(prForgetful)
%   Depending on the probability of forgetfulness
%   provides a value of true or false

% If the probability that forgetfulness is higher than 0.5, return true:2
if prForgetful > 0.5
    forgetful = 2;

% If probability is 0.5, then take a random number
elseif prForgetful == 0.5
    forgetful = get_forgetfulness(rand(1));

% If probability is less than 0.5, then return false: 1
else
    forgetful = 1;
end

function alertness = get_alertness(prAlertness, isNightOwl, startTime)
%alertness =  get_alertness(prAlertness, isNightOwl, startTime)
%   Determine the level of alertness depending on probability

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