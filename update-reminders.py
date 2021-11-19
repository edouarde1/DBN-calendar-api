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

# Parses the dateTime String (could do this better?)
def format_date(raw_dateTime):
    dt = raw_dateTime.split('T')
    startDate = dt[0]
    startTime = dt[1].split('-')[0]
    return startDate, startTime;

# Calculates the length of the event
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

    if(reminders['useDefault'] == True or not "overrides" in reminders): result = 'None'
    else:

        overrides = reminders['overrides']
        
        reminderList = []
        for ov in overrides:
            if 'minutes' in ov: reminderList.append(str(ov['minutes']) + ' ' + 'minutes')
        for r in reminderList:
            result += '\n\t\t- ' + r
    return result

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
        start_string = event['start'].get('dateTime')
        end_string = event['end'].get('dateTime')
        startDate, startTime = format_date(start_string)
        print(event['summary'])
        print('\t- Date:', startDate)
        print('\t- Start:', startTime)
        print('\t- Length:', get_length(start_string, end_string))
        print('\t- Colour:', get_color(event['colorId']))
        print('\t- Reminders:', get_reminders(event['reminders']))

    return events

def update_numReminder (service, event, calId ,numReminder):
    if(numReminder == 1):    # One reminder 10 min before 
        event['overrides'] = [{'method': 'popup', 'minutes': 10}]
        updated_event = service.events().update(calendarId=calId, eventId=event['id'], body=event).execute()
    elif(numReminder == 2):   # reminder 10 min , 1  hour before
        event['overrides'] = [{'method': 'popup', 'minutes': 10}, {'method': 'popup', 'minutes': 60}]
        updated_event = service.events().update(calendarId=calId, eventId=event['id'], body=event).execute()
    elif(numReminder == 3):
        event['overrides'] = [{'method': 'popup', 'minutes': 10}, {'method': 'popup', 'minutes': 60},{'method': 'popup', 'minutes': 1440}]    # reminder 10 min, 1 hour, 1 day before
    else:
        print("No Update")


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
            update_numReminder(service, event, myCalendar["id"], 2 )
            if("overrides" in event):
                print(event['reminders'])
                print(event['overrides'])

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