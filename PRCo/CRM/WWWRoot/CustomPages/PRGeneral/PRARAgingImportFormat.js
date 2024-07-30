/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/
function validate()
{
    var sErrors = "";    
    var praaif_NumberHeaderLines = new Number(document.EntryForm.praaif_numberheaderlines.value);
    
    var praaif_DateSelectionCriteriaRowIndex = new Number(document.EntryForm.praaif_dateselectioncriteriarowindex.value);
    if (praaif_DateSelectionCriteriaRowIndex > praaif_NumberHeaderLines) {
        if (sErrors != "") sErrors += "\n";
        sErrors += "The Date Selection Criteria Row Index must be less than or equal to the Number of Header Lines.";
    }

    var praaif_RunDateRowIndex = new Number(document.EntryForm.praaif_rundaterowindex.value);
    if (praaif_RunDateRowIndex > praaif_NumberHeaderLines) {
        if (sErrors != "") sErrors += "\n";
        sErrors += "The Run Date Row Index must be less than or equal to the Number of Header Lines.";
    }
    
    var praaif_AsOfDateRowIndex = new Number(document.EntryForm.praaif_asofdaterowindex.value);
    if (praaif_AsOfDateRowIndex > praaif_NumberHeaderLines) {
        if (sErrors != "") sErrors += "\n";
        sErrors += "The As Of Date Row Index must be less than or equal to the Number of Header Lines.";
    }
    
    if (sErrors != "")
    {
        alert(sErrors);
        return false;
    }
    
    return true;    
}

function save()
{
    document.EntryForm.submit();
}

