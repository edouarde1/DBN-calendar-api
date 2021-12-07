# Google Calendar Reminder System
COSC 329 Final Project
UBC Okanagan Campus
Authors: Edouard Eltherington and Veronica Jack
Due 12 December 2021 

## Table of Contents
* [General Information](#general-information)
* [Language and Modules](#language-and-modules)
* [Setup](#setup)
* [Classes and Functions](#classes-and-functions)
* [Future Considerations](#future-considerations)

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
  - Google client library for Python
  ```pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib```
  - [BayesNetToolbox](https://github.com/bayesnet/bnt.git)

1. Check that all files are present and in the correct directories according to the graph below:

```
Your directory
|   
└─── bnt-master (contains BayesNetToolbox)
|    
└─── GCRS (project folder)
     |  main.py
     |  profile.py
     |  updatereminders.py

```

2. Make sure the code will be running in the file directory. If you are using Visual Studio Code, you can check this setting with these steps:
    1. Go to `File` > `Preferences` > `Settings`
    2. Search for "execute in file dir"
    3. Check the box for "When executing a file in terminal, whether to use execute the file's directory, instead of the current open folder"

You are now ready to execute [main.py](main.py)

`Please note that Matlab does not need to be running when main.py is executed. Python will run Matlab and initialize the BNT itself as long as the files are in the appropriate directories`

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

#### mk_model.m

