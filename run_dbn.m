function bestAction = run_dbn(ex, isNightOwl, startTime, travel, priority)
    dbn = mk_needPrepTime;
    bestAction = sim_decision(dbn, ex, isNightOwl, startTime, travel, priority);
end