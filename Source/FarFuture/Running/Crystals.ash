
string CrystalsChooseNextAction(GameState state)
{
    /*
    Run plan:
    Acquire flute.
    Play flute in quarters to acquire skill.
    Hail alien, play skilled flute at alien.
    Talk to uhura, ask her what we should do.
    Hail alien again, play skilled flute.
    */
    if (state.item_currently_carrying != ITEM_FLUTE)
    {
        return tryToAcquireItem(state, ITEM_FLUTE);
    }
    else
    {
        if (state.skill_levels[SKILL_TYPE_FLUTE] != SKILL_LEVEL_AMAZING)
        {
            //Go to quarters:
            if (state.current_location != LOCATION_QUARTERS || state.sublocation != "")
                return tryToReachLocation(state, LOCATION_QUARTERS);
            else
                return "Play the flute for a while";
        }
        else
        {
            if (state.current_location != LOCATION_BRIDGE)
                return tryToReachLocation(state, LOCATION_BRIDGE);
            else
            {
                if (!state.played_amazing_flute_for_crystal_aliens)
                {
                    if (state.sublocation == "")
                    {
                        return findOptionMatchingSubstrings(state, "Speak to ", "Uhura");
                    }
                    else if (state.sublocation == "conversation_uhura_main")
                    {
                        return findOptionMatchingSubstrings(state, "Will you please hail the alien vessel?");
                    }
                    else
                        return tryToReachLocation(state, LOCATION_BRIDGE);
                    
                }
                else if (!state.phase_state_will_be_modulated)
                {
                    //Ask uhura about that:
                    if (state.sublocation == "")
                    {
                        return findOptionMatchingSubstrings(state, "Speak to ", "Uhura");
                    }
                    else if (state.sublocation == "conversation_uhura_main")
                    {
                        return findOptionMatchingSubstrings(state, "What do you think we should do?");
                    }
                    else
                        return tryToReachLocation(state, LOCATION_BRIDGE);
                }
                else
                {
                    if (state.sublocation == "")
                    {
                        return findOptionMatchingSubstrings(state, "Speak to ", "Uhura");
                    }
                    else if (state.sublocation == "conversation_uhura_main")
                    {
                        return findOptionMatchingSubstrings(state, "Will you please hail the alien vessel?");
                    }
                    else
                        return tryToReachLocation(state, LOCATION_BRIDGE);
                }
            }
        }
    }
    
    return "";
}