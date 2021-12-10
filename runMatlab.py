import matlab.engine

# Start Matlab, Initialize BNT, pass the engine back
def initialize():
    eng = matlab.engine.start_matlab()
    eng.init(nargout=0);
    return eng;

# Make the DBN model and pass the model back
def run_dbn(eng, isNightOwl, event):
    setting = 2 # SETTINGS= 1: random simulation  2: event simulation
    startTime = event['my_startTimeType'] # 1, 2, or 3
    travel = event['my_travel'] # 1 or 2
    priority = event['my_priority'] # 1 or 2
    best_action = eng.run_dbn(setting, isNightOwl, startTime, travel, priority);
    return best_action

def stop_matlab(eng):
    eng.quit()