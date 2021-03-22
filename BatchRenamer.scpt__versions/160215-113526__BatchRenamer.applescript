(*
Batch Renamer:  copyright 2016 by Steve Thompson
*)

property thePs : {} --static global variable, stands for 'parameters'
property uniqueString : "ùùøøø"
global fr, ns, nsacn, oa, oaacn, aps, irc, ce

--Handler runs when dragging items onto app icon:
on open draggedItems
	mainRoutine(draggedItems)
end open



--DEFINE FUNCTIONS:

on mainRoutine(draggedItems)
	--The find and replace choice will automatically avoid changing the name extension.
	set {fr, ns, nsacn, oa, oaacn, aps, irc, ce} to {"Find and Replace", "Number Sequentially", Â
		"Number Sequentially, attach to current name", "Order Alphabetically", Â
		"Order Alphabetically, attach to current name", "Add Prefix/Suffix", Â
		"Insert/Remove Characters", "Change Extension"}
	--Have user make main choice:
	set userChoice to listChoice({fr, ns, nsacn, oa, oaacn, aps, irc, ce}, Â
		"ÑÑÑÑWhat To Do?ÑÑÑÑ", "Proceed")
	
	--Present a set of additional choices based on what user has chosen already:
	set thePs to additionalChoices(userChoice)
	if thePs is false then return --app quits.
	
	set renamedItems to {}
	--Now rename each dragged item, including a unique suffix so they won't match the name 
	--of any other item:
	repeat with i from 1 to (count of draggedItems)
		set end of renamedItems to renameItem(LI(i, draggedItems), userChoice, thePs)
	end repeat
	
	--Now remove the unique suffix:
	repeat with i from 1 to (count of renamedItems)
		removeUniqueString(LI(i, renamedItems))
	end repeat
end mainRoutine


on additionalChoices(userChoice)
	try
		set thePs to setParameters(userChoice)
		if userChoice is fr then
			set thePs's caseBool to button returned of Â
				dialog(0, "Should the Find and Replace be case-sensitive?", {"Cancel", "Yes", "No"})
			set thePs's searchString to text returned of Â
				dialog("", "Enter the text to replace:", {"Cancel", "Proceed"})
			set thePs's replaceString to text returned of Â
				dialog("", "Enter the text to replace it with:", {"Cancel", "Proceed"})
		else if userChoice is in {ns, nsacn} then
			set thePs's curN to text returned of dialog("001", Â
				"Enter a starting number, including total number of digits desired:", {"Cancel", "Proceed"})
			if userChoice is nsacn then
				set thePs's attachBeginOrEnd to button returned of dialog(0, Â
					"Attach at beginning or end of current name?", {"Cancel", "End", "Beginning"})
			end if
			if userChoice is ns or thePs's attachBeginOrEnd is "Beginning" then
				set befOrAft to "after"
			else
				set befOrAft to "before"
			end if
			set thePs's additionalTxt to text returned of dialog("", Â
				"Enter any additional text you want placed " & befOrAft & " the number:", Â
				{"Cancel", "Proceed"})
		else if userChoice is aps then
			set listChoice to (choose from list Â
				{"Prefix", "Suffix", "Both"} with title Â
				"Add a Prefix, Suffix, or Both?" OK button name "Proceed") as text
			if listChoice is "Both" or listChoice is "Prefix" then
				set thePs's pfx to text returned of dialog("", "Enter the Prefix:", {"Cancel", "Proceed"})
			end if
			if listChoice is "Both" or listChoice is "Suffix" then
				set thePs's sfx to text returned of dialog("", "Enter the Suffix:", {"Cancel", "Proceed"})
			end if
			
		else if userChoice is irc then
			set thePs's listChoice to listChoice({"Insert", "Remove"}, "Insert Text or Remove Text?", Â
				"Proceed") as text
			if thePs's listChoice is "Remove" then
				set thePs's removeFromWhere to listChoice({"The Left", "The Right"}, Â
					"Remove starting from which end?", "Proceed") as text
				set thePs's removeStartPosition to text returned of dialog("1", "Enter the starting position:", Â
					{"Cancel", "Proceed"}) as integer
				set thePs's removeNum to text returned of dialog("", "Enter the number of characters to remove:", Â
					{"Cancel", "Proceed"}) as integer
			else if thePs's listChoice is "Insert" then
				set thePs's insertFromWhere to listChoice({"The Left", "The Right"}, Â
					"Insert starting from which end?", "Proceed") as text
				set thePs's insertStartPosition to text returned of dialog("1", "Enter the starting position:", Â
					{"Cancel", "Proceed"}) as integer
				set thePs's insertTxt to text returned of dialog("", "Enter the text to insert:", {"Cancel", "Proceed"})
			end if
			
		else if userChoice is ce then
			set thePs's newExt to text returned of dialog("", "Enter the new extension:", {"Cancel", "Proceed"})
			
		else if userChoice is in {oa, oaacn} then
			set thePs's curN to text returned of dialog("aaa", Â
				"Enter a starting letter combo, including total number of characters desired:", {"Cancel", "Proceed"})
			if userChoice is oaacn then
				set thePs's attachBeginOrEnd to button returned of dialog(0, Â
					"Attach at beginning or end of current name?", {"Cancel", "End", "Beginning"})
			end if
			if userChoice is oa or thePs's attachBeginOrEnd is "Beginning" then
				set befOrAft to "after"
			else
				set befOrAft to "before"
			end if
			set thePs's additionalTxt to text returned of dialog("", Â
				"Enter any additional text you want placed " & befOrAft & " the letters:", Â
				{"Cancel", "Proceed"})
		end if
	on error
		return false
	end try
	return thePs
end additionalChoices


on setParameters(userChoice)
	set thePs to {}
	if userChoice is in {ns, nsacn, oa, oaacn} then
		set thePs to {curN:"", additionalTxt:"", attachBeginOrEnd:""}
	else if userChoice is irc then
		set thePs to {listChoice:"", insertStartPosition:0, removeStartPosition:0, insertFromWhere:Â
			"", removeFromWhere:"", removeNum:0, insertTxt:""}
	else if userChoice is in {ce, aps} then
		set thePs to {pfx:"", sfx:"", newExt:""}
	else if userChoice is fr then
		set thePs to {caseBool:"", searchString:"", replaceString:""}
	end if
	return thePs
end setParameters



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
		set newName to (uniqueString & thePs's curN & thePs's additionalTxt & theExt)
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
	else if userChoice is oa then
		set newName to (thePs's curN & thePs's additionalTxt & theExt)
		tell application "System Events" to set name of theItem to newName
		set thePs's curN to incrementAlphabet(thePs's curN)
	else if userChoice is oaacn then
		if thePs's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
			tell application "System Events" to set name of theItem to Â
				(thePs's curN) & (thePs's additionalTxt) & theName & theExt
		else -- Then place the number at end of name, with the additionalTxt coming just before it.
			tell application "System Events" to set name of theItem to Â
				theName & (thePs's additionalTxt) & (thePs's curN) & theExt
		end if
		set thePs's curN to incrementAlphabet(thePs's curN)
	else if userChoice is aps then
		tell application "System Events" to set name of theItem to Â
			(thePs's pfx & theName & thePs's sfx & theExt)
		
	else if userChoice is irc then
		if thePs's listChoice is "Remove" then
			if thePs's removeFromWhere is "The Left" then
				set x to (thePs's removeStartPosition)
			else
				set x to -(thePs's removeStartPosition)
			end if
			--If x is too many characters in from left, skip this item:
			if (x > (count of theName)) or ((x + ((thePs's removeNum) - 1) ³ Â
				(count of theName))) then return
			set removalText to (characters x thru (x + ((thePs's removeNum) - 1)) of theName) as text
			--If counting from the right:
			set removalText to (characters x thru (x - ((thePs's removeNum) - 1)) of theName) as text
			
			set newName to (replace(removalText, "", theName) & theExt)
		else if thePs's listChoice is "Insert" then
			if thePs's insertFromWhere is "The Left" then
				set x to (thePs's insertStartPosition)
				if x > 1 then
					set newName to ((characters 1 thru (x - 1) of theName & Â
						thePs's insertTxt & characters x thru -1 of theName) as text) & theExt
				else
					set newName to (thePs's insertTxt & (characters x thru -1 of theName as text)) & theExt
				end if
			else
				set x to -(thePs's insertStartPosition)
				if x < -1 then
					set newName to (characters 1 thru x of theName) & thePs's insertTxt & Â
						(characters (x + 1) thru -1 of theName) & theExt
				else
					set newName to (theName & thePs's insertTxt & theExt)
				end if
			end if
		end if
		tell application "System Events" to set name of theItem to newName
	end if
	
	tell application "System Events" to return path of theItem
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
		if name extension of theItem is "" then
			set theExt to ""
		else
			set theExt to "." & name extension of theItem
		end if
	end tell
	set theName to replace(theExt, "", theName)
	return {(theName & uniqueString), theExt}
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
	set charList to every text item of theChars
	set theOrder to Â
		{"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
	repeat with i from 1 to count of charList
		if LI(-i, charList) is "z" then
			setLI(-i, charList, "a")
			if i = (count of charList) then
				set charList to "a" & (charList as text)
			end if
		else
			set thePos to getIndex(LI(-i, charList), theOrder)
			setLI(-i, charList, LI(thePos + 1, theOrder))
			exit repeat
		end if
	end repeat
	return charList as text
end incrementAlphabet



on dialog(defaultTxt, theMessage, theButtons)
	set lastButton to count of theButtons
	try
		if defaultTxt = 0 then
			return display dialog theMessage with title "BatchRenamer" buttons theButtons Â
				default button lastButton
		else
			return display dialog theMessage with title "BatchRenamer" default answer Â
				defaultTxt buttons theButtons default button lastButton
		end if
	on error
		return false
	end try
end dialog

--The last 3 parameters must be strings.
on listChoice(theList, theTitle, okButton)
	return (choose from list theList with title theTitle Â
		OK button name okButton) as text
end listChoice

--theItem must be string path.
on removeUniqueString(theItem)
	tell application "System Events" to set theName to name of item theItem
	set newName to replace(uniqueString, "", theName)
	tell application "System Events" to set name of item theItem to newName
end removeUniqueString


