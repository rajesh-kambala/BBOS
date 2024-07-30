<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,10";

    blkEntry=eWare.GetBlock("PRCompanyLicenseNewEntry");
    blkEntry.Title="License";
    blkEntry.Width = "80%";
    Entry = blkEntry.GetEntry("prli_CompanyId");
    Entry.Hidden = true;


    var prli_CompanyLicenseId = getIdValue("prli_CompanyLicenseId");
    // indicate that this is new
    if (prli_CompanyLicenseId == "-1" )
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    
    sListingAction = eWare.Url("PRCompany/PRCompanyLicenseListing.asp")+ "&prli_CompanyId=" + comp_companyid;
    sSummaryAction = eWare.Url("PRCompany/PRCompanyLicense.asp")+ "&prli_CompanyLicenseId="+ prli_CompanyLicenseId;

    recCompanyLicense = eWare.FindRecord("PRCompanyLicense", "prli_CompanyLicenseId="+ prli_CompanyLicenseId);

    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
	        recCompanyLicense = eWare.CreateRecord("PRCompanyLicense");
            recCompanyLicense.prli_CompanyId = comp_companyid;
            Entry.DefaultValue = comp_companyid;

            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        }
        
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
    	    if (isUserInGroup(sSecurityGroups))
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }

    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRCompanyLicense WHERE prli_CompanyLicenseId="+ prli_CompanyLicenseId;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else 
    {
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

    }
    blkContainer.CheckLocks = false;

    blkContainer.AddBlock(blkEntry);
    eWare.AddContent(blkContainer.Execute(recCompanyLicense));

    if (eWare.Mode == Save) 
    {
	    if (bNew)
	        Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction);
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));
        
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n        document.getElementById('prli_companyid').value='" + comp_companyid + "';");
        //Response.Write("\n        RemoveDropdownItemByValue('prli_type', 'PACA');");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");        
    }
    else
        Response.Write(eWare.GetPage());

%>
<!-- #include file="CompanyFooters.asp" -->
