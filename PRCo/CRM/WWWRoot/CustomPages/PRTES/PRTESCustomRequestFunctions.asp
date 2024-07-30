<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009-2014

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/


/*
 * Creates the TES requests for the specified companyIDs
 */
function createTES(sSubjectCompanyID, sCompanyIds, sHowSent, sFollowupDate, sUserid) {

    return createTES2(sSubjectCompanyID, sCompanyIds, sHowSent, sFollowupDate, sUserid, "")

}

function createTES2(sSubjectCompanyID, sCompanyIds, sHowSent, sFollowupDate, sUserid, sSecondRequest) {
    return createTES3(sSubjectCompanyID, sCompanyIds, sHowSent, sFollowupDate, sUserid, "", "Pending")
}

function createTES3(sSubjectCompanyID, sCompanyIds, sHowSent, sFollowupDate, sUserid, sSecondRequest, interactionStatus) {

    // If we don't have a followup date, let's set one
    // for 15 days out.
    if (sFollowupDate == null) {
        sFollowupDate = getDateAsString(new Date().setDate(new Date().getDate() + 15));
    }

    
    dtDate = new Date();
    sDate = (dtDate.getMonth() + 1) + "/" + dtDate.getDate() + "/" + dtDate.getYear();
    sDate = getDBDate(sDate);


    // Create a follow-up task
    recCommunication = eWare.CreateRecord("Communication");
    recCommunication.comm_DateTime = getDBDate(sFollowupDate);
    recCommunication.comm_ToDateTime = sDate;
    recCommunication.comm_Note = 'Custom investigation started.  Please review trade information.';
    recCommunication.comm_Subject = 'Custom investigation started.  Please review trade information.';
    recCommunication.comm_Type = 'Task';
    recCommunication.comm_Action = 'ToDo';
    recCommunication.comm_Status = interactionStatus;
    recCommunication.comm_Priority = 'Normal';
    recCommunication.comm_PRCategory = 'R';
    recCommunication.comm_PRSubcategory = 'CI';
    recCommunication.SaveChanges();

    recCommLink = eWare.CreateRecord("Comm_Link");
    recCommLink.cmli_Comm_CommunicationId = recCommunication("comm_CommunicationID");
    recCommLink.cmli_Comm_CompanyId = sSubjectCompanyID;

    // Assign to the rating analyist
    sSQL = "SELECT ListingSpecalistID = dbo.ufn_GetPRCoSpecialistUserId(" + sSubjectCompanyID + ", 0)"
    recListingSpecalist = eWare.CreateQueryObj(sSQL);
    recListingSpecalist.SelectSQL();
    if (!recListingSpecalist.eof) {
        recCommLink.cmli_Comm_UserId = recListingSpecalist("ListingSpecalistID");        
    }
    recCommLink.SaveChanges();

    if (sSecondRequest == "Y") {
        sSecondRequest = "'Y'";
    } else {
        sSecondRequest = "null";
    }

    var iCount = 0;
    var szProcessedIDs = "";
    arrCompanyIds = new String(sCompanyIds).split(",");
    for (ndx=0; ndx<arrCompanyIds.length; ndx++)
    {

        sID = new String(arrCompanyIds[ndx]).replace(/^\s*/, "").replace(/\s*$/, "");;
        var szKey = "," + sID + ",";

        // Skip this ID if it has already been processed.
        if (szProcessedIDs.indexOf(szKey) == -1) {
        
            var sSQL = "EXECUTE usp_CreateTES " + 
                            "@ResponderCompanyID = " + sID + ", " +
                            "@SubjectCompanyID = " + sSubjectCompanyID + ", " +
                            "@UserId = " + sUserid + ", " +
                            "@Source = 'MI', " +
                            "@CreatedDate = '" + sDate + "', " +
                            "@IsSecondRequest = " + sSecondRequest;

            if (sHowSent != null) {
                sSQL += ", @SentMethod = '" + sHowSent + "'";
            }                            
                            
            recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.ExecSql()
            
            iCount++;
            szProcessedIDs += szKey;
        }                
    }
    
    return "Created TES requests for " + iCount + " companies.";
}
%>