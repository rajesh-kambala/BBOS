<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="AdCampaignAd.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2019-2024

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
    bDebug = false;

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var CompanyID = new String(Request.QueryString("Key1"));
    var Entry;

    // set up the main record
    var AdCampaignID = getIdValue("pradc_AdCampaignID");
    var AdCampaignHeaderID = getIdValue("pradch_AdCampaignHeaderID");
    var SourceID = getIdValue("SourceID");
    var sEntityWebUserList = "prwuld_WebUserListID";

    Response.Write("<script type='text/javascript' src='AdCampaignAd.js'></script>")

    DEBUG("CompanyID=" + CompanyID);  DEBUG("SourceID=" + SourceID);

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
		Response.Redirect(eWare.URL("PRAdvertising/AdCampaignKYC.asp?pradch_AdCampaignHeaderID=" + AdCampaignHeaderID));
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
    blkAdCampaignAd=eWare.GetBlock("AdCampaignAdKYC");
    blkAdCampaignAd.ArgObj = recPRAdCampaign;
    blkAdCampaignAd.Title="Ad Campaign Know Your Commodity Ad";

    blkAdCampaignAd.GetEntry("pradc_cost").OnChangeScript = "stripDollarComma(this);";

    //Digital Section
    blkAdCampaignAdDigital = eWare.GetBlock("AdCampaignAdKYCDigital");
    blkAdCampaignAdDigital.ArgObj = recPRAdCampaign; 
    blkAdCampaignAdDigital.Title="Digital Ad";

    //Print Section
    blkAdCampaignAdPrint = eWare.GetBlock("AdCampaignAdKYCPrint");
    blkAdCampaignAdPrint.ArgObj = recPRAdCampaign; 
    blkAdCampaignAdPrint.Title="Print Ad";

    //Hide the KYCCommodityID since we are building it custom
    Entry = blkAdCampaignAd.GetEntry("pradc_KYCCommodityID");
    Entry.ReadOnly = true;	// Readonly and Hidden in combination will render the tag, which is used later in the code
    Entry.Hidden = true;

    if(bNew)
    {
        blkAdCampaignAd.GetEntry("pradc_AdCampaignHeaderID").DefaultValue = AdCampaignHeaderID;
        blkAdCampaignAd.GetEntry("pradc_CompanyID").DefaultValue = CompanyID;
    }

    blkAdCampaignAd.GetEntry("pradc_Placement").OnChangeScript = "onPlacementChangeKYC()";
    blkAdCampaignAd.GetEntry("pradc_placement").LookupFamily = "pradc_PlacementKYC";

    blkAdCampaignAd.GetEntry("pradc_AdSize").LookupFamily = "pradc_AdSize_KYC";

    //Ad Details Section
    if(eWare.Mode == View)
    {
        blkAdCampaignDetails=eWare.GetBlock("AdCampaignDetailsViewKYC");
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

    //Hide the KYCCommodityID since we are building it custom
    Entry = blkAdCampaignAd.GetEntry("pradc_KYCCommodityID");
    Entry.ReadOnly = true;	// Readonly and Hidden in combination will render the tag, which is used later in the code
    Entry.Hidden = true;

    // Ad Campaign Summary (Impression Count, Click Count, and Average Rank
    var recPRAdCampaignSummary = eWare.FindRecord("vPRAdCampaignSummary", "pradc_AdCampaignID = " + AdCampaignID);
    blkSummary = eWare.GetBlock('PRAdCampaignSummary');
    blkSummary.Title = "Ad Campaign Summary";
    blkSummary.ARgObj = recPRAdCampaignSummary;
    
    entry = blkSummary.GetEntry("pradc_impressioncount");
    entry.ReadOnly = true;

    entry = blkSummary.GetEntry("pradc_clickcount");
    entry.ReadOnly = true;

    //Billing Terms List Section
    var sWhere = "pract_AdCampaignID = " + AdCampaignID; 
    var recBillingTermsList = null;
    recBillingTermsList = eWare.FindRecord("PRAdCampaignTerms", sWhere);
    blkBillingTermsList = eWare.GetBlock("AdCampaignTermsList");
    blkBillingTermsList.ArgObj = recBillingTermsList;

    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.CheckLocks = false;
    
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

        blkAdCampaignAd.GetEntry("pradc_KYCEdition").DefaultValue = recSourcePRAdCampaign.pradc_KYCEdition;
        blkAdCampaignAd.GetEntry("pradc_KYCCommodityID").DefaultValue = recSourcePRAdCampaign.pradc_KYCCommodityID;

        blkAdCampaignAd.GetEntry("pradc_Placement").DefaultValue = recSourcePRAdCampaign.pradc_Placement;
        blkAdCampaignAd.GetEntry("pradc_Premium").DefaultValue = recSourcePRAdCampaign.pradc_Premium;
        blkAdCampaignAd.GetEntry("pradc_Notes").DefaultValue = recSourcePRAdCampaign.pradc_Notes;
        
        blkAdCampaignAdDigital.GetEntry("pradc_StartDate").DefaultValue = recSourcePRAdCampaign.pradc_StartDate;
        recPRAdCampaign.pradc_StartDate = recSourcePRAdCampaign.pradc_StartDate;

        blkAdCampaignAdDigital.GetEntry("pradc_EndDate").DefaultValue = recSourcePRAdCampaign.pradc_EndDate;
        recPRAdCampaign.pradc_EndDate = recSourcePRAdCampaign.pradc_EndDate;

        blkAdCampaignAdDigital.GetEntry("pradc_CreativeStatus").DefaultValue = recSourcePRAdCampaign.pradc_CreativeStatus;
        recPRAdCampaign.pradc_CreativeStatus = recSourcePRAdCampaign.pradc_CreativeStatus;

        blkAdCampaignAdPrint.GetEntry("pradc_CreativeStatusPrint").DefaultValue = recSourcePRAdCampaign.pradc_CreativeStatusPrint;
        recPRAdCampaign.pradc_CreativeStatusPrint = recSourcePRAdCampaign.pradc_CreativeStatusPrint;
        
        blkAdCampaignAdDigital.GetEntry("pradc_TargetURL").DefaultValue = recSourcePRAdCampaign.pradc_TargetUrl;
        recPRAdCampaign.pradc_TargetURL = recSourcePRAdCampaign.pradc_TargetUrl;

        blkAdCampaignDetails.GetEntry("pradc_AdFileCreatedBy").DefaultValue = recSourcePRAdCampaign.pradc_AdFileCreatedBy;
        recPRAdCampaign.pradc_AdFileCreatedBy = recSourcePRAdCampaign.pradc_AdFileCreatedBy;

        blkAdCampaignDetails.GetEntry("pradc_AdFileUpdatedBy").DefaultValue = recSourcePRAdCampaign.pradc_AdFileUpdatedBy;
        recPRAdCampaign.pradc_AdFileUpdatedBy = recSourcePRAdCampaign.pradc_AdFileUpdatedBy;
    }

    DEBUG("AdCampaignID=" + AdCampaignID); DEBUG("AdCampaignHeaderID=" + AdCampaignHeaderID); DEBUG("bNew=" + bNew); DEBUG("eWare.Mode=" + eWare.Mode);

    sListingAction = eWare.Url("PRAdvertising/AdCampaignKYC.asp")+ "&pradch_AdCampaignHeaderID=" + AdCampaignHeaderID;
    sSummaryAction = eWare.Url("PRAdvertising/AdCampaignAdKYC.asp")+ "&pradc_AdCampaignID=" + AdCampaignID;

    //Add blocks
    blkContainer.AddBlock(blkHeader);
    blkContainer.AddBlock(blkAdCampaignAd);
    blkContainer.AddBlock(blkAdCampaignAdDigital);
    blkContainer.AddBlock(blkAdCampaignAdPrint);
    blkContainer.AddBlock(blkAdCampaignDetails);

    if(eWare.Mode != Edit && blkSummary) {
        blkContainer.AddBlock(blkSummary);
    }

    // blkContent is a catchall for the various page sections which will be dynamically built and moved to other sections of the page
    blkContent = eWare.GetBlock("Content");

    recPRAdCampaignFileDigital = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode = '" + FILETYPECODE_DIGITAL_IMAGE + "'");
    recPRAdCampaignFilePrint = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode = '" + FILETYPECODE_PRINT_IMAGE + "'");



    if (eWare.Mode == Edit || eWare.Mode == Save) {
        blkContent.Contents += "<table style='width:750px' id='tImageUploadDigital'><tr><td colspan=4 style='padding-left:15px'><input id='uploadstatusdigital' name='_uploadstatusdigital' type='hidden' value='0' /><span class='VIEWBOXCAPTION' id='_Captpradc_adimageuploaddigital'>Digital Ad Image File Name:</span>&nbsp;<span class='VIEWBOX'>" + recPRAdCampaignFileDigital.ItemAsString("pracf_FileName") + "</span><br /><iframe id='_frame_uploadadimagefile' src='AdCampaignFileUpload.aspx?SubmitFlag=2&FileTypeCode=DI' frameborder='0' style='height:60; width:100%;'></iframe></td></tr></table>"; 
        blkContent.Contents += "<table style='width:750px' id='tImageUploadPrint'><tr><td colspan=4 style='padding-left:15px'><input id='uploadstatusprint' name='_uploadstatusprint' type='hidden' value='0' /><span class='VIEWBOXCAPTION' id='_Captpradc_adimageuploadprint'>Print Ad Image File Name:</span>&nbsp;<span class='VIEWBOX'>" + recPRAdCampaignFilePrint.ItemAsString("pracf_FileName") + "</span><br /><iframe id='_frame_uploadadimagefile2' src='AdCampaignFileUpload.aspx?SubmitFlag=P&FileTypeCode=PI' frameborder='0' style='height:60; width:100%;'></iframe></td></tr></table>"; 
    }
    else if (eWare.Mode == View) 
    {
        ProcessAdImage(recPRAdCampaignFileDigital.pracf_FileTypeCode, recPRAdCampaignFileDigital.ItemAsString("pracf_FileName"),recPRAdCampaignFileDigital.ItemAsString("pracf_FileName_disk"));
        ProcessAdImage(recPRAdCampaignFilePrint.pracf_FileTypeCode, recPRAdCampaignFilePrint.ItemAsString("pracf_FileName"),recPRAdCampaignFilePrint.ItemAsString("pracf_FileName_disk"));
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
        // draw the select box based upon the KYCCommodities
        sCommoditySelectDisplay = "<div style='{display:none}'> <div id='div_pradc_kyccommodityid' >" + 
            "<span id='_Captpradc_kyccommodityid' class='VIEWBOXCAPTION'>&nbsp;KYC Commodity Article:</span><br/>" +
            "<span>&nbsp;<select class='EDIT' size='1' NAME='pradc_kyccommodityid' id='pradc_kyccommodityid'>" ;

        // get the list of commodities (actually, Web User Lists)
		sSQL = 
            "SELECT prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_AttributeID, prkycc_GrowingMethodID " +
            " FROM PRKYCCommodity " +
            " WHERE prkycc_HasAd = 'Y' ORDER BY prkycc_PostName ASC"
        
        var recKYCCommodities  = eWare.CreateQueryObj(sSQL);
        recKYCCommodities.SelectSQL();
        var valFound = false;

        while (!recKYCCommodities.eof) 
        {
            sSelected = "";

            if ( (recKYCCommodities("prkycc_KYCCommodityID") == recPRAdCampaign("pradc_KYCCommodityID")) ||
                 (SourceID != "-1" && recKYCCommodities("prkycc_KYCCommodityID") == recSourcePRAdCampaign("pradc_KYCCommodityID"))
               )
            {
                sSelected = " SELECTED ";
                valFound = true;
            }

            sCommoditySelectDisplay += "<option " + sSelected + "value='" + 
                                            recKYCCommodities("prkycc_KYCCommodityID") + "' >" +
                                            recKYCCommodities("prkycc_PostName") + 
                                        "</option> ";
            recKYCCommodities.NextRecord();
        }

        if(valFound)
            sSelected = "";
        else
            sSelected = " SELECTED ";
        sCommoditySelectDisplay += "<option value=''" + sSelected + ">--None--</option>";
        sCommoditySelectDisplay += "</select></span><span>&nbsp;&nbsp;</span></div></div>";
        
        Response.Write(sCommoditySelectDisplay);
        sCommoditySelectDraw = " AppendCell('_Captpradc_adsize', 'div_pradc_kyccommodityid', true);";

        sSaveAction = changeKey(sURL, "em", "2");
        blkContainer.AddButton(eWare.Button("Save", "Save.gif", "javascript:document.EntryForm.action='" + sSaveAction + "'; saveKYC();"));

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
    	// Get the commodity article id
        var sPostName = "";

        if(recPRAdCampaign.ItemAsString("pradc_KYCCommodityID") != "")
        {
            sSQL = "SELECT prkycc_KYCCommodityID, prkycc_ArticleID, prkycc_PostName, prkycc_CommodityID, prkycc_AttributeID, prkycc_GrowingMethodID " +
                " FROM PRKYCCommodity " +
                " WHERE prkycc_KYCCommodityID = " + recPRAdCampaign.ItemAsString("pradc_KYCCommodityID");
        
		    recCommodity = eWare.CreateQueryObj(sSQL);
		    recCommodity.SelectSQL();
		    if (recCommodity.RecordCount > 0) {
                sPostName = recCommodity("prkycc_PostName");
            }
        }

        sCommoditySelectDisplay = "<div style=\"display:none\"> <div id=\"div_commodity_article\" >" + 
                    "<span ID=\"_Captcommodity_article\" class=\"VIEWBOXCAPTION\">&nbsp;KYC Commodity Article:</span><br/>" +
                    "<span class=\"VIEWBOX\">&nbsp;" + sPostName + "</span></div></div>";

        Response.Write(sCommoditySelectDisplay);

        sCommoditySelectDraw = " AppendCell(\"_Captpradc_adsize\", \"div_commodity_article\", true);";

        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

        sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this ad campaign?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
        blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
            
        sChangeAction = changeKey(sURL, "em", "1");
        blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sChangeAction + "';document.EntryForm.submit();"));

        blkContainer.AddButton(eWare.Button("Terms","edit.gif",changeKey(eWare.Url("PRAdvertising/AdCampaignTerms.asp"),"pradc_AdCampaignID",AdCampaignID)));
    
        var sReplicateUrl = changeKey(eWare.Url("PRAdvertising/AdCampaignAdKYC.asp") + "&SourceID="+ AdCampaignID, "pradch_AdCampaignHeaderID", AdCampaignHeaderID);
        var sReplicateAction = "javascript:if (confirm('Are you sure you want to copy this Ad?')) { location.href='" + sReplicateUrl + "';}";
        blkContainer.AddButton(eWare.Button("Replicate", "save.gif", sReplicateAction));
    }

    //Move digital filename up to other block
    sFilenameDrawDigital = " \n  var img=document.getElementById('tdAdImage'); ";
    sFilenameDrawDigital += "\n if(img)";
    sFilenameDrawDigital += "\n   img.innerHTML = img.innerHTML + '<br><br><span class=\"VIEWBOXCAPTION\">Digital Ad Image File Name:</span><br><span class=\"VIEWBOX\">' + document.getElementById('_HIDDENpracf_filename').value + '</span><br><br>';";

    sFilenameDrawPrint = " \n  var img2=document.getElementById('tdAdImage2'); ";
    sFilenameDrawPrint += "\n if(img2)";
    sFilenameDrawPrint += "\n   img2.innerHTML = img2.innerHTML + '<br><br><span class=\"VIEWBOXCAPTION\">Print Ad Image File Name:</span><br><span class=\"VIEWBOX\">' + document.getElementById('_HIDDENpracf_filename2').value + '</span><br><br>';";
    
    //Move digital iframe up to other block
    sIFrameDrawDigital = " AppendCell(\"_Captpradc_creativestatus\", \"tImageUploadDigital\", false);";
    sIFrameDrawPrint   = " AppendCell(\"_Captpradc_creativestatusprint\", \"tImageUploadPrint\", false);";
    
    //Add hidden prac_filename field on screen to be updated by file uploader
    blkFileContent = eWare.GetBlock("Content");

    if (recPRAdCampaignFileDigital.eof || bNew) 
        blkFileContent.Contents += "<input id='_HIDDENpracf_filename' name='_HIDDENpracf_filename' type='hidden' />"; 
    else
        blkFileContent.Contents += "<input id='_HIDDENpracf_filename' name='_HIDDENpracf_filename' type='hidden' value=\"" + recPRAdCampaignFileDigital.pracf_FileName + "\"/>"; 

    if (recPRAdCampaignFilePrint.eof || bNew) 
        blkFileContent.Contents += "<input id='_HIDDENpracf_filename2' name='_HIDDENpracf_filename2' type='hidden' />"; 
    else
        blkFileContent.Contents += "<input id='_HIDDENpracf_filename2' name='_HIDDENpracf_filename2' type='hidden' value=\"" + recPRAdCampaignFilePrint.pracf_FileName + "\"/>"; 

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
    var szFileName="";
    //Save or update PRAdCampaignFile records
    if(eWare.Mode == Save)
    {
        sSQL = "SELECT Capt_US FROM Custom_Captions WITH (NOLOCK) WHERE Capt_FamilyType = 'Choices' AND Capt_Family = 'PRCompanyAdUploadDirectory'";
        var recCompanyAdUploadDirectory = eWare.CreateQueryObj(sSQL);
        recCompanyAdUploadDirectory.SelectSQL();
        var RootDir = recCompanyAdUploadDirectory("Capt_US");

        recPRAdCampaign.pradc_KYCCommodityID = getFormValue("pradc_kyccommodityid"); 
        recPRAdCampaign.SaveChanges();

        //Digital File
        if(getFormValue("_HIDDENpracf_filename") != "" && getFormValue("_HIDDENpracf_filename") != "undefined" )
        {
            recPRAdCampaignFileDigital = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode='" + FILETYPECODE_DIGITAL_IMAGE + "'");
            szFileName = RootDir+"\\"+getFormValue("_HIDDENpracf_filename");

            if(existsFile(szFileName) == true)
            {
                if(recPRAdCampaignFileDigital.eof)
                {
                    //Not found - create record
                    recPRAdCampaignFileDigital = eWare.CreateRecord("PRAdCampaignFile");
                    recPRAdCampaignFileDigital.pracf_AdCampaignID = AdCampaignID;
                    recPRAdCampaignFileDigital.pracf_FileTypeCode = FILETYPECODE_DIGITAL_IMAGE;
                    recPRAdCampaignFileDigital.pracf_Sequence = 1;
                    recPRAdCampaignFileDigital.pracf_Language = "E";
                }

                recPRAdCampaignFileDigital.pracf_filename_disk = getDiskFilename(CompanyID, AdCampaignID, getFormValue("_HIDDENpracf_filename"));
                recPRAdCampaignFileDigital.pracf_filename = getFormValue("_HIDDENpracf_filename"); //get filename from javascript form variable
                recPRAdCampaignFileDigital.SaveChanges();

                //Rename image file to new disk name
                file1=szFileName;;
                file2=RootDir+"\\"+recPRAdCampaignFileDigital.pracf_filename_disk;
                renameFile(file1, file2);
            }
        }

        //Print File
        if(getFormValue("_HIDDENpracf_filename2") != "" && getFormValue("_HIDDENpracf_filename2") != "undefined")
        {
            recPRAdCampaignFilePrint = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode='" + FILETYPECODE_PRINT_IMAGE + "'");
            if(recPRAdCampaignFilePrint.eof)
            {
                //Not found - create record
                recPRAdCampaignFilePrint = eWare.CreateRecord("PRAdCampaignFile");
                recPRAdCampaignFilePrint.pracf_AdCampaignID = AdCampaignID;
                recPRAdCampaignFilePrint.pracf_FileTypeCode = FILETYPECODE_PRINT_IMAGE;
                recPRAdCampaignFilePrint.pracf_Sequence = 1;
                recPRAdCampaignFilePrint.pracf_Language = "E";
            }

            recPRAdCampaignFilePrint.pracf_filename = getFormValue("_HIDDENpracf_filename2"); //get filename from javascript form variable
            recPRAdCampaignFilePrint.SaveChanges();
        }
    }

    if(eWare.Mode == Save)
    {
        if(bNew)
        {
            // Update PRAdCampaignTerms record and header cost
            var billingDate = BillingDate_KYC(recPRAdCampaign);
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
	Response.Write("\n\tPRCompanyAdvertisementFormUpdates(" + AdCampaignID + ", " + eWare.Mode + ", '/" + sInstallName + "/CustomPages/PRAdvertising/AdCampaignAdKYC.asp?SID=" + SID + "');");
	Response.Write("\n\tdocument.forms['EntryForm'].onsubmit=Form_OnSubmit;");

    if (eWare.Mode == Edit)
    {
        Response.Write(sCommoditySelectDraw); 
        Response.Write(sIFrameDrawDigital);
        Response.Write(sIFrameDrawPrint);
    }
    else if(eWare.Mode == View)
    {
        Response.Write(sCommoditySelectDraw); 
        Response.Write(sFilenameDrawDigital);
        Response.Write(sFilenameDrawPrint);
    }

    Response.Write("\n\tvar p=document.getElementById('_Captpradc_placement');");
    Response.Write("\n\tp.innerText='Ad Position:';");

    //Blank out default dates
    //Response.Write("\n\tvar startDate=document.getElementById('_Datapradc_startdate');");
    //Response.Write("\n\tif(startDate != null && startDate.innerText == '01/01/1900') {");
    //Response.Write("\n\tdocument.getElementById('_Datapradc_startdate').innerText = '';");
    //Response.Write("\n\t}");

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