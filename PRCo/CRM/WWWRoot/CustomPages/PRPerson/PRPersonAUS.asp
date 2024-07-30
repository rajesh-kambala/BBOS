<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->

<%
	doPage();

function doPage()
{
	// the following is a custom copy of "PersonSummaryPageInclude.asp" 
	var sAbbrEntityName = "WebUserListDetail";
	var sEntityPrefix = "prwuld";
	var sEntityName = "PR" + sAbbrEntityName;							// PRWebUserListDetail
    var sListingPage = "PRPerson/PRPersonAUSListing.asp";
    var sSummaryPage = "PRPerson/PRPersonAUS.asp";
    var sEntityIdName = sEntityPrefix + "_" + sAbbrEntityName + "Id";	// prwuld_WebUserListDetailId
    var sNewEntryBlockName = "PR" + sAbbrEntityName + "NewEntry";		// PRWebUserListDetailNewEntry
    var sEntityWebUserList = "prwuld_WebUserListID";
    var sNewEntryBlockTitle = "Alerts Company Entry";

	var sSQL = "";
	var sCompanySelectDisplay;
    var sSecurityGroups = sDefaultPersonSecurity;
    
    var WebUserListDetailId = getIdValue(sEntityIdName);
    var MonitoredCompanyId = getIdValue("prwuld_associatedid");
    var WebUserListId = getIdValue("prwucl_webuserlistid");
    
    // eWare
    var Entry;
    var MonitoredCompanyEntry;
    var rec;


    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    var sDisplayError = null;
    
	// a little error check (should already have been filtered from the previous screen)
	// Multiple active Person_Link records
	sSQL = "SELECT COUNT(PeLi_CompanyID) As \"CompanyCount\" FROM Person_Link WITH (NOLOCK) WHERE PeLi_PersonID=" + pers_personid + " AND PeLi_PRStatus = 1 GROUP BY PeLi_PersonID, PeLi_CompanyID HAVING COUNT(PeLi_CompanyID) > 1";
	var recCheck = eWare.CreateQueryObj(sSQL);
	recCheck.SelectSQL();
	if (recCheck.RecordCount > 0) {
		lErrorMsg.push(getErrorHeader("User has multiple active Company Links (for the same company), but can only have one."));
		var blkErrorMsg = eWare.GetBlock("Content");
		blkErrorMsg.Contents = getErrorHeader("User has multiple active Company Links (for the same company), but can only have one.");
		blkContainer.AddBlock(blkErrorMsg);
		eWare.Mode = View;
        eWare.AddContent(blkContainer.Execute(rec)); 
        Response.Write(eWare.GetPage('Person'));
        return;
	}
	recCheck = null;
		
    blkEntry=eWare.GetBlock(sNewEntryBlockName);
    blkEntry.Title=sNewEntryBlockTitle;
    // set the screen values
    
    // We don't really have a default value to put here. This will be determined by the choice in the dropdown.
    Entry = blkEntry.GetEntry(sEntityWebUserList);
    Entry.ReadOnly = true;	// Readonly and Hidden in combination will render the tag, which is used later in the code
    Entry.Hidden = true;

	// Add a search select field for AssociatedID (based on the company record)
    MonitoredCompanyEntry = eWare.GetBlock("Entry");
    MonitoredCompanyEntry.EntryType = 56;
    MonitoredCompanyEntry.LookUpFamily = "Company";
    MonitoredCompanyEntry.DefaultType = 0;
    MonitoredCompanyEntry.Width = 50;
    MonitoredCompanyEntry.FieldName = "prwuld_AssociatedID";
    MonitoredCompanyEntry.Caption = "Monitored Company";
    MonitoredCompanyEntry.CaptionPos = MonitoredCompanyEntry.CapTop;
    MonitoredCompanyEntry.NewLine = false;
    MonitoredCompanyEntry.Required = true;
    blkEntry.AddBlock(MonitoredCompanyEntry);

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkEntry);

    // indicate that this is new
    if (WebUserListDetailId == -1)
    {
	    rec = eWare.CreateRecord(sEntityName);
		rec.item(sEntityWebUserList) = WebUserListId;

        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    else
    {
        rec = eWare.FindRecord(sEntityName, sEntityIdName + "=" + WebUserListDetailId);
    }
    sListingAction = eWare.Url(sListingPage) + "&T=Person&Capt=AUS+List";
    sSummaryAction = changeKey(eWare.Url(sSummaryPage), sEntityIdName, WebUserListDetailId) + "&T=Person&Capt=AUS+List";

    bValidationError = false;
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Save)
    {
        if (blkContainer.Validate())
        {
            // if we are saving, make sure this company is not already listed for this person
            recDuplicate = eWare.FindRecord("PRWebUserListDetail", 
                                            "prwuld_AssociatedID=" + MonitoredCompanyId + " AND prwuld_WebUserListID=" + WebUserListId + " AND prwuld_AssociatedType = 'C'");
            if (!recDuplicate.eof)
            {    
                bValidationError = true;
                sError = "<table style=\"display:none;\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" class=\"ErrorContent\"><tr id=\"tr_Error\">"+
                         "<td width=\"100%\" class=\"ErrorContent\">Error - The selected company is already being monitored by this company/person.</TD></TR></TABLE>";
                Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
                Response.Write(sError);
                sDisplayError = "InsertRow(\"_Captprwuld_AssociatedID\", \"tr_Error\");";
                Entry = blkEntry.GetEntry("prwuld_AssociatedID");
                MonitoredCompanyEntry.DefaultValue = MonitoredCompanyId;
            }
            else
            {
                // instead of calling .Execute(rec) we are going to call the stored procedure
                // which is also responsible for creating the company relationship records
                //blkContainer.Execute(rec); 
                var sSP = "EXEC usp_SaveAUS ";
                sSP += WebUserListId + ", " + (WebUserListDetailId != -1 ? WebUserListDetailId : "null") + ", " + MonitoredCompanyId + ", " + user_userid;
                qrySave = eWare.CreateQueryObj(sSP,"");
                qrySave.ExecSQL();
                    
	            if (WebUserListDetailId == -1)
	                Response.Redirect(sListingAction);
	            else
	                Response.Redirect(sSummaryAction);
	        }
        }
        else
        {
            bValidationError = true;
        }
    }
    
    if (eWare.Mode == Edit || bValidationError)
    {
        // draw the select box based upon the companies this person is linked to; actual id value is the WebUserList
        sCompanySelectDisplay = "<div style=\"{display:none}\"> <div id=\"div_prwucl_webuserlistid\" >" + 
            "<span id=\"_Captprwucl_webuserlistid\" class=\"VIEWBOXCAPTION\">&nbsp;Company:</span><br/>" +
            "<span>&nbsp;<select class=\"EDIT\" size=\"1\" NAME=\"prwucl_webuserlistid\">" ;

        // get the list of companies (actually, Web User Lists)
		sSQL = 
			"SELECT prwucl_WebUserListID, comp_Name " +
			"  FROM Person_Link WITH (NOLOCK) " +
			"       INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = PeLi_CompanyID " +
			"       LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkID " +
			"       LEFT OUTER JOIN PRWebUserList WITH (NOLOCK) ON prwucl_WebUserID = prwu_WebUserID " +
			" WHERE PeLi_PersonID = " + pers_personid +
			"   AND prwucl_TypeCode = 'AUS' ";

        var recCompanies = eWare.CreateQueryObj(sSQL);
        recCompanies.SelectSQL();
        while (!recCompanies.eof) 
        {
            sSelected = "";
            if (recCompanies("prwucl_WebUserListID") == rec("prwuld_WebUserListID"))
                sSelected = " SELECTED ";
            sCompanySelectDisplay += "<option " + sSelected + "value=\""+ recCompanies("prwucl_WebUserListID") + "\" >"+ recCompanies("comp_name") + "</option> ";
            recCompanies.NextRecord();
        }
        sCompanySelectDisplay += "</select></span><span>&nbsp;&nbsp;</span></div></div>";
        
        Response.Write(sCompanySelectDisplay);
        sCompanySelectDraw = " AppendCell(\"_Captprwuld_AssociatedID\", \"div_prwucl_webuserlistid\", true);";
        
        if (WebUserListDetailId == -1 )
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }
        eWare.Mode = Edit;        
        eWare.AddContent(blkContainer.Execute(rec)); 
        Response.Write(eWare.GetPage('Person'));

    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM " + sEntityName + " WHERE " + sEntityIdName + "="+ WebUserListDetailId;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else // view mode
    {
		// Get the monitoring company name
        var sMonitoringCompany = "";
		sSQL = "SELECT comp_Name FROM Company WITH (NOLOCK) INNER JOIN Person_Link ON PeLi_CompanyID = comp_CompanyID INNER JOIN PRWebUser WITH (NOLOCK) ON prwu_PersonLinkID = PeLi_PersonLinkID INNER JOIN PRWebUserList ON prwucl_WebUserID = prwu_WebUserID INNER JOIN PRWebUserListDetail ON prwuld_WebUserListID = prwucl_WebUserListID WHERE prwuld_WebUserListDetailID = " + WebUserListDetailId;
		recCompany = eWare.CreateQueryObj(sSQL);
		recCompany.SelectSQL();
		if (recCompany.RecordCount > 0) {
			sMonitoringCompany = recCompany("comp_Name");
		}

        sCompanySelectDisplay = "<div style=\"display:none\"> <div id=\"div_monitoring_company\" >" + 
            "<span ID=\"_Captmonitoring_company\" class=\"VIEWBOXCAPTION\">&nbsp;Monitoring Company:</span><br/>" +
            "<span class=\"VIEWBOX\">&nbsp;" + sMonitoringCompany + "</span></div></div>";
        Response.Write(sCompanySelectDisplay);
        sCompanySelectDraw = " AppendCell(\"_Dataprwuld_AssociatedID\", \"div_monitoring_company\", true);";

        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
            {
                sDeleteUrl = changeKey(sURL, "em", "3");
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
            }
    	}
        eWare.AddContent(blkContainer.Execute(rec)); 
        Response.Write(eWare.GetPage('Person'));
    }

    Response.Write("\n<script type=\"text/javascript\">");
    Response.Write("\n    function initBBSI() ");
    Response.Write("\n    {");

    if (sDisplayError != null) Response.Write(sDisplayError); 
    if (eWare.Mode == Edit || eWare.Mode == View) Response.Write(sCompanySelectDraw); 

    Response.Write("\n    }");
    Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
    Response.Write("\n</script>");
}
%>
<!-- #include file ="../RedirectTopContent.asp" -->
