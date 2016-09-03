import "scripts/FarFuture/Parsing/Person In Area.ash";
import "scripts/FarFuture/Parsing/Blue Messages.ash";
import "scripts/FarFuture/Parsing/Intro Messages.ash";
import "scripts/FarFuture/Parsing/Sublocation.ash";

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