# Google Calendar Reminder System
COSC 329 Final Project due 12 December 2021

Authors: Edouard Eltherington and Veronica Jack

## Table of Contents
* [General Information](#general-information)
* [Project Steps](#project-steps)
* [Language and Modules](#language-and-modules)
* [Setup](#setup)
* [Classes and Functions](#classes-and-functions)
* [Future Development](#future-development)

## General Information
The purpose of this project is to use a calendar API to build a personalized reminder system. The system grabs upcoming events and decides whether any reminder notifications are appropriate depending on the user's profile. The model also considers information about the event, such as the start time, priority level, and location. The system's decsion-making process makes use of a Dynamic Bayes' Network model and utility function to decide how many, if any, reminders will be set.

Please view our [demonstration]() and [report]() to learn more about how our reminder system reacts to different types of users and events.

## Project Steps and Timeline
The project can be broken up into four main steps:

1. Pull upcoming events from the user's Google Calendar.

2. Build a DBN with the event and user information.

3. Determine the best number of reminders using a utility function (and test with simulations).

4. Set the number of reminders for the event in the user's Google Calendar.

We completed these four steps over this timeline:

* Chose the Project Option: Calendar API Reminder System (Oct. 29)

* Decided to use Google Calendar API and Python (Oct. 31)

* Learned how to use the API to pull upcoming events from our Google Calendar and update the number of reminders on an event (Nov. 14)

* Created and adjusted a graphical model based on our intuitions (Nov. 4 - Dec. 10)

* Built and debugged the DBN based on our graphical model (Nov. 19 - Dec. 9)

* Developed the utility function to determine the best number of reminders (Nov. 26 - Dec. 9)

* Tested the program using simulations and integrated Matlab with Python (Dec. 9 - Dec. 10)

8. Complete documentation and video for submission (Dec. 12)

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

1. Complete the Google Calendar API prerequisites
    - Create or have a Google Cloud Platform project with the Google Calendar API enabled. For help, refer to [Create a project and enable the API](https://developers.google.com/workspace/guides/create-project).
    - Create and download authorization credentials for a desktop application, and change the name of the credentials file to `credentials.json`. For help, refer to [Create credentials](https://developers.google.com/workspace/guides/create-credentials). 

<br>

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

<br>

3. Make sure the code will be running in the file directory. If you are using Visual Studio Code, you can check this setting with these steps:
    1. Go to `File` > `Preferences` > `Settings`
    2. Search for "execute in file dir"
    3. Check the box for "When executing a file in terminal, whether to use execute the file's directory, instead of the current open folder"

<br>

4. Create events in your Google Calendar (take note of the name of this calendar) and ensure each event has a name, colour ('Tomato' for high-priority), start time, and location (leave blank if no travel is required).

You are now ready to execute main.py.

If you are running it for the second time but would like to change the user profile, simply delete user_profile.txt and run the program again to enter new information.

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
- Simulation settings available:
    - 1: Create random evidence
    - 2: Create fixed observable evidence (used in Project to determine the appropriate number of reminders)
    - 3: Create fixed hidden evidence (*Note: Feature unavailable*)

#### get_meu.m
- Action-selection function which determines how many reminders to set based on the probability of needing preparation time.

#### util.m
- Function that determines the utility of setting a reminder depending on whether or not it was needed.

## Future Development
As mentioned in our report, as we developed our graphical model based on our intuitions, we developed an ideal model that we realized could not be completed before the project due date.


The following are our ideas for improving or further developing the program:

- Convert the binary travel variable into a more complex one where the program can take the specified location of the event, and then look up the realistic travel time in Google Maps to determine how much travel would be required.
- Add a layer to the priority variable that looks at both the colour and name of the event. For example, if the name included "exam" or "interview" compared to "appointment" the priority level would be different.
- Determine a way to gather evidence for the user's level of forgetfulness. This could be done with the user's location and if the user arrived to events on time or at all. This would create an attendance percentage.
- Create a variable for time until the event starts from when the event was created. 
- Change NightOwl to be a variable that could change over time and have a transition function that also depends on the user's attendance and number of events at different times of day in the last couple of months.

<br>

Features that were not implemented:

- a simulation setting for fixing hidden evidence. We determined that this was not necessary for the application to function.
- use the input for the user's level of forgetfulness as evidence in the DBN. Currently, forgetfulness is a hidden and temporal variable with a transition function. Ideally, forgetfulness would be infuenced by an observable variable. See above in our list of ideas for improvements.
