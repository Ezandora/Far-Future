void processIntroMessages(GameState state, string [int] messages)
{
	foreach key, message in messages
	{
		if (message.contains_text("You are on the bridge.") || message.contains_text("You quickly scoot into the turbolift, which is connected to the major parts of the ship.") || message.contains_text("You are in the lounge.  Crew members are hanging around at tables, drinking and playing games.  Off to one side, some members are fiddling with various instruments.") || message.contains_text("You are in engineering.") || message.contains_text("You are on the Holofloor.") || message.contains_text("The floor's computer speaks, \"Welcome back, Admiral, which simulation would you like to activate?"))
		{
			state.sublocation = "";
		}
        else if (message.contains_text("You sit at the weapons console.  It looks like the torpedo bay is empty, but phasers are ready to fire.") || message.contains_text("You sit at the weapons console.  It looks like the torpedo bay is empty, but phasers are ready to fire."))
            state.sublocation = "weapons_console";
		else if (message.contains_text("You are in ") && message.contains_text("'s quarters."))
        {
			state.sublocation = "";
        }
		else if (message.contains_text("There is a high-tech visor here"))
		{
			state.item_locations[ITEM_VISOR] = state.current_location;
		}
		else if (message.contains_text("There is a flute here."))
		{
			state.item_locations[ITEM_FLUTE] = state.current_location;
		}
		else if (message.contains_text("There is a Federation-Issue Phaser here."))
			state.item_locations[ITEM_PHASER] = state.current_location;
		else if (message.contains_text("There is a bottle of "))
		{
			//There is a bottle of Double Green Porter here.
			state.item_locations[ITEM_DRINK] = state.current_location;
			state.drink_name = message.group_string("There is a bottle of (.*?) here\\.")[0][1];
		}
        else if (message.contains_text("Carefully taking aim, you send a phaser blast over (under? in front of?) the hostile ship's bow."))
        {
            if (state.skill_levels[SKILL_TYPE_GUNNER] == SKILL_LEVEL_AMAZING)
            {
                state.fired_amazing_warning_shot = true;
            }
        }
		else if (message.contains_text("Space: the final frontier. These are the voyages of the Starship..."))
		{
			state.sublocation = "intro";
		}
		else if (message.contains_text("@ffa_ishere@") || message.contains_text("@ffa_movingannounce@"))
		{
			//bugggg
		}
		else if (message.contains_text("A strange harmonic sound comes over the channel and you think maybe the being is looking at you expectantly as the sound fades."))
		{
			state.sublocation = "crystal_intro_1";
			state.alien_race_type = ALIEN_RACE_CRYSTALS;
		}
        else if (message.contains_text("A nebulous cloud fades in on the viewscreen"))
        {
			state.alien_race_type = ALIEN_RACE_CLOUD;
        }
        else if (message.contains_text("I sensed that you needed me on the bridge") && message.contains_text("stumbles out of Turbolift"))
        {
            state.last_minute_troi_was_paged_to_bridge = state.minutes_in;
        }
		else if (message.contains_text("After a few moments, the being turns off-screen and fiddles with something."))
		{
			state.sublocation = "crystal_intro_2";
			state.alien_race_type = ALIEN_RACE_CRYSTALS;
		}
		else if (message.contains_text("The noise of your ship is rather discordant and we can not abide it.  In the interest of interstellar harmony, we shall be bringing all systems on your ship to cesura in 44 measures."))
		{
			state.sublocation = "crystal_intro_3";
			state.alien_race_type = ALIEN_RACE_CRYSTALS;
		}
		else if (message.contains_text("A scarred, rugged, bumpy humanoid with dark complexion materializes on the view screen"))
		{
			state.sublocation = "klingon_intro_1";
			state.alien_race_type = ALIEN_RACE_KLINGONS;
		}
        else if (message.contains_text("Fine, that will do.  I must inform you that you and your crew have"))
        {
			state.sublocation = "klingon_intro_2";
			state.alien_race_type = ALIEN_RACE_KLINGONS;
        }
        else if (message.contains_text("The name of your ship") && message.contains_text("in our language") && message.contains_text("For this, you will die."))
        {
            //The name of your ship, Organization, in our language insinuates that our great uncle had a pleasant date with a snake. For this, you will die.
			state.sublocation = "klingon_intro_3";
			state.alien_race_type = ALIEN_RACE_KLINGONS;
        }
        else if (message.contains_text("A strange cloud floats silently near the viewscreen."))
        {
            state.alien_race_type = ALIEN_RACE_CLOUD;
        }
        else if (message.contains_text("The hostile vessel is not responding") && message.contains_text("Uhura informs you after a minute"))
        {
            //This could be cloud or borg or the emoticons.
            if (state.alien_race_type == ALIEN_RACE_UNKNOWN)
                state.alien_race_type = ALIEN_RACE_UNRECOGNISED;
        }
        else if (message.contains_text("assimilate your crew and ship. Resistance is futile"))
        {
			state.sublocation = "borg_intro_1";
			state.alien_race_type = ALIEN_RACE_BORG;
        }
        else if (message.contains_text("You approach the replicator in your quarters"))
        {
            state.sublocation = "quarters_replicator";
        }
        else if (message.contains_text("We heard that your ancients are off the ship right now so we're going to come over for a spacekegger and party until the spacecows come home k that's cool right"))
        {
			state.sublocation = "emoticon_intro_1";
			state.alien_race_type = ALIEN_RACE_EMOTICONS;
        }
        else if (message.contains_text("For some reason, everyone on the bridge looks very happy and a little excited."))
        {
            state.lies_told_crew = TOLD_CREW_ICE_CREAM_AND_PROBABLY_WILL_SURVIVE;
        }
        else if (message.contains_text("For some reason, everyone on the bridge looks happy and a little excited."))
        {
            state.lies_told_crew = TOLD_CREW_ICE_CREAM;
        }
        else if (message.contains_text("For some reason, everyone on the bridge looks unhappy, depressed, but excited."))
        {
            //This message seems to also happen for TOLD_CREW_SOMEWHAT_LESS_ABYSMAL.
            state.lies_told_crew = TOLD_CREW_ABYSMAL;
        }
        else if (message.contains_text("That was wonderful") && message.contains_text("but somehow out of phase"))
        {
            state.played_amazing_flute_for_crystal_aliens = true;
        }
        else if (message.contains_text("Perhaps I can modulate the phase of the communicator when you next speak to the "))
        {
            state.phase_state_will_be_modulated = true;
        }
        else if (message.contains_text("Ran through the Computers fer Dummies Holofloor program a time or so"))
        {
            state.asked_jicky_about_the_computer = true;
        }
        else if (message.contains_text("appears on the viewscreen, \"What do you want, worm?"))
        {
            state.sublocation = "klingon_conversation_1";
			state.alien_race_type = ALIEN_RACE_KLINGONS;
        }
        else if (message.contains_text("unleashed my empathy.  I can feel everyone on this ship"))
        {
            state.gave_troi_alcohol = true;
        }
        else if (message.contains_text("Like magic, an item appears in the replicator.") || message.contains_text("Looks like the convoluted nature of time-travel has caught up with you and your daily replicator credit is still used up from the last time you were in the far-future"))
        {
            state.used_replicator = true;
        }
		else
		{
			//Run through regexes:
			boolean found_match = false;
			
			foreach key, match in __persons_in_area_regexes
			{
				string [int][int] result = message.group_string(match.regex);
				if (result.count() == 0)
					continue;
				
				found_match = true;
				string person_name;
				string occupation;
				if (match.name_is_first_result)
				{
					person_name = result[0][1];
					occupation = result[0][2];
				}
				else
				{
					person_name = result[0][2];
					occupation = result[0][1];
				}
				//print_html("Found \"" + person_name + "\" with the occupation \"" + occupation + "\"");
				
				if (occupation == "" || person_name == "")
				{
					found_match = false;
					break;
				}
				state.occupations_to_names[occupation] = person_name;
				state.occupations_to_last_seen_locations[occupation] = state.current_location; //is this useful?
				break;
			}
			if (!found_match && __setting_debug)
				printSilent("Unrecognised intro message \"" + message + "\"", "red");
		}
	}
}
