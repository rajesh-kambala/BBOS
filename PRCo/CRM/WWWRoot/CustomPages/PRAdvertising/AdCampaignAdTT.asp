<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="AdCampaignAd.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2019

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Reporter Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.

***********************************************************************
***********************************************************************/

doPage();

function doPage()
{
    bDebug=false;

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var CompanyID = new String(Request.QueryString("Key1"));

    // set up the main record
    var AdCampaignID = getIdValue("pradc_AdCampaignID");
    var AdCampaignHeaderID = getIdValue("pradch_AdCampaignHeaderID");
    var SourceID = getIdValue("SourceID");

    Response.Write("<script type='text/javascript' src='AdCampaignAd.js'></script>")

    DEBUG("CompanyID=" + CompanyID);
    DEBUG("SourceID=" + SourceID);

    var bNew = false;

    if(AdCampaignID > -1)
    {
        recPRAdCampaign = eWare.FindRecord("PRAdCampaign", "pradc_AdCampaignID=" + AdCampaignID);
        if(AdCampaignHeaderID != null)
        {
            AdCampaignHeaderID = recPRAdCampaign.pradc_AdCampaignHeaderID;
        }
    }
    else
    {
        //New blank record
        DEBUG("New blank record");
        recPRAdCampaign = eWare.CreateRecord("PRAdCampaign");

        bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }

    if (eWare.Mode == PreDelete )
	{
        DeleteAdCampaign(AdCampaignID);
		Response.Redirect(eWare.URL("PRAdvertising/AdCampaignTT.asp?pradch_AdCampaignHeaderID=" + AdCampaignHeaderID));
        return; 
	}

    //Header
    recPRAdCampaignHeader = eWare.FindRecord("PRAdCampaignHeader", "pradch_AdCampaignHeaderID=" + AdCampaignHeaderID);

    var blkHeader=eWare.GetBlock("AdCampaignAdHeader");
    blkHeader.ArgObj = recPRAdCampaignHeader;
    blkHeader.Title="Ad Campaign";
    entry = blkHeader.GetEntry("pradch_Name").ReadOnly = true;
    entry = blkHeader.GetEntry("pradch_TypeCode").ReadOnly = true;

    //Ad Campaign Section
    blkAdCampaignAd=eWare.GetBlock("AdCampaignAdTT");
    blkAdCampaignAd.ArgObj = recPRAdCampaign;
    blkAdCampaignAd.Title="Ad Campaign Trading & Transportation Guide Ad";

    if(bNew)
    {
        blkAdCampaignAd.GetEntry("pradc_AdCampaignHeaderID").DefaultValue = AdCampaignHeaderID;
        blkAdCampaignAd.GetEntry("pradc_CompanyID").DefaultValue = CompanyID;
    }

    blkAdCampaignAd.GetEntry("pradc_Placement").OnChangeScript = "onPlacementChangeTT()";
    blkAdCampaignAd.GetEntry("pradc_placement").LookupFamily = "pradc_PlacementTT";

    blkAdCampaignAd.GetEntry("pradc_cost").OnChangeScript = "stripDollarComma(this);";

    //Ad Details Section
    if(eWare.Mode == View)
    {
        blkAdCampaignDetails=eWare.GetBlock("AdCampaignDetailsView");
        blkAdCampaignDetails.Title="Ad Details";
        recAdCampaignDetails = eWare.FindRecord("vPRAdCampaign", "pracf_AdCampaignID=" + AdCampaignID);
        blkAdCampaignDetails.ArgObj = recAdCampaignDetails;
    }
    else
    {
        blkAdCampaignDetails=eWare.GetBlock("AdCampaignDetailsEdit");
        blkAdCampaignDetails.Title="Ad Details";
        blkAdCampaignDetails.ArgObj = recPRAdCampaign;

        blkAdCampaignDetails.GetEntry("pradc_CreatedDate").ReadOnly = true;
        blkAdCampaignDetails.GetEntry("pradc_CreatedBy").ReadOnly = true;
        blkAdCampaignDetails.GetEntry("pradc_UpdatedDate").ReadOnly = true;
        blkAdCampaignDetails.GetEntry("pradc_UpdatedBy").ReadOnly = true;
    }

    //Billing Terms List Section
    var sWhere = "pract_AdCampaignID = " + AdCampaignID; 
    var recBillingTermsList = null;
    recBillingTermsList = eWare.FindRecord("PRAdCampaignTerms", sWhere);
    blkBillingTermsList = eWare.GetBlock("AdCampaignTermsList");
    blkBillingTermsList.ArgObj = recBillingTermsList;

    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.CheckLocks = false;

    if(eWare.Mode == Edit)
    {
        var fldBP = blkAdCampaignAd.GetEntry("pradc_AdSize");
        fldBP.LookupFamily = "pradc_AdSize_curr";
    }
    
    if(SourceID != "-1")
    {
        DEBUG("Replicate");

        if (eWare.Mode < Edit)
            eWare.Mode = Edit;

        recSourcePRAdCampaign = eWare.FindRecord("PRAdCampaign", "pradc_AdCampaignID=" + SourceID);

        blkAdCampaignAd.GetEntry("pradc_CompanyID").DefaultValue = recSourcePRAdCampaign.pradc_CompanyID;
        blkAdCampaignAd.GetEntry("pradc_AdCampaignHeaderID").DefaultValue = recSourcePRAdCampaign.pradc_AdCampaignHeaderID;
        blkAdCampaignAd.GetEntry("pradc_Name").DefaultValue = recSourcePRAdCampaign.pradc_Name;
        blkAdCampaignAd.GetEntry("pradc_AdCampaignType").DefaultValue = recSourcePRAdCampaign.pradc_AdCampaignType;

        blkAdCampaignAd.GetEntry("pradc_ttedition").DefaultValue = recSourcePRAdCampaign.pradc_BluePrintsEdition;
        blkAdCampaignAd.GetEntry("pradc_creativestatus").DefaultValue = recSourcePRAdCampaign.pradc_CreativeStatus;
        blkAdCampaignAd.GetEntry("pradc_premium").DefaultValue = recSourcePRAdCampaign.pradc_Premium;
        blkAdCampaignAd.GetEntry("pradc_placement").DefaultValue = recSourcePRAdCampaign.pradc_Placement;
        blkAdCampaignAd.GetEntry("pradc_notes").DefaultValue = recSourcePRAdCampaign.pradc_Notes;
        blkAdCampaignAd.GetEntry("pradc_adsize").DefaultValue = recSourcePRAdCampaign.pradc_AdSize;
    }

    DEBUG("AdCampaignID=" + AdCampaignID);
    DEBUG("AdCampaignHeaderID=" + AdCampaignHeaderID);
    DEBUG("bNew=" + bNew);
    DEBUG("eWare.Mode=" + eWare.Mode);

    sListingAction = eWare.Url("PRAdvertising/AdCampaignTT.asp")+ "&pradch_AdCampaignHeaderID=" + AdCampaignHeaderID;
    sSummaryAction = eWare.Url("PRAdvertising/AdCampaignAdTT.asp")+ "&pradc_AdCampaignID=" + AdCampaignID;

    //Add blocks
    blkContainer.AddBlock(blkHeader);
    blkContainer.AddBlock(blkAdCampaignAd);
    blkContainer.AddBlock(blkAdCampaignDetails);

    // blkContent is a catchall for the various page sections which will be dynamically built and moved to other sections of the page
    blkContent = eWare.GetBlock("Content");

    recPRAdCampaignFile = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID);

    if (eWare.Mode == Edit || eWare.Mode == Save) {
        blkContent.Contents += "<table style='width:750px'><tr id=trImageUpload><td colspan=4 style='padding-left:15px'><input id='uploadstatus' name='_uploadstatus' type='hidden' value='0' /><span class='VIEWBOXCAPTION' id='_Captpradc_adimageupload'>Ad Image File Name:</span>&nbsp;<span class='VIEWBOX'>" + recPRAdCampaignFile.ItemAsString("pracf_FileName") + "</span><br /><iframe id='_frame_uploadadimagefile' src='AdCampaignFileUpload.aspx' frameborder='0' style='height:60; width:100%;'></iframe></td></tr></table>"; 
    }
    else if (eWare.Mode == View) 
    {
        ProcessAdImage(recPRAdCampaignFile.pracf_FileTypeCode, recPRAdCampaignFile.ItemAsString("pracf_FileName"), recPRAdCampaignFile.ItemAsString("pracf_FileName_disk"));
    }
    
    //Hide/disable fields
    entry = blkAdCampaignAd.GetEntry("pradc_CompanyID");
    entry.ReadOnly = true;
    entry.Hidden = true;
    
    entry = blkAdCampaignAd.GetEntry("pradc_AdCampaignHeaderID");
    entry.ReadOnly = true; 
    entry.Hidden = true; 

    entry = blkAdCampaignAd.GetEntry("pradc_AdCampaignType");
    entry.ReadOnly = true; 
    entry.Hidden = true; 

    entry = blkAdCampaignAd.GetEntry("pradc_Name");
    entry.ReadOnly = true; 
    entry.Hidden = true; 

    entry = blkAdCampaignAd.GetEntry("pradc_Discount");
    entry.ReadOnly = true; 
    entry.Hidden = true;

    blkContainer.AddBlock(blkContent);

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {

        sSaveAction = changeKey(sURL, "em", "2");
        blkContainer.AddButton(eWare.Button("Save", "Save.gif", "javascript:document.EntryForm.action='" + sSaveAction + "'; saveTT();"));

        if (bNew)
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
	    }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }
	}
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

        sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this ad campaign?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
        blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
            
        sChangeAction = changeKey(sURL, "em", "1");
        blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sChangeAction + "';document.EntryForm.submit();"));

        blkContainer.AddButton(eWare.Button("Terms","edit.gif",changeKey(eWare.Url("PRAdvertising/AdCampaignTerms.asp"),"pradc_AdCampaignID",AdCampaignID)));

        var sReplicateUrl = changeKey(eWare.Url("PRAdvertising/AdCampaignAdTT.asp") + "&SourceID="+ AdCampaignID, "pradch_AdCampaignHeaderID", AdCampaignHeaderID);
        var sReplicateAction = "javascript:if (confirm('Are you sure you want to copy this Ad?')) { location.href='" + sReplicateUrl + "';}";
        blkContainer.AddButton(eWare.Button("Replicate", "save.gif", sReplicateAction));
    }
    
    //Add hidden prac_filename field on screen to be updated by file uploader
    blkFileContent = eWare.GetBlock("Content");
    if (recPRAdCampaignFile.eof || bNew) 
        blkFileContent.Contents += "<input id='_HIDDENpracf_filename' name='_HIDDENpracf_filename' type='hidden' />"; 
    else
        blkFileContent.Contents += "<input id='_HIDDENpracf_filename' name='_HIDDENpracf_filename' type='hidden' value=\"" + recPRAdCampaignFile.pracf_FileName + "\"/>"; 
    blkContainer.AddBlock(blkFileContent);

    if(blkBillingTermsList) {
        var blkTitle = eWare.GetBlock('Content');
        blkTitle.Contents = "<div class='PANEREPEAT' style='padding-left:15px' nowrap='true'>Billing Terms</div>";
        blkContainer.AddBlock(blkTitle);
        blkContainer.AddBlock(blkBillingTermsList);
    }

    eWare.AddContent(blkContainer.Execute());

    AdCampaignID = recPRAdCampaign("pradc_AdCampaignID") //in case it changed due to duplicate
    var file1="";
    var file2=""

    //Save or update PRAdCampaignFile record
    if(eWare.Mode == Save)
    {
        sSQL = "SELECT Capt_US FROM Custom_Captions WITH (NOLOCK) WHERE Capt_FamilyType = 'Choices' AND Capt_Family = 'PRCompanyAdUploadDirectory'";
        var recCompanyAdUploadDirectory = eWare.CreateQueryObj(sSQL);
        recCompanyAdUploadDirectory.SelectSQL();
        var RootDir = recCompanyAdUploadDirectory("Capt_US");

        if(getFormValue("_HIDDENpracf_filename") != "" && getFormValue("_HIDDENpracf_filename") != "undefined" )
        {
            recPRAdCampaignFile = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID);

            if(recPRAdCampaignFile.eof)
            {
                //Not found - create record
                recPRAdCampaignFile = eWare.CreateRecord("PRAdCampaignFile");
                recPRAdCampaignFile.pracf_AdCampaignID = AdCampaignID;
                recPRAdCampaignFile.pracf_FileTypeCode = FILETYPECODE_DIGITAL_IMAGE;
                recPRAdCampaignFile.pracf_Sequence = 1;
                recPRAdCampaignFile.pracf_Language = "E";
            }

            recPRAdCampaignFile.pracf_filename_disk = getDiskFilename(CompanyID, AdCampaignID, getFormValue("_HIDDENpracf_filename"));
            recPRAdCampaignFile.pracf_filename = getFormValue("_HIDDENpracf_filename"); //get filename from javascript form variable
            recPRAdCampaignFile.SaveChanges();

            //Rename image file
            file1=RootDir+"\\"+recPRAdCampaignFile.pracf_filename;
            file2=RootDir+"\\"+recPRAdCampaignFile.pracf_filename_disk;
            renameFile(file1, file2);
        }
    }
    
    if(eWare.Mode == Save)
    {
        if(bNew)
        {
            // Update PRAdCampaignTerms record and header cost
            var billingDate = BillingDate_TT(recPRAdCampaign);
            InsertAdCampaignTermsRecord(AdCampaignID, AdCampaignHeaderID, recPRAdCampaign, billingDate);
        }
        else
        {
            // Update header cost
            UpdateAdCampaignHeaderCost(AdCampaignHeaderID);
        }
    }

    //************************
    //Script Section BEGIN
    //************************
    Response.Write("\n<script type='text/javascript'>");
	Response.Write("\nfunction initBBSI()"); 
	Response.Write("\n{ ");
	Response.Write("\n\tPRCompanyAdvertisementFormUpdates(" + AdCampaignID + ", " + eWare.Mode + ", '/" + sInstallName + "/CustomPages/PRAdvertising/AdCampaignAdTT.asp?SID=" + SID + "');");
	Response.Write("\n\tdocument.forms['EntryForm'].onsubmit=Form_OnSubmit;");

    Response.Write("\n\tvar p=document.getElementById('_Captpradc_placement');");
    Response.Write("\n\tp.innerText='Ad Position:';");

	Response.Write("\n} ");
    Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
	Response.Write("\n</script>");
    //************************
    //Script Section END
    //************************
    
    if (eWare.Mode == Save) 
    {
	    if (bNew)
	        Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction);
    }
    else 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));
    }
}
Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
%>
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->

