void processBlueMessages(GameState state, string [int] messages)
{
	//Split out the "<br>" problem:
	string [int] messages_2;
	foreach key, s in messages
	{
		if (s.contains_text("<br>"))
		{
			string [int] message_3 = s.split_string_alternate("<br>");
			messages_2.listAppendList(message_3);
		}
		else
			messages_2.listAppend(s);
	}
	messages = messages_2;
/*
Unrecognised blue message " You are holding a Federation-Issue Phaser.<br>You are an amazing hacker.<br>You are an amazing ship's gunner."
*/
	state.item_currently_carrying = ITEM_NONE;
	foreach key, message in messages
	{
		if (message.contains_text("since you first heard the red alert."))
		{
			state.minutes_in = message.group_string("<b>([0-9]*)</b>")[0][1].to_int_silent();
		}
		else if (message.contains_text("You are holding a high-tech visor."))
		{
			state.item_currently_carrying = ITEM_VISOR;
		}
		else if (message.contains_text("You are holding a flute."))
		{
			state.item_currently_carrying = ITEM_FLUTE;
		}
		else if (message.contains_text("You are holding a bottle of"))
		{
			//You are holding a bottle of Fermented Tribble.
			state.item_currently_carrying = ITEM_DRINK;
			state.drink_name = message.group_string("You are holding a bottle of (.*?)\\.")[0][1];
		}
		else if (message.contains_text("You are an amazing hacker."))
			state.skill_levels[SKILL_TYPE_HACKING] = SKILL_LEVEL_AMAZING;
		else if (message.contains_text("You are an amazing ship's gunner."))
			state.skill_levels[SKILL_TYPE_GUNNER] = SKILL_LEVEL_AMAZING;
		else if (message.contains_text("You are amazing with a phaser."))
			state.skill_levels[SKILL_TYPE_PHASER] = SKILL_LEVEL_AMAZING;
		else if (message.contains_text("You are an amazing floutist.") || message.contains_text("You are an amazing flautist."))
			state.skill_levels[SKILL_TYPE_FLUTE] = SKILL_LEVEL_AMAZING;
		else
        {
            if (__setting_debug)
                printSilent("Unrecognised blue message \"" + message + "\"", "red");
        }
	}
	if (state.item_currently_carrying != ITEM_NONE)
		state.item_locations[state.item_currently_carrying] = LOCATION_CARRYING;
}

