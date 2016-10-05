//FarFuture - solves the Time-Spinner's far future once.
//This script is in the public domain.

import "scripts/FarFuture/Globals.ash";
import "scripts/FarFuture/Support/Library.ash";
import "scripts/FarFuture/Support/Serialise.ash";
import "scripts/FarFuture/GameState.ash";
import "scripts/FarFuture/Parsing/Parse.ash";
import "scripts/FarFuture/Running/Core.ash";

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
    
    int medals = get_property_int("timeSpinnerMedals");
    if (medals == 0) //just assume they haven't had this property read yet, or are on an older version
        medals = 20;
    
    boolean should_mallsell_replicated_item = false;
    if (desired_item_name.contains_text("memory") || desired_item_name.contains_text("alpha") || desired_item_name.contains_text("disk"))
        __item_desired_to_replicate = $item[Memory Disk, Alpha];
    else if (desired_item_name.contains_text("tea") || desired_item_name.contains_text("food") || desired_item_name.contains_text("earl grey"))
        __item_desired_to_replicate = $item[Tea, Earl Grey, Hot];
    else if (desired_item_name.contains_text("ears") || desired_item_name.contains_text("unstable") || desired_item_name.contains_text("pointy") || desired_item_name.contains_text("spock") || desired_item_name.contains_text("vulcan"))
        __item_desired_to_replicate = $item[Unstable Pointy Ears];
    else if (desired_item_name.contains_text("kanar") || desired_item_name.contains_text("cardassian") || desired_item_name.contains_text("kardashian") || desired_item_name.contains_text("gin") || desired_item_name.contains_text("booze") || desired_item_name.contains_text("drink") || desired_item_name.contains_text("alcohol") || desired_item_name.contains_text("shot") || desired_item_name.contains_text("pvp"))
        __item_desired_to_replicate = $item[Shot of Kardashian Gin];
    else if (desired_item_name.contains_text("history") || desired_item_name.contains_text("riker") || desired_item_name.contains_text("googling") || desired_item_name.contains_text("search"))
        __item_desired_to_replicate = $item[Riker's Search History];
    else if (desired_item_name.contains_text("mall") || desired_item_name.contains_text("whatever") || desired_item_name.contains_text("idk"))
    {
        boolean [item] replicable_items;
        if (medals >= 5)
            replicable_items[$item[Shot of Kardashian Gin]] = true;
        if (medals >= 10)
            replicable_items[$item[Riker's Search History]] = true;
        if (medals >= 15)
            replicable_items[$item[Tea\, Earl Grey\, Hot]] = true;
        if (medals >= 20)
            replicable_items[$item[memory disk\, alpha]] = true;
        
        foreach it in replicable_items
        {
            if (__item_desired_to_replicate.mall_price() < it.mall_price())
                __item_desired_to_replicate = it;
        }
        should_mallsell_replicated_item = true;
    }
    if (desired_item_name.is_integer())
    {
        item converted = desired_item_name.to_int_silent().to_item();
        if ($items[memory disk\, alpha,Unstable Pointy Ears,Shot of Kardashian Gin,Riker's Search History,Tea\, Earl Grey\, Hot] contains converted)
            __item_desired_to_replicate = converted;
    }
    if ((desired_item_name == " " || desired_item_name == "" || desired_item_name == "help" || desired_item_name == "list") && !get_property_boolean("_futureReplicatorUsed"))
    {
        print_html("Are you sure you don't want to replicate anything? Options:");
        if (medals >= 5)
            print_html("<b>drink</b> - Shot of Kardashian Gin - Epic one-drunkenness drink, gives PVP fights");
        if (medals >= 15)
            print_html("<b>food</b> - Tea, Earl Grey, Hot - Epic one-fullness food");
        if (medals >= 20)
            print_html("<b>memory</b> - Memory Disk, Alpha - Sell in mall for others to play the game.");
        if (medals >= 10)
            print_html("<b>history</b> - Riker's Search History - combat item, deals ~950 sleaze damage.");
        print_html("<b>ears</b> - Unstable Pointy Ears - +3 stats/fight accessory");
        print_html("<b>mall</b> - Whatever sells for the most. (will add it to store)");
        print_html("&nbsp;");
        print_html("<b>none</b> - Yes, I'm certain I don't want to replicate anything.");
        return;
    }
    else if (desired_item_name != "" && __item_desired_to_replicate == $item[none] && desired_item_name != "none" && desired_item_name != "nothing")
    {
        print_html("Sorry, don't know how to make \"" + desired_item_name + "\".");
    }
    
    int starting_amount_of_replicated_item = __item_desired_to_replicate.item_amount();
	
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
            else
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
    if (should_mallsell_replicated_item && __item_desired_to_replicate.item_amount() > starting_amount_of_replicated_item && __item_desired_to_replicate.item_amount() > 0 && have_shop() && __item_desired_to_replicate != $item[none])
    {
        put_shop(__item_desired_to_replicate.mall_price(), 0, 1, __item_desired_to_replicate);
    }
}