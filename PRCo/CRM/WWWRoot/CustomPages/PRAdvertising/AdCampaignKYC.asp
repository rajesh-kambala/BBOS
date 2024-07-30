<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
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

    // Determine if this is new or edit
    var AdCampaignHeaderID = getIdValue("pradch_AdCampaignHeaderID");
    var CompanyID = new String(Request.QueryString("Key1"));

    DEBUG("AdCampaignHeaderID=" + AdCampaignHeaderID);
    DEBUG("CompanyID=" + CompanyID);

    recAdCampaignHeader = eWare.FindRecord("PRAdCampaignHeader", "pradch_AdCampaignHeaderID=" + AdCampaignHeaderID);

    sListingAction = changeKey(eWare.Url("PRAdvertising/CompanyAdvertisementListing.asp"), "Key1", CompanyID);
    sSummaryAction = eWare.Url("PRAdvertising/AdCampaignHeader.asp?pradch_AdCampaignHeaderID=" + AdCampaignHeaderID );

    var blkMain = eWare.GetBlock("AdCampaignHeader");
    blkMain.Title = "Ad Campaign";

    entry = blkMain.GetEntry("pradch_Discount");
    entry.ReadOnly = true; 
    entry.Hidden = true; 

    //Advertisements List Section
    var sWhere = "pradch_AdCampaignHeaderID=" + AdCampaignHeaderID;
    var recAdvertisementList = null;
    recAdvertisementList = eWare.FindRecord("vPRAdCampaignKYCList", sWhere);
    blkAdvertisementList = eWare.GetBlock("AdCampaignAdListKYC");
    blkAdvertisementList.CaptionFamily = "PRAdvertisementCaptions";
    blkAdvertisementList.ArgObj = recAdvertisementList;

    var blkTitle1 = eWare.GetBlock('Content');
    blkTitle1.Contents = "<div class='PANEREPEAT' style='padding-left:15px' nowrap='true'>Advertisements</div>";

    blkContainer.AddBlock(blkMain);
    blkContainer.AddBlock(blkTitle1);
    blkContainer.AddBlock(blkAdvertisementList);    

    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

    sDeleteUrl = changeKey(eWare.Url("PRAdvertising/AdCampaignHeader.asp"), "pradch_AdCampaignHeaderID", AdCampaignHeaderID);
    sDeleteAction = "javascript:if (confirm('Are you sure you want to delete this ad campaign header (and sub-campaigns)?')) { location.href='" + changeKey(sDeleteUrl, "em", "3") + "';}";
    blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteAction));

    sChangeUrl = changeKey(eWare.Url("PRAdvertising/AdCampaignHeader.asp"), "pradch_AdCampaignHeaderID", AdCampaignHeaderID);
    blkContainer.AddButton(eWare.Button("Change", "edit.gif", sChangeUrl));
    
    sNewAdUrl = changeKey(eWare.Url("PRAdvertising/AdCampaignAdKYC.asp"), "pradch_AdCampaignHeaderID", AdCampaignHeaderID);
    blkContainer.AddButton(eWare.Button("New Advertisement","edit.gif",sNewAdUrl));

    eWare.AddContent(blkContainer.Execute(recAdCampaignHeader));
    Response.Write(eWare.GetPage());
}
%>