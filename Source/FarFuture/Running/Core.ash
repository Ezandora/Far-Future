
import "scripts/FarFuture/Running/Actions.ash";
import "scripts/FarFuture/Running/Borg.ash";
import "scripts/FarFuture/Running/Cloud.ash";
import "scripts/FarFuture/Running/Crystals.ash";
import "scripts/FarFuture/Running/Emoticons.ash";
import "scripts/FarFuture/Running/Klingons.ash";
import "scripts/FarFuture/Running/Replicate.ash";
import "scripts/FarFuture/Running/Unknown.ash";

string executeOption(GameState state, int chosen_option_id, string chosen_option_name)
{
	if (chosen_option_id <= 0 && chosen_option_name != "")
	{
		if (state.current_button_choices contains chosen_option_name)
		{
			chosen_option_id = state.current_button_choices[chosen_option_name];
		}
	}
	if (chosen_option_id > 0)
	{
		//Run choice:
		string found_option_name;
		foreach option_name, option_id in state.current_button_choices
		{
			if (option_id == chosen_option_id)
				found_option_name = option_name;
		}
		if (found_option_name == "")
			found_option_name = chosen_option_id;
		print_html("Executing action <b>" + found_option_name + "</b>");
		if (__setting_debug && __setting_do_not_execute_actions)
		{
			return "";
		}
		return visit_url("choice.php?whichchoice=1199&option=" + chosen_option_id);
	}
    else
    {
        print("Unable to determine next option.");
        return "";
    }
}

string executeOption(GameState state, int chosen_option_id)
{
	return executeOption(state, chosen_option_id, "");
}

string executeOption(GameState state, string chosen_option_name)
{
	return executeOption(state, 0, chosen_option_name);
}

string chooseAndExecuteAction(GameState state)
{
	if (state.sublocation == "unrecognised")
	{
		print("Unable to determine where we are.");
		return "";
	}
	//Hardcoded places:
	if (state.sublocation == "intro")
	{
		return executeOption(state, 1);
	}
	else if (state.sublocation == "crystal_intro_1")
		return executeOption(state, "Enjoy the harmonic sounds");
	else if (state.sublocation == "crystal_intro_2")
		return executeOption(state, 1);
	else if (state.sublocation == "crystal_intro_3")
    {
        if (state.current_button_choices contains "Play the flute") //crystals, or snorlax?
            return executeOption(state, "Play the flute");
        else
            return executeOption(state, 2);
    }
	else if (state.sublocation == "klingon_intro_1")
		return executeOption(state, 2);
    else if (state.sublocation == "klingon_intro_2")
		return executeOption(state, 1);
    else if (state.sublocation == "klingon_intro_3")
		return executeOption(state, 1);
    else if (state.sublocation == "klingon_conversation_1")
		return executeOption(state, "&quot;You best turn around, for your own health.&quot;");
    else if (state.sublocation == "borg_intro_1")
        return executeOption(state, "&quot;This conversation is futile.&quot;");
    else if (state.sublocation == "emoticon_intro_1")
        return executeOption(state, 2);
    
	
	//Is there an item here we can pick up, and we don't have anything? Might as well grab it, doesn't cost any minutes.
	if (state.item_currently_carrying == ITEM_NONE)
	{
		//This should probably support the phaser, the visor, and the tricorder, but we don't need those.
		foreach option_name in $strings[Take the flute]
		{
			if (state.current_button_choices contains option_name)
			{
				return executeOption(state, option_name);
			}
		}
		if (state.current_button_choices contains ("Take the " + state.drink_name))
			return executeOption(state, ("Take the " + state.drink_name));
	}
    
    string next_action;
    if (__item_desired_to_replicate != $item[none] && !state.used_replicator)
        next_action = ReplicateChooseNextAction(state);
    else if (state.alien_race_type == ALIEN_RACE_BORG)
        next_action = BorgChooseNextAction(state);
    else if (state.alien_race_type == ALIEN_RACE_CLOUD)
        next_action = CloudChooseNextAction(state);
    else if (state.alien_race_type == ALIEN_RACE_CRYSTALS)
        next_action = CrystalsChooseNextAction(state);
    else if (state.alien_race_type == ALIEN_RACE_EMOTICONS)
        next_action = EmoticonsChooseNextAction(state);
    else if (state.alien_race_type == ALIEN_RACE_KLINGONS)
        next_action = KlingonsChooseNextAction(state);
    else if (state.alien_race_type == ALIEN_RACE_UNKNOWN)
        next_action = UnknownChooseNextAction(state);
    else if (state.alien_race_type == ALIEN_RACE_UNRECOGNISED)
    {
        //This could be borg, cloud, or the party aliens.
        //Fortunately, this should only happen if we're run on a game in progress.
        //Theoretically, we try to solve all three at once...
        print("Unable to recognise aliens.");
    }
    
    if (next_action != "")
    {
        if (next_action.is_integer())
            return executeOption(state, next_action.to_int_silent());
        else
            return executeOption(state, next_action);
    }
	
    print("Unable to determine next option.");
	return "";
}
