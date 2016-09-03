
string ReplicateChooseNextAction(GameState state)
{
    if (__item_desired_to_replicate == $item[none])
        return "";
    if (state.used_replicator)
        return "";
    if (state.current_location != LOCATION_QUARTERS)
        return tryToReachLocation(state, LOCATION_QUARTERS);
    else if (state.sublocation == "")
    {
        return "Use the Replicator";
    }
    else if (state.sublocation == "quarters_replicator")
    {
        string match = "";
        if (__item_desired_to_replicate == $item[Unstable Pointy Ears])
        {
            match = findOptionMatchingSubstrings(state, "Ears, Pointy");
        }
        else if (__item_desired_to_replicate == $item[Shot of Kardashian Gin])
        {
            match = findOptionMatchingSubstrings(state, "Gin, Kardashian, Shot");
        }
        else if (__item_desired_to_replicate == $item[Riker's Search History])
        {
            match = findOptionMatchingSubstrings(state, "History, Search, Riker's");
        }
        else if (__item_desired_to_replicate == $item[Tea, Earl Grey, Hot])
        {
            match = findOptionMatchingSubstrings(state, "Tea, Earl Grey, Hot");
        }
        else if (__item_desired_to_replicate == $item[Memory Disk, Alpha])
        {
            match = findOptionMatchingSubstrings(state, "Memory Disk, Alpha");
        }
        if (match == "") //they probably don't have it unlocked yet
        {
            //should this be an abort? hmm... probably, since we are reentrant. They can just re-run the script, and we'll start again.
            abort("Unable to replicate " + __item_desired_to_replicate + ". Re-run the script and pick something else (or nothing) to replicate.");
            state.used_replicator = true; //just assume yes
            return findOptionMatchingSubstrings(state, "Nothing, for now.");
        }
        else
            return match;
    }
    else
        return tryToReachLocation(state, LOCATION_QUARTERS);
    
    return "";
}