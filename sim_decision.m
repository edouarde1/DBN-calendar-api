function prNeedPrepTime = sim_decision(dbn, ex, isNightOwl, startTime, forgetful, travel, priority)
% function prNeedPrepTime = sim_decision(dbn, forgetful, isNightOwl)
% ARGS: dbn = dynamic bayes net model specified by BNT syntax
%       ex = setting used to generate evidence
%            (1=random, 2=fixed observable, 3=fixed hidden)
%       forgetful = forgetfulness of the user (1=low, 2=med, 3=high)
%       isNightOwl = if user is nightowl (1=false, 2=true)
% Note: The user values forgetful and isNightOwl fix the evidence

engine = bk_inf_engine(dbn); % set up inference engine
T = 30; % 30 time steps to view patterns over time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a series of evidence in advance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ex == 1
    disp('Creating random evidence...')
    ev = sample_dbn(dbn,T); % creates random evidence from dbn cpts
    evidence = cell(7,T);   % 7 nodes per slice, time steps
    onodes = dbn.observed;
    evidence(onodes,:) = ev(onodes,:); % all cells besides onodes are empty

elseif ex == 2
    fprintf(['Creating evidence with isNightOwl=%d, StartTime=%d, ' ...
        'Forgetfulness=%d, Travel=%d, Priority=%d\n'], ...
        isNightOwl, startTime, forgetful, travel, priority)
    evidence = cell(7,T);
    for ii = 1:T % Iterate through evidence and fix values to event info
        evidence{1,ii} = isNightOwl;
        evidence{2,ii} = startTime;
        evidence{4,ii} = forgetful;
        evidence{5,ii} = travel;
        evidence{6,ii} = priority;
    end

else
    NPT_fixed = 1; % NeedPrepTime={1=false, 2=true}
    fprintf('Creating evidence with NeedPrepTime=%d', NPT_fixed)
    evidence = sample_seq(dbn, NPT_fixed, Time);
end

% disp(evidence) % Can print out evidence - not pretty

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
prForgetful = get_field(dbn.CPD{dbn.names('Forgetfulness')},'cpt');
prForgetful
belief = [belief, prForgetful(3)];
subplot(1,2,1);
plot(belief, 'o-', LineWidth=1)

% log best decision
[bestA, eu] = get_meu(prForgetful(3));
exputil = [exputil, eu];
fprintf('t=%d: best action = %s, EU = %f\n', 0, bestA, eu);
subplot(1,2,2);
plot(exputil, '*-', LineWidth=1);

% At t=1, initialize the belief state
[engine, ll(1)] = dbn_update_bel1(engine, evidence(:,1))

marg = dbn_marginal_from_bel(engine, 1)
prForgetful = marg.T
belief = [belief, prForgetful(3)];
subplot(1,2,1);
plot(belief, 'o-', LineWidth=1);

% log best decision
[bestA, eu] = get_meu(prForgetful(3));
exputil = [exputil, eu];
fprintf('t=%d: best action = %s, EU = %f\n', 0, bestA, eu);
subplot(1,2,2);
plot(exputil, '*-', LineWidth=1);

% Repeat inference steps for each time step
for t=2:T
    % update belief with evidence at current time step
    [engine, ll(1)] = dbn_update_bel(engine, evidence(:,t-1:t));

    % extract marginals of current belief state
    i = 1;
    marg = dbn_marginal_from_bel(engine, i);
    prForgetful = marg.T;

    % log best decision
    [bestA, eu] = get_meu(prForgetful(3));
    exputil = [exputil, eu];
    fprintf('t=%d: best action = %s, EU = %f\n', 0, bestA, eu);
    subplot(1,2,2);
    plot(exputil, '*-', LineWidth=1);
    xlabel('Time Steps');
    ylabel('EU')
    axis([0 T -5 5]); % limits of EU

    % keep track of results and plot it
    belief = [belief, prForgetful(3)];
    subplot(1,2,1);
    plot(belief, 'o-', LineWidth=1)
    xlabel('Time Steps');
    ylabel('Pr(Forgetfulness) = high');
    axis([0 T 0 1]);
    pause(0.01);
end