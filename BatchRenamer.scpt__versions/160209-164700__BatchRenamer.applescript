(*
Batch Renamer:

*)
property thePs : {} --static global variable, stands for 'parameters'
global fr, ns, nsacn, oa, oaacn, aps, irc, ce

on open draggedItems
	mainRoutine(draggedItems)
end open



--DEFINE FUNCTIONS:

on mainRoutine(draggedItems)
	--The find and replace choice should automatically avoid changing the extension.
	--The 'Insert/Remove Characters' choice should include the option
	--of having those characters be auto-incremented if they are alphabetic or numeric.
	set {fr, ns, nsacn, oa, oaacn, aps, irc, ce} to {"Find and Replace", "Number Sequentially", Â
		"Number Sequentially, attach to current name", "Order Alphabetically", Â
		"Order Alphabetically, attach to current name", "Add Prefix/Suffix", Â
		"Insert/Remove Characters", "Change Extension"}
	--Have user make main choice:
	set userChoice to listChoice({fr, ns, nsacn, oa, oaacn, aps, irc, ce}, Â
		"ÑÑÑÑWhat Shall We Do?ÑÑÑÑ", "Choose an option:", "Proceed")
	
	--Present a set of additional choices based on what user has chosen already:
	set thePs to additionalChoices(userChoice)
	if thePs is false then return
	--Now process each item:
	repeat with i from 1 to (count of draggedItems)
		renameItem(LI(i, draggedItems), userChoice, thePs)
	end repeat
end mainRoutine




on additionalChoices(userChoice)
	try
		if userChoice is fr then
			set thePs to {caseBool:"", searchString:"", replaceString:""}
			set thePs's caseBool to button returned of Â
				(display dialog "Should the Find and Replace be case-sensitive?" buttons Â
					{"Cancel", "Yes", "No"} default button 3)
			set thePs's searchString to text returned of Â
				(display dialog "Enter the text to replace:" default answer "")
			set thePs's replaceString to text returned of Â
				(display dialog "Enter the text to replace it with:" default answer "")
		else if userChoice is ns then
			set thePs to {curN:"", additionalTxt:""}
			set thePs's curN to text returned of (display dialog Â
				"Enter a starting number, including total number of " & Â
				"digits desired:" default answer "001" buttons {"Cancel", "Proceed"} default button 2)
			set thePs's additionalTxt to text returned of Â
				(display dialog "Enter any additional text you want placed after the number:" default answer Â
					"" buttons {"Cancel", "Proceed"} default button 2)
		else if userChoice is nsacn then
			set thePs to {attachBeginOrEnd:"", curN:"", additionalTxt:""}
			set thePs's attachBeginOrEnd to button returned of Â
				(display dialog "Attach at beginning or end of current name?" buttons Â
					{"Cancel", "End", "Beginning"} default button 3)
			if thePs's attachBeginOrEnd is "Beginning" then
				set befOrAft to "after"
			else
				set befOrAft to "before"
			end if
			set thePs's curN to text returned of (display dialog Â
				"Enter a starting number, including total number of " & Â
				"digits desired:" default answer "001" buttons {"Cancel", "Proceed"} default button 2)
			set thePs's additionalTxt to text returned of Â
				(display dialog "Enter any additional text you want placed " & befOrAft Â
					& " the number:" default answer Â
					"" buttons {"Cancel", "Proceed"} default button 2)
		else if userChoice is aps then
			set thePs to {pfx:"", sfx:""}
			set listChoice to (choose from list Â
				{"Prefix", "Suffix", "Both"} with title Â
				"Add a Prefix, Suffix, or Both?" OK button name "Proceed") as text
			if listChoice is "Both" then
				set thePs's pfx to text returned of (display dialog Â
					"Enter the Prefix:" default answer "" buttons {"Cancel", "Proceed"} default button 2)
				set thePs's sfx to text returned of (display dialog Â
					"Enter the Suffix:" default answer "" buttons {"Cancel", "Proceed"} default button 2)
			else if listChoice is "Prefix" then
				set thePs's pfx to text returned of (display dialog Â
					"Enter the Prefix:" default answer "" buttons {"Cancel", "Proceed"} default button 2)
			else if listChoice is "Suffix" then
				set thePs's sfx to text returned of (display dialog Â
					"Enter the Suffix:" default answer "" buttons {"Cancel", "Proceed"} default button 2)
			end if
		else if userChoice is irc then
			
		else if userChoice is ce then
			
		end if
	on error
		return false
	end try
	
	return thePs
end additionalChoices



on renameItem(theItem, userChoice, thePs)
	if class of theItem is not alias then set theItem to (theItem as alias)
	set {theName, theExt} to itemName(theItem)
	if userChoice is fr then
		if thePs's caseBool is "Yes" then
			considering case
				set newName to replace(thePs's searchString, thePs's replaceString, theName)
			end considering
		else
			set newName to replace(thePs's searchString, thePs's replaceString, theName)
		end if
		tell application "System Events" to set name of theItem to (newName & theExt)
	else if userChoice is ns then
		set newName to (thePs's curN & thePs's additionalTxt & theExt)
		tell application "System Events" to set name of theItem to newName
		set thePs's curN to incrementNum(thePs's curN)
	else if userChoice is nsacn then
		if thePs's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
			tell application "System Events" to set name of theItem to Â
				(thePs's curN) & (thePs's additionalTxt) & theName & theExt
		else -- Then place the number at end of name, with the additionalTxt coming just before it.
			tell application "System Events" to set name of theItem to Â
				theName & (thePs's additionalTxt) & (thePs's curN) & theExt
		end if
		set thePs's curN to incrementNum(thePs's curN)
	else if userChoice is aps then
		tell application "System Events" to set name of theItem to Â
			(thePs's pfx & theName & thePs's sfx & theExt)
	end if
	return
end renameItem


--Increments theNum that theItem will be renamed with, and converts it back to text.
--If the num requires zeros at the beginning, it adds them.
on incrementNum(theNum)
	--Increment curN:
	set numLength to (count of theNum)
	set theNum to (theNum as integer)
	set theNum to ((theNum) + 1)
	set theNum to (theNum as text)
	--If there need to be zeros at beginning of curN, make them:
	if (count of theNum) is not numLength then
		set numZeros to (numLength - (count of theNum))
		set theZeros to ""
		repeat numZeros times
			set theZeros to (theZeros & "0")
		end repeat
		set theNum to (theZeros & theNum)
	end if
	return theNum
end incrementNum


--theItem must be alias to the item. Returns the name (without its extension), and the extension
--as separate items.
on itemName(theItem)
	tell application "System Events"
		set theName to name of theItem
		set theExt to "." & name extension of theItem
	end tell
	set theName to replace(theExt, "", theName)
	return {theName, theExt}
end itemName






--Replaces searchString with replaceString inside theString:
on replace(searchString, replaceString, theString)
	set item_list to explode(theString, searchString)
	set theResult to implode(item_list, replaceString)
	return theResult -- returns a new, modified string.
end replace



-- This function separates pieces of a string into list items, using theDelimit
-- as the separator. theDelimit can be either string or list of strings.
on explode(theString, theDelimit)
	set origDelimit to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelimit
	set theResult to every text item of theString
	set AppleScript's text item delimiters to origDelimit
	return theResult
end explode


--This function re-assembles a list of strings into a single string,
--using theDelimit as glue to reconnect each string.  theDelimit must be a string.
on implode(textlist, theDelimit)
	set origDelimit to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelimit
	set theString to (textlist as string)
	set AppleScript's text item delimiters to origDelimit
	return theString
end implode


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


--This function is for assigning a value to a list item:
on setLI(itemNum, theList, theValue)
	set item itemNum of theList to theValue
end setLI


on getIndex(theItem, theList)
	if class of theList is not in {integer, real, text, list} then return false --function stops.
	--If theList is a number then coerce into text:
	if (count of theList) is 0 then set theList to (theList as text)
	if theItem is not in theList then return false -- function stops.
	--Else, theItem must be in theList, so:	
	set indexList to {}
	set itemLength to (count of (theItem as text))
	if (count of theList) is 1 then -- Then theItem IS theList.
		set end of indexList to 1
		return indexList -- function stops.
	end if
	if class of theList is list then
		repeat with i from 1 to count of theList
			if (theItem is (LI(i, theList))) then set end of indexList to i -- Appends number to end of list.
		end repeat
	else if class of theList is text then -- Then theItem is also text.
		set {theLimit, x, i} to {count of theList, 1, 1}
		set theItem to (theItem as text)
		repeat while theLimit > (itemLength - 1)
			if theItem is (characters i thru (i + itemLength - 1) of theList as text) then
				set end of indexList to i
			end if
			set i to (i + 1)
			set theLimit to (theLimit - 1)
		end repeat
	end if
	if indexList is {} then return false
	--Else:
	return indexList
end getIndex


on incrementAlphabet(theChars)
	set theOrder to Â
		{"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
	repeat with i from 1 to count of theChars
		if character -i of theChars is not "z" then
			set x to (getIndex(character -i of theChars, theOrder) as integer)
			set x to LI((x + 1), theOrder)
			set theChars to ((characters 1 thru (-i - 1) of theChars as text) & x)
			exit repeat
		end if
	end repeat
end incrementAlphabet



on dialog(defaultTxt, theMessage, theButtons, dfButtonNum)
	try
		if defaultTxt is "" then
			display dialog theMessage with title "BatchRenamer" buttons theButtons Â
				default button dfButtonNum
		else
			display dialog theMessage with title "BatchRenamer" default answer Â
				defaultTxt buttons theButtons default button dfButtonNum
		end if
	on error
		return false
	end try
end dialog

--The last 3 parameters must be strings.
on listChoice(theList, theTitle, thePrompt, okButton)
	return (choose from list theList with title theTitle with prompt thePrompt Â
		OK button name okButton) as text
end listChoice