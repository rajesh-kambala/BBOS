<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,10";

    blkMain=eWare.GetBlock("PRCompanyAliasNewEntry");
    blkMain.Title="Company Alias";
    Entry = blkMain.GetEntry("pral_CompanyId");
    Entry.Hidden = true;

    // Determine if this is new or edit
    var sCustomAction = new String(Request.QueryString("customact"));
    var pral_CompanyAliasId = getIdValue("pral_CompanyAliasId");
    // indicate that this is new
    if (pral_CompanyAliasId == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    sListingAction = eWare.Url("PRCompany/PRCompanyAliasListing.asp")+ "&pral_CompanyId=" + comp_companyid;
    sSummaryAction = eWare.Url("PRCompany/PRCompanyAlias.asp")+ "&pral_CompanyAliasId="+ pral_CompanyAliasId;

    recCompanyAlias = eWare.FindRecord("PRCompanyAlias", "pral_CompanyAliasId=" + pral_CompanyAliasId);

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
            if (!isEmpty(comp_companyid)) 
            {
                recCompanyAlias=eWare.CreateRecord("PRCompanyAlias");
                recCompanyAlias.pral_CompanyId = comp_companyid;
                Entry.DefaultValue = comp_companyid;
            }
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
        sql = "DELETE FROM PRCompanyAlias WHERE pral_CompanyAliasId="+ pral_CompanyAliasId;
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

    blkContainer.AddBlock(blkMain);

    if (eWare.Mode == Edit)
    {
        var blkBanners = eWare.GetBlock('content');
        blkBanners.contents = "<span style=\"display:none;\"><input type=text id=\"txtDummy\"></span>";
        blkContainer.AddBlock(blkBanners);
    }

    eWare.AddContent(blkContainer.Execute(recCompanyAlias));
    
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
        Response.Write("\n        document.getElementById('pral_companyid').value='" + comp_companyid + "';");
        //Response.Write("\n        LoadComplete('');");
        Response.Write("\n    }");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }
    else
        Response.Write(eWare.GetPage());

%>
<!-- #include file="CompanyFooters.asp" -->
