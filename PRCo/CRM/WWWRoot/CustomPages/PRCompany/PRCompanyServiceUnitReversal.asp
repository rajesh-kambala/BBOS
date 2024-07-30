<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%
    var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
    var user_userid = eWare.getContextInfo("User", "User_UserId");

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
    prsuu_ServiceUnitUsageId = getIdValue("prsuu_ServiceUnitUsageId");
    
    if (eWare.Mode == Save)
    {
        sListingAction = eWare.Url("PRCompany/PRCompanyServiceUnitUsageListing.asp") + "&T=Company&Capt=Services";
        // collect the information and pass it on to the DB usp_ that will persist it.
        var sReversalReasonCode = getFormValue("prsuu_reversalreasoncode");
        var sSQL = "EXECUTE usp_ReverseServiceUnitUsage " + 
                "@OriginalServiceUnitUsageId = " + prsuu_ServiceUnitUsageId + ", " +
                "@ReversalReason = '" + sReversalReasonCode + "', " +
                "@SourceCode = 'C', " +
                "@CRMUserID = " + user_userid + " " 
                
        try
        {
            recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.ExecSql();
            Response.Redirect(sListingAction);
        }
        catch (exception)
        {
            Session.Contents("prco_exception") = exception;
            Session.Contents("prco_exception_continueurl") = sListingAction;
            Response.Redirect(eWare.Url("PRCoErrorPage.asp"));
        
        }
    } 
    if (eWare.Mode <= Edit)
    {
        // this screen will always show in edit mode
        if (eWare.Mode<Edit) eWare.Mode=Edit;

        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyServiceUnitReversal.js\"></script>");

        blkMain = eWare.GetBlock("PRServiceUnitUsageReversal");
        blkMain.Title = "Business Report Usage Reversal";

        Entry = blkMain.GetEntry("prsuu_ReversalReasonCode");
        //Entry.LookupFamily = 'prsuu_ReversalReasonCode';
        Entry.DefaultValue = 'O';
        Entry.AllowBlank = false;

        blkContainer.AddBlock(blkMain);
        blkContainer.CheckLocks = false;

	    var sCancel = eWare.URL("PRCompany/PRCompanyServiceUnitUsage.asp")+ "&prsuu_ServiceUnitUsageId=" + prsuu_ServiceUnitUsageId + "&T=Company&Capt=Services";
	    blkContainer.AddButton(eWare.Button("Save", "save.gif",  "#\" onClick=\"if (validate()) save();\""));
	    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancel));
        
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage());
    }
%>
<!-- #include file ="CompanyFooters.asp" -->

