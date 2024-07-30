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
    bDebug=false;

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var CompanyID = new String(Request.QueryString("Key1"));

    // set up the main record
    var AdCampaignID = getIdValue("pradc_AdCampaignID");
    var AdCampaignHeaderID = getIdValue("pradch_AdCampaignHeaderID");
    var SourceID = getIdValue("SourceID");
    var DigitalType = "";

    Response.Write("<script type='text/javascript' src='AdCampaignAd.js'></script>")

    DEBUG("eWare.Mode=" + eWare.Mode);
    DEBUG("CompanyID=" + CompanyID);
    DEBUG("SourceID=" + SourceID);
    DEBUG("AdCampaignID=" + AdCampaignID);

    var bNew = false;

    if(AdCampaignID > -1)
    {
        recPRAdCampaign = eWare.FindRecord("PRAdCampaign", "pradc_AdCampaignID=" + AdCampaignID);
        DigitalType = recPRAdCampaign.pradc_AdCampaignTypeDigital;
        if(AdCampaignHeaderID != null)
            AdCampaignHeaderID = recPRAdCampaign.pradc_AdCampaignHeaderID;
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

    DEBUG("AdCampaignHeaderID=" + AdCampaignHeaderID);

    if (eWare.Mode == PreDelete )
	{
        DeleteAdCampaign(AdCampaignID);
		Response.Redirect(eWare.URL("PRAdvertising/AdCampaignDigital.asp?pradch_AdCampaignHeaderID=" + AdCampaignHeaderID));
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
    blkAdCampaignAd=eWare.GetBlock("AdCampaignAdDigital");
    blkAdCampaignAd.ArgObj = recPRAdCampaign;
    blkAdCampaignAd.Title="Ad Campaign Digital Ad";

    if(bNew)
    {
        blkAdCampaignAd.GetEntry("pradc_AdCampaignHeaderID").DefaultValue = AdCampaignHeaderID;
        blkAdCampaignAd.GetEntry("pradc_CompanyID").DefaultValue = CompanyID;
    }

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

        blkAdCampaignAd.GetEntry("pradc_AdCampaignTypeDigital").DefaultValue = recSourcePRAdCampaign.pradc_AdCampaignTypeDigital;
        blkAdCampaignAd.GetEntry("pradc_StartDate").DefaultValue = recSourcePRAdCampaign.pradc_StartDate;
        blkAdCampaignAd.GetEntry("pradc_CreativeStatus").DefaultValue = recSourcePRAdCampaign.pradc_CreativeStatus;
        blkAdCampaignAd.GetEntry("pradc_EndDate").DefaultValue = recSourcePRAdCampaign.pradc_EndDate;
        blkAdCampaignAd.GetEntry("pradc_TargetURL").DefaultValue = recSourcePRAdCampaign.pradc_TargetURL;
        blkAdCampaignAd.GetEntry("pradc_IndustryType").DefaultValue = recSourcePRAdCampaign.pradc_IndustryType;
        blkAdCampaignAd.GetEntry("pradc_Language").DefaultValue = recSourcePRAdCampaign.pradc_Language;
        blkAdCampaignAd.GetEntry("pradc_Notes").DefaultValue = recSourcePRAdCampaign.pradc_Notes;
    }

    DEBUG("bNew=" + bNew);

    sListingAction = eWare.Url("PRAdvertising/AdCampaignDigital.asp")+ "&pradch_AdCampaignHeaderID=" + AdCampaignHeaderID;
    sSummaryAction = eWare.Url("PRAdvertising/AdCampaignAdDigital.asp")+ "&pradc_AdCampaignID=" + AdCampaignID;

    //Add blocks
    blkContainer.AddBlock(blkHeader);
    blkContainer.AddBlock(blkAdCampaignAd);
    blkContainer.AddBlock(blkAdCampaignDetails);
    if(eWare.Mode != Edit && blkSummary) {
        blkContainer.AddBlock(blkSummary);
    }

    // blkContent is a catchall for the various page sections which will be dynamically built and moved to other sections of the page
    blkContent = eWare.GetBlock("Content");

    recPRAdCampaignFile = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode = '" + FILETYPECODE_DIGITAL_IMAGE + "'");
    recPRAdCampaignFileEmail = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode = '" + FILETYPECODE_DIGITAL_IMAGE_EMAIL + "'");
    recPRAdCampaignFilePDF = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode = '" + FILETYPECODE_DIGITAL_IMAGE_PDF + "'");
    recPRAdCampaignFileMobile = eWare.FindRecord("PRAdCampaignFile", "pracf_AdCampaignID=" + AdCampaignID + " AND pracf_FileTypeCode = '" + FILETYPECODE_DIGITAL_IMAGE_MOBILE + "'");

    if (eWare.Mode == Edit || eWare.Mode == Save) {
        blkContent.Contents += "<td id='fileRegion1'><table style='width:750px' id='tImageUploadDigital'><tr id=trImageUpload><td colspan=4 style='padding-left:15px'><input id='uploadstatus' name='_uploadstatus' type='hidden' value='0' /><span class='VIEWBOXCAPTION' id='_Captpradc_adimageupload'>Ad Image File Name:</span>&nbsp;<span class='VIEWBOX'>" + recPRAdCampaignFile.ItemAsString("pracf_FileName") + "</span><br /><iframe id='_frame_uploadadimagefile' src='AdCampaignFileUpload.aspx?SubmitFlag=2&FileTypeCode=DI' frameborder='0' style='height:60; width:100%;'></iframe></td></tr></table></td>"; 
        blkContent.Contents += "<td id='fileRegion2'><table style='width:750px' id='tImageUploadDigitalMobile'><tr><td colspan=4 style='padding-left:15px'><input id='uploadstatusmobile' name='_uploadstatusmobile' type='hidden' value='0' /><span class='VIEWBOXCAPTION' id='_Captpradc_adimageuploadmobile'>Mobile Ad Image File Name:</span>&nbsp;<span class='VIEWBOX'>" + recPRAdCampaignFileMobile.ItemAsString("pracf_FileName") + "</span><br /><iframe id='_frame_uploadadimagefile2' src='AdCampaignFileUpload.aspx?SubmitFlag=3&FileTypeCode=DIM' frameborder='0' style='height:35; width:100%;'></iframe><input type='checkbox' id='chkDeleteMobile' name='chkDeleteMobile'><label for='chkDeleteMobile'>Delete Mobile Image</label></td></tr></table></td>"; 
        blkContent.Contents += "<td id='fileRegion3'><table style='width:750px' id='tImageUploadDigitalEmail'><tr><td colspan=4 style='padding-left:15px'><input id='uploadstatusemail' name='_uploadstatusemail' type='hidden' value='0' /><span class='VIEWBOXCAPTION' id='_Captpradc_adimageuploademail'>Email Ad Image File Name:</span>&nbsp;<span class='VIEWBOX'>" + recPRAdCampaignFileEmail.ItemAsString("pracf_FileName") + "</span><br /><iframe id='_frame_uploadadimagefile3' src='AdCampaignFileUpload.aspx?SubmitFlag=4&FileTypeCode=DIE' frameborder='0' style='height:35; width:100%;'></iframe><input type='checkbox' id='chkDeleteEmail' name='chkDeleteEmail'><label for='chkDeleteEmail'>Delete Email Image</label></td></tr></table></td>"; 
        blkContent.Contents += "<td id='fileRegion4'><table style='width:750px' id='tImageUploadDigitalPDF'><tr><td colspan=4 style='padding-left:15px'><input id='uploadstatuspdf' name='_uploadstatuspdf' type='hidden' value='0' /><span class='VIEWBOXCAPTION' id='_Captpradc_adimageuploadpdf'>PDF Ad Image File Name:</span>&nbsp;<span class='VIEWBOX'>" + recPRAdCampaignFilePDF.ItemAsString("pracf_FileName") + "</span><br /><iframe id='_frame_uploadadimagefile4' src='AdCampaignFileUpload.aspx?SubmitFlag=P&FileTypeCode=DIPDF' frameborder='0' style='height:35; width:100%;'></iframe><input type='checkbox' id='chkDeletePDF' name='chkDeletePDF'><label for='chkDeletePDF'>Delete PDF Image</label></td></tr></table></td>"; 

    }
    else if (eWare.Mode == View) 
    {
        ProcessAdImage(recPRAdCampaignFile.pracf_FileTypeCode, recPRAdCampaignFile.ItemAsString("pracf_FileName"), recPRAdCampaignFile.ItemAsString("pracf_FileName_disk"));

        if (DigitalType == "CSEU") {
            ProcessAdImage2(recPRAdCampaignFileEmail.pracf_FileTypeCode, recPRAdCampaignFileEmail.ItemAsString("pracf_FileName"), recPRAdCampaignFileEmail.ItemAsString("pracf_FileName_disk"), "3");
            ProcessAdImage2(recPRAdCampaignFilePDF.pracf_FileTypeCode, recPRAdCampaignFilePDF.ItemAsString("pracf_FileName"), recPRAdCampaignFilePDF.ItemAsString("pracf_FileName_disk"), "4");
        } else {
            ProcessAdImage2(recPRAdCampaignFileMobile.pracf_FileTypeCode, recPRAdCampaignFileMobile.ItemAsString("pracf_FileName"), recPRAdCampaignFileMobile.ItemAsString("pracf_FileName_disk"), "2");
        }
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

    entry = blkAdCampaignAd.GetEntry("pradc_Discount");
    entry.ReadOnly = true; 
    entry.Hidden = true; 

    //Hide pradc_CommodityId since we are building it custom
    entry = blkAdCampaignAd.GetEntry("pradc_CommodityId");
    entry.ReadOnly = true;	// Readonly and Hidden in combination will render the tag, which is used later in the code
    entry.Hidden = true;

    blkContainer.AddBlock(blkContent);

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        sSaveAction = changeKey(sURL, "em", "2");
        blkContainer.AddButton(eWare.Button("Save", "Save.gif", "javascript:document.EntryForm.action='" + sSaveAction + "'; saveDigital();"));

        if (bNew)
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

        // Draw the select box based upon pradc_CommodityId
        sCommoditySelectDisplay = "<div style='{display:none}'> <div id='div_pradc_commodityid' >" + 
            "<span id='_Captpradc_commodityid' class='VIEWBOXCAPTION'>&nbsp;Commodity (Search Results Page):</span><br/>" +
            "<span>&nbsp;<select class='EDIT' size='1' NAME='pradc_commodityid' id='pradc_commodityid'>" ;

        // get the list of commodities
		sSQL = 
            "SELECT prcm_RootParentID, prcm_CommodityId, prcm_ParentId, prcm_Level, prcm_Name, prcm_FullName, prcm_CommodityCode " +
            " FROM PRCommodity WITH (NOLOCK) " +
            " ORDER BY prcm_RootParentID, prcm_FullName"

        var recCommodities  = eWare.CreateQueryObj(sSQL);
        recCommodities.SelectSQL();
        var valFound = false;

        while (!recCommodities.eof) 
        {
            sSelected = "";

            if ( (recCommodities("prcm_CommodityId") == recPRAdCampaign("pradc_CommodityID")))
            {
                sSelected = " SELECTED ";
                valFound = true;
            }

            sCommoditySelectDisplay += "<option " + sSelected + "value='" + 
                                            recCommodities("prcm_CommodityId") + "' >" +
                                            recCommodities("prcm_FullName") + 
                                        "</option> ";
            recCommodities.NextRecord();
        }

        if(valFound)
            sSelected = "";
        else
            sSelected = " SELECTED ";
        sCommoditySelectDisplay += "<option value=''" + sSelected + ">--None--</option>";
        sCommoditySelectDisplay += "</select></span><span>&nbsp;&nbsp;</span></div></div>";
        
        Response.Write(sCommoditySelectDisplay);
        sCommoditySelectDraw = " AppendCell('_Datapradc_cost', 'div_pradc_commodityid', false);";
	}
    else 
    {
        // Get the commodity article id
        var sPostName = "";

        if(recPRAdCampaign.ItemAsString("pradc_CommodityID") != "")
        {
            sSQL = "SELECT prcm_RootParentID, prcm_CommodityId, prcm_ParentId, prcm_Level, prcm_Name, prcm_FullName, prcm_CommodityCode " +
                " FROM PRCommodity WITH (NOLOCK) " +
                " WHERE prcm_CommodityID = " + recPRAdCampaign.ItemAsString("pradc_CommodityID");
        
		    recCommodity = eWare.CreateQueryObj(sSQL);
		    recCommodity.SelectSQL();
		    if (recCommodity.RecordCount > 0) {
                sPostName = recCommodity("prcm_FullName");
            }
        }

        sCommoditySelectDisplay = "<div style=\"display:none\"> <div id=\"div_commodity_name\" >" + 
                    "<span ID=\"_Captcommodity_article\" class=\"VIEWBOXCAPTION\">&nbsp;Commodity (Search Results Page):</span><br/>" +
                    "<span class=\"VIEWBOX\">&nbsp;" + sPostName + "</span></div></div>";

        Response.Write(sCommoditySelectDisplay);

        sCommoditySelectDraw = " AppendCell(\"_Datapradc_cost\", \"div_commodity_name\", false);";

        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

        sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this ad campaign?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
        blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
            
        sChangeAction = changeKey(sURL, "em", "1");
        blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sChangeAction + "';document.EntryForm.submit();"));

        blkContainer.AddButton(eWare.Button("Terms","edit.gif",changeKey(eWare.Url("PRAdvertising/AdCampaignTerms.asp"),"pradc_AdCampaignID",AdCampaignID)));
    
        var sReplicateUrl = changeKey(eWare.Url("PRAdvertising/AdCampaignAdDigital.asp") + "&SourceID="+ AdCampaignID, "pradch_AdCampaignHeaderID", AdCampaignHeaderID);
        var sReplicateAction = "javascript:if (confirm('Are you sure you want to copy this Ad?')) { location.href='" + sReplicateUrl + "';}";
        blkContainer.AddButton(eWare.Button("Replicate", "save.gif", sReplicateAction));
    }

    //Add hidden prac_filename field on screen to be updated by file uploader
    blkFileContent = eWare.GetBlock("Content");
    blkFileContent.Contents += GetHiddenFileBlock(recPRAdCampaignFile, ""); 
    blkFileContent.Contents += GetHiddenFileBlock(recPRAdCampaignFileMobile, "2"); 
    blkFileContent.Contents += GetHiddenFileBlock(recPRAdCampaignFileEmail, "3"); 
    blkFileContent.Contents += GetHiddenFileBlock(recPRAdCampaignFilePDF, "4"); 
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
    var file1_mobile="";
    var file2_mobile="";
    var szFileName="";

    //Save or update PRAdCampaignFile record
    if(eWare.Mode == Save)
    {
        sSQL = "SELECT Capt_US FROM Custom_Captions WITH (NOLOCK) WHERE Capt_FamilyType = 'Choices' AND Capt_Family = 'PRCompanyAdUploadDirectory'";
        var recCompanyAdUploadDirectory = eWare.CreateQueryObj(sSQL);
        recCompanyAdUploadDirectory.SelectSQL();
        var RootDir = recCompanyAdUploadDirectory("Capt_US");

        InsertImageFile(CompanyID, AdCampaignID, AdCampaignHeaderID, recPRAdCampaign, FILETYPECODE_DIGITAL_IMAGE, RootDir, "");
        InsertImageFile(CompanyID, AdCampaignID, AdCampaignHeaderID, recPRAdCampaign, FILETYPECODE_DIGITAL_IMAGE_MOBILE, RootDir, "2");
        InsertImageFile(CompanyID, AdCampaignID, AdCampaignHeaderID, recPRAdCampaign, FILETYPECODE_DIGITAL_IMAGE_EMAIL, RootDir, "3");
        InsertImageFile(CompanyID, AdCampaignID, AdCampaignHeaderID, recPRAdCampaign, FILETYPECODE_DIGITAL_IMAGE_PDF, RootDir, "4");

        DeleteImageFile(AdCampaignID, "chkDeleteMobile", FILETYPECODE_DIGITAL_IMAGE_MOBILE);
        DeleteImageFile(AdCampaignID, "chkDeleteEmail", FILETYPECODE_DIGITAL_IMAGE_EMAIL);
        DeleteImageFile(AdCampaignID, "chkDeletePDF", FILETYPECODE_DIGITAL_IMAGE_PDF);

        recPRAdCampaign.pradc_CommodityId = getFormValue("pradc_commodityid");
        recPRAdCampaign.SaveChanges();
    }

    if(eWare.Mode == Save)
    {
        if(bNew)
        {
            // Update PRAdCampaignTerms record and header cost
            var billingDate = BillingDate_Digital(recPRAdCampaign);
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

    %>
        var actd = document.getElementById("pradc_adcampaigntypedigital");
        if(actd != null)
        {
            actd.onchange = pradc_adcampaigntypedigital_SetStatus;
        }

        pradc_adcampaigntypedigital_SetStatus();
    <%

    Response.Write(sCommoditySelectDraw); 

	Response.Write("\n\tPRCompanyAdvertisementFormUpdates(" + AdCampaignID + ", " + eWare.Mode + ", '/" + sInstallName + "/CustomPages/PRAdvertising/AdCampaignAdDigital.asp?SID=" + SID + "');");
	Response.Write("\n\tdocument.forms['EntryForm'].onsubmit=Form_OnSubmit;");

    Response.Write("\n\tvar n1=document.getElementById('pradc_notes');");
    Response.Write("\n\tn1.setAttribute('rows', '2');");
    Response.Write("\n\tn1.setAttribute('cols', '55');");

    Response.Write("\n\tAppendCell(\"_Datapradc_adfileupdatedby\", \"fileRegion1\");");
    Response.Write("\n\tAppendCell(\"_Datapradc_createdby\", \"fileRegion2\");");
    Response.Write("\n\tAppendCell(\"_Datapradc_createdby\", \"fileRegion3\");");
    Response.Write("\n\tAppendCell(\"_Datapradc_updatedby\", \"fileRegion4\");");
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


    if (eWare.Mode == Edit && bNew) { %>
        <script type="text/javascript" >
            window.setTimeout(function () {
                var optionsToSelect = ['Produce', 'Transportation', 'Supply and Service'];
                var select = document.getElementById('pradc_industrytype');
                for (var i = 0, l = select.options.length, o; i < l; i++ )
                {
                  o = select.options[i];
                    if (optionsToSelect.indexOf(o.text) != -1)
                        o.selected = true;
                    else
                        o.selected = false;
                }

                optionsToSelect = ['English'];
                select = document.getElementById('pradc_language');
                for (var i = 0, l = select.options.length, o; i < l; i++ )
                {
                  o = select.options[i];
                    if (optionsToSelect.indexOf(o.text) != -1)
                        o.selected = true;
                    else
                        o.selected = false;
                }
            });
        </script>
    <% } 
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
%>
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->

