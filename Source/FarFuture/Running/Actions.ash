

string findOptionMatchingSubstrings(GameState state, string [int] strings)
{
	foreach button_name in state.current_button_choices
    {
        boolean passes_tests = true;
        foreach key, str in strings
        {
            if (!button_name.contains_text(str))
            {
                passes_tests = false;
                break;
            }
        }
        if (passes_tests)
            return button_name;
    }
    return "";
}


string findOptionMatchingSubstrings(GameState state, string str1, string str2)
{
    string [int] strings;
    strings.listAppend(str1);
    strings.listAppend(str2);
    return findOptionMatchingSubstrings(state, strings);
}

string findOptionMatchingSubstrings(GameState state, string str1)
{
    string [int] strings;
    strings.listAppend(str1);
    return findOptionMatchingSubstrings(state, strings);
}


string escapeSublocation(GameState state)
{
    if (state.sublocation == "conversation_uhura_main")
    {
        return findOptionMatchingSubstrings(state, "That will be all, thank you ", "Uhura");
    }
    else if (state.sublocation == "weapons_console")
    {
        return findOptionMatchingSubstrings(state, "Don't Fire");
    }
    else if (state.sublocation == "conversation_jicky_main")
    {
        return findOptionMatchingSubstrings(state, "Good bye, ");
    }
    else if (state.sublocation == "conversation_bones_main")
    {
        return findOptionMatchingSubstrings(state, "I guess this conversation is over");
    }
    else if (state.sublocation == "conversation_spock_main")
    {
        return findOptionMatchingSubstrings(state, "Good day, sir");
    }
    else if (state.sublocation == "conversation_riker_main")
    {
        return findOptionMatchingSubstrings(state, "As you were");
    }
    else if (state.sublocation == "quarters_replicator")
    {
        return findOptionMatchingSubstrings(state, "Nothing, for now.");
    }
    
    
    abort("implement escaping sublocation " + state.sublocation);
    return "";
}

string tryToReachLocation(GameState state, int wanted_location_id)
{
	if (wanted_location_id == LOCATION_UNKNOWN)
        return "";
    
    //Generate plan to get there:
    if (state.sublocation != "")
        return escapeSublocation(state);
    
    if (state.current_location == LOCATION_QUARTERS && wanted_location_id != LOCATION_QUARTERS)
    {
        return "Go to the Bridge";
    }
    if (wanted_location_id == LOCATION_QUARTERS)
    {
        if (state.current_location == LOCATION_BRIDGE)
        {
            return "Go to your Quarters";
        }
    }
    if (state.current_location == LOCATION_TURBOLIFT)
    {
        if (wanted_location_id == LOCATION_BRIDGE || wanted_location_id == LOCATION_QUARTERS)
        {
            return "Go to the Bridge";
        }
        else if (wanted_location_id == LOCATION_ENGINEERING)
        {
            return "Go to Engineering";
        }
        else if (wanted_location_id == LOCATION_LOUNGE)
        {
            return "Go to the Lounge";
        }
        else if (wanted_location_id == LOCATION_HOLOFLOOR)
        {
            return "Go to the Holofloor";
        }
    }
    else
    {
        //Go to the turbolift?
        return "Enter the Turbolift";
    }
    
    return "";
}

string tryToAcquireItem(GameState state, int item_type)
{
    if (state.item_currently_carrying == item_type) //what
        return "";
    //Do we know where it is?
    if (state.item_locations[item_type] == LOCATION_UNKNOWN)
    {
        //No? Visit every room we have yet to visit.
        for i from 1 to 6
        {
            if (state.locations_visited[i])
                continue;
            return tryToReachLocation(state, i);
        }
        return "";
    }
    else
    {
        //Yes? Go to that room, pick it up.
        if (state.current_location != state.item_locations[item_type] || state.sublocation != "")
        {
            return tryToReachLocation(state, state.item_locations[item_type]);
        }
        else
        {
            if (item_type == ITEM_VISOR)
            {
                return "Take the visor";
            }
            else if (item_type == ITEM_FLUTE)
            {
                return "Take the flute";
            }
            else if (item_type == ITEM_DRINK)
            {
                return "Take the " + state.drink_name;
            }
            else if (item_type == ITEM_PHASER)
            {
                return "Take the phaser";
            }
            else
                return "";
        }
    }
    //FIXME we should support collecting the phaser from riker, but none of the peaceful solutions require it, so...
    return "";
}

string reassureCrewWithCleverLies(GameState state)
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
            return findOptionMatchingSubstrings(state, "Please patch me through to the whole ship.");
        }
        else if (state.sublocation == "conversation_uhura_speaking_to_ship")
            return findOptionMatchingSubstrings(state, "There's free ice cream in the Lounge AND we are probably going to survive this encounter");
        else
            return tryToReachLocation(state, LOCATION_BRIDGE);
    }
}