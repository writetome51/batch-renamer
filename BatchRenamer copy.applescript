(*********************************
BatchRenamer,  Copyright � 2021 - 2030 by Steve Thompson.
All Rights Reserved.  Thou shalt not steal.

Renames batch of items in Mac Finder (anything that can be renamed).  
This script can be saved as an application, or be run as is.

## How to use

### 1.  Select items in the Finder.

Remember:  Items appear in the renaming queue in the order they are selected.  
So for example, the items you want to rename appear in a Finder window in this order:  
-  image.jpg  
-  essay.doc  
-  folder1
		
But you want to rename them (with numbers at the beginning) in this order:  
-  01 folder1  
-  02 image.jpg  
-  03 essay.doc

So you must select the items in that order (folder1, image.jpg, essay.doc) before you run  
the app.

### 2.  Run the app.
**********************************)


--static globals
property params : {}


--global constants

-- initial choices
global |FR|, |NS|, |NSACN|, |OA|, |OAACN|, |APS|, |IRC|, |CE|, |CAPITAL|, |CHANGECASE|
global |MAIN_CHOICES| -- list containing initial choices.

global |INSERT|, |REMOVE| -- 2 choices
global |INSERT_REMOVE| -- list containing 2 choices

global |LEFT|, |RIGHT|
global |LEFT_RIGHT|

global |PROCEED|
global |CANCEL_PROCEED|
global |GO_BACK|

global |UNIQUESTRING|


--Handler runs when app is double-clicked:
on run
	
	tell application "Finder" to set selectedItemPaths to selection
	
	if selectedItemPaths's length = 0 then return (display dialog �
		"Items must be selected in the Finder window before launching me." & �
		return & return & "I'm going to quit now. Bye." with title �
		"BatchRenamer" buttons {"OK"} default button 1 giving up after 5)
	
	mainRoutine(selectedItemPaths)
end run


on mainRoutine(itemPaths)
	try
		setGlobalConstants()
		
		repeat
			set params to {}
			
			set choice to �
				listChoice(|MAIN_CHOICES|, "What To Do With These Names?", |PROCEED|)
			
			set params to getAdditionalChoices(choice)
			
			set {newNames, newPaths} to �
				get_newNames_newPaths(itemPaths, choice, params)
			
			if userApproves(newNames) then
				renameAll(itemPaths, newNames, newPaths)
				exit repeat
			end if
		end repeat
		
	on error
		return
	end try
end mainRoutine


on setGlobalConstants()
	--The only option that affects the name extension is "Change Extension".
	set {|FR|, |NS|, |NSACN|, |OA|, |OAACN|, |APS|, |IRC|, |CE|, |CAPITAL|, |CHANGECASE|} to �
		{"Find and Replace", "Number Sequentially", �
			"Number Sequentially, attach to current name", "Order Alphabetically", �
			"Order Alphabetically, attach to current name", "Add Prefix/Suffix", �
			"Insert/Remove Characters", "Change Extension", "Capitalize", "Change Case"}
	
	set |MAIN_CHOICES| to �
		{|FR|, |NS|, |NSACN|, |OA|, |OAACN|, |APS|, |IRC|, |CE|, |CAPITAL|, |CHANGECASE|}
	
	set {|INSERT|, |REMOVE|} to {"Insert", "Remove"}
	set |INSERT_REMOVE| to {|INSERT|, |REMOVE|}
	
	set {|LEFT|, |RIGHT|} to {"The Left", "The Right"}
	set |LEFT_RIGHT| to {|LEFT|, |RIGHT|}
	
	set |PROCEED| to "Proceed"
	set |CANCEL_PROCEED| to {"Cancel", |PROCEED|}
	set |GO_BACK| to "No, Go Back"
	
	set |UNIQUESTRING| to "�&�*�#�%�"
end setGlobalConstants


on getAdditionalChoices(userChoice)
	
	set params to getDefaultParameters(userChoice)
	
	if userChoice is |FR| then
		set params to setFindReplaceParams(params)
		
	else if userChoice is in {|NS|, |NSACN|} then
		set params to setNumberSequentiallyParams(params, userChoice)
		
	else if userChoice is |APS| then
		set params to setAddPrefixSuffixParams(params)
		
	else if userChoice is |IRC| then
		set params to setInsertRemoveParams(params)
		
	else if userChoice is |CE| then
		set params's newExt to text returned of �
			dialogWithTextInput("", "Enter the new extension:", |CANCEL_PROCEED|)
		
	else if userChoice is in {|OA|, |OAACN|} then
		set params to setOrderAlphabeticallyParams(params, userChoice)
		
	end if
	
	return params
end getAdditionalChoices


on userApproves(newNames)
	set previewString to getPreviewString(newNames)
	--Show the user a preview of the new names:
	set theResult to �
		dialogWithButtons("Is this what you wanted?" & return & return & previewString, �
			{"Cancel", |GO_BACK|, "Yes"})
	if button returned of theResult is "Cancel" then
		error "User cancelled"
	else if button returned of theResult is |GO_BACK| then
		return false
	end if
	
	return true
end userApproves


on getPreviewString(newNames)
	set previewString to ""
	
	repeat with i from 1 to count of newNames
		-- We don't need to see more than 20 lines of new names:
		if i = 21 then
			set previewString to previewString & "and so on...."
			exit repeat
		end if
		set newName to replace(|UNIQUESTRING|, "", LI(i, newNames))
		set previewString to (previewString & newName & return)
	end repeat
	
	return previewString
end getPreviewString


on setFindReplaceParams(params)
	set params's caseBool to button returned of �
		dialogWithButtons("Should the Find and Replace be case-sensitive?", {"Cancel", "Yes", "No"})
	if params's caseBool is "Cancel" then error "Error"
	
	set params's searchString to text returned of �
		dialogWithTextInput("", "Enter the text to find:", |CANCEL_PROCEED|)
	set params's replaceString to text returned of �
		dialogWithTextInput("", "Enter the text to replace it with:", |CANCEL_PROCEED|)
	
	return params
end setFindReplaceParams


on setNumberSequentiallyParams(params, userChoice)
	set params's curN to text returned of �
		dialogWithTextInput("001", "Enter a starting number:", |CANCEL_PROCEED|)
	if userChoice is |NSACN| then
		set params's attachBeginOrEnd to button returned of �
			dialogWithButtons("Attach at beginning or end of current name?", �
				{"Cancel", "End", "Beginning"})
	end if
	if userChoice is |NS| or params's attachBeginOrEnd is "Beginning" then
		set befOrAft to "after"
	else
		set befOrAft to "before"
	end if
	set params's additionalTxt to text returned of dialogWithTextInput("", �
		"Enter any additional text you want placed " & befOrAft & " the number:", �
		|CANCEL_PROCEED|)
	
	return params
end setNumberSequentiallyParams


on setAddPrefixSuffixParams(params)
	set listChoice to listChoice({"Prefix", "Suffix", "Both"}, �
		"Add a Prefix, Suffix, or Both?", |PROCEED|)
	if listChoice is "Both" or listChoice is "Prefix" then
		set params's pfx to text returned of dialogWithTextInput("", "Enter the Prefix:", |CANCEL_PROCEED|)
	end if
	if listChoice is "Both" or listChoice is "Suffix" then
		set params's sfx to text returned of dialogWithTextInput("", "Enter the Suffix:", |CANCEL_PROCEED|)
	end if
	
	return params
end setAddPrefixSuffixParams


on setInsertRemoveParams(params)
	
	set params's listChoice to �
		listChoice(|INSERT_REMOVE|, (|INSERT| & " or " & |REMOVE| & " Text?"), |PROCEED|)
	
	if params's listChoice is |REMOVE| then
		set params's removeFromWhere to getStartingFromWhereChoice(params's listChoice)
		set params's removeStartPosition to getStartPosition()
		
		set params's removeNum to text returned of �
			dialogWithTextInput("", "Enter the number of characters to remove:", |CANCEL_PROCEED|) �
				as integer
		
	else if params's listChoice is |INSERT| then
		set params's insertFromWhere to getStartingFromWhereChoice(params's listChoice)
		set params's insertStartPosition to getStartPosition()
		
		set params's insertTxt to text returned of �
			dialogWithTextInput("", "Enter the text to insert:", |CANCEL_PROCEED|)
	end if
	
	return params
end setInsertRemoveParams


on setOrderAlphabeticallyParams(params, userChoice)
	set params's curN to text returned of dialogWithTextInput("aaa", �
		"Enter a starting letter combo, including total number of characters desired:", �
		|CANCEL_PROCEED|)
	if userChoice is |OAACN| then
		set params's attachBeginOrEnd to button returned of �
			dialogWithButtons("Attach at beginning or end of current name?", �
				{"Cancel", "End", "Beginning"})
	end if
	if userChoice is |OA| or params's attachBeginOrEnd is "Beginning" then
		set befOrAft to "after"
	else
		set befOrAft to "before"
	end if
	set params's additionalTxt to text returned of dialogWithTextInput("", �
		"Enter any additional text you want placed " & befOrAft & " the letters:", �
		|CANCEL_PROCEED|)
	
	return params
end setOrderAlphabeticallyParams



on getStartingFromWhereChoice(action)
	return listChoice(|LEFT_RIGHT|, (action & " starting from which end?"), |PROCEED|)
end getStartingFromWhereChoice


on getStartPosition()
	return text returned of �
		dialogWithTextInput("1", "Enter the starting position:", |CANCEL_PROCEED|) as integer
end getStartPosition


on get_newNames_newPaths(itemPaths, userChoice, params)
	--Convert to string paths:
	repeat with i from 1 to (count of itemPaths)
		setLI(i, itemPaths, LI(i, itemPaths) as text)
	end repeat
	
	set {newPaths, newNames} to {{}, {}}
	
	--Process each dragged item:
	repeat with i from 1 to count of itemPaths
		--Create new name string:
		set newName to getNewName(LI(i, itemPaths), userChoice, params)
		set end of newNames to newName
		set end of newPaths to getNewPath(LI(i, itemPaths), newName)
	end repeat
	
	return {newNames, newPaths}
end get_newNames_newPaths



on getNewPath(oldPath, newName)
	set pathList to explode(oldPath, ":")
	if pathList ends with "" then set pathList to LI({1, -2}, pathList)
	
	setLI(-1, pathList, newName)
	return implode(pathList, ":")
end getNewPath


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


on get_theName_theExtension(itemPath)
	set theName to getNameFromPath(itemPath)
	set theList to explode(theName, ".")
	if (count of theList) = 1 then
		set theExt to ""
	else
		set theExt to "." & (LI(-1, theList) as text)
		set theName to LI({1, -2}, theList) as text
	end if
	return {theName, theExt}
end get_theName_theExtension


on getTail(numChars, str)
	set lst to every text item of str
	return LI({-numChars, -1}, lst) as text
end getTail


on getHead(numChars, str)
	set lst to every text item of str
	return LI({1, numChars}, lst) as text
end getHead



--Replaces searchString with replaceString inside theString:
on replace(searchString, replaceString, theString)
	set item_list to explode(theString, searchString)
	return implode(item_list, replaceString)
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
		return (items (item 1 of itemNum as integer) thru �
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
	set theOrder to every text item of getAlphabet("lower")
	
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


on dialogWithTextInput(defaultTxt, theMessage, theButtons)
	set lastButton to count of theButtons
	
	return display dialog theMessage with title "BatchRenamer" default answer �
		defaultTxt buttons theButtons default button lastButton
end dialogWithTextInput


on dialogWithButtons(theMessage, theButtons)
	set lastButton to count of theButtons
	
	return display dialog theMessage with title "BatchRenamer" buttons theButtons �
		default button lastButton
end dialogWithButtons


on listChoice(theList, thePrompt, okButton)
	return (choose from list theList with title �
		"BatchRenamer" with prompt thePrompt OK button name okButton) as text
end listChoice



on removeUniqueStrings(renamedItemPaths)
	repeat with i from 1 to (count of renamedItemPaths)
		set theName to getNameFromPath(LI(i, renamedItemPaths))
		set newName to replace(|UNIQUESTRING|, "", theName)
		
		tell application "System Events" to �
			set name of item (my LI(i, renamedItemPaths)) to newName
	end repeat
end removeUniqueStrings


--itemPath must be a colon-delimited path string. 
--Example: "Macintosh HD:Users:Username:Desktop:Filename.txt"
on getNameFromPath(itemPath)
	set theParts to explode(itemPath, ":")
	if theParts ends with "" then set theParts to LI({1, -2}, theParts)
	return LI(-1, theParts) as text
end getNameFromPath


on renameAll(itemPaths, newNames, renamedPaths)
	repeat with i from 1 to count of itemPaths
		tell application "System Events" to set name of item �
			(my LI(i, itemPaths)) to my LI(i, newNames)
	end repeat
	
	--Remove unique string from each item name:
	repeat with i from 1 to (count of renamedPaths)
		set theName to getNameFromPath(LI(i, renamedPaths))
		set newName to replace(|UNIQUESTRING|, "", theName)
		
		tell application "System Events" to �
			set name of item (my LI(i, renamedPaths)) to newName
	end repeat
end renameAll



on getNewName(itemPath, userChoice, params)
	set {theName, theExt} to get_theName_theExtension(itemPath)
	
	if userChoice is |FR| then
		set newName to getNewName_FR(params, theName)
		
	else if userChoice is |NS| then
		set newName to getNewName_NS(params)
		
	else if userChoice is |NSACN| then
		set newName to getNewName_NSACN(params, theName)
		
	else if userChoice is |OA| then
		set newName to getNewName_OA(params)
		
	else if userChoice is |OAACN| then
		set newName to getNewName_OAACN(params, theName)
		
	else if userChoice is |APS| then
		set newName to (params's pfx & theName & params's sfx)
		
	else if userChoice is |IRC| then
		set newName to getNewName_IRC(params, theName)
	end if
	
	if userChoice is |CE| then return getNewName_CE(params, theName)
	
	return (|UNIQUESTRING| & newName & theExt)
end getNewName


on getNewName_OA(params)
	set newName to (params's curN & params's additionalTxt)
	set params's curN to incrementAlphabet(params's curN)
	return newName
end getNewName_OA


on getNewName_OAACN(params, oldName)
	if params's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
		set newName to (params's curN) & (params's additionalTxt) & oldName
	else -- Then place the number at end of name, with the additionalTxt coming just before it.
		set newName to oldName & (params's additionalTxt) & (params's curN)
	end if
	set params's curN to incrementAlphabet(params's curN)
	return newName
end getNewName_OAACN


on getNewName_NS(params)
	set newName to (params's curN & params's additionalTxt)
	set params's curN to incrementNum(params's curN)
	return newName
end getNewName_NS


on getNewName_NSACN(params, oldName)
	if params's attachBeginOrEnd is "Beginning" then -- Then place the number at beginning of name.
		set newName to (params's curN) & (params's additionalTxt) & oldName
	else -- Then place the number at end of name, with the additionalTxt coming just before it.
		set newName to (oldName & (params's additionalTxt) & (params's curN))
	end if
	set params's curN to incrementNum(params's curN)
	return newName
end getNewName_NSACN


on getNewName_CE(params, oldName)
	return (|UNIQUESTRING| & oldName & "." & params's newExt)
end getNewName_CE


on getNewName_FR(params, oldName)
	if params's caseBool is "Yes" then
		considering case
			return replace(params's searchString, params's replaceString, oldName)
		end considering
	else
		return replace(params's searchString, params's replaceString, oldName)
	end if
end getNewName_FR



on getNewName_IRC(params, oldName)
	if params's listChoice is "Remove" then
		set oldNameLength to count of oldName
		
		if (params's removeStartPosition > oldNameLength) or �
			((params's removeNum) > oldNameLength) then return oldName
		
		set endPosition to ((params's removeStartPosition) + (params's removeNum)) - 1
		
		if params's removeFromWhere is |RIGHT| then �
			set oldName to reverse of every text item of oldName as text
		
		--If the removeStartPosition is not at beginning of name, save first part of name:
		if params's removeStartPosition > 1 then
			set firstPart to getHead((params's removeStartPosition) - 1, oldName)
		else
			set firstPart to ""
		end if
		
		--If (endPosition + 1) exceeds the number of chars in oldName, this means 
		--the user wanted to trim off the end of oldName:
		if (endPosition + 1) > oldNameLength then
			set newName to firstPart
		else
			set newName to (firstPart & (getTail(oldNameLength - endPosition, oldName)))
		end if
		if params's removeFromWhere is |RIGHT| then �
			set newName to reverse of every text item of newName as text
		
		return newName
		
	else if params's listChoice is "Insert" then
		set x to (params's insertStartPosition)
		if params's insertFromWhere is |LEFT| then
			if x > (count of oldName) then set {x, params's insertFromWhere} to {-1, |RIGHT|}
			if x > 1 then
				return (((characters 1 thru (x - 1) of oldName as text) & �
					params's insertTxt & characters x thru -1 of oldName as text))
			else
				return (params's insertTxt & (characters x thru -1 of oldName as text))
			end if
		end if
		if params's insertFromWhere is |RIGHT| then
			if (x > 0) then set x to -(params's insertStartPosition)
			if x < -1 then
				return (characters 1 thru x of oldName as text) & params's insertTxt & �
					(characters (x + 1) thru -1 of oldName as text)
			else
				return (oldName & params's insertTxt)
			end if
		end if
	end if
end getNewName_IRC


on getDefaultParameters(userChoice)
	set params to {}
	
	if userChoice is in {|NS|, |NSACN|, |OA|, |OAACN|} then
		set params to params & {curN:"", additionalTxt:"", attachBeginOrEnd:""}
		
	else if userChoice is |IRC| then
		set params to params & �
			{listChoice:"", insertStartPosition:0, removeStartPosition:0, insertFromWhere:�
				"", removeFromWhere:"", removeNum:0, insertTxt:""}
		
	else if userChoice is in {|CE|, |APS|} then
		set params to params & {pfx:"", sfx:"", newExt:""}
		
	else if userChoice is |FR| then
		set params to params & {caseBool:"", searchString:"", replaceString:""}
	end if
	return params
end getDefaultParameters



on getUppercase(str)
	return getCharsTranslated(str, getAlphabet("lower"), getAlphabet("upper"))
end getUppercase


on getLowercase(str)
	return getCharsTranslated(str, getAlphabet("upper"), getAlphabet("lower"))
end getLowercase



on getCharsTranslated(str, fromAlphabet, toAlphabet)
	script private
		return translateEachCharIn(str)
		
		
		on translateEachCharIn(str)
			set translation to ""
			
			repeat with char in str
				set translation to (translation & getTranslated(char))
			end repeat
			
			return translation
		end translateEachCharIn
		
		
		on getTranslated(char)
			set i to offset of char in fromAlphabet
			
			if notFound(i) then return char as string
			
			return (character i of toAlphabet) as string
		end getTranslated
		
		
		on notFound(num)
			return num = 0
		end notFound
		
	end script
	
	
	run private
end getCharsTranslated


on getAlphabet(theCase)
	if theCase = "lower" then return "abcdefghijklmnopqrstuvwxyz"
	return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
end getAlphabet