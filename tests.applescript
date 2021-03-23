
on getTail(numChars, str)
	set lst to every text item of str
	return LI({-numChars, -1}, lst) as text
end getTail


on getHead(numChars, str)
	set lst to every text item of str
	return LI({1, numChars}, lst) as text
end getHead



--This function is just for creating a short-hand way of accessing a list item.
--ItemNum can be a single integer, or a list of two integers for accessing a range of items:
on LI(itemNum, theList)
	if class of itemNum is integer then
		return (item itemNum of theList)
	else if class of itemNum is list then
		return (items (item 1 of itemNum as integer) thru Â
			(item 2 of itemNum as integer) of theList)
	end if
end LI



on setOrderAlphabeticallyParams(params, userChoice)
	set params's curN to text returned of dialogWithTextInput("aaa", Â
		"Enter a starting letter combo, including total number of characters desired:", Â
		|CANCEL_PROCEED|)
	if userChoice is |OAACN| then
		set params's attachBeginOrEnd to button returned of Â
			dialogWithButtons("Attach at beginning or end of current name?", Â
				{"Cancel", "End", "Beginning"})
	end if
	if userChoice is |OA| or params's attachBeginOrEnd is "Beginning" then
		set befOrAft to "after"
	else
		set befOrAft to "before"
	end if
	set params's additionalTxt to text returned of dialogWithTextInput("", Â
		"Enter any additional text you want placed " & befOrAft & " the letters:", Â
		|CANCEL_PROCEED|)
	
	return params
end setOrderAlphabeticallyParams