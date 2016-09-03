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

