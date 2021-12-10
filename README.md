# Google Calendar Reminder System
COSC 329 Final Project due 12 December 2021

Authors: Edouard Eltherington and Veronica Jack

## Table of Contents
* [General Information](#general-information)
* [Language and Modules](#language-and-modules)
* [Setup](#setup)
* [Classes and Functions](#classes-and-functions)

## General Information
The purpose of this project is to use a calendar API to build a personalized reminder system. The system grabs upcoming events and decides whether any reminder notifications are appropriate depending on the user's profile. The model also considers information about the event, such as the start time, priority level, and location. The system's decsion-making process makes use of a Dynamic Bayes' Network model and utility function to decide how many, if any, reminders will be set.

Please view our [demonstration]() and [report]() to learn more about how our reminder system reacts to different types of users and events.

## Language and Modules
This program was created with the following language and module versions:

- Python 3.9.7
- matlabengineforpython R2021b
- Google client library for Python
  - google 3.0.0
  - google-api-core 2.2.1
  - google-api-python-client 2.28.0
  - google-auth 2.3.2
  - google-auth-httplib2 0.1.0
  - google-auth-oauthlib 0.4.6
  - googleapis-common-protos 1.53.0
- Matlab R2021b
- BayesNetToolbox 2014

## Setup
0. Please use the following resources to ensure the languages and modules are installed.
    - [Matlab engine for python](https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html)
    - [BayesNetToolbox](https://github.com/bayesnet/bnt.git)
    - Google client library for Python:

        ```
        pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
        ```
<br>

1. Go through the Google Calendar API prerequisites
    - Create or have a Google Cloud Platform project with the Google Calendar API enabled. For help, refer to [Create a project and enable the API](https://developers.google.com/workspace/guides/create-project).
    - Create and download authorization credentials for a desktop application. For help, refer to [Create credentials](https://developers.google.com/workspace/guides/create-credentials).
<br><br>

2. Check that all files are present and in the correct directories according to the graph below:

    ```
    Parent Directory
    |   
    └─── bnt-master (contains BayesNetToolbox)
    |    
    └─── DBN-calendar-api
        |  credentials.json
        |  get_meu.m
        |  init.m
        |  main.py
        |  mk_needPrepTime.m
        |  profile.py
        |  README.md
        |  run_dbn.m
        |  runmatlab.py
        |  sim_decision.m
        |  updatereminders.py
        |  util.m
    ```

3. Make sure the code will be running in the file directory. If you are using Visual Studio Code, you can check this setting with these steps:
    1. Go to `File` > `Preferences` > `Settings`
    2. Search for "execute in file dir"
    3. Check the box for "When executing a file in terminal, whether to use execute the file's directory, instead of the current open folder"

You are now ready to execute main.py.

*Please note that Matlab does not need to be running when main.py is executed. Python will run Matlab and initialize the BNT itself as long as the files are in the appropriate directories*

## Classes and Functions
This project has 2 core parts:
1. The python code which interacts with the user, the Matlab code, and the user's Google Calendar
2. The Matlab code that takes input from the python code, creates a Dynamic Bayes' Network model, determines the best action, and returns the best action to the python code.

### Python
#### main.py
- Main file that the user runs; uses the other python files to interact with the user, Google Calendar, and Matlab.

#### profile.py
- Used by main.py to ask the user questions to build a user profile.
- Questions asked include the user's name, level of forgetfulness, sleeping habit, and Google Calendar name.

#### runmatlab.py
- Used by main.py to initialize the Bayes' Net Toolbox, create the DBN model from the user's profile, and determine the best number of reminders for each event.

#### updatereminders.py
- Used by main.py to access the user's Google Calendar and retrieve upcoming events
- After the best action is determined, this class also implements the best action by updating the number of reminders on the upcoming events.

### Matlab

#### init.m
- Used by updatereminders.py to open Matlab and initialize the Bayes' Net Toolbox.

#### run_dbn.m
- Used by updatereminders.py to run mk_needPrepTime.m and sim_decision.m

#### mk_needPrepTime.m
- Creates the DBN model based on our intuitions described in our report.

#### sim_decision.m
- Simulation environment that provides the best action after simulating the event with the DBN over 70 time steps.

#### get_meu.m
- Action-selection function which determines how many reminders to set based on the probability of needing preparation time.

#### util.m
- Function that determines the utility of setting a reminder depending on whether or not it was needed.

