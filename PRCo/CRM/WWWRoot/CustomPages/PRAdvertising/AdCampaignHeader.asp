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

    if(eWare.Mode == View)
        eWare.Mode = Edit

    var blkMain = eWare.GetBlock("AdCampaignHeader");
    blkMain.Title = "Ad Campaign";

    // Determine if this is new or edit
    var AdCampaignHeaderID = getIdValue("pradch_AdCampaignHeaderID");
    DEBUG("pradch_AdCampaignHeaderID=" + AdCampaignHeaderID);

    var CompanyID = new String(Request.QueryString("Key1"));

    DEBUG("CompanyID="+CompanyID);

    // indicate that this is new
    if (AdCampaignHeaderID == "-1")
    {
        bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    else
    {
        bNew = false;
    }

    sListingAction = changeKey(eWare.Url("PRAdvertising/CompanyAdvertisementListing.asp"), "key1", CompanyID);
    sSummaryAction = eWare.Url("PRAdvertising/AdCampaignHeader.asp?pradch_AdCampaignHeaderID=" + AdCampaignHeaderID );

    eWare.AddContent("<script type=\"text/javascript\" src=\"AdCampaignHeader.js\"></script>")

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save()"));
    }
    else if (eWare.Mode == PreDelete )
    {
	    //Perform a physical delete of the record
	    sql = "EXEC usp_DeleteAdCampaignHeader " + AdCampaignHeaderID + ", 1";
	    qryDelete = eWare.CreateQueryObj(sql);
	    qryDelete.ExecSql();
	    Response.Redirect(eWare.URL("PRAdvertising/CompanyAdvertisementListing.asp"));
    }
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
        blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
        blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
    }

    if (bNew)
    {
        recAdCampaignHeader=eWare.CreateRecord("PRAdCampaignHeader");
        recAdCampaignHeader.pradch_CompanyID = CompanyID;
        recAdCampaignHeader.pradch_HQID = CompanyID;

        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
    }
    else
    {
        recAdCampaignHeader = eWare.FindRecord("PRAdCampaignHeader", "pradch_AdCampaignHeaderID=" + AdCampaignHeaderID);

        var F = new String(Request.QueryString("F"));
        sCancelAction = changeKey(eWare.Url(F), "pradch_AdCampaignHeaderID", AdCampaignHeaderID);
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
    }

    var entry = blkMain.GetEntry("pradch_ApprovedByPersonID");
    entry.Restrictor = "pradch_CompanyID";

    entry = blkMain.GetEntry("pradch_CompanyID");
    entry.ReadOnly = true; 
    entry.Hidden = true; 
    entry.DefaultValue = CompanyID;

    if(eWare.Mode == Edit)
    {
        entry = blkMain.GetEntry("pradch_Cost");
        entry.ReadOnly = true; 
        if(bNew) entry.Hidden = true;

        entry = blkMain.GetEntry("pradch_Discount");
        entry.ReadOnly = true; 
        entry.Hidden = true;
    }

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);

    if (eWare.Mode == Edit)
    {
        var blkBanners = eWare.GetBlock('content');
        blkBanners.contents = "<span style=\"display:none;\"><input type=text id=\"txtDummy\"></span>";
        blkContainer.AddBlock(blkBanners);
    }

    eWare.AddContent(blkContainer.Execute(recAdCampaignHeader));
    
    if (eWare.Mode == Save) 
    {
        if(recAdCampaignHeader.pradch_TypeCode == "BP")
            sListingAction = changeKey(eWare.Url("PRAdvertising/AdCampaignBP.asp"), "pradch_AdCampaignHeaderID", recAdCampaignHeader.pradch_adcampaignheaderid);
        else if(recAdCampaignHeader.pradch_TypeCode == "D")
            sListingAction = changeKey(eWare.Url("PRAdvertising/AdCampaignDigital.asp"), "pradch_AdCampaignHeaderID", recAdCampaignHeader.pradch_adcampaignheaderid);
        else if(recAdCampaignHeader.pradch_TypeCode == "KYC")
            sListingAction = changeKey(eWare.Url("PRAdvertising/AdCampaignKYC.asp"), "pradch_AdCampaignHeaderID", recAdCampaignHeader.pradch_adcampaignheaderid);
        else if(recAdCampaignHeader.pradch_TypeCode == "TT")
            sListingAction = changeKey(eWare.Url("PRAdvertising/AdCampaignTT.asp"), "pradch_AdCampaignHeaderID", recAdCampaignHeader.pradch_adcampaignheaderid);

        if(bNew)
        {
            recAdCampaignHeader.pradch_CompanyID = CompanyID;
            recAdCampaignHeader.SaveChanges();
        }

        Response.Redirect(sListingAction);
    }
    else
    {
        Response.Write(eWare.GetPage());
    }
}
Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
%>