
string UnknownChooseNextAction(GameState state)
{
	//We don't know the aliens? Head to the bridge, talk to them.
    if (state.current_location != LOCATION_BRIDGE)
        return tryToReachLocation(state, LOCATION_BRIDGE);
    else
    {
        //Talk to them:
        if (state.sublocation == "" && state.current_button_choices contains "Speak with the alien")
        {
            return "Speak with the alien";
        }
        else
        {
            //Talk to uhura:
            if (state.current_location != LOCATION_BRIDGE)
                return tryToReachLocation(state, LOCATION_BRIDGE);
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
            }
        }
    }
    return "";
}