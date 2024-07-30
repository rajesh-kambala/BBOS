/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/
var nPublishedBanksCount = 0;

function validate()
{
    var sSaveErrors = "";
    
    oName = document.EntryForm.prcb_name;
    if (oName.value == "")
    {
        sSaveErrors += "Name is required.\n";
    }
    
    if (sSaveErrors != "")
    {
        alert("To save this Bank, the following changes are required:\n\n" 
            + sSaveErrors + "\n\nCorrect these issues before continuing.");
    
        return false;
    }
    
	return true;
}

/* **************************************************************************************
 *  function: save
 *  Description: performs the validate and save 
 *
 ***************************************************************************************/
function save()
{
	if (validate())	
		document.EntryForm.submit();
}
