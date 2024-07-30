//***********************************************************************
//***********************************************************************
// Copyright Travant Solutions, Inc. 2000-2006
//
// The use, disclosure, reproduction, modification, transfer, or  
// transmittal of  this work for any purpose in any form or by any 
// means without the written  permission of Travant Solutions is 
// strictly prohibited.
//
// Confidential, Unpublished Property of Travant Solutions, Inc.
// Use and distribution limited solely to authorized personnel.
//
// All Rights Reserved.
//
// Notice:  This file was created by Travant Solutions, Inc.  Contact
// by e-mail at info@travant.com
//
// Filename:		formFunctions2.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>

function LimitCheckCount(szObjectName, szControlName, szFunctionality, iLimit) {
    if (GetCheckedCount(szControlName) > iLimit) {
		displayErrorMessage('A maximum of ' + iLimit.toString() + ' ' + szObjectName + ' can be selected for ' + szFunctionality + '.');
		return false;
    }
    
    return confirmSelect(szObjectName, szControlName);
}


// Asks the user to confirm the selected item should
// be deleted.
function confirmDelete(szObjectName, szControlName) {
	if (IsItemSelected(szControlName)) {
		if (confirm("Are you sure you want to delete the selected " + szObjectName + "?")) {
			return true;
		}
	} else {
		displayErrorMessage('Please select a ' + szObjectName + ' to delete.');
		return false;
	}
	
	return false;
}

function confirmDelete2(szObjectName)
{
    var e = confirm("Are you sure you want to delete this " + szObjectName + "?"); 
    //alert(e);
    return e;
}

// Asks the user to confirm the selected item should
// be deleted.
function confirmEdit(szObjectName, szControlName) {
	if (IsItemSelected(szControlName)) {
		return true;
	}
	
	displayErrorMessage('Please select a ' + szObjectName + ' to edit.');
	return false;
}

// 
function confirmOverrwrite(szMsgName) {
	if (bDisplayConfirmations) {
	    var szMessage = "";
	    if (szMsgName == "NewSearch")
	    {
	        szMessage = "Are you sure you want to overrwrite the search criteria already entered and begin a new search?";
	    }
	    else
	    {
	        szMessage = "Are you sure you want to overrwrite the search criteria already entered?";
	    } 
	    
		return confirm(szMessage);
	} else {
	    // Confirmation messages not needed
		return true;
	}
}

// Asks the user to confirm the selected item should
// be [action].
function confirmSelect2(szObjectName, szControlName, szAction) {
	if (IsItemSelected(szControlName)) {
		return confirm("Are you sure you want to " + szAction + " the selected " + szObjectName + "?")
	}
	
	displayErrorMessage('Please select a ' + szObjectName + ' to ' + szAction + '.');
	return false;
}


// Asks the user to confirm the selected item should
// be ???.
function confirmSelect(szObjectName, szControlName) {
	if (IsItemSelected(szControlName)) {
		return true;
	}
	
	displayErrorMessage('Please select a ' + szObjectName + '.');
	return false;
}

// Asks the user to confirm the selected item should
// be deleted.
function confirmOneSelected(szObjectName, szControlName) {
	if (!IsItemSelected(szControlName)) {
		displayErrorMessage('Please select a ' + szObjectName + '.');
		return false;
	}
	
	if (GetCheckedCount(szControlName) > 1) {
		displayErrorMessage('Please select only one ' + szObjectName + '.');
		return false;
	}
	
	return true;
}


// Determines if an item in the specified
// list control is selected.
function IsItemSelected(szName) {
	oListControl = document.getElementsByName(szName);
	for(var i = 0; i < oListControl.length; i++) {
		if (oListControl[i].checked) {
			return true;
		}
	}
	
	return false;
}

// 
function GetSelectedValue(szName) {
	oListControl = document.getElementsByName(szName);
	for(var i = 0; i < oListControl.length; i++) {
		if (oListControl[i].checked) {
			return oListControl[i].value;
		}
	}
	return "";
}

// Moves the selected item in the 
// specified control one spot in the
// specified direction.
function Move(bUp, oControl) {

	var iSelectedIndex;
	var iNewIndexOffset;
	var iLength;
	
	var szTextA;
	var szValueA;
	var szTextB;
	var szValueB;
	
	iSelectedIndex = oControl.selectedIndex;
	if (iSelectedIndex == -1) {
		return;
	}
	
	iLength = oControl.length;

	// Check to see if we're at either end of
	// the list.
	if (bUp) {
		iNewIndexOffet = -1;
		if (iSelectedIndex == 0) {
			return;
		}
	} else {
		iNewIndexOffet = 1;
		if (iSelectedIndex == (iLength - 1)) {
			return;
		}
	}
	
	szTextA	= oControl[iSelectedIndex].text;
	szValueA= oControl[iSelectedIndex].value;

	szTextB	= oControl[iSelectedIndex + iNewIndexOffet].text;
	szValueB= oControl[iSelectedIndex + iNewIndexOffet].value;

	oControl[iSelectedIndex].text	= szTextB;
	oControl[iSelectedIndex].value	= szValueB;
	
	oControl[iSelectedIndex + iNewIndexOffet].text	= szTextA;
	oControl[iSelectedIndex + iNewIndexOffet].value	= szValueA;
	
	oControl.selectedIndex = iSelectedIndex + iNewIndexOffet;
}

// Selects all of the items in the
// specified control.
function SelectAllInList(oControl) {
	for (i=0; i<oControl.length; i++) {
	    if (!oControl[i].disabled) {
			oControl[i].selected = true;
		}
	}
}

// Determines if an option is selected
function IsOptionSelected(oControl) {
	for (i=0; i<oControl.length; i++) {
	    if (oControl[i].selected) {
			return true;
		}
	}
	return false;
}

// Determines if an option is selected
function SelectOption(oControl, szValue) {
	for (i=0; i<oControl.length; i++) {
		if (oControl[i].value == szValue) {
			oControl[i].selected = true;
		}
	}
}

// Sets the Checked property for the specified control name
// to the specified value.
function CheckAll(szPrefix, bChecked) {
	var oCheckboxes = document.body.getElementsByTagName("INPUT");
	for(var i = 0; i < oCheckboxes.length; i++) {
		if ((oCheckboxes[i].type == "checkbox") &&
		    (oCheckboxes[i].name.indexOf(szPrefix) == 0)) {
		    if (oCheckboxes[i].disabled == false) {
				oCheckboxes[i].checked = bChecked;
			}
		}
	}
}

// Sets the Checked property for all the controls within the
// specified checkboxcontrol list
function CheckAllInList(szName, bChecked, iMaxIndex)
{
    //alert("Entering Check All In List")
    for(var i = 0; i <= iMaxIndex; i++)
    {
        var szControlName = szName + i;
        var e = document.getElementById(szControlName);
        if(e != null) {
            e.checked = bChecked;	 
        }
    }
    //alert("Exiting Check All In List");
}


// Determines if any checkboxes on the current
// page with the specified name prefix are checked.
function AreAnyChecked(szPrefix) {
	var oCheckboxes = document.body.getElementsByTagName("INPUT");
	
	for(var i = 0; i < oCheckboxes.length; i++) {
		if ((oCheckboxes[i].type == "checkbox") &&
		    (oCheckboxes[i].name.indexOf(szPrefix) == 0)) {
		
			if (oCheckboxes[i].checked) {
			    return true;
			}
		}
	}
	
	return false;
}

// Determines if any checkboxes on the current
// page with the specified name prefix are checked.
function GetCheckedCount(szPrefix) {
    var iCount = 0;
	var oCheckboxes = document.body.getElementsByTagName("INPUT");
	
	for(var i = 0; i < oCheckboxes.length; i++) {
		if ((oCheckboxes[i].type == "checkbox") &&
		    (oCheckboxes[i].name.indexOf(szPrefix) == 0) &&
			(oCheckboxes[i].checked)) {
			iCount++;
		}
	}

	return iCount;
}



function disableAll(form) {
	var iLength = form.elements.length;
	for(i=0; i<iLength; i++) {
		if ((form.elements[i].type != 'submit') &&
		    (form.elements[i].type != undefined) &&
		    (form.elements[i].type != 'hidden')) {
			form.elements[i].disabled = true;
		}
	}
}

function moveSelectedOptions(from,to) {
	for (var i=0; i<from.length; i++) {
		var o = from.options[i];
		
		if (to.length == undefined) {
			index=0;
		} else {
			index=to.length;
		}
		
		if (o.selected) {
			to.options[index] = new Option( o.text, o.value, false, false);
		}
	}

	for (var i=(from.length-1); i>=0; i--) {
		var o = from.options[i];
		if (o.selected) {
			from.options[i] = null;
		}
	}
	
	from.selectedIndex = -1;
	to.selectedIndex = -1;
}

function moveAllOptions(from,to) {
	SelectAllInList(from);
	moveSelectedOptions(from,to);
}

function confirmSearch() {
	return confirm('Because no criteria has been specified, the search may take several seconds. Do you want to continue?');
}

function openWindow(szFileName, iHeight, iWidth) {
	return window.open(szFileName, "MPSWin", "height=" + iHeight +",width=" + iWidth +",location=no,resizable=no,scrollbars=no,status=no,toolbar=no");
}

function outputMoney(number) {
   	return outputDollars(Math.floor(number-0) + '') + outputCents(number - 0);
}

function outputCents(amount) {
    amount = Math.round( ( (amount) - Math.floor(amount) ) *100);
    return (amount < 10 ? '.0' + amount : '.' + amount);
}

function outputDollars(number) {
  	if (number.length <= 3) {
    	return (number == '' ? '0' : number);
  	} else {
     	var mod = number.length%3;
       	var output = (mod == 0 ? '' : (number.substring(0,mod)));
       	for (var i=0 ; i < Math.floor(number.length/3) ; i++) {
           	if ((mod ==0) && (i ==0))
       	      output+= number.substring(mod+3*i,mod+3*i+3);
       	   else
       	      output+= ',' + number.substring(mod+3*i,mod+3*i+3);
       	}
    	return (output);
   	}
}

function ToggleControlState(bDisabled, szInputControl, szLabelControl) {
	eInput = document.getElementById(szInputControl);
	eLabel = document.getElementById(szLabelControl);
	
	if (bDisabled) {
		eInput.disabled = true;
		eLabel.className = 'labelDisabled';
	} else {
		eInput.disabled = false;
		eLabel.className = 'label';			
	}
}

function padWithLeadingZeros(szValue, iMaxLength) {
	if (szValue.length > 0) {
		var iMaxLength = 10 - szValue.length;
		for(i=0; i<iMaxLength; i++) {
			szValue = "0" + szValue;			
		}
	}
	return szValue;
}
