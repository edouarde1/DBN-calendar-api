# pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib

from __future__ import print_function
import datetime
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

# Ensure you have credentials.json from console.cloud.google.com in directory
# Delete the token.json file if scope changes or if error running
SCOPES = ['https://www.googleapis.com/auth/calendar']

# Establish connection using credentials
def establish_connection():
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
def get_color(colorId):
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
def get_startTime_Type(startTime):
    time = int(startTime.split(":")[0])
    if(time < 11): return "morning"
    elif(time > 17): return "night"
    else: return "day"           
    
# Parses the dateTime String to get the start date and start time separately
def format_date(raw_dateTime):
    dt = raw_dateTime.split('T')
    startDate = dt[0]
    startTime = dt[1].split('-')[0]

    return startDate, startTime;

# Calculates the length of the event (end time - start time)
def get_length(start_string, end_string):
    format = "%Y-%m-%d %H:%M:%S"
    
    startDate, startTime = format_date(start_string)
    start_dt_str = startDate + " " + startTime
    start_dt_obj = datetime.datetime.strptime(start_dt_str, format)
    
    endDate, endTime = format_date(end_string)
    end_dt_str = endDate + " " + endTime
    end_dt_obj = datetime.datetime.strptime(end_dt_str, format)
    
    return (end_dt_obj - start_dt_obj)

# From reminders object, make the reminders readable
def get_reminders(reminders):
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

# Prints event details to terminal
def print_event(event):
    start_string = event['start'].get('dateTime')
    end_string = event['end'].get('dateTime')
    startDate, startTime = format_date(start_string)
    startTimeType = get_startTime_Type(startTime)
    length = get_length(start_string, end_string)
    reminders = get_reminders(event['reminders'])
    color = get_color(event['colorId'])
    priority = 'T' if color == 'tomato' else 'F' 
    travel = 'T' if ("location" in event) and ('http' not in event['location']) else 'F'
    print(event['summary'])
    print('\t- Date:', startDate)
    print('\t- Start:', startTime, startTimeType)
    print('\t- Length:', length)
    print('\t- Color:', color)
    print('\t- Priority:', priority)
    print('\t- Travel:', travel)
    print('\t- Reminders:', get_reminders(event['reminders']))   

    return {'Date' : startDate, 'Start':startTime, 'startTimeType' : startTimeType, 'Priority' : priority, 'travel' : travel ,'Reminders' : reminders}

# If storing the information in a text file (TODO: REMOVE IF GIVING DIRECTLY TO MATLAB)
def store_event_info(info_dict):
    with open("eventInfo", "w", encoding="utf-8") as outfile:
        for key in info_dict:
            outfile.write(info_dict[key])

# Retrieve and print upcoming events
# TODO: how to get these results to Matlab?
def get_upcoming_events(service, calId):
    # Get upcoming events (max. 10)
    now = datetime.datetime.utcnow().isoformat() + 'Z' # 'Z' indicates UTC time
    print('\nUPCOMING EVENTS')
    events_result = service.events().list(calendarId=calId, timeMin=now,
                                        maxResults=10, singleEvents=True,
                                        orderBy='startTime').execute()
    events = events_result.get('items', [])

    if not events:
        print('No upcoming events found.')
    for event in events:
        store_event_info(print_event(event)) # prints values for debugging and also stores in txt file

    return events

def update_numReminder (service, event, calId ,numReminder):
    
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


def main():
    
        # Establish the connection using credentials
        service = establish_connection()

        # The name of the calendar to access
        myCalName = 'COSC329 Project Calendar'
       
        # Get Calendar List
        response = service.calendarList().list().execute()
        calendarsList = response.get('items')
    
        # Retreive the calendar
        for c in calendarsList:
            if(c["summary"] == myCalName):
                myCalendar = c
    
        # Confirm the calendar
        print('\nMy Calendar: ', end="")
        print(myCalendar["summary"])
    
        # Get the upcoming events
        events = get_upcoming_events(service, myCalendar["id"])
    

        # TODO: Run Matlab code from this Python program
        
        # TODO: Get best action from Matlab result
        
        # TODO: Do the best action
        
        # Update Number of reminders
        for event in events:
            print(event)
            if(update_numReminder(service, event, myCalendar["id"],  4 )):
                print("UPDATED REMINDERS")
                print_event(event)

        """"
    except FileNotFoundError:
        print('File missing. Ensure you have credentials.json in the directory')
    except Exception:
        print('Error')
        print('Try deleting the token.json file and re-running the program.')
        print(Exception) # TODO: what kinds of errors? provide meaningful message

        """
if __name__ == '__main__':
    main()