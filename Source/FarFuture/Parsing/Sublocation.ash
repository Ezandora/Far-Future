void tryToRecogniseSublocation(GameState state)
{
	if (state.sublocation != "unrecognised")
		return;
		
	//Try the buttons.
	foreach s in state.current_button_choices
	{
		if (s.contains_text("That will be all, thank you ") && s.contains_text("Uhura"))
		{
			state.sublocation = "conversation_uhura_main";
		}
		else if (s.contains_text("There's free ice cream in the Lounge AND we are probably going to survive this encounter."))
		{
			state.sublocation = "conversation_uhura_speaking_to_ship";
		}
		else if (s.contains_text("What do you sense about crew morale?"))
			state.sublocation = "conversation_troi_main";
        else if (s.contains_text("Tell me about the computer") || s.contains_text("Knock, knock"))
			state.sublocation = "conversation_jicky_main";
		else if (s.contains_text("Leave Computer"))
			state.sublocation = "quarters_computer";
        else if (s.contains_text("I guess this conversation is over")) //????
            state.sublocation = "conversation_bones_main";
        else if (s.contains_text("Good day, sir"))
            state.sublocation = "conversation_spock_main";
        else if (s.contains_text("As you were"))
            state.sublocation = "conversation_riker_main";
	}
	
	if (state.sublocation == "unrecognised" && __setting_debug)
		printSilent("Unrecognised sub-location.", "red");
}
