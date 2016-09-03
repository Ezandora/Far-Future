
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