(*******************
Batch Renamer:  renames batch of items in Finder (files, folders, anything that
can be renamed).

How to use:

1.  Select items in the Finder.  
        (
		Remember:  Items appear in the renaming queue in the order they are selected.
              So for example, the items you want to rename appear in a Finder window in this order:
	 		-  image.jpg
			-  essay.doc
			-  folder1
		
              But you want to rename them (with numbers at the beginning) in this order:
			-  01 folder1
			-  02 image.jpg
			-  03 essay.doc
		
	      So you must select the items in that order, then run the script.
	)
	

2.  Run the script.
*******************)


--static globals
property params : {}
property uniqueString : "ø&ø*ø#ø%ø"

--nonstatic globals
global fr, ns, nsacn, oa, oaacn, aps, irc, ce

(*
--Handler runs when dragging items onto app icon:
on open (selectedItems)
	-- Because dragging items onto an applescript app is now unreliable (due to an applescript bug)
	-- we're no longer doing it this way.
	display dialog "This application is not a droplet.  You must launch by double-clicking the icon." & Â
		return & return & Â
		"It's going to quit now.  Bye." buttons {"OK"} default button 1 giving up after 5
end open
*)


--Handler runs when app is double-clicked:
on run
	tell application "Finder" to set selectedItems to selection
	
	if selectedItems's length = 0 then return (display dialog Â
		"Items must be selected in the Finder window before running this application." & Â
		return & return & "It's going to quit now.  Bye." with title Â
		"BatchRenamer" buttons {"OK"} default button 1 giving up after 5)
	
	mainRoutine(selectedItems)
end run



--DEFINE FUNCTIONS:

on mainRoutine(selectedItems)
	try
		
		--Every option (except for 'change extension') will not affect the name extension.
		set {fr, ns, nsacn, oa, oaacn, aps, irc, ce} to {"Find and Replace", "Number Sequentially", Â
			"Number Sequentially, attach to current name", "Order Alphabetically", Â
			"Order Alphabetically, attach to current name", "Add Prefix/Suffix", Â
			"Insert/Remove Characters", "Change Extension"}
		
		repeat
			set params to {}
			
			--Have user make main choice:
			set choice to listChoice({fr, ns, nsacn, oa, oaacn, aps, irc, ce}, Â
				"What Shall I Do With These Names?", "Proceed")
			
			--Present a set of additional choices based on what user has chosen already:
			set renameParams to getRenameParameters(choice)
			
			--Now rename each dragged item.
			if renameItems(selectedItems, choice, renameParams) is true then exit repeat
		end repeat
	on error
		return
	end try
end mainRoutine


on getRenameParameters(userChoice)
	try
		set params to getDefaultParameters(userChoice)
		
		if userChoice is fr then
			set params to setFindReplaceParams(params)
			
		else if userChoice is in {ns, nsacn} then
			set params to setNumberSequentiallyParams(params, userChoice)
			
		else if userChoice is aps then
			set params to setAddPrefixSuffixParams(params)
			
		else if userChoice is irc then
			set params to setInsertRemoveParams(params)
			
		else if userChoice is ce then
			set params's newExt to text returned of dialog("", "Enter the new extension:", {"Cancel", "Proceed"})
			
		else if userChoice is in {oa, oaacn} then
			set params to setOrderAlphabeticallyParams(params, userChoice)
			
		end if
	end try
	
	return params
end getRenameParameters


on setOrderAlphabeticallyParams(params, userChoice)
	set params's curN to text returned of dialog("aaa", Â
		"Enter a starting letter combo, including total number of characters desired:", {"Cancel", "Proceed"})
	if userChoice is oaacn then
		set params's attachBeginOrEnd to button returned of dialog(0, Â
			"Attach at beginning or end of current name?", {"Cancel", "End", "Beginning"})
	end if
	if userChoice is oa or params's attachBeginOrEnd is "Beginning" then
		set befOrAft to "after"
	else
		set befOrAft to "before"
	end if
	set params's additionalTxt to text returned of dialog("", Â
		"Enter any additional text you want placed " & befOrAft & " the letters:", Â
		{"Cancel", "Proceed"})
	
	return params
end setOrderAlphabeticallyParams


on setFindReplaceParams(params)
	set params's caseBool to button returned of Â
		dialog(0, "Should the Find and Replace be case-sensitive?", {"Cancel", "Yes", "No"})
	set params's searchString to text returned of Â
		dialog("", "Enter the text to replace:", {"Cancel", "Proceed"})
	set params's replaceString to text returned of Â
		dialog("", "Enter the text to replace it with:", {"Cancel", "Proceed"})
	
	return params
end setFindReplaceParams


on setNumberSequentiallyParams(params, userChoice)
	set params's curN to text returned of dialog("001", Â
		"Enter a starting number, including total number of digits desired:", {"Cancel", "Proceed"})
	if userChoice is nsacn then
		set params's attachBeginOrEnd to button returned of dialog(0, Â
			"Attach at beginning or end of current name?", {"Cancel", "End", "Beginning"})
	end if
	if userChoice is ns or params's attachBeginOrEnd is "Beginning" then
		set befOrAft to "after"
	else
		set befOrAft to "before"
	end if
	set params's additionalTxt to text returned of dialog("", Â
		"Enter any additional text you want placed " & befOrAft & " the number:", Â
		{"Cancel", "Proceed"})
	
	return params
end setNumberSequentiallyParams


on setAddPrefixSuffixParams(params)
	set listChoice to listChoice({"Prefix", "Suffix", "Both"}, Â
		"Add a Prefix, Suffix, or Both?", "Proceed") as text
	if listChoice is "Both" or listChoice is "Prefix" then
		set params's pfx to text returned of dialog("", "Enter the Prefix:", {"Cancel", "Proceed"})
	end if
	if listChoice is "Both" or listChoice is "Suffix" then
		set params's sfx to text returned of dialog("", "Enter the Suffix:", {"Cancel", "Proceed"})
	end if
	
	return params
end setAddPrefixSuffixParams


on setInsertRemoveParams(params)
	set params's listChoice to listChoice({"Insert", "Remove"}, "Insert Text or Remove Text?", Â
		"Proceed") as text
	if params's listChoice is "Remove" then
		set params's removeFromWhere to listChoice({"The Left", "The Right"}, Â
			"Remove starting from which end?", "Proceed") as text
		set params's removeStartPosition to text returned of dialog("1", "Enter the starting position:", Â
			{"Cancel", "Proceed"}) as integer
		set params's origRemoveNum to text returned of dialog("", "Enter the number of characters to remove:", Â
			{"Cancel", "Proceed"}) as integer
	else if params's listChoice is "Insert" then
		set params's insertFromWhere to listChoice({"The Left", "The Right"}, Â
			"Insert starting from which end?", "Proceed") as text
		set params's insertStartPosition to text returned of dialog("1", "Enter the starting position:", Â
			{"Cancel", "Proceed"}) as integer
		set params's insertTxt to text returned of dialog("", "Enter the text to insert:", {"Cancel", "Proceed"})
	end if
	
	return params
end setInsertRemoveParams




on renameItems(selectedItems, userChoice, params)
	
	--Convert every item in selectedItems to string paths:
	repeat with i from 1 to (count of selectedItems)
		setLI(i, selectedItems, LI(i, selectedItems) as text)
	end repeat
	
	set {modifiedItemsPaths, newNames} to {{}, {}}
	
	--Process each dragged item:
	repeat with i from 1 to count of selectedItems
		--Create new name string:
		set newName to newNameString(LI(i, selectedItems), userChoice, params)
		set end of newNames to newName
		--Create new path to item with new name:
		set pathList to explode((LI(i, selectedItems)), ":")
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
	set theResult to dialog(0, "Is this what you wanted?" & return & return & Â
		previewString, {"Cancel", "No, Go Back", "Yes"})
	if button returned of theResult is "Cancel" then return true -- ends script.
	if button returned of theResult is "No, Go Back" then return false
	
	--Do the actual renaming:
	renameAll(selectedItems, newNames)
	
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


on itemName(itemPath)
	set theName to itemNameWithExt(itemPath)
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
		return (items (item 1 of itemNum as integer) thru Â
			(item 2 of itemNum as integer) of theList)
	end if
end LI


--This function is for assigning a value to a list item:
on setLI(itemNum, theList, theValue)
	set item itemNum of theList to theValue
end setLI


on getIndex(theItem, theList)
	if class of theList is not in {integer, real, text, list} then return false
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


on listChoice(theList, thePrompt, okButton)
	return (choose from list theList with title Â
		"BatchRenamer" with prompt thePrompt OK button name okButton) as text
end listChoice



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
		tell application "System Events" to set name of item Â
			(my LI(i, theItems)) to my LI(i, theNames)
	end repeat
end renameAll


on newNameString(theItem, userChoice, params)
	set {theName, theExt} to itemName(theItem)
	if userChoice is fr then
		if params's caseBool is "Yes" then
			considering case
				set newName to replace(params's searchString, params's replaceString, theName)
			end considering
		else
			set newName to replace(params's searchString, params's replaceString, theName)
		end if
	else if userChoice is ns then
		set newName to (params's curN & params's additionalTxt)
		set params's curN to incrementNum(params's curN)
	else if userChoice is nsacn then
		if params's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
			set newName to (params's curN) & (params's additionalTxt) & theName
		else -- Then place the number at end of name, with the additionalTxt coming just before it.
			set newName to (theName & (params's additionalTxt) & (params's curN))
		end if
		set params's curN to incrementNum(params's curN)
	else if userChoice is oa then
		set newName to (params's curN & params's additionalTxt)
		set params's curN to incrementAlphabet(params's curN)
	else if userChoice is oaacn then
		if params's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
			set newName to (params's curN) & (params's additionalTxt) & theName
		else -- Then place the number at end of name, with the additionalTxt coming just before it.
			set newName to theName & (params's additionalTxt) & (params's curN)
		end if
		set params's curN to incrementAlphabet(params's curN)
	else if userChoice is aps then
		set newName to (params's pfx & theName & params's sfx)
	else if userChoice is irc then
		if params's listChoice is "Remove" then
			set params's removeNum to params's origRemoveNum
			set {x, params's removeNum} to {(params's removeStartPosition), ((params's removeNum) - 1)}
			--if theItem is "Macintosh HD:Applications:AppleScript:Applications:BatchRenamer project:0020.scpt" then return params's removeNum
			--If x is too many characters in from left or right, skip this item:
			if (x > (count of theName)) or ((params's removeNum) ³ (count of theName)) then return
			if (params's removeFromWhere is "The Right") then set {x, params's removeNum} Â
				to {-(params's removeStartPosition), -(params's removeNum)}
			set y to (x + (params's removeNum))
			--set removalText to (characters x thru y of theName as text)
			set nameChars to every text item of theName
			if params's removeFromWhere is "The Left" then
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
		else if params's listChoice is "Insert" then
			set x to (params's insertStartPosition)
			if params's insertFromWhere is "The Left" then
				if x > (count of theName) then set {x, params's insertFromWhere} to {-1, "The Right"}
				if x > 1 then
					set newName to (((characters 1 thru (x - 1) of theName as text) & Â
						params's insertTxt & characters x thru -1 of theName as text))
				else
					set newName to (params's insertTxt & (characters x thru -1 of theName as text))
				end if
			end if
			if params's insertFromWhere is "The Right" then
				if (x > 0) then set x to -(params's insertStartPosition)
				if x < -1 then
					set newName to (characters 1 thru x of theName as text) & params's insertTxt & Â
						(characters (x + 1) thru -1 of theName as text)
				else
					set newName to (theName & params's insertTxt)
				end if
			end if
		end if
	end if
	if userChoice is ce then
		set newName to (uniqueString & theName & "." & params's newExt)
	else --If it's any of the other choices:
		set newName to (uniqueString & newName & theExt)
	end if
	return newName
end newNameString


on getDefaultParameters(userChoice)
	set params to {origRemoveNum:0}
	if userChoice is in {ns, nsacn, oa, oaacn} then
		set params to params & {curN:"", additionalTxt:"", attachBeginOrEnd:""}
	else if userChoice is irc then
		set params to params & {listChoice:"", insertStartPosition:0, removeStartPosition:0, insertFromWhere:Â
			"", removeFromWhere:"", removeNum:0, insertTxt:""}
	else if userChoice is in {ce, aps} then
		set params to params & {pfx:"", sfx:"", newExt:""}
	else if userChoice is fr then
		set params to params & {caseBool:"", searchString:"", replaceString:""}
	end if
	return params
end getDefaultParameters
