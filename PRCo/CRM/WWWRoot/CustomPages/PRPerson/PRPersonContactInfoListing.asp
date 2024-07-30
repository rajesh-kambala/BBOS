<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
	doPage();


function doPage()
{
	var sContents = "";
    var sSecurityGroups = sDefaultPersonSecurity;
    var tabContext = "&T=Person&Capt=Contact+Info";

    if (eWare.Mode == Edit)
        eWare.Mode = View;

	blkContainer.CheckLocks = false;

    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        sCancelAction = eWare.Url("PRPerson/PRPersonContactInfoListing.asp")+ "&pers_PersonId=" + pers_personid;
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
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
	        {
                blkContainer.AddButton(eWare.Button("New Email Address", "new.gif", eWare.URL("PRGeneral/PREmail.asp")+ "&pers_personid=" + pers_personid + tabContext));
                blkContainer.AddButton(eWare.Button("New Phone", "new.gif", eWare.URL("PRPerson/PRPersonPhone.asp") + tabContext));
                blkContainer.AddButton(eWare.Button("New Address", "new.gif", eWare.URL("PRPerson/PRPersonAddress.asp") + tabContext));
            }
        }


	    // only show these if the page is in view mode
        var recWeb = eWare.FindRecord('vPersonEmail', 'elink_RecordId=' + pers_personid);
	    var grdWeb = eWare.GetBlock("PRPersonEmailGrid");
	    grdWeb.DisplayForm=false;
	    grdWeb.ArgObj = recWeb;
        grdWeb.PadBottom = false;
        var blkWeb = eWare.GetBlock("Content");
        if (recWeb.RecordCount == 0)
        {
            sContents = createAccpacBlockHeader("WebEmail","No Email", "100%");
            sContents +=createAccpacBlockFooter();
            blkWeb.contents = sContents;
        }
        else
            blkWeb.contents = grdWeb.Execute(recWeb);

        var recPhone = eWare.FindRecord('vPRPersonPhone', 'plink_RecordID=' + pers_personid);
	    var grdPhone = eWare.GetBlock("PersonPhoneGrid");
	    grdPhone.DeleteGridCol("phon_personid");
	    grdPhone.DisplayForm=false;
	    grdPhone.ArgObj = recPhone;
	    grdPhone.PadBottom = false;
        var blkPhone = eWare.GetBlock("Content");
        if (recPhone.RecordCount == 0)
        {
            sContents = createAccpacBlockHeader("Phones","No Phones", "100%");
            sContents +=createAccpacBlockFooter();
            blkPhone.contents = sContents;
        }
        else
            blkPhone.contents = grdPhone.Execute();

	    var recAddress = eWare.FindRecord('vPRAddress','adli_personid=' + pers_personid);
	    var grdAddress = eWare.GetBlock("PRPersonAddressGrid");
	    grdAddress.ArgObj = recAddress;
	    grdAddress.DisplayForm=false;
	    grdAddress.PadBottom = false;
	    var blkAddress = eWare.GetBlock("Content");
        if (recAddress.RecordCount == 0)
        {
            sContents = createAccpacBlockHeader("Addresses", "No Addresses", "100%");
            sContents +=createAccpacBlockFooter();
            blkAddress.contents = sContents;
        }
        else
            blkAddress.contents = grdAddress.Execute();

	    blkContainer.AddBlock(blkWeb);
	    blkContainer.AddBlock(blkPhone);
    	blkContainer.AddBlock(blkAddress);
    }
    
    Response.Write("\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n");

	eWare.AddContent(blkContainer.Execute(recPerson));
    // this doesn't necesarily have to be called in form load... just after PRGeneral.js is loaded
	eWare.AddContent("<script type=\"text/javascript\" >transformAllDocumentCRMEmailLinks();</script>\n");

    if (eWare.Mode == Save) 
    {
	    Response.Redirect(eWare.Url("PRPerson/PRPersonContactInfoListing.asp") + "&pers_PersonId=" + pers_personid + tabContext);
    }
    else if (eWare.Mode == Edit) 
    {
	    Response.Write(eWare.GetPage('Person'));
    }
    else
	    Response.Write(eWare.GetPage('Person'));

	displayUserMsg();	    	    
}
%>

<!-- #include file ="../RedirectTopContent.asp" -->
