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
