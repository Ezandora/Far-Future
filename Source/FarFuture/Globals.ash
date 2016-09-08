since r17163;
string __version = "1.0.6";

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
int ITEM_TRICORDER = 5;

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