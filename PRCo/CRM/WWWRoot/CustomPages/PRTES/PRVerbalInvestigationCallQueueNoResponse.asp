<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2015

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


doPage();

//
// We are building this page manually, i.e. querying and saving the data ourselves
// due to the Master/Child relationship
//
//
function doPage() {
    var sCompanyID = getIdValue("prtesr_ResponderCompanyID");

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;


    if (eWare.Mode == View) {
    
        eWare.Mode = Edit;
    
        recVIResponder = eWare.FindRecord("vPRVICallAttemptNoResponse", "prtesr_ResponderCompanyID=" + sCompanyID);
        var blkEntry=eWare.GetBlock("PRVICallAttempt");
        blkEntry.Title="Verbal Investigation Call Attempt";
        blkEntry.ArgObj=recVIResponder;
        
        var entryCompanyID = blkEntry.GetEntry("prtesr_ResponderCompanyID");
        entryCompanyID.ReadOnly = true;

        var entryLocation = blkEntry.GetEntry("CityStateCountryShort");
        entryLocation.ReadOnly = true;
        
        blkContainer.AddBlock(blkEntry);
        
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRTES/PRVerbalInvestigationCallQueueDetail.asp") + "&prtesr_ResponderCompanyID=" + sCompanyID + "&T=Company&Capt=Trade+Activity"));
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        
        eWare.AddContent(blkContainer.Execute()); 
        Response.Write(eWare.GetPage(''));  
    }

    if (eWare.Mode == Save) {
    
        recVerbalInvestigationCA = eWare.CreateRecord("PRVerbalInvestigationCA");
        recVerbalInvestigationCA.prvict_CallDisposition = getFormValue("prvict_calldisposition");
        recVerbalInvestigationCA.prvict_Notes = getFormValue("prvict_notes");
        recVerbalInvestigationCA.SaveChanges();
        
     
        sSQL = "SELECT * FROM vPRTESVISubjectCompanies WHERE prtesr_ResponderCompanyID=" + sCompanyID;
        recSubjectCompanies = eWare.CreateQueryObj(sSQL);
        recSubjectCompanies.SelectSQL();
        
        while (!recSubjectCompanies.eof) {
        
            recVerbalInvestigationCAVI = eWare.CreateRecord("PRVerbalInvestigationCAVI");
            recVerbalInvestigationCAVI.prvictvi_VerbalInvestigationCAID = recVerbalInvestigationCA.prvict_VerbalInvestigationCAID;
            recVerbalInvestigationCAVI.prvictvi_VerbalInvestigationID = recSubjectCompanies("prtesr_VerbalInvestigationID");
            recVerbalInvestigationCAVI.prvictvi_TESRequestID = recSubjectCompanies("prtesr_TESRequestID");
            recVerbalInvestigationCAVI.SaveChanges();
            
            recSubjectCompanies.NextRecord();
        }

        // Some call dispositions result in the TES request being flagged
        // as responded to
        if ((getFormValue("prvict_calldisposition") == "WR") ||
            (getFormValue("prvict_calldisposition") == "NE")) {

            var sSQL = "UPDATE PRTESRequest SET prtesr_Received='Y', prtesr_ReceivedMethod = 'V', prtesr_ReceivedDateTime=GETDATE(), prtesr_ProcessedByUserID = NULL FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID WHERE prvi_Status = 'O' AND prtesr_ResponderCompanyID = " + sCompanyID + " AND prtesr_SentMethod = 'VI' AND prtesr_Received IS NULL";
            var recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
            recUpdatePRTESRequest.ExecSql();
            
        // Otherwise remove any subject companies that we have met the max call
        // attempts for.            
        } else {
            var sSQL = "EXEC usp_ProcessVICallAttempts " + sCompanyID; 
            var recProcessVICallAttempts = eWare.CreateQueryObj(sSQL);
            recProcessVICallAttempts.ExecSql();
        }
        
        
        Response.Redirect(eWare.Url("PRTES/PRVerbalInvestigationCallQueueDetail.asp") + "&prtesr_ResponderCompanyID=" + sCompanyID);        
    }
}
%>