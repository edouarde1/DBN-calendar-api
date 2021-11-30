function val = util( needPrepTime )
% function val = util( needHelp )
% Action is to set reminders in Google Calendar
%
% needPrepTime = 1 (false), 2 (true)
%
% utility value range: [-5, +5]

% reference point
val = 0;

% Penalty: disruption
% Reminders are supposed to be disruptful, but that in itself not great
val = val - 0.5

% if prepTime is NOT needed
% then user doesn't need a reminder
% so a reminder would be VERY disruptful and pointless
if needPrepTime == 1
    val = val - 2.5

% if prepTime IS needed
% then user does need a reminder
% so a reminder would be helpful
else
    val = val + 4

end
