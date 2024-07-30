<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,10";

    if (eWare.Mode == Edit )
        eWare.Mode = View;

    var blkNotes = eWare.GetBlock("PRCompanyNotes");
    blkNotes.Title="Contact Info Notes";
    entry = blkNotes.GetEntry("prcomnot_CompanyNoteNote");
    entry.Caption = "Contact Info Notes:";
    entry.ReadOnly = true;

    var recCompanyNote = eWare.FindRecord("PRCompanyNote", "prcomnot_CompanyId=" + comp_companyid + " AND prcomnot_CompanyNoteType='PRCCI'");
    blkNotes.ArgObj = recCompanyNote;
    blkContainer.AddBlock(blkNotes);

	blkContainer.CheckLocks = false;

    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        sCancelAction = eWare.Url("PRCompany/PRCompanyContactInfoListing.asp")+ "&comp_CompanyId=" + comp_companyid;
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
            {
                sSaveAction = removeKey(sURL, "em");
    	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.action='" + sSaveAction + "';document.EntryForm.submit();"));
            }
        }
    }
    else 
    {
        tabContext = "&T=Company&Capt=Contact+Info";

        blkContainer.AddButton(eWare.Button("Attention Lines", "AddRecToGroup.gif" , eWare.Url("PRCompany/PRCompanyAttentionLine.asp") + tabContext));

        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
            {
                if (recCompany.comp_PRLocalSource !=  "Y") {

                    // Replicate is explicitly being moved inside the TRX management per QA request
                    sReplicateAction = eWare.Url("PRCompany/PRCompanyReplicate.asp")+ "&RepType=3&RepId=" + comp_companyid + "&comp_CompanyId=" + comp_companyid + tabContext;
                    blkContainer.AddButton(eWare.Button("Replicate Emails & Websites", "includeall.gif", "javascript:location.href='"+sReplicateAction+"';"));
                }

	            blkContainer.AddButton(eWare.Button("New&nbsp;Web/Email<br/>Address", "new.gif", removeKey(eWare.URL("PRGeneral/PREmail.asp"), "Key2" ) + tabContext));
	            blkContainer.AddButton(eWare.Button("New Phone", "new.gif", eWare.URL("PRCompany/PRCompanyPhone.asp") + tabContext));
	            blkContainer.AddButton(eWare.Button("New Address", "new.gif", eWare.URL("PRCompany/PRCompanyAddress.asp") + tabContext));

			    if (recCompany.comp_PRIndustryType !=  "L") {
				    var btnLinkTerminalMarket = eWare.Button("New Terminal Market","New.gif", eWare.URL("PRCompany/PRCompanyTerminalMarket.asp"));
				    blkContainer.AddButton(btnLinkTerminalMarket);
			    }
    	    }
        }

        if (recCompany.comp_PRLocalSource !=  "Y") {
            blkContainer.AddButton(eWare.Button("Edit Social Media", "edit.gif", eWare.URL("PRCompany/PRCompanyIFrame.asp") + tabContext + "&FrameURL=" + Server.URLEncode("PRCompanySocialMediaEdit.aspx?CompanyID=" + Request.QueryString("Key1"))));
        }

        blkContainer.AddButton(eWare.Button("Change Notes", "edit.gif", eWare.URL("PRCompany/PRCompanyNotes.asp") + "&notetype=PRCCI"));

	    // only show these if the page is in view mode
    	var recWeb = eWare.FindRecord('vCompanyEmail','elink_RecordId=' + comp_companyid);
	    grdWeb = eWare.GetBlock("PREmailGrid");
	    grdWeb.DisplayForm=false;
	    grdWeb.ArgObj = recWeb;
        grdWeb.PadBottom = false;
        grdWeb.DeleteGridCol("elink_RecordId");   // Don't show companys.
        blkWeb = eWare.GetBlock("Content");
        if (recWeb.RecordCount == 0 )
        {
            var sContents = createAccpacBlockHeader("WebEmail","No Email/Web Addresses", "100%");
            sContents +=createAccpacBlockFooter();
            blkWeb.contents = sContents;
        }
        else
            blkWeb.contents = grdWeb.Execute();

    	var recPhone = eWare.FindRecord('vPRCompanyPhone','plink_RecordID=' + comp_companyid);
	    grdPhone = eWare.GetBlock("CompanyPhoneGrid");
	    grdPhone.DeleteGridCol("plink_RecordID");
	    grdPhone.DisplayForm=false;
	    grdPhone.ArgObj = recPhone;
        grdPhone.PadBottom = false;
        blkPhone = eWare.GetBlock("Content");
        if (recPhone.RecordCount == 0 )
        {
            var sContents = createAccpacBlockHeader("Phones","No Phones", "100%");
            sContents +=createAccpacBlockFooter();
            blkPhone.contents = sContents;
        }
        else
            blkPhone.contents = grdPhone.Execute();


	    var recAddress = eWare.FindRecord('vPRAddress','adli_CompanyId=' + comp_companyid);
	    // recAddress.OrderBy = "CRM.dbo.ufn_GetAddressListSeq(adli_Type)";

	    grdAddress = eWare.GetBlock("PRCompanyAddressGrid");

	    grdAddress.ArgObj = recAddress;
	    grdAddress.DisplayForm=false;
        grdAddress.PadBottom = false;
	    blkAddress = eWare.GetBlock("Content");
        if (recAddress.RecordCount == 0 )
        {
            var sContents = createAccpacBlockHeader("Addresses","No Addresses", "100%");
            sContents +=createAccpacBlockFooter();
            blkAddress.contents = sContents;
        }
        else
            blkAddress.contents = grdAddress.Execute();


	    var recSocialMedia = eWare.FindRecord("PRSocialMedia","prsm_CompanyID=" + comp_companyid);
	    blkSocialMedia = eWare.GetBlock("Content");
        if (recSocialMedia.RecordCount == 0 )
        {
            var sContents = createAccpacBlockHeader("Social Media","No Social Media URLs", "100%");
            sContents +=createAccpacBlockFooter();
            blkSocialMedia.contents = sContents;
        }
        else {
            var grdSocialMedia = eWare.GetBlock("PRSocialMediaGrid");
	        grdSocialMedia.ArgObj = recSocialMedia;
	        grdSocialMedia.DeleteGridCol("prsm_companyid");
	        grdSocialMedia.DisplayForm=false;
            grdSocialMedia.PadBottom = false;
            blkSocialMedia.contents = grdSocialMedia.Execute();
        }

	    var recTerminalMarket = eWare.FindRecord("PRCompanyTerminalMarket","prct_CompanyId=" + comp_companyid);
	    var blkTerminalMarket = eWare.GetBlock("Content");
        if (recTerminalMarket.RecordCount == 0 )
        {
            var sContents = createAccpacBlockHeader("Terminal Market","No Terminal Markets", "100%");
            sContents +=createAccpacBlockFooter();
            blkTerminalMarket.contents = sContents;
        }
        else {
            var grdTerminalMarket = eWare.GetBlock("PRCompanyTerminalMarketGrid");
	        grdTerminalMarket.ArgObj = recTerminalMarket;
	        grdTerminalMarket.DisplayForm=false;
            grdTerminalMarket.PadBottom = false;
            blkTerminalMarket.contents = grdTerminalMarket.Execute();
        }

	    blkContainer.AddBlock(blkWeb);
	    blkContainer.AddBlock(blkPhone);
    	blkContainer.AddBlock(blkAddress);
        blkContainer.AddBlock(blkSocialMedia);
        blkContainer.AddBlock(blkTerminalMarket);
    }
    
    eWare.AddContent(blkContainer.Execute());

    // this doesn't necesarily have to be called in form load... just after PRGeneral.js is loaded
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n");
    eWare.AddContent("\n<script type=\"text/javascript\" >transformAllDocumentCRMEmailLinks();</script>");

    if (eWare.Mode == Save) 
    {
	    Response.Redirect(eWare.Url("PRCompany/PRCompanyContactInfoListing.asp"));
    }
    else if (eWare.Mode == Edit) 
    {
	    Response.Write(eWare.GetPage('Company'));
    }
    else
	    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->
