# Main File to run

from os import path
import profile as p
import updatereminders as ur

def main(): 
    if not path.exists("user_profile.txt"):
        profile = p.new_user()
    else:
        profile = p.read_profile()
    
    cont = input('This program will now ask you to log into your Google Account to access your Google Calendar.\nPlease press \'y\' to continue or press any other letter to quit.\n')
    if cont.lower() == 'y':
        print(f"Updating reminders for {profile['name']}\'s calendar: {profile['calendarName']}")
        ur.update_reminders(profile["calendarName"])
        print("Update complete.\nGoodbye.")
    else:
        quit()

if __name__ == '__main__':
    main()