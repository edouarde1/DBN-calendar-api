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