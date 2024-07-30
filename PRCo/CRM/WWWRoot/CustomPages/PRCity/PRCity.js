///***********************************************************************
// ***********************************************************************
//  Copyright Produce Report Company 2006-2013

//  The use, disclosure, reproduction, modification, transfer, or  
//  transmittal of  this work for any purpose in any form or by any 
//  means without the written permission of Produce Report Company is 
//  strictly prohibited.
// 
//  Confidential, Unpublished Property of Produce Report Company.
//  Use and distribution limited solely to authorized personnel.
// 
//  All Rights Reserved.
// 
//  Notice:  This file was created by Travant Solutions, Inc.  Contact
//  by e-mail at info@travant.com.
// 
// 
//***********************************************************************
//***********************************************************************/
function validate()
{
	var focusControl= null;
	var sAlertMsg = "";
	
	var txtCity = document.EntryForm.prci_city;
	var txtState = document.EntryForm.prci_stateidTEXT;
	
	// From previous phone file.
	if (txtCity.value == "")
	{
		sAlertMsg += " - City is a required field.\n";
		focusControl = txtCity;
	} 
	
	if (txtState.value == "")
	{
	    sAlertMsg += " - State is a required field.\n";
		if (focusControl != null)
			focusControl = txtState;
	} 
	
	if (sAlertMsg != "")
	{
		alert ("The following changes are required to save the City record:\n\n" + sAlertMsg);
		if (focusControl != null)
			focusControl.focus();
		return false;
	}
	
	return true;
}

function save()
{
	if (validate() == true)
	{
		document.EntryForm.submit();
	}
}
