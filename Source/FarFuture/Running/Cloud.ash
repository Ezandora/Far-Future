
string CloudChooseNextAction(GameState state)
{
    /*
    Run plan:
    Find drink, collect it.
    Go to the holofloor, waste time.
    Waste time until 40.
    Go to bridge, page troi, give her the drink, choose the right option.
    */
    
    if (state.lies_told_crew != TOLD_CREW_ICE_CREAM_AND_PROBABLY_WILL_SURVIVE)
    {
        return reassureCrewWithCleverLies(state);
    }
    else if (!state.gave_troi_alcohol && state.item_currently_carrying != ITEM_DRINK)
    {
        return tryToAcquireItem(state, ITEM_DRINK);
    }
    else
    {
        if (state.minutes_in < 40)
        {
            if (state.minutes_in < 34)
            {
                if (state.current_location != LOCATION_HOLOFLOOR || state.sublocation != "")
                    return tryToReachLocation(state, LOCATION_HOLOFLOOR);
                else
                    return findOptionMatchingSubstrings(state, "Computer, activate a random recreation program.");
            }
            if (state.sublocation != "" || state.current_location != LOCATION_BRIDGE)
                return tryToReachLocation(state, LOCATION_BRIDGE);
            else
                return "Wait a minute";
        }
        else if (state.current_location != LOCATION_BRIDGE)
            return tryToReachLocation(state, LOCATION_BRIDGE);
        else if (state.sublocation == "")
        {
            //Deal with @ffa_ishere@ bug:
            string match = findOptionMatchingSubstrings(state, "Speak to Counselor");
            if (match != "")
                return match;
            match = findOptionMatchingSubstrings(state, "Speak to Morale Officer");
            if (match != "")
                return match;
            //Is troi here? Talk to her. Otherwise, page her.
            if (state.occupations_to_last_seen_locations["Ship's Counselor"] == LOCATION_BRIDGE)
            {
                if (state.minutes_in < 40) //not worth talking to her yet
                    return "Wait a minute";
                else
                {
                    match = findOptionMatchingSubstrings(state, "Speak to " + state.occupations_to_names["Ship's Counselor"]);
                    if (match != "")
                        return match;
                    else //page troi - she was on the bridge, but left
                        return findOptionMatchingSubstrings(state, "Speak to ", "Uhura");
                }
            }
            else
            {
                return findOptionMatchingSubstrings(state, "Speak to ", "Uhura");
            }
        }
        else if (state.sublocation == "conversation_uhura_main")
        {
            if (state.last_minute_troi_was_paged_to_bridge == state.minutes_in)
            {
                return tryToReachLocation(state, LOCATION_BRIDGE);
            }
            else
            {
                //We should probably use this, but we don't need to:
                /*if (state.occupations_to_names contains "Ship's Counselor")
                {
                    abort("correct paging");
                }*/
                string match = findOptionMatchingSubstrings(state, "Please page Counselor ");
                if (match == "")
                    match = findOptionMatchingSubstrings(state, "Please page Morale Officer");
                if (match == "")
                {
                    //maybe she's there already?
                    return tryToReachLocation(state, LOCATION_BRIDGE);
                }
                return match;
            }
        }
        else
        {
            if (!state.gave_troi_alcohol)
            {
                return findOptionMatchingSubstrings(state, "Offer " + state.drink_name);
            }
            else
                return findOptionMatchingSubstrings(state, "What are you feeling?");
        }
    }
    return "";
}