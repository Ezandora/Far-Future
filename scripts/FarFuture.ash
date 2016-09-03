//FarFuture - solves the Time-Spinner's far future once.
//This script is in the public domain.

since r17163;
string __version = "1.0";

boolean __setting_debug = false;
//These settings only work when __setting_debug is true:
boolean __setting_do_not_execute_actions = false;
boolean __setting_one_turn_at_a_time = false;
boolean __setting_run_file_test = false;
//We save state to a file, to make the script reentrant:
string __setting_file_state_path = "data/FarFuture_Data_" + my_id() + ".txt";

int ALIEN_RACE_UNKNOWN = 0;
int ALIEN_RACE_KLINGONS = 1;
int ALIEN_RACE_EMOTICONS = 2;
int ALIEN_RACE_CRYSTALS = 3;
int ALIEN_RACE_CLOUD = 4;
int ALIEN_RACE_BORG = 709;
int ALIEN_RACE_UNRECOGNISED = 11;

int LOCATION_UNKNOWN = 0;
int LOCATION_QUARTERS = 1;
int LOCATION_BRIDGE = 2;
int LOCATION_TURBOLIFT = 3;
int LOCATION_LOUNGE = 4;
int LOCATION_ENGINEERING = 5;
int LOCATION_HOLOFLOOR = 6;
int LOCATION_CARRYING = 11; //for items

int ITEM_NONE = 0;
int ITEM_VISOR = 1;
int ITEM_FLUTE = 2;
int ITEM_DRINK = 3;
int ITEM_PHASER = 4;

int SKILL_TYPE_NONE = 0;
int SKILL_TYPE_HACKING = 1;
int SKILL_TYPE_GUNNER = 2;
int SKILL_TYPE_PHASER = 3;
int SKILL_TYPE_FLUTE = 4;

int SKILL_LEVEL_UNSKILLED = 0;
int SKILL_LEVEL_ADEQUATE = 1;
int SKILL_LEVEL_ABLE = 2;
int SKILL_LEVEL_AMAZING = 3;

int TOLD_CREW_NOTHING = 0;
int TOLD_CREW_ABYSMAL = 1;
int TOLD_CREW_SOMEWHAT_LESS_ABYSMAL = 2;
int TOLD_CREW_ICE_CREAM = 3;
int TOLD_CREW_ICE_CREAM_AND_PROBABLY_WILL_SURVIVE = 4;

item __item_desired_to_replicate;

void printSilentNoEscape(string line, string font_colour)
{
    print_html("<font color=\"" + font_colour + "\">" + line + "</font>");
}


void printSilent(string line, string font_colour)
{
    printSilentNoEscape(line.entity_encode(), font_colour);
}

void printSilent(string line)
{
    print_html(line.entity_encode());
}


string stringAddSpacersEvery(string s, int distance)
{
	buffer out;
	//easiest no-effort implementation, which isn't particularly efficient:
	for i from 0 to s.length() - 1
	{
		if ((i + 1) % distance == 0)
			out.append("\n");
		out.append(s.char_at(i));
	}
	
	return out.to_string();
}

//From Guide's Library.ash:

string [int] listMakeBlankString()
{
	string [int] result;
	return result;
}

void listAppend(string [int] list, string entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

string listJoinComponents(string [int] list, string joining_string, string and_string)
{
	buffer result;
	boolean first = true;
	int number_seen = 0;
	foreach i, value in list
	{
		if (first)
		{
			result.append(value);
			first = false;
		}
		else
		{
			if (!(list.count() == 2 && and_string != ""))
				result.append(joining_string);
			if (and_string != "" && number_seen == list.count() - 1)
			{
				result.append(" ");
				result.append(and_string);
				result.append(" ");
			}
			result.append(value);
		}
		number_seen = number_seen + 1;
	}
	return result.to_string();
}

string listJoinComponents(string [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


//split_string returns an immutable array, which will error on certain edits
//Use this function - it converts to an editable map.
string [int] split_string_mutable(string source, string delimiter)
{
	string [int] result;
	string [int] immutable_array = split_string(source, delimiter);
	foreach key in immutable_array
		result[key] = immutable_array[key];
	return result;
}

//This returns [] for empty strings. This isn't standard for split(), but is more useful for passing around lists. Hacky, I suppose.
string [int] split_string_alternate(string source, string delimiter)
{
    if (source.length() == 0)
        return listMakeBlankString();
    return split_string_mutable(source, delimiter);
}



//Allows error checking. The intention behind this design is Errors are passed in to a method. The method then sets the error if anything went wrong.
record Error
{
	boolean was_error;
	string explanation;
};

Error ErrorMake(boolean was_error, string explanation)
{
	Error err;
	err.was_error = was_error;
	err.explanation = explanation;
	return err;
}

Error ErrorMake()
{
	return ErrorMake(false, "");
}

void ErrorSet(Error err, string explanation)
{
	err.was_error = true;
	err.explanation = explanation;
}

void ErrorSet(Error err)
{
	ErrorSet(err, "Unknown");
}

//to_int will print a warning, but not halt, if you give it a non-int value.
//This function prevents the warning message.
//err is set if value is not an integer.
int to_int_silent(string value, Error err)
{
	if (is_integer(value))
        return to_int(value);
    ErrorSet(err, "Unknown integer \"" + value + "\".");
	return 0;
}

int to_int_silent(string value)
{
	return to_int_silent(value, ErrorMake());
}


void listAppendList(string [int] list, string [int] entries)
{
	foreach key in entries
		list.listAppend(entries[key]);
}



//Additions to standard API:
//Auto-conversion property functions:
boolean get_property_boolean(string property)
{
	return get_property(property).to_boolean();
}

int get_property_int(string property)
{
	return get_property(property).to_int_silent();
}

location get_property_location(string property)
{
	return get_property(property).to_location();
}

float get_property_float(string property)
{
	return get_property(property).to_float();
}

monster get_property_monster(string property)
{
	return get_property(property).to_monster();
}
//Map serialisation functions:
string __serialisation_token = "•";
string serialiseMap(int [string] map)
{
	string [int] out_list;
	foreach key, v in map
	{
		out_list.listAppend(key);
		out_list.listAppend(v);
	}
	return out_list.listJoinComponents(__serialisation_token);
}
void deserialiseMap(string serialised_string, int [string] map)
{
	string [int] linearised_string = serialised_string.split_string_alternate(__serialisation_token);
	foreach key, s in linearised_string
	{
		if (key % 2 != 0)
			continue;
		map[s] = linearised_string[key + 1].to_int_silent();
	}
}

string serialiseMap(int [int] map)
{
	string [int] out_list;
	foreach key, v in map
	{
		out_list.listAppend(key);
		out_list.listAppend(v);
	}
	return out_list.listJoinComponents(__serialisation_token);
}
void deserialiseMap(string serialised_string, int [int] map)
{
	string [int] linearised_string = serialised_string.split_string_alternate(__serialisation_token);
	foreach key, s in linearised_string
	{
		if (key % 2 != 0)
			continue;
		map[s.to_int_silent()] = linearised_string[key + 1].to_int_silent();
	}
}

string serialiseMap(string [string] map)
{
	string [int] out_list;
	foreach key, v in map
	{
		out_list.listAppend(key);
		out_list.listAppend(v);
	}
	return out_list.listJoinComponents(__serialisation_token);
}
void deserialiseMap(string serialised_string, string [string] map)
{
	string [int] linearised_string = serialised_string.split_string_alternate(__serialisation_token);
	foreach key, s in linearised_string
	{
		if (key % 2 != 0)
			continue;
		map[s] = linearised_string[key + 1];
	}
}


string serialiseMap(boolean [int] map)
{
	string [int] out_list;
	foreach key, v in map
	{
		out_list.listAppend(key);
		out_list.listAppend(v);
	}
	return out_list.listJoinComponents(__serialisation_token);
}
void deserialiseMap(string serialised_string, boolean [int] map)
{
	string [int] linearised_string = serialised_string.split_string_alternate(__serialisation_token);
	foreach key, s in linearised_string
	{
		if (key % 2 != 0)
			continue;
		map[s.to_int_silent()] = linearised_string[key + 1].to_boolean();
	}
}
Record GameState
{
	int minutes_in;
	string starship_name;
	
	int alien_race_type;
	
	int current_location;
	
	int [string] current_button_choices;
	
	int [int] item_locations;
	int item_currently_carrying;
	
	string [string] occupations_to_names;
	int [string] occupations_to_last_seen_locations;
	
	boolean [int] locations_visited;
	
	int [int] skill_levels;
	
	string drink_name;
	string sublocation;
    int lies_told_crew;
    boolean invalid;
    boolean played_amazing_flute_for_crystal_aliens;
	boolean phase_state_will_be_modulated; //it wouldn't be star trek without technobabble
    boolean fired_amazing_warning_shot;
    boolean asked_jicky_about_the_computer;
    boolean gave_troi_alcohol;
    boolean used_replicator;
    boolean borg_failed;
    int last_minute_troi_was_paged_to_bridge;
	//Things after this line need to be added to the file states written/tested:
};

void readFileState(GameState state)
{
	string [string] file_state;
	file_to_map(__setting_file_state_path, file_state);
	
	state.minutes_in = file_state["minutes_in"].to_int_silent();
    state.current_location = file_state["current_location"].to_int_silent();
	state.starship_name = file_state["starship_name"];
	state.alien_race_type = file_state["alien_race_type"].to_int_silent();
	state.item_currently_carrying = file_state["item_currently_carrying"].to_int_silent();
	state.drink_name = file_state["drink_name"];
	state.sublocation = file_state["sublocation"];
	
	deserialiseMap(file_state["current_button_choices"], state.current_button_choices);
	deserialiseMap(file_state["item_locations"], state.item_locations);
	deserialiseMap(file_state["occupations_to_names"], state.occupations_to_names);
	deserialiseMap(file_state["occupations_to_last_seen_locations"], state.occupations_to_last_seen_locations);
	deserialiseMap(file_state["locations_visited"], state.locations_visited);
	deserialiseMap(file_state["skill_levels"], state.skill_levels);
    
	state.lies_told_crew = file_state["lies_told_crew"].to_int_silent();
	state.invalid = file_state["invalid"].to_boolean();
	state.played_amazing_flute_for_crystal_aliens = file_state["played_amazing_flute_for_crystal_aliens"].to_boolean();
	state.phase_state_will_be_modulated = file_state["phase_state_will_be_modulated"].to_boolean();
    state.fired_amazing_warning_shot = file_state["fired_amazing_warning_shot"].to_boolean();
    state.asked_jicky_about_the_computer = file_state["asked_jicky_about_the_computer"].to_boolean();
    state.gave_troi_alcohol = file_state["gave_troi_alcohol"].to_boolean();
    state.used_replicator = file_state["used_replicator"].to_boolean();
    state.borg_failed = file_state["borg_failed"].to_boolean();
    state.last_minute_troi_was_paged_to_bridge = file_state["last_minute_troi_was_paged_to_bridge"].to_int_silent();
}

void writeFileState(GameState state)
{
	string [string] file_state;
	file_state["minutes_in"] = state.minutes_in;
    file_state["current_location"] = state.current_location;
	file_state["starship_name"] = state.starship_name;
	file_state["alien_race_type"] = state.alien_race_type;
	file_state["item_currently_carrying"] = state.item_currently_carrying;
	file_state["current_button_choices"] = serialiseMap(state.current_button_choices);
	file_state["item_locations"] = serialiseMap(state.item_locations);
	file_state["occupations_to_names"] = serialiseMap(state.occupations_to_names);
	file_state["occupations_to_last_seen_locations"] = serialiseMap(state.occupations_to_last_seen_locations);
	file_state["locations_visited"] = serialiseMap(state.locations_visited);
	file_state["skill_levels"] = serialiseMap(state.skill_levels);
	
	file_state["drink_name"] = state.drink_name;
	file_state["sublocation"] = state.sublocation;
    file_state["lies_told_crew"] = state.lies_told_crew;
    file_state["invalid"] = state.invalid;
    file_state["played_amazing_flute_for_crystal_aliens"] = state.played_amazing_flute_for_crystal_aliens;
    file_state["phase_state_will_be_modulated"] = state.phase_state_will_be_modulated;
	file_state["fired_amazing_warning_shot"] = state.fired_amazing_warning_shot;
	file_state["asked_jicky_about_the_computer"] = state.asked_jicky_about_the_computer;
    file_state["gave_troi_alcohol"] = state.gave_troi_alcohol;
    file_state["used_replicator"] = state.used_replicator;
    file_state["borg_failed"] = state.borg_failed;
    file_state["last_minute_troi_was_paged_to_bridge"] = state.last_minute_troi_was_paged_to_bridge;
    
	map_to_file(file_state, __setting_file_state_path);
}

void testFileState()
{
	GameState state;
    //Generate test data:
    state.minutes_in = 7;
	state.starship_name = "Boomer";
	
	state.alien_race_type = 5;
	
	state.current_location = 9;
	
    state.current_button_choices["Yay, Jick!"] = 1;
    state.current_button_choices["The big red one"] = 2;
    state.current_button_choices["Make choice.php time out"] = 4;
    state.current_button_choices["Off switch"] = 9;
	
    state.item_locations[6] = 7;
    state.item_locations[7] = 89;
	state.item_currently_carrying = 1;
	
    state.occupations_to_names["Ship's Wharf"] = "Worf";
    
    state.occupations_to_last_seen_locations["Space Dentist"] = 1;
    state.occupations_to_last_seen_locations["Space Accountant"] = 2;
    state.occupations_to_last_seen_locations["Space Electrician"] = 3;
	
    state.locations_visited[1] = true;
    state.locations_visited[2] = false;
	
    state.skill_levels[1] = 2;
    state.skill_levels[2] = 3;
	
    state.drink_name = "Kanar with Damar";
    state.sublocation = "Underwater";
    state.lies_told_crew = 2147483647;
    state.invalid = true;
    state.played_amazing_flute_for_crystal_aliens = true;
	state.phase_state_will_be_modulated = true;
    state.fired_amazing_warning_shot = true;
    state.asked_jicky_about_the_computer = true;
    state.gave_troi_alcohol = true;
    state.used_replicator = true;
    state.borg_failed = true;
    state.last_minute_troi_was_paged_to_bridge = 39;
    
    
    string state_original_string = state.to_json();
    writeFileState(state);
    GameState state_2;
	readFileState(state_2);
    string state_new_string = state_2.to_json();
    if (state_original_string != state_new_string)
    {
        print("Error: Mismatch between writing/reading the states.");
        print("Original: " + state_original_string);
        print("New: " + state_new_string);
    }
    else
        print("testFileState() passes tests.");
}
Record PersonInAreaRegexMatch
{
	string regex;
	boolean name_is_first_result; //otherwise, second
};

void listAppend(PersonInAreaRegexMatch [int] list, PersonInAreaRegexMatch entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

PersonInAreaRegexMatch PersonInAreaRegexMatchMake(string regex, boolean name_is_first_result)
{
	PersonInAreaRegexMatch match;
	match.regex = regex;
	match.name_is_first_result = name_is_first_result;
	return match;
}

static
{
	PersonInAreaRegexMatch [int] __persons_in_area_regexes;
	void initialisePersonInAreaMatches()
	{
		if (__persons_in_area_regexes.count() != 0)
			return;
		__persons_in_area_regexes.listAppend(PersonInAreaRegexMatchMake("Your (.*?), (.*?), is here\\.", false)); //√
		__persons_in_area_regexes.listAppend(PersonInAreaRegexMatchMake("(.*?), the (.*?), is hanging around\\.", true)); //√
		__persons_in_area_regexes.listAppend(PersonInAreaRegexMatchMake("\"Greetings,\" says (.*?), the (.*?)\\.", true)); //√
		__persons_in_area_regexes.listAppend(PersonInAreaRegexMatchMake("(.*?) is here, ready to act as (.*?)\\.", true)); //√
		__persons_in_area_regexes.listAppend(PersonInAreaRegexMatchMake("\"At your service,\" announces (.*?), the (.*?)\\.", true)); //√
	}
	initialisePersonInAreaMatches();
}
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
		else if (message.contains_text("You are an amazing floutist."))
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
void processIntroMessages(GameState state, string [int] messages)
{
	foreach key, message in messages
	{
		if (message.contains_text("You are on the bridge.") || message.contains_text("You quickly scoot into the turbolift, which is connected to the major parts of the ship.") || message.contains_text("You are in the lounge.  Crew members are hanging around at tables, drinking and playing games.  Off to one side, some members are fiddling with various instruments.") || message.contains_text("You are in engineering.") || message.contains_text("You are on the Holofloor.") || message.contains_text("The floor's computer speaks, \"Welcome back, Admiral, which simulation would you like to activate?"))
		{
			state.sublocation = "";
		}
        else if (message.contains_text("You sit at the weapons console.  It looks the torpedo bay is empty, but phasers are ready to fire."))
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

//We return the gamestate because of values/references.
//If we want to blank out state, we have to assign it to a new state. But that only changes where our function argument points to; our caller will refer to the older one.
//An alternative would be manually blanking out every field, but that requires upkeep.
GameState parsePageText(GameState state, string page_text)
{
	string title = page_text.group_string("<td style=.color: white;. align=center bgcolor=blue><b>([^<]*)")[0][1];
	//print_html("title = \"" + title + "\"");
	
	string [int][int] title_split = title.group_string("Starship (.*?) :: (.*)");
	if (title_split.count() == 0 && !page_text.contains_text("blue><b>The Far Future"))
    {
        state.invalid = true;
		return state;
    }
	string starship_name = title_split[0][1];
	string location_name = title_split[0][2];
	if (state.starship_name != starship_name || state.invalid)
	{
        if (__setting_debug)
            printSilent("New adventure! Resetting.");
		//Reset, somehow?
		GameState blank_state;
		state = blank_state;
	}
	state.sublocation = "unrecognised";
	state.starship_name = starship_name;
	if (location_name == "In your Quarters")
		state.current_location = LOCATION_QUARTERS;
	else if (location_name == "In the Bridge")
		state.current_location = LOCATION_BRIDGE;
	else if (location_name == "In the Turbolift")
		state.current_location = LOCATION_TURBOLIFT;
	else if (location_name == "In the Lounge")
		state.current_location = LOCATION_LOUNGE;
	else if (location_name == "In Engineering")
		state.current_location = LOCATION_ENGINEERING;
	else if (location_name == "In the Holofloor")
		state.current_location = LOCATION_HOLOFLOOR;
	else
    {
        if (__setting_debug)
            printSilent("Unrecognised location name \"" + location_name + "\"", "red");
    }
	
	state.locations_visited[state.current_location] = true;
	
	string intro_text_raw = page_text.group_string("<tr><td><div></div>(.*?)<div style=.border: 1px solid blue; padding: 1em.>")[0][1];
    boolean ignore_blue_text = false;
	if (intro_text_raw == "")
    {
		intro_text_raw = page_text.group_string("<tr><td><div></div>(.*?)<center>")[0][1];
        ignore_blue_text = true;
    }
	//print_html("intro_text_raw = \"" + intro_text_raw.entity_encode() + "\"");
	string blue_text_raw = page_text.group_string("<div style=.border: 1px solid blue; padding: 1em.>(.*?)</div>")[0][1];
	//print_html("blue_text_raw = \"" + blue_text_raw.entity_encode() + "\"");
	
	string [int] intro_messages = intro_text_raw.split_string_mutable("<p>");
	string [int] blue_messages = blue_text_raw.split_string_mutable("<p>");
	foreach key, s in intro_messages
	{
		if (s == "")
			remove intro_messages[key];
	}
	foreach key, s in blue_messages
	{
		if (s == "")
			remove blue_messages[key];
	}
    if (__setting_debug)
    {
        printSilent("intro_messages = \"" + intro_messages.listJoinComponents(" / ") + "\"", "gray");
        printSilent("blue_messages = \"" + blue_messages.listJoinComponents(" / ") + "\"", "gray");
	}
    
	processIntroMessages(state, intro_messages);
    if (!ignore_blue_text)
        processBlueMessages(state, blue_messages);
	
	
	string [int][int] buttons_raw = page_text.group_string("<input type=hidden name=option value=([0-9]*)><input  class=button type=submit value=\"([^\"]*)\">");
	//print_html("buttons_raw = \"" + buttons_raw.to_json().entity_encode() + "\"");
	int [string] buttons;
	foreach key in buttons_raw
	{
		int option_value = buttons_raw[key][1].to_int_silent();
		string name = buttons_raw[key][2];
		buttons[name] = option_value;
	}
	state.current_button_choices = buttons;
	tryToRecogniseSublocation(state);
	//print_html("buttons = " + buttons.to_json());
	writeFileState(state);
	return state;
}



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

string CloudChooseNextAction(GameState state)
{
    /*
    Run plan:
    Find drink, collect it.
    Go to the holofloor, waste time.
    Waste time until 40.
    Go to bridge, page troi, give her the drink, choose the right option.
    */
    //oops
    
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
        if (state.minutes_in < 39)
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
            //Is troi here? Talk to her. Otherwise, page her.
            if (state.occupations_to_last_seen_locations["Ship's Counselor"] == LOCATION_BRIDGE)
            {
                if (state.minutes_in < 40) //not worth talking to her yet
                    return "Wait a minute";
                else
                {
                    string match = findOptionMatchingSubstrings(state, "Speak to " + state.occupations_to_names["Ship's Counselor"]);
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
                    abort("unimplemented: can't find option to page the Counselor");
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
string EmoticonsChooseNextAction(GameState state)
{
    /*
    Run plan:
    Talk to uhura, talk to ship, pick the last option.
    Go to holofloor, run the recreational program until there's nothing more to do.
    */
    if (state.lies_told_crew != TOLD_CREW_ICE_CREAM_AND_PROBABLY_WILL_SURVIVE)
    {
        return reassureCrewWithCleverLies(state);
    }
    else
    {
        if (state.current_location != LOCATION_HOLOFLOOR || state.sublocation != "")
            return tryToReachLocation(state, LOCATION_HOLOFLOOR);
        else
        {
            return findOptionMatchingSubstrings(state, "Computer, activate a random recreation program.");
        }
        
    }
    return "";
}

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

string ReplicateChooseNextAction(GameState state)
{
    if (__item_desired_to_replicate == $item[none])
        return "";
    if (state.used_replicator)
        return "";
    if (state.current_location != LOCATION_QUARTERS)
        return tryToReachLocation(state, LOCATION_QUARTERS);
    else if (state.sublocation == "")
    {
        return "Use the Replicator";
    }
    else if (state.sublocation == "quarters_replicator")
    {
        string match = "";
        if (__item_desired_to_replicate == $item[Unstable Pointy Ears])
        {
            match = findOptionMatchingSubstrings(state, "Ears, Pointy");
        }
        else if (__item_desired_to_replicate == $item[Shot of Kardashian Gin])
        {
            match = findOptionMatchingSubstrings(state, "Gin, Kardashian, Shot");
        }
        else if (__item_desired_to_replicate == $item[Riker's Search History])
        {
            match = findOptionMatchingSubstrings(state, "History, Search, Riker's");
        }
        else if (__item_desired_to_replicate == $item[Tea, Earl Grey, Hot])
        {
            match = findOptionMatchingSubstrings(state, "Tea, Earl Grey, Hot");
        }
        else if (__item_desired_to_replicate == $item[Memory Disk, Alpha])
        {
            match = findOptionMatchingSubstrings(state, "Memory Disk, Alpha");
        }
        if (match == "") //they probably don't have it unlocked yet
        {
            //should this be an abort? hmm... probably, since we are reentrant. They can just re-run the script, and we'll start again.
            abort("Unable to replicate " + __item_desired_to_replicate + ". Re-run the script and pick something else (or nothing) to replicate.");
            state.used_replicator = true; //just assume yes
            return findOptionMatchingSubstrings(state, "Nothing, for now.");
        }
        else
            return match;
    }
    else
        return tryToReachLocation(state, LOCATION_QUARTERS);
    
    return "";
}

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
		//This should probably support the phaser and the visor, but we don't need those.
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

void runGame()
{
	GameState state;
	readFileState(state);
	string page_text = visit_url("choice.php");
	
    int iterations = 0;
    int limit = 100;
    if (__setting_debug && __setting_one_turn_at_a_time)
        limit = 1;
	while (true)
	{
        iterations += 1;
		//Parse page text:
        
        string medals_earned_string = page_text.group_string("at least I have the memory of earning <b>([0-9]*) medals</b> in the future.")[0][1];
        if (medals_earned_string.length() > 0)
        {
            string text;
            if (page_text.contains_text("is pinning a second medal to your uniform"))
            {
                text = "Mission successful, earning two medals.";
            }
            else if (page_text.contains_text("Just as your commanding officer is pinning a medal to your uniform, you feel yourself being pulled back from the future"))
            {
                text = "Mission successful, earning one medals.";
            }
            else if (page_text.contains_text("You find yourself abrubtly returned to the present"))
            {
                //failure. either by sleep, or by the enemy winning
                text = "Mission failed!";
            }
            else
                text = "Unknown state!";
            print(text);
            print("You've earned " + medals_earned_string + " medals so far.");
            GameState blank_state;
            writeFileState(blank_state);
            break;
        }
		state = parsePageText(state, page_text);
        if (state.invalid)
            break;
        
        if (iterations > limit)
            break;
		
		page_text = chooseAndExecuteAction(state);
        writeFileState(state);
        if (__setting_debug)
            printSilent("state = " + state.to_json().stringAddSpacersEvery(150), "grey");
	}
}

void main(string desired_item_name)
{
    print("FarFuture.ash version " + __version);
	if (__setting_debug && __setting_run_file_test) //breaks one-at-a-time handling
	{
		testFileState();
        return;
	}
    desired_item_name = desired_item_name.to_lower_case();
    
    if (desired_item_name.contains_text("memory") || desired_item_name.contains_text("alpha") || desired_item_name.contains_text("disk"))
        __item_desired_to_replicate = $item[Memory Disk, Alpha];
    else if (desired_item_name.contains_text("tea") || desired_item_name.contains_text("food") || desired_item_name.contains_text("earl grey"))
        __item_desired_to_replicate = $item[Tea, Earl Grey, Hot];
    else if (desired_item_name.contains_text("ears") || desired_item_name.contains_text("unstable") || desired_item_name.contains_text("pointy") || desired_item_name.contains_text("spock") || desired_item_name.contains_text("vulcan"))
        __item_desired_to_replicate = $item[Unstable Pointy Ears];
    else if (desired_item_name.contains_text("kanar") || desired_item_name.contains_text("cardassian") || desired_item_name.contains_text("kardashian") || desired_item_name.contains_text("gin") || desired_item_name.contains_text("booze") || desired_item_name.contains_text("drink") || desired_item_name.contains_text("alcohol") || desired_item_name.contains_text("shot"))
        __item_desired_to_replicate = $item[Shot of Kardashian Gin];
    else if (desired_item_name.contains_text("mall") || desired_item_name.contains_text("whatever") || desired_item_name.contains_text("idk"))
    {
        foreach it in $items[memory disk\, alpha,Unstable Pointy Ears,Shot of Kardashian Gin,Riker's Search History,Tea\, Earl Grey\, Hot]
        {
            if (__item_desired_to_replicate.mall_price() < it.mall_price())
                __item_desired_to_replicate = it;
        }
    }
    if (desired_item_name.is_integer())
    {
        item converted = desired_item_name.to_int_silent().to_item();
        if ($items[memory disk\, alpha,Unstable Pointy Ears,Shot of Kardashian Gin,Riker's Search History,Tea\, Earl Grey\, Hot] contains converted)
            __item_desired_to_replicate = converted;
    }
    if ((desired_item_name == " " || desired_item_name == "") && !get_property_boolean("_futureReplicatorUsed")) //FIXME whatever this is named
    {
        print_html("Are you sure you don't want to replicate anything? Options:");
        print_html("<b>memory</b> - Memory Disk, Alpha - Sell in mall for others to play the game.");
        print_html("<b>ears</b> - Unstable Pointy Ears - +3 stats/fight accessory");
        print_html("<b>drink</b> - Shot of Kardashian Gin - Epic one-drunkenness drink, gives PVP fights");
        print_html("<b>food</b> - Tea, Earl Grey, Hot - Epic one-fullness food");
        print_html("<b>mall</b> - Whatever sells for the most. (won't add it to store)");
        print_html("&nbsp;");
        print_html("<b>none</b> - Yes, I'm certain I don't want to replicate anything.");
        return;
    }
    else if (desired_item_name != "" && __item_desired_to_replicate == $item[none] && desired_item_name != "none" && desired_item_name != "nothing")
    {
        print_html("Sorry, don't know how to make \"" + desired_item_name + "\".");
    }
	
	//Are we in a game?
    string page_text = visit_url("choice.php");
    if (!page_text.contains_text("Starship ") && !page_text.contains_text("blue><b>The Far Future")) //hack
    {
        boolean use_memory_disk_alpha = false;
        if ($item[time-spinner].item_amount() == 0)
        {
            print("You don't seem to have a time-spinner.");
            if ($item[Memory Disk, Alpha].available_amount() > 0)
            {
                boolean yes = user_confirm("Do you want to use a memory disk, alpha?");
                if (!yes)
                    return;
                else
                    use_memory_disk_alpha = true;
            }
            return;
        }
        //Start game:
        if (use_memory_disk_alpha)
        {
            page_text = visit_url("inv_use.php?whichitem=9121");
        }
        else
        {
    
            if (my_adventures() == 0 && !use_memory_disk_alpha)
            {
                print("Can't use time spinner without adventures.");
                return;
            }
            
            page_text = visit_url("inv_use.php?whichitem=9104");
            int minutes = page_text.group_string("You have ([0-9]*) minutes left today.")[0][1].to_int_silent();
            if (minutes < 2) //no time
            {
                print("Your time-spinner is outa time. Try tomorrow?");
                return;
            }
            page_text = visit_url("choice.php?whichchoice=1195&option=4");
        }
    }
	runGame();
}