<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,10";

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
    blkMain=eWare.GetBlock("PRCompanyTradeAssocNewEntry");
    blkMain.Title="Trade Association Membership";

    // Determine if this is new or edit
    var recordID = getIdValue("prcta_CompanyTradeAssociationID");

    // indicate that this is new
    if (recordID == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    sListingAction = eWare.Url("PRCompany/PRCompanyTradeAssociationListing.asp")+ "&prcta_CompanyId=" + comp_companyid;
    sSummaryAction = eWare.Url("PRCompany/PRCompanyTradeAssociation.asp")+ "&prcta_CompanyTradeAssociationID="+ recordID;

    recCompanyTradeAssoc = eWare.FindRecord("PRCompanyTradeAssociation", "prcta_CompanyTradeAssociationID=" + recordID);

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
            if (!isEmpty(comp_companyid)) 
            {
                recCompanyTradeAssoc=eWare.CreateRecord("PRCompanyTradeAssociation");
                recCompanyTradeAssoc.prcta_CompanyID = comp_companyid;
            }
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
	    }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }
	    if (isUserInGroup(sSecurityGroups))
            blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
	}
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRCompanyTradeAssociation WHERE prcta_CompanyTradeAssociationID="+ recordID;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
	    if (isUserInGroup(sSecurityGroups))
        {
            sDeleteUrl = changeKey(sURL, "em", "3");
            blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
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

    eWare.AddContent(blkContainer.Execute(recCompanyTradeAssoc));
    
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
    }
    else
        Response.Write(eWare.GetPage());

%>
<!-- #include file="CompanyFooters.asp" -->
