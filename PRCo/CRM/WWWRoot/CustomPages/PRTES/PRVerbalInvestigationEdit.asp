<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyHeaders.asp" -->
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


function doPage() {
    
	var sCancelAction = Session("ReturnURL");
	if (isEmpty(sCancelAction)) {
	    sCancelAction = eWare.Url(Request.QueryString("F"));
	}
    
    var sVerbalInvestigationID = getIdValue("prvi_VerbalInvestigationID");
    if (eWare.Mode < Edit)
        eWare.Mode = Edit;
    
    blkEntry=eWare.GetBlock("PRVerbalInvestigationEntry");
    blkEntry.Title="Verbal Investigation";

    // indicate that this is new
    if (sVerbalInvestigationID == -1 )
    {
	    recVerbalInvestigation = eWare.CreateRecord("PRVerbalInvestigation");
		recVerbalInvestigation.prvi_CompanyID = comp_companyid;
		
        entryCompanyID = blkEntry.GetEntry("prvi_CompanyID");
        entryCompanyID.DefaultValue = comp_companyid;		
        entryCompanyID.ReadOnly = true;
        
        blkEntry.GetEntry("prvi_TargetNumberOfIntegrityReports").DefaultValue = 0;
        blkEntry.GetEntry("prvi_TargetNumberOfPayReports").DefaultValue = 0;
        blkEntry.GetEntry("prvi_MaxNumberOfAttempts").DefaultValue = 0;
    }
    else
    {
        recVerbalInvestigation = eWare.FindRecord("PRVerbalInvestigation", "prvi_VerbalInvestigationID=" + sVerbalInvestigationID);
    }   
    
    
    if (eWare.Mode == Save)
    {
        blkEntry.Execute(recVerbalInvestigation);

        if (Session("VICompanyIDs") != null) {            

            var iCount = 0;
            var szProcessedIDs = "";
            arrCompanyIds = new String(Session("VICompanyIDs")).split(",");
            for (ndx=0; ndx<arrCompanyIds.length; ndx++)
            {
                sID = new String(arrCompanyIds[ndx]).replace(/^\s*/, "").replace(/\s*$/, "");
                var szKey = "," + sID + ",";

                // Skip this ID if it has already been processed.
                if (szProcessedIDs.indexOf(szKey) == -1) {                
                    var sSQL = "EXECUTE usp_CreateTES " + 
                                "@ResponderCompanyID = " + sID + ", " +
                                "@SubjectCompanyID = " + comp_companyid + ", " +
                                "@VerbalInvestigationID = " + recVerbalInvestigation.prvi_VerbalInvestigationID + ", " +
                                "@UserId = " + user_userid + ", " +
                                "@Source = 'VI', " +
                                "@SentMethod = 'VI'";
                                
                    recQuery = eWare.CreateQueryObj(sSQL);
                    recQuery.ExecSql()
                    
                    szProcessedIDs += szKey;
                }
            }                
            
            Session("VICompanyIDs") = null;
        }
        
        Response.Write("<p>Saved");
        
        if (sVerbalInvestigationID == -1 )
        {
            var iAssignedToUserID = 0;
            sSQL = "SELECT dbo.ufn_GetPRCoSpecialistUserID(" + comp_companyid + ", 0) As AssignedToUserID;";
            recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.SelectSQL();   
            if (!recQuery.eof) {
                iAssignedToUserID = recQuery("AssignedToUserID");
            }
        
            sSQL = "EXECUTE usp_CreateTask " +
                    "@CreatorUserId=" + user_userid + ", " +  
                    "@AssignedToUserId=" + iAssignedToUserID + ", " +  
                    "@TaskNotes= 'Created a new verbal investigation.', " +
                    "@RelatedCompanyId=" + comp_companyid + ", " +  
                    "@StartDateTime='" + Request("prvi_targetcompletiondate")  + "', " +
                    "@Status = 'Pending', " +
                    "@PRCategory = 'R', " +
                    "@PRSubcategory = 'VI'";
            recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.ExecSql()
        
            Response.Redirect(eWare.Url("PRTES/PRVerbalInvestigationList.asp")+ "&comp_companyid=" + comp_companyid + "&T=Company&Capt=Trade+Activity");
        } else {            
            Response.Redirect(eWare.Url("PRTES/PRVerbalInvestigationView.asp")+ "&prvi_VerbalInvestigationID=" + recVerbalInvestigation.prvi_VerbalInvestigationID + "&T=Company&Capt=Trade+Activity");
        }
        return;
    }    
    
    if (eWare.Mode == Edit)
    {
        
        blkEntry.ArgObj = recVerbalInvestigation;
        blkContainer.AddBlock(blkEntry);


        if (Session("VICompanyIDs") != null) {
            var recCompanies = eWare.FindRecord("vPRCompanyLocation", "comp_CompanyID IN (" + Session("VICompanyIDs") + ")");
            var grdCompanyLocation = eWare.GetBlock("PRCompanyLocationGrid");
            grdCompanyLocation.ArgObj = recCompanies;
            grdCompanyLocation.PadBottom = false;
            blkContainer.AddBlock(grdCompanyLocation);
        }

        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        eWare.AddContent(blkContainer.Execute()); 

        Response.Write(eWare.GetPage('New'));  
        return;   
    }        
}

%>
        <script type="text/javascript" src="../PRCoGeneral.js"></script>
        <script type="text/javascript" src="PRVerbalInvestigationEdit.asp.js"></script>
        <script type="text/javascript">
            function initBBSI() {
                RemoveDropdownItemByName("prvi_status", "--None--");
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>
                
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->