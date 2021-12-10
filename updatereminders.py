# pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib

import matlab.engine
import datetime
import os.path
import runmatlab as rm
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

# Ensure you have credentials.json from console.cloud.google.com in directory
# Delete the token.json file if scope changes or if error running
SCOPES = ['https://www.googleapis.com/auth/calendar']

# Establish connection using credentials
def __establish_connection():
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    # HTTP object used to make requests. Has timeout set by default.
    return build('calendar', 'v3', credentials=creds)

# Determines event color from Google Calendar code
def __get_color(colorId):
    colorId = int(colorId)
    switch = { # default calendar colour is purple ("grape")
        1 : "lavender",     # lavender
        2 : "sage",         # light green
        4 : "flamingo",     # pink
        5 : "banana",       # yellow
        6 : "tangerine",    # orange
        7 : "peacock",      # light blue
        8 : "graphite",     # grey
        9 : "blueberry",    # dark blue
        10: "basil",        # dark green
        11: "tomato"        # red   
    }
    return switch.get(colorId, "invalid input") 

# Determines if the event starts in the morning, day, or night
def __get_startTime_Type(startTime):
    time = int(startTime.split(":")[0])
    if(time < 11) and (time > 5): return 1   # morning 5am - 11am
    elif(time > 17) or (time < 5): return 3  # night 5pm - 5am
    else: return 2                           # day 11am - 5pm
    
# Parses the dateTime String to get the start date and start time separately
def __format_date(raw_dateTime):
    dt = raw_dateTime.split('T')
    startDate = dt[0]
    startTime = dt[1].split('-')[0]
    return startDate, startTime;

# Calculates the length of the event (end time - start time)
def __get_length(start_string, end_string):
    format = "%Y-%m-%d %H:%M:%S"
    
    startDate, startTime = __format_date(start_string)
    start_dt_str = startDate + " " + startTime
    start_dt_obj = datetime.datetime.strptime(start_dt_str, format)
    
    endDate, endTime = __format_date(end_string)
    end_dt_str = endDate + " " + endTime
    end_dt_obj = datetime.datetime.strptime(end_dt_str, format)
    
    return (end_dt_obj - start_dt_obj)

# From reminders object, make the reminders readable
def __get_reminders(reminders):
    result = ''
    if("overrides" not in reminders): result = 'None'
    else:
        overrides = reminders['overrides']
        reminderList = []
        for ov in overrides:
            if 'minutes' in ov: reminderList.append(str(ov['minutes']) + ' ' + 'minutes')
        for r in reminderList:
            result += '\n\t\t- ' + r
    return result

# Prints event details to terminal and adds formatted values to event object
def __print_event(event):
    start_string = event['start'].get('dateTime')
    end_string = event['end'].get('dateTime')
    startDate, startTime = __format_date(start_string)
    my_startTimeType = __get_startTime_Type(startTime)
    length = __get_length(start_string, end_string)
    reminders = __get_reminders(event['reminders'])
    color = __get_color(event['colorId'])
    my_priority = 2 if color == 'tomato' else 1 # Matlab formatting: 1-False, 2-True
    my_travel = 2 if ("location" in event) and ('http' not in event['location']) else 1
    print(event['summary'])
    print('\t- Date:', startDate)
    print('\t- Start:', startTime, my_startTimeType)
    print('\t- Length:', length)
    print('\t- Color:', color)
    print('\t- Priority:', my_priority)
    print('\t- Travel:', my_travel)
    print('\t- Reminders:', reminders)
    
    event['my_startTimeType'] = my_startTimeType
    event['my_travel'] = my_travel
    event['my_priority'] = my_priority

    return event

# Retrieve and print upcoming events (max. 10)
def __get_upcoming_events(service, calId):
    now = datetime.datetime.utcnow().isoformat() + 'Z' # 'Z' indicates UTC time
    print('\n=====UPCOMING EVENTS=====')
    events_result = service.events().list(calendarId=calId, timeMin=now,
                                        maxResults=2, singleEvents=True, # TODO: CHANGE BACK TO 10
                                        orderBy='startTime').execute()
    events = events_result.get('items', [])
    
    if not events:
        print('No upcoming events found.')
    
    for i in range(len(events)):
        events[i] = __print_event(events[i]) # prints values for debugging

    return events

# Update the number of reminders on the event
def __update_numReminder(service, event, calId ,numReminder):
    if(numReminder in [0, 1, 2, 3]):
        reminders = event['reminders']
        
        if(numReminder == 0 and 'overrides' in reminders):
            del reminders['overrides']
        elif(numReminder == 1):    # One reminder 10 min before 
            reminders['overrides'] = [{'method': 'popup', 'minutes': 10}]
        elif(numReminder == 2):   # reminder 10 min , 1  hour before
            reminders['overrides'] = [{'method': 'popup', 'minutes': 10}, {'method': 'popup', 'minutes': 60}]
        elif(numReminder == 3):
            reminders['overrides'] = [{'method': 'popup', 'minutes': 10}, {'method': 'popup', 'minutes': 60}, {'method': 'popup', 'minutes': 1440}]    # reminder 10 min, 1 hour, 1 day before
        
        reminders['useDefault'] = False     
        service.events().update(calendarId=calId, eventId=event['id'], body=event).execute()
        return True
        
    else:
        print("No Update. Invalid number of reminders.")
        return False

# Called from main.py to update the reminders for upcoming events in the calendar specified
def update_reminders(calendarName, isNightOwl):
        # Establish the connection using credentials
        service = __establish_connection()
       
        # Get Calendar List
        response = service.calendarList().list().execute()
        calendarsList = response.get('items')
    
        # Retreive the calendar
        for c in calendarsList:
            if(c["summary"] == calendarName):
                myCalendar = c
    
        # Confirm the calendar
        print(f"\nCalendar Retrieved: {myCalendar['summary']}")
    
        # Get the upcoming events
        events = __get_upcoming_events(service, myCalendar["id"])
    
        # Open Matlab, init BNT, make model
        print('\nOpening Matlab and initializing the BNT...')
        eng = rm.initialize()
        
        # Go through upcoming events, pass to Matlab, get action, do action
        for event in events:         
            print(f"\nPassing values to Matlab for {event['summary']}...")
            
            best_action = rm.run_dbn(eng, isNightOwl, event)
            print(f"\nThe number of reminders recommended for {event['summary']} is to set {best_action} reminder(s).")
            
            print("\n===== BEFORE UPDATE =====")
            __print_event(event)
            
            if(__update_numReminder(service, event, myCalendar["id"],  best_action )):
                print("\n===== AFTER UPDATE =====")
                __print_event(event)
            else:
                print("\n===== NO REMINDER SET =====")
        
        rm.stop_matlab(eng)

        """"
    except FileNotFoundError:
        print('File missing. Ensure you have credentials.json in the directory')
    except Exception:
        print('Error')
        print('Try deleting the token.json file and re-running the program.')
        print(Exception) # TODO: what kinds of errors? provide meaningful message

        """