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
