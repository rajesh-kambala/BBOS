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
// Filename:		formFunctions.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>

// Declare our Dirty flag
var bDirty=false;

// This event will fire when any
// control on the form is changed.
function onDataChange() {
	bDirty=true;
}

// This function fires prior to the unloading
// of the page.  It checks the Dirty flag to
// determine if we should warn the user.
function onPageUnload() {
	if (bDirty == true) {
		event.returnValue = "Changes have not been saved.  If you continue, the changes will be lost.";
	}
}


// Iterate through all of the elements on
// the form.  Set the element's onChange
// event handler to the global handler to
// set the dirty flag.
function onFormLoad() {
	
	preOnFormLoad();
	
	var oForm = document.forms[0];
	for (i=0; i < oForm.elements.length; i++) {
		var oElement = oForm.elements[i];

		//if (oElement.tsiSkipOnChange) {
		if (oElement.getAttribute('tsiSkipOnChange')) {
			//
		} else {
			oForm.elements[i].onchange = onDataChange;
		}
	}
	
	postOnFormLoad();	
}

// Invoked from the onFormLoad method
function preOnFormLoad() {
}

// Invoked from the onFormLoad method
function postOnFormLoad() {
	setDefaultFocus();
}

// Invoked from the postOnFormLoad method
function setDefaultFocus() {
}

// Set the appropriate event handlers.
window.onbeforeunload = onPageUnload;
window.onload = onFormLoad;

// Determine if the <ENTER> button should
// submit the form.  Defaults to true.
// Can be overridden on the client.
var bEnterSubmits = true;

// Determines if the <ENTER> key was pressed
// and then determines if the form should be
// submitted.  By default only looks for a
// btnSave button, then btnSearch.
function SubmitOnEnter() { 
	if (!bEnterSubmits) {
		return;
	}
	
    if (event.keyCode == 13) {
		var e = document.getElementById('btnSave');
		if (e == undefined) {
			e = document.getElementById('btnSearch');
		}
		
		if (e != undefined) {
			e.click();
			event.keyCode=0;
            return false;
        }
    }
}

// Set our event handler.
document.onkeydown = SubmitOnEnter;