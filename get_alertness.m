function alertness = get_alertness(prAlertness, isNightOwl, startTime)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

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