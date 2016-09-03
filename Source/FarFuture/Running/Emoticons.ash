string EmoticonsChooseNextAction(GameState state)
{
    /*
    Run plan:
    Talk to uhura, talk to ship, pick the last option.
    Go to holofloor, run the recreational program until there's nothing more to do.
    */
    if (state.lies_told_crew != TOLD_CREW_ICE_CREAM_AND_PROBABLY_WILL_SURVIVE)
    {
        return reassureCrewWithCleverLies(state);
    }
    else
    {
        if (state.current_location != LOCATION_HOLOFLOOR || state.sublocation != "")
            return tryToReachLocation(state, LOCATION_HOLOFLOOR);
        else
        {
            return findOptionMatchingSubstrings(state, "Computer, activate a random recreation program.");
        }
        
    }
    return "";
}