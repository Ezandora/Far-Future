
string BorgChooseNextAction(GameState state)
{
    /*
    Run plan:
    Talk to Jicky, ask him about the computer.
    Go to the holofloor, educate ourselves about the computer machine.
    Go to our quarters, hack into borg ship.
    */
    if (state.skill_levels[SKILL_TYPE_HACKING] != SKILL_LEVEL_AMAZING)
    {
        if (!state.asked_jicky_about_the_computer)
        {
            //Head to engineering:
            if (state.current_location != LOCATION_ENGINEERING)
                return tryToReachLocation(state, LOCATION_ENGINEERING);
            else if (state.sublocation == "")
            {
                if (state.occupations_to_names["Chief Engineer"] == "")
                {
                    //@ffa_ishere@ bug
                    foreach s in $strings[Johnny,Jicky,Dobby,Lonny,Tommy,Robby,Dougy,Ronny] //FIXME don't know if that's all of them
                    {
                        string match = findOptionMatchingSubstrings(state, "Speak to " + s);
                        if (match != "")
                            return match;
                    }
                    print("@ffa_ishere@ bug active, can't continue");
                    return "";
                }
                else
                    return findOptionMatchingSubstrings(state, "Speak to " + state.occupations_to_names["Chief Engineer"]);
            }
            else if (state.sublocation == "conversation_jicky_main")
            {
                return findOptionMatchingSubstrings(state, "Tell me about the computer");
            }
            else
            {
                return tryToReachLocation(state, LOCATION_ENGINEERING);
            }
        }
        else
        {
            if (state.current_location != LOCATION_HOLOFLOOR || state.sublocation != "")
                return tryToReachLocation(state, LOCATION_HOLOFLOOR);
            else
            {
                return findOptionMatchingSubstrings(state, "Computer, activate Computers for Dummies program");
            }
            
        }
    }
    else
    {
        if (state.current_location != LOCATION_QUARTERS)
            return tryToReachLocation(state, LOCATION_QUARTERS);
        else if (state.sublocation == "")
        {
            return findOptionMatchingSubstrings(state, "Access the Computer");
        }
        else if (state.sublocation == "quarters_computer")
        {
            string match = findOptionMatchingSubstrings(state, "Execute &quot;ssh ");
            if (match == "")
                state.borg_failed = true;
            return match;
        }
        else
            return tryToReachLocation(state, LOCATION_QUARTERS);
    }
    return "";
}