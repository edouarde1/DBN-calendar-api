% Initialize the Bayes' Net Toolbox
% Get the current directory (to come back to after initializing)
currentFolder = pwd;
% To avoid Windows/Mac compatibility issues, run cd commands separate
cd ..
cd bnt-master
% add the path to BNT to the Matlab session
addpath( genpathKPM( pwd ))
% Initialize the BNT
%test_BNT;
% Return to DBN-calendar-api directory
cd(currentFolder)