<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013-2021

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    doPage();

function doPage()
{

    // bDebug = true;
    var blkContent = eWare.GetBlock("Content");
    blkContent.Contents  = "<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";

    var blkInstructions = eWare.GetBlock("Content");
    blkInstructions.Contents = "<table width='100%' cellpadding='0' cellspacing='0' border='0'><tbody><tr><td style='width:5%;'></td><td width='95%'>";
    blkInstructions.Contents =  blkInstructions.Contents + "<p>To embed a text link, highlight the text, click on the <b>Insert/Edit Link</b> toolbar button, enter the URL, and under the <b>Advanced Tab</b> enter <b>explicitlink</b> in the Stylesheet Classes textbox.<p/>";
    blkInstructions.Contents =  blkInstructions.Contents + "<p>To embed an image, first upload the image to WordPress and copy the link.  Then click on the <b>Insert/Edit Image</b> toolbar button, paste the image URL, and enter other optional info such as Alternative Text, Width, and Height.  If you want the image to also be a hyperlink, then on the <b>Link</b> tab and enter the destination URL.<p/>";
    blkInstructions.Contents =  blkInstructions.Contents + "<p>You can optionally click on the <b>Source</b> toolbar button to switch to HTML mode and then work directly with raw HTML.<p/>";
    blkInstructions.Contents =  blkInstructions.Contents + "</td></tr></tbody></table>";

    // TODO: reset these to something reasonable.
    var sSecurityGroups = "1,2,3,4,5,6,10";
    
    var prpbar_publicationarticleid = getIdValue("prpbar_PublicationArticleID");
    DEBUG(prpbar_publicationarticleid);
    
    
    var blkContainer = eWare.GetBlock("container");
    blkContainer.CheckLocks = false;
        
    var blkEntry = eWare.GetBlock("PRBBOSPopup");
    blkEntry.Title = "BBOS Popup";

    // Get the current record for the entry
    var recTrainingArticle;
    if (prpbar_publicationarticleid != -1) {
        recTrainingArticle = eWare.FindRecord("PRPublicationArticle", "prpbar_PublicationArticleID=" + prpbar_publicationarticleid);
    } else {
        // get a new record and edit it.
        recTrainingArticle = eWare.CreateRecord("PRPublicationArticle");

        if (eWare.Mode < Edit) {
            eWare.Mode = Edit;
        }
    }
    blkEntry.ArgObj=recTrainingArticle
   
    
   
    var sListingAction = eWare.URL("PRPublication/PRBBOSPopupListing.asp");

    // Mode Responses
    if ( eWare.Mode == PreDelete ) {
        var qryDelete = eWare.CreateQueryObj("DELETE FROM PRPublicationArticle WHERE prpbar_PublicationArticleID = " + prpbar_publicationarticleid);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
        return;

    } 
    
    if ( eWare.Mode == Save ) {
        if (blkEntry.Validate()) {
            // Fill in some extra fields
            recTrainingArticle.prpbar_PublicationCode = "BBOSPU";

            blkEntry.Execute(recTrainingArticle);
            
            if (prpbar_publicationarticleid == -1)  // this won't happen. Put it here while testing.
                Response.Redirect(sListingAction);
            else
                Response.Redirect(sSummaryAction(prpbar_publicationarticleid));

            return;

        } else {
            // Reset some of the defaults
            blkEntry.GetEntry("prpbar_Name").DefaultValue = String(Request.Form("prpbar_Name"));
            blkEntry.GetEntry("prpbar_PublishDate").DefaultValue = String(Request.Form("prpbar_PublishDate"));
            blkEntry.GetEntry("prpbar_Body").DefaultValue = String(Request.Form("prpbar_Body"));
            eWare.Mode = Edit;
        }
    }
    
    if ( eWare.Mode == Edit ) {
        var fldPublishDate = blkEntry.GetEntry("prpbar_PublishDate");
        fldPublishDate.Required = true;

        var today = new Date();
        var tomorrow = new Date();
        tomorrow.setDate(today.getDate()+1);
        fldPublishDate.DefaultValue =  getDateAsString(tomorrow);

        fld = blkEntry.GetEntry("prpbar_IndustryTypeCode");
        fld.Size = 4;

        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", eWare.URL("PRPublication/PRTrainingArticleListing.asp")));
    }
        
    if ( eWare.Mode == View ) {
        var sDeleteAction;
        if (prpbar_publicationarticleid != -1)
            sDeleteAction = "javascript:if (confirmDelete()) { location.href='" + changeKey(sURL, "em", "3") + "' };" ;
        else
            sDeleteAction = sListingAction;

        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        blkContainer.AddButton(eWare.Button("Delete","delete.gif", sDeleteAction));
        blkContainer.AddButton(eWare.Button("Change","edit.gif", "javascript:document.EntryForm.action='" + sSummaryAction(prpbar_publicationarticleid) + "'; document.EntryForm.submit();"));
    }


	blkContainer.AddBlock(blkContent);
    blkContainer.AddBlock(blkEntry);
    blkContainer.AddBlock(blkInstructions);

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("New"));

%>
    <script type="text/javascript" src="PRBBOSPopup.js"></script>
<%

if ( eWare.Mode == Edit ) {
%>
        <script type="text/javascript" src="../../fckeditor/fckeditor.js"></script>
        <script type="text/javascript" src="../FCKFields.js"></script>
        <script type="text/javascript">FCKFields('prpbar_body');</script>

   <script type="text/javascript">
       function initBBSI() {
           RemoveDropdownItemByName("prpbar_accesslevel", "--None--");
           RemoveDropdownItemByName("prpbar_size", "--None--");
       }
       if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
    </script>
<%    
}
}

function sSummaryAction(PublicationArticleId)
{
    if (String(PublicationArticleId).length > 0)
        return eWare.URL("PRPublication/PRBBOSPopup.asp") + "&prpbar_PublicationArticleID=" + String(PublicationArticleId);
    else
        return eWare.URL("PRPublication/PRBBOSPopup.asp");
}
%>
