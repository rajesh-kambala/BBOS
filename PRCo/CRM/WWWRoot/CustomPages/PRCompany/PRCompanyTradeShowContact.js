/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2018

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

function validate()
{
    var sSaveErrors = "";

    oTradeShowCode = document.getElementById("prctsc_tradeshowcode");
    if (oTradeShowCode.value == "")
        sSaveErrors += "Trade Show is required.\n";

    oYear = document.getElementById("prctsc_year");
    if (oYear.value == "")
        sSaveErrors += "Year is required.\n";

    oPerson = document.getElementById("prctsc_personid");
    if (oPerson.value == "")
        sSaveErrors += "Person is required.\n";

    if (sSaveErrors != "")
    {
        alert("To save this Trade Show Contact, the following changes are required:\n\n" 
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
    {
        //document.EntryForm.em.value = '0';
        document.EntryForm.submit();
    }
}
