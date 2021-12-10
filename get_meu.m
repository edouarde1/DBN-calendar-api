function [action, eu_reminder] = get_meu( prNeedPrepTime ) 
% function [action, eu_reminder] = get_meu( prNeedPrepTime )
% Get maximum expected utility value
% Given the probability of NeedPrepTime, there are 4 actions:
% 1) Do nothing
% 2) Set 1 reminder (10 min before event)
% 3) Set 2 reminders (10 min and 1 hr before event)
% 4) Set 3 reminders (10 min, 1 hr, and 24 hrs before event)

% Set default
action = 0; % set 0 reminders

% Compute the EU for each action 
% Expected utility of doing nothing
eu_none = 0;

% Expected utility of setting a reminder
eu_reminder = prNeedPrepTime * util(2) + (1 - prNeedPrepTime) * util(1);

% Override default if setting a reminder is
% If EU is better than doing nothing but is low
if eu_reminder > eu_none
    action = 1; % set 1 reminder
    % If EU is VERY high
    if eu_reminder > 1.5
        action = 3; % set 3 reminders
    % If EU is medium
    elseif eu_reminder > 1
        action = 2; % set 2 reminders
    end
end
