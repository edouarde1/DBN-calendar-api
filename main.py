# Main File to run

from os import path
import profile as p
import updatereminders as ur

def main(): 
    if not path.exists("user_profile.txt"):
        profile = p.new_user()
    else:
        profile = p.read_profile()
    
    cont = input("""The Reminder System will do the following:
        1) Ask you to log into your Google Account to access your Google Calendar.\n
        2) Access the next 10 upcoming events on your calendar.\n
        3) Initialize the Bayes Net Toolbox in Matlab.\n
        4) Determine how many, if any, reminders should be set on each event.\n
        5) Set the number of reminders in your Google Calendar\n
        Please note: Graphs will be produced to show the probability of needing a reminder along with the expected utility of setting a reminder.\n\n
        To continue, please press \'y\'\n
        To quit, press any other letter.\n
        >""")
    if cont.lower() == 'y':
        print(f"Updating reminders for {profile['name']}\'s calendar: {profile['calendarName']}")
        ur.update_reminders(profile["calendarName"], profile['isNightOwl'])
        print("Update complete.\nGoodbye.")
    else:
        quit()

if __name__ == '__main__':
    main()