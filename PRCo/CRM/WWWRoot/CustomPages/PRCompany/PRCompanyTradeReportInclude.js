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
function save()
{
    var hdn_RelatedCompanies = document.all("hdn_relatedcompanylist");
    sRelatedCompanies = "," + hdn_RelatedCompanies.value + "," ;

    inp_subjectid = document.all("prtr_subjectid");
    inp_responderid = document.all("prtr_responderid");
    sResponderId = "";
    sSubjectId = "";
    sCompanyId = "";
    if (inp_subjectid != null)
        sSubjectId = inp_subjectid.value;
    if (inp_responderid != null)
        sResponderId = inp_responderid.value    


    sCompanyId = sResponderId ;    
    sEmptyFieldMsg = "You must enter a Responder Company.";
    if (bIsTRBy == true)
    {
        sCompanyId = sSubjectId;
        sEmptyFieldMsg = "You must enter a Subject Company.";    
    }
    if (sCompanyId == "")
    {
        alert(sEmptyFieldMsg);
        if (bIsTRBy == true)
            document.all("prtr_subjectidTEXT").focus();
        else    
            document.all("prtr_responderidTEXT").focus();
        return;

    }

    // sGlobalCompanyId is defined in PRCompanyTradeReport.asp as the comp_companyid where this was launched
    if (sGlobalCompanyId == sCompanyId)
    {
        alert("A company cannot submit a trade report on itself.");
        return;
    }
    if (sRelatedCompanies.indexOf("," + sCompanyId + "," ) > -1)
    {
        alert("A company cannot submit a trade report on its headquarter, branch, sibling branch, or an affiliated company.");
        return;
    }
    
    document.EntryForm.submit();
}

function toggleDateFieldsForRange(init) {

    if (document.all._DateRangeFilter.value == "") {
        document.all.prtr_date_start.disabled = false;
        document.all.prtr_date_end.disabled = false;



        if (!init) {
            document.all.prtr_date_start.value = "";
            document.all.prtr_date_end.value = "";
        }

    } else {
        document.all.prtr_date_start.disabled = true;
        document.all.prtr_date_end.disabled = true;
    }
}