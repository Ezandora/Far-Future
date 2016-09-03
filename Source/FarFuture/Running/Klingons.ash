
string KlingonsChooseNextAction(GameState state)
{
    /*
    Run plan:
    Educate ourselves in gunnery.
    Fire a warning shot across their bow.
    Hail them and choose the section option.
    */
    
    if (state.skill_levels[SKILL_TYPE_GUNNER] != SKILL_LEVEL_AMAZING)
    {
        if (state.current_location != LOCATION_HOLOFLOOR || state.sublocation != "")
            return tryToReachLocation(state, LOCATION_HOLOFLOOR);
        else
            return findOptionMatchingSubstrings(state, "Computer, activate program Kobayashi Maru"); //such a cute kitty! what do you mean, not that maru?
    }
    else
    {
        //Fire a warning shot across their nose.
        if (state.current_location != LOCATION_BRIDGE)
            return tryToReachLocation(state, LOCATION_BRIDGE);
        else if (!state.fired_amazing_warning_shot)
        {
            if (state.sublocation != "weapons_console")
            {
                if (state.sublocation != "")
                    return tryToReachLocation(state, LOCATION_BRIDGE);
                else
                    return findOptionMatchingSubstrings(state, "Sit at the Weapons Console");
            }
            else
            {
                return findOptionMatchingSubstrings(state, "Fire a Warning Shot");
            }
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
            {
                return tryToReachLocation(state, LOCATION_BRIDGE);
            }
        }
    }
    return "";
}