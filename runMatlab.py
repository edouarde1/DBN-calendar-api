import matlab.engine

# Start Matlab
eng = matlab.engine.start_matlab()

# Initialize the BayesNetToolbox
eng.init(nargout=0)

