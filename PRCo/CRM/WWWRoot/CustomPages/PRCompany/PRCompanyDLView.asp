<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2021

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
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
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyDLInclude.js\"></script>");

    if (eWare.Mode>View) 
        eWare.Mode=View;

    blkRow1 = eWare.GetBlock('container');

    var blkNotes = eWare.GetBlock("PRCompanyNotes");
    blkNotes.Title="Descriptive Line Notes";
    entry = blkNotes.GetEntry("prcomnot_CompanyNoteNote");
    entry.Caption = "Descriptive Line Notes:";
    entry.ReadOnly = true;

    var recCompanyNote = eWare.FindRecord("PRCompanyNote", "prcomnot_CompanyId=" + comp_companyid + " AND prcomnot_CompanyNoteType='DL'");
    blkNotes.ArgObj = recCompanyNote;
    blkRow1.AddBlock(blkNotes);

    // DL
    var blkDLDisplay = eWare.GetBlock("content");
    var recDLs = eWare.FindRecord("PRDescriptiveLine", "prdl_companyid=" + comp_companyid);
    recDLs.OrderBy = "prdl_DescriptiveLineId";
    blkDLDisplay.contents = createViewListing(recDLs, "prdl_LineContent", "EditableDL", "Descriptive Lines", "Publish Descriptive Lines", recCompany.comp_prpublishDL);
    blkRow1.AddBlock(blkDLDisplay);

    // Unload
    var recUnload = eWare.FindRecord("PRUnloadHours", "pruh_CompanyID=" + comp_companyid);
    recUnload.OrderBy = "pruh_UnloadHoursID";
    var blkUnload = eWare.GetBlock("content");
    blkUnload.NewLine = false;
    blkUnload.contents = createViewListing(recUnload, "pruh_LineContent", "tblUnloadHours", "Unload Hours", "Publish Unload Hours", recCompany.comp_PRPublishUnloadHours);
    blkRow1.AddBlock(blkUnload);

    blkContainer.AddBlock(blkRow1);

    // Brands
    var recBrands = eWare.FindRecord("PRCompanyBrand","prc3_CompanyId=" + comp_companyid);
    grdBrands = eWare.GetBlock("PRCompanyBrandGrid");
    grdBrands.ArgObj = recBrands;
    blkBrands = eWare.GetBlock("Content");
    blkBrands.contents = grdBrands.Execute();
    blkContainer.AddBlock(blkBrands);

    blkContainer.CheckLocks = false;
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", eWare.Url("PRCompany/PRCompanyProfile.asp") + "&T=Company&Capt=Profile"));
    blkContainer.AddButton(eWare.Button("Change Notes", "edit.gif", eWare.URL("PRCompany/PRCompanyNotes.asp") + "&notetype=DL"));

    if (iTrxStatus == TRX_STATUS_EDIT)
    {
		if (isUserInGroup("1,2,4,5,6,10"))
		{
			blkContainer.AddButton(eWare.Button("Edit&nbsp;D/L","edit.gif", eWare.URL("PRCompany/PRCompanyDL.asp")));
		}

        if (isUserInGroup("1,2,3,4,5,6,10"))
        {
            blkContainer.AddButton(eWare.Button("New Brand","New.gif", eWare.URL("PRCompany/PRCompanyBrand.asp")));
            blkContainer.AddButton(eWare.Button("Sequence Brands", "forecastrefresh.gif", eWare.URL("PRCompany/PRCompanyBrandSequence.asp"))); 
            var sReplicateAction = eWare.Url("PRCompany/PRCompanyReplicate.asp")+ "&RepType=9&RepId=" + comp_companyid + "&comp_CompanyId=" + comp_companyid;
            blkContainer.AddButton(eWare.Button("Replicate Brands", "includeall.gif", "javascript:location.href='"+sReplicateAction+"';"));
        }
    }  


    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage(''));
}

function createViewListing(recDLs, colName, controlName, caption, publishCaption, publish) {

    var sCompleteDLString = "";
    while (! recDLs.eof) 
    {
        sLine = recDLs(colName);
        if (isEmpty(sLine))
            sLine = "";

        sCompleteDLString += sLine;
        if (!recDLs.eof)
            sCompleteDLString += "<br/>\n";

        recDLs.NextRecord();
    }
        
    var sContents = createAccpacBlockHeader(controlName, caption, "100%", "100%");

    sContents += "\n<table CELLPADDING=0 CELLSPACING=0 BORDER=0>\n";


    szCheckedImage = "EmptyCheck.gif";
    if (publish) {
        szCheckedImage = "FilledCheck.gif";
    }

    sContents += "<tr>\n";        
    sContents += "<td  CLASS=VIEWBOXCAPTION>\n";
    sContents += publishCaption + ":<br/><img src=/" + sInstallName + "/img/Bullets/" + szCheckedImage + " />\n";
    sContents += "</td>\n";
    sContents += "</tr>\n";



    sContents += "<tr height=5><td></td></tr>\n";
    sContents += "<tr>\n";
    sContents += "<td valign=TOP ><span class=VIEWBOXCAPTION>D/L Listing:</span><br/>\n";
    sContents += "<div style=\"margin:1px;padding:2px;border-style:solid;border-width:1px;width:240px;height:500px;overflow-y : scroll;\">\n"; 
    sContents += "<span CLASS=\"VIEWBOX\">\n";
    sContents += sCompleteDLString;
    sContents += "</span></div></td>\n";
    sContents += "</tr>\n";
    sContents += "</table>\n";

        
    sContents += createAccpacBlockFooter();
		
	return sContents;
}%>
<!-- #include file ="CompanyFooters.asp" -->
