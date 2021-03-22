get reverse of every text item of "abcdefg" as text


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



