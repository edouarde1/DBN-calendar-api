function prNeedPrepTime = sim_decision(dbn, ex, isNightOwl, startTime, travel, priority)
% function prNeedPrepTime = sim_decision(dbn, forgetful, isNightOwl)
% ARGS: dbn = dynamic bayes net model specified by BNT syntax
%       ex = setting used to generate evidence
%            (1=random, 2=fixed observable, 3=fixed hidden)
%       forgetful = forgetfulness of the user (1=low, 2=med, 3=high)
%       isNightOwl = if user is nightowl (1=false, 2=true)
% Note: The user values forgetful and isNightOwl fix the evidence

engine = bk_inf_engine(dbn); % set up inference engine
T = 30;

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
    for ii = 1:2 % Iterate through evidence and fix values to event info
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

% at t=0, no evidence has been entered, so the probability is same as the
% prior encoded in the DBN itself

prForgetful = get_field( dbn.CPD{ dbn.names('Forgetfulness') }, 'cpt' )
belief = [belief, prForgetful(2)];
subplot(1, 2, 1);
plot(belief, 'o-', LineWidth=1)

% log best decision
[bestA, eu] = get_meu( prForgetful(2) );
exputil = [exputil, eu];
fprintf('t=%d: best action = %s, eu = %f\n', 0, bestA, eu);
subplot( 1, 2, 2 );
plot( exputil, '*-', LineWidth=1);

% at t=1: initialize the belief state 
[engine, ll(1)] = dbn_update_bel1(engine, evidence(:,1));

marg = dbn_marginal_from_bel(engine, 1);
prForgetful = marg.T
belief = [belief, prForgetful(2)];
subplot( 1, 2, 1 );
plot( belief, 'o-', LineWidth=1);

% log best decision
[bestA, eu] = get_meu( prForgetful(2) );
exputil = [exputil, eu];
fprintf('t=%d: best action = %s, eu = %f\n', 0, bestA, eu);
subplot( 1, 2, 2 );
plot( exputil, '*-' );

% Repeat inference steps for each time step
for t=2:T
  % update belief with evidence at current time step
  [engine, ll(t)] = dbn_update_bel(engine, evidence(:,t-1:t));
  
  % extract marginals of the current belief state
  i = 1;
  marg = dbn_marginal_from_bel(engine, i);
  prForgetful = marg.T;

  % log best decision
  [bestA, eu] = get_meu( prForgetful(2) );
  exputil = [exputil, eu]; 
  fprintf('t=%d: best action = %s, eu = %f\n', t, bestA, eu);
  subplot( 1, 2, 2 );
  plot( exputil, '*-', LineWidth=1);
  xlabel( 'Time Steps' );
  ylabel( 'EU(Help)' );
  axis( [ 0 T -5 5] );

  % keep track of results and plot it
  belief = [belief, prForgetful(2)];
  subplot( 1, 2, 1 );
  plot( belief, 'o-' );
  xlabel( 'Time Steps' );
  ylabel( 'Pr(NeedHelp)' );
  axis( [ 0 T 0 1] );
  pause(0.01);
end



