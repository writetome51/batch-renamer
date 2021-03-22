(*
Batch Renamer:  renames batches of files and/or folders.
*)

property thePs : {} --static global variable, stands for 'parameters'
property uniqueString : "ררררר"
global fr, ns, nsacn, oa, oaacn, aps, irc, ce

--Handler runs when dragging items onto app icon:
on open draggedItems
	mainRoutine(draggedItems)
end open


--Handler runs when app is double-clicked:
on run
	display dialog "This application is intended to be run only by dragging " & return & ֲ
		"items onto its icon.  It's going to quit now.  Bye." buttons {"OK"} ֲ
		default button 1 giving up after 5
end run


--DEFINE FUNCTIONS:

on mainRoutine(draggedItems)
	try
		--Convert every item in draggedItems to string paths:
		repeat with i from 1 to (count of draggedItems)
			setLI(i, draggedItems, LI(i, draggedItems) as text)
		end repeat
		--Every option (except for 'change extension') will not affect the name extension.
		set {fr, ns, nsacn, oa, oaacn, aps, irc, ce} to {"Find and Replace", "Number Sequentially", ֲ
			"Number Sequentially, attach to current name", "Order Alphabetically", ֲ
			"Order Alphabetically, attach to current name", "Add Prefix/Suffix", ֲ
			"Insert/Remove Characters", "Change Extension"}
		repeat
			--Have user make main choice:
			set userChoice to listChoice({fr, ns, nsacn, oa, oaacn, aps, irc, ce}, ֲ
				"What Shall I Do With These File Names?", "Proceed")
			if userChoice is false then return --app quits.
			--Present a set of additional choices based on what user has chosen already:
			set thePs to additionalChoices(userChoice)
			if thePs is false then return --app quits.
			
			--Now rename each dragged item.  If renameItems() returns true,
			--then the app can quit.
			if renameItems(draggedItems, userChoice, thePs) is true then exit repeat
		end repeat
	on error
		return
	end try
end mainRoutine


on additionalChoices(userChoice)
	try
		set thePs to setParameters(userChoice)
		if userChoice is fr then
			set thePs's caseBool to button returned of ֲ
				dialog(0, "Should the Find and Replace be case-sensitive?", {"Cancel", "Yes", "No"})
			set thePs's searchString to text returned of ֲ
				dialog("", "Enter the text to replace:", {"Cancel", "Proceed"})
			set thePs's replaceString to text returned of ֲ
				dialog("", "Enter the text to replace it with:", {"Cancel", "Proceed"})
		else if userChoice is in {ns, nsacn} then
			set thePs's curN to text returned of dialog("001", ֲ
				"Enter a starting number, including total number of digits desired:", {"Cancel", "Proceed"})
			if userChoice is nsacn then
				set thePs's attachBeginOrEnd to button returned of dialog(0, ֲ
					"Attach at beginning or end of current name?", {"Cancel", "End", "Beginning"})
			end if
			if userChoice is ns or thePs's attachBeginOrEnd is "Beginning" then
				set befOrAft to "after"
			else
				set befOrAft to "before"
			end if
			set thePs's additionalTxt to text returned of dialog("", ֲ
				"Enter any additional text you want placed " & befOrAft & " the number:", ֲ
				{"Cancel", "Proceed"})
		else if userChoice is aps then
			set listChoice to listChoice({"Prefix", "Suffix", "Both"}, ֲ
				"Add a Prefix, Suffix, or Both?", "Proceed") as text
			if listChoice is "Both" or listChoice is "Prefix" then
				set thePs's pfx to text returned of dialog("", "Enter the Prefix:", {"Cancel", "Proceed"})
			end if
			if listChoice is "Both" or listChoice is "Suffix" then
				set thePs's sfx to text returned of dialog("", "Enter the Suffix:", {"Cancel", "Proceed"})
			end if
			
		else if userChoice is irc then
			set thePs's listChoice to listChoice({"Insert", "Remove"}, "Insert Text or Remove Text?", ֲ
				"Proceed") as text
			if thePs's listChoice is "Remove" then
				set thePs's removeFromWhere to listChoice({"The Left", "The Right"}, ֲ
					"Remove starting from which end?", "Proceed") as text
				set thePs's removeStartPosition to text returned of dialog("1", "Enter the starting position:", ֲ
					{"Cancel", "Proceed"}) as integer
				set thePs's origRemoveNum to text returned of dialog("", "Enter the number of characters to remove:", ֲ
					{"Cancel", "Proceed"}) as integer
			else if thePs's listChoice is "Insert" then
				set thePs's insertFromWhere to listChoice({"The Left", "The Right"}, ֲ
					"Insert starting from which end?", "Proceed") as text
				set thePs's insertStartPosition to text returned of dialog("1", "Enter the starting position:", ֲ
					{"Cancel", "Proceed"}) as integer
				set thePs's insertTxt to text returned of dialog("", "Enter the text to insert:", {"Cancel", "Proceed"})
			end if
			
		else if userChoice is ce then
			set thePs's newExt to text returned of dialog("", "Enter the new extension:", {"Cancel", "Proceed"})
			
		else if userChoice is in {oa, oaacn} then
			set thePs's curN to text returned of dialog("aaa", ֲ
				"Enter a starting letter combo, including total number of characters desired:", {"Cancel", "Proceed"})
			if userChoice is oaacn then
				set thePs's attachBeginOrEnd to button returned of dialog(0, ֲ
					"Attach at beginning or end of current name?", {"Cancel", "End", "Beginning"})
			end if
			if userChoice is oa or thePs's attachBeginOrEnd is "Beginning" then
				set befOrAft to "after"
			else
				set befOrAft to "before"
			end if
			set thePs's additionalTxt to text returned of dialog("", ֲ
				"Enter any additional text you want placed " & befOrAft & " the letters:", ֲ
				{"Cancel", "Proceed"})
		end if
	on error
		return false
	end try
	return thePs
end additionalChoices




on renameItems(draggedItems, userChoice, thePs)
	set {modifiedItemsPaths, newNames} to {{}, {}}
	--Process each dragged item:
	repeat with i from 1 to count of draggedItems
		--Create new name string:
		set newName to newNameString(LI(i, draggedItems), userChoice, thePs)
		set end of newNames to newName
		--Create new path to item with new name:
		set pathList to explode((LI(i, draggedItems)), ":")
		if pathList ends with "" then set pathList to LI({1, -2}, pathList)
		setLI(-1, pathList, newName)
		set end of modifiedItemsPaths to implode(pathList, ":")
	end repeat
	set {i, previewString} to {1, ""}
	--Create a string for previewing the new names:
	repeat with i from 1 to count of newNames
		if i = 21 then
			set previewString to previewString & "and so on...."
			exit repeat
		end if
		set previewString to previewString & replace(uniqueString, "", LI(i, newNames)) & return
		set i to (i + 1)
	end repeat
	--Show the user a preview of the new names:
	set theResult to dialog(0, "Is this what you wanted?" & return & return & ֲ
		previewString, {"Cancel", "No, Go Back", "Yes"})
	if button returned of theResult is "Cancel" then return true
	if button returned of theResult is "No, Go Back" then return false
	--Do the actual renaming:
	renameAll(draggedItems, newNames)
	
	--Now remove the unique suffix:
	removeUniqueStrings(modifiedItemsPaths)
	return true
end renameItems


--Increments theNum that theItem will be renamed with, and converts it back to text.
--If the num requires zeros at the beginning, it adds them.
on incrementNum(theNum)
	if class of theNum is not text then set theNum to (theNum as text)
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


--theItem must be string path to the item. Returns the name (without its extension), and the extension
--as separate items.
on itemName(theItem)
	set theName to itemNameWithExt(theItem)
	set theList to explode(theName, ".")
	if (count of theList) = 1 then
		set theExt to ""
	else
		set theExt to "." & (LI(-1, theList) as text)
		set theName to replace(theExt, "", theName) --removes extension from theName
	end if
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
		return (items (item 1 of itemNum as integer) thru ֲ
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
	set theOrder to ֲ
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
			return display dialog theMessage with title "BatchRenamer" buttons theButtons ֲ
				default button lastButton
		else
			return display dialog theMessage with title "BatchRenamer" default answer ֲ
				defaultTxt buttons theButtons default button lastButton
		end if
	on error
		return false
	end try
end dialog

--The last 3 parameters must be strings.
on listChoice(theList, thePrompt, okButton)
	try
		return (choose from list theList with title ֲ
			"BatchRenamer" with prompt thePrompt OK button name okButton) as text
	on error
		return false
	end try
end listChoice

--theItem must be string path.
on removeUniqueStrings(renamedItems)
	repeat with i from 1 to (count of renamedItems)
		set theName to LI(-1, explode(LI(i, renamedItems) as string, ":")) --extracts item name from path.
		--if theName is "" then the item is a folder and the path must have ended with a colon:
		if theName is "" then set theName to LI(-2, explode(LI(i, renamedItems) as string, ":"))
		set newName to replace(uniqueString, "", theName) --removes uniqueString.
		tell application "System Events" to set name of item (my LI(i, renamedItems)) to newName
	end repeat
end removeUniqueStrings




--theItem must be a colon-delimited path string. 
--Example: "Macintosh HD:Users:Username:Desktop:Filename.txt"
--Returns theItem's name (without the full path) as string.
on itemNameWithExt(theItem)
	set theParts to explode(theItem, ":")
	if theParts ends with "" then set theParts to LI({1, -2}, theParts)
	return LI(-1, theParts) as text
end itemNameWithExt




on renameAll(theItems, theNames)
	repeat with i from 1 to count of theItems
		tell application "System Events" to set name of item ֲ
			(my LI(i, theItems)) to my LI(i, theNames)
	end repeat
end renameAll


on newNameString(theItem, userChoice, thePs)
	set {theName, theExt} to itemName(theItem)
	if userChoice is fr then
		if thePs's caseBool is "Yes" then
			considering case
				set newName to replace(thePs's searchString, thePs's replaceString, theName)
			end considering
		else
			set newName to replace(thePs's searchString, thePs's replaceString, theName)
		end if
	else if userChoice is ns then
		set newName to (thePs's curN & thePs's additionalTxt)
		set thePs's curN to incrementNum(thePs's curN)
	else if userChoice is nsacn then
		if thePs's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
			set newName to (thePs's curN) & (thePs's additionalTxt) & theName
		else -- Then place the number at end of name, with the additionalTxt coming just before it.
			set newName to (theName & (thePs's additionalTxt) & (thePs's curN))
		end if
		set thePs's curN to incrementNum(thePs's curN)
	else if userChoice is oa then
		set newName to (thePs's curN & thePs's additionalTxt)
		set thePs's curN to incrementAlphabet(thePs's curN)
	else if userChoice is oaacn then
		if thePs's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
			set newName to (thePs's curN) & (thePs's additionalTxt) & theName
		else -- Then place the number at end of name, with the additionalTxt coming just before it.
			set newName to theName & (thePs's additionalTxt) & (thePs's curN)
		end if
		set thePs's curN to incrementAlphabet(thePs's curN)
	else if userChoice is aps then
		set newName to (thePs's pfx & theName & thePs's sfx)
	else if userChoice is irc then
		if thePs's listChoice is "Remove" then
			set thePs's removeNum to thePs's origRemoveNum
			set {x, thePs's removeNum} to {(thePs's removeStartPosition), ((thePs's removeNum) - 1)}
			--if theItem is "Macintosh HD:Applications:AppleScript:Applications:BatchRenamer project:0020.scpt" then return thePs's removeNum
			--If x is too many characters in from left or right, skip this item:
			if (x > (count of theName)) or ((thePs's removeNum) ³ (count of theName)) then return
			if (thePs's removeFromWhere is "The Right") then set {x, thePs's removeNum} ֲ
				to {-(thePs's removeStartPosition), -(thePs's removeNum)}
			set y to (x + (thePs's removeNum))
			--set removalText to (characters x thru y of theName as text)
			set nameChars to every text item of theName
			if thePs's removeFromWhere is "The Left" then
				--If the removeStartPosition is not at beginning of name, save first part of name:
				if x > 1 then
					set firstPart to implode(LI({1, (x - 1)}, nameChars), "")
				else
					set firstPart to ""
				end if
				--Set x to the first char that comes after the section of theName to be removed:
				set x to (y + 1)
				--If x now exceeds the number of chars in theName, this means the user wanted to trim 
				--off the last character(s) of theName:
				if x > (count of theName) then
					set newName to firstPart
				else
					set newName to (firstPart & (LI({x, -1}, nameChars) as text)) --(replace(removalText, "", theName))
				end if
			else
				--If the removeStartPosition is not at end of name, save last part of name:
				if x < -1 then
					set lastPart to implode(LI({-1, (x + 1)}, nameChars), "")
				else
					set lastPart to ""
				end if
				--Set x to the first char that comes before the section of theName to be removed:
				set x to (y - 1)
				--If positive x now exceeds the number of chars in theName, this means the user wanted to trim 
				--off the first character(s) of theName:
				if (-(x) > (count of theName)) then
					set newName to lastPart
				else
					set newName to ((LI({1, x}, nameChars) as text) & lastPart)
				end if
			end if
		else if thePs's listChoice is "Insert" then
			set x to (thePs's insertStartPosition)
			if thePs's insertFromWhere is "The Left" then
				if x > (count of theName) then set {x, thePs's insertFromWhere} to {-1, "The Right"}
				if x > 1 then
					set newName to (((characters 1 thru (x - 1) of theName as text) & ֲ
						thePs's insertTxt & characters x thru -1 of theName as text))
				else
					set newName to (thePs's insertTxt & (characters x thru -1 of theName as text))
				end if
			end if
			if thePs's insertFromWhere is "The Right" then
				if (x > 0) then set x to -(thePs's insertStartPosition)
				if x < -1 then
					set newName to (characters 1 thru x of theName as text) & thePs's insertTxt & ֲ
						(characters (x + 1) thru -1 of theName as text)
				else
					set newName to (theName & thePs's insertTxt)
				end if
			end if
		end if
	end if
	if userChoice is ce then
		set newName to (uniqueString & theName & "." & thePs's newExt)
	else --If it's any of the other choices:
		set newName to (uniqueString & newName & theExt)
	end if
	return newName
end newNameString


on setParameters(userChoice)
	set thePs to {origRemoveNum:0}
	if userChoice is in {ns, nsacn, oa, oaacn} then
		set thePs to thePs & {curN:"", additionalTxt:"", attachBeginOrEnd:""}
	else if userChoice is irc then
		set thePs to thePs & {listChoice:"", insertStartPosition:0, removeStartPosition:0, insertFromWhere:ֲ
			"", removeFromWhere:"", removeNum:0, insertTxt:""}
	else if userChoice is in {ce, aps} then
		set thePs to thePs & {pfx:"", sfx:"", newExt:""}
	else if userChoice is fr then
		set thePs to thePs & {caseBool:"", searchString:"", replaceString:""}
	end if
	return thePs
end setParameters

