from os import path

# Read text from user_profile.txt
def read_profile():
    infile = open("user_profile.txt", "r", encoding="utf-8")
    info = infile.read().split("\n")
    user = {"name" : info[0],
            "calendarName" : info[1],
            "forgetful" : int(info[2]),
            "isNightOwl" : int(info[3])}
    infile.close()
    print(f"Welcome back, {user['name']}!\n")
    return user
         
# Write text to user_profile.txt   
def write_profile(user):
    print("Saving Profile...")
    outfile = open("user_profile.txt", "w", encoding="utf-8")
    outfile.write(str(user["name"]) + '\n' 
                  + str(user["calendarName"]) + '\n'
                  + str(user["forgetful"]) + '\n'
                  + str(user["isNightOwl"]))
    outfile.close()
    if path.exists("user_profile.txt"):
        print("Profile saved successfully.")
    else:
        print("Error saving profile")

# Check user's input for new user questions
def confirm_input(question):
    # Ask the question
    ans = input(question)
    
    # Depending on the question, check if input is appropriate
    if "forgetful" in question and not ("low" in ans.lower() or "med" in ans.lower() or "high" in ans.lower()):
        print("Please specify low, med, or high.")
        confirm_input(question)
    if "night owl" in question and not ("yes" in ans.lower() or "no" in ans.lower()):
        print("Please specify yes or no")
        confirm_input(question)
        
    # Ask user to confirm input
    check = input(f'You entered \'{ans}\'. Is this correct? ')
    check = check.lower()
    if 'y' in check:
        if "Calendar" in question: return ans
        if "forgetful" in question:
            if ans == "low": return 1
            if ans == "med": return 2
            if ans == "high": return 3
        if "owl" in question:
            if ans == "yes": return 2
            if ans == "no": return 1
    else:
        confirm_input(question)

# Ask questions to create user profile
def new_user():
    user = {}
    print("Welcome to the Google Calendar Reminder System.")
    user["name"] = input('Please enter your name: ')
    print(f'Hi, {user["name"]}.')
    print('To begin, please answer the following questions.')
    user["calendarName"] = confirm_input('What is the name of the Google Calendar you want to set reminders for? ')
    user["forgetful"] = confirm_input('How forgetful are you (low, med, high)? ')
    user["isNightOwl"] = confirm_input('Would you consider yourself a night owl, meaning that you prefer or tend to stay up late and go to sleep late (yes/no)? ')
    print(f'Thank you, {user["name"]}.')
    write_profile(user)
    return user
    