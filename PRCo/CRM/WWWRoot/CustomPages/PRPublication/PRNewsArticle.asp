<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2018

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
/////////////////////////////////////////////////////////
//Filename: PRnewsArticle.asp
//Author:           Tad M. Eness */
//////////////////////////////////////////////////

doPage();


function doPage()
{
    var fld, i;  // working storage
    var bbos_url, website_url;

    // bDebug = true;
    var blkContent = eWare.GetBlock("Content");
    blkContent.Contents = "<script type=text/javascript src=\"../PRCoGeneral.js\"></script>";
    blkContent.Contents += "<script type=text/javascript src=\"PRNewsArticle.js\"></script>";
    
    // TODO: reset these to something reasonable.
    var sSecurityGroups = "1,2,3,4,5,6,10";
    
    var prpbar_publicationarticleid = getIdValue("prpbar_PublicationArticleID");
    DEBUG(prpbar_publicationarticleid);
    
    
    var blkContainer = eWare.GetBlock("container");
    blkContainer.CheckLocks = false;
        
    var blkEntry = eWare.GetBlock("PRNewsArticleEntry");
    blkEntry.Title = "BBOS News Article";
    
    // Get the current record for the entry
    var recNewsArticle;
    if (prpbar_publicationarticleid != -1) {
        recNewsArticle = eWare.FindRecord("PRPublicationArticle", "prpbar_PublicationArticleID=" + prpbar_publicationarticleid);
    } else {
        // get a new record and edit it.
        recNewsArticle = eWare.CreateRecord("PRPublicationArticle");
        if (eWare.Mode < Edit) {
            eWare.Mode = Edit;
        }
    }
    blkEntry.ArgObj=recNewsArticle
    
    
    // Some constants
    var qry = eWare.CreateQueryObj("Select RTrim(Cast(Capt_US As nvarchar(max))) As Capt_US From Custom_Captions Where Capt_Family = 'BBOS' And Capt_Code = 'URL'");
    qry.SelectSQL();
    if (! qry.Eof) {
		bbos_url = String(qry("Capt_US"));
    }

    qry = eWare.CreateQueryObj("Select RTrim(Cast(Capt_US As nvarchar(max))) As Capt_US From Custom_Captions Where Capt_Family = 'Website' And Capt_Code = 'URL'");
    qry.SelectSQL();
    if (! qry.Eof) {
		website_url = String(qry("Capt_US"));
    }
    qry = null;
    
    var sListingAction = eWare.URL("PRPublication/PRNewsArticleListing.asp");
    
    var sPreviewAction = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "NewsArticle.aspx";
    sPreviewAction = changeKey(sPreviewAction, "ArticleID", String(prpbar_publicationarticleid));
    sPreviewAction = changeKey(sPreviewAction, "Preview", "1");

    // Mode Responses
    if ( eWare.Mode == PreDelete ) {
        var qryDelete = eWare.CreateQueryObj("DELETE FROM PRPublicationArticle WHERE prpbar_PublicationArticleID = " + prpbar_publicationarticleid);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    } else if ( eWare.Mode == Save ) {
        if (blkEntry.Validate()) {
            // Fill in some extra fields
            recNewsArticle.prpbar_PublicationCode = "News";
            recNewsArticle.prpbar_Sequence = 999;
            recNewsArticle.prpbar_News = 'Y';

            var sPublicationCode = "";
            var sIndustryType = new String(Request.Form("cbBBOS"));
            if (sIndustryType != "undefined") {
                sPublicationCode += sIndustryType;
            }

            sIndustryType = new String(Request.Form("cbBBOSLumber"));
            if (sIndustryType != "undefined") {
                sPublicationCode += sIndustryType;
            }

            if (sPublicationCode.length > 0) {
                sPublicationCode += ",";
            }
            recNewsArticle.prpbar_IndustryTypeCode = sPublicationCode;
            
            
            blkEntry.Execute(recNewsArticle);
            
            // need to update any id references in record with the real id.
            var id = String(recNewsArticle("prpbar_PublicationArticleID"));
            var re = /#ID#/gim;
            var bNeedSave = false;
            var sFields = [ "prpbar_Abstract", "prpbar_Body" ];
            for (i = 0; i < sFields.length; i++) {
                var sText = recNewsArticle(sFields[i]);
                if (re.test(sText)) {
                    sText = sText.replace(re, id);
                    bNeedSave = true;
                }
                recNewsArticle(sFields[i]) = sText;
            }
            if (bNeedSave) {
                recNewsArticle.SaveChanges();
            }

            if (prpbar_publicationarticleid == -1)  // this won't happen. Put it here while testing.
                Response.Redirect(sListingAction);
            else
                Response.Redirect(sSummaryAction(prpbar_publicationarticleid));
        } else {
            // Reset some of the defaults
            blkEntry.GetEntry("prpbar_Name").DefaultValue = String(Request.Form("prpbar_Name"));
            blkEntry.GetEntry("prpbar_MembersOnly").DefaultValue = (Request.Form("prpbar_MembersOnly").Count > 0) ? "Y" : "";
            blkEntry.GetEntry("prpbar_RSS").DefaultValue = (Request.Form("prpbar_RSS").Count > 0) ? "Y" : "";
            blkEntry.GetEntry("prpbar_CategoryCode").DefaultValue = String(Request.Form("prpbar_CategoryCode"));
            blkEntry.GetEntry("prpbar_PublishDate").DefaultValue = String(Request.Form("prpbar_PublishDate"));
            blkEntry.GetEntry("prpbar_ExpirationDate").DefaultValue = String(Request.Form("prpbar_ExpirationDate"));
            blkEntry.GetEntry("prpbar_Abstract").DefaultValue = String(Request.Form("prpbar_Abstract"));
            blkEntry.GetEntry("prpbar_Body").DefaultValue = String(Request.Form("prpbar_Body"));
            eWare.Mode = Edit;
        }
    }
    
    if ( eWare.Mode == Edit ) {
        var fldViewCount = blkEntry.GetEntry("prpbar_ViewCount");
        fldViewCount.Hidden = true;
        
        var fldPublishDate = blkEntry.GetEntry("prpbar_PublishDate");
        fldPublishDate.Required = true;

        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", eWare.URL("PRPublication/PRNewsArticleListing.asp")));
        
    } else if ( eWare.Mode == View ) {
        var sDeleteAction;
        if (prpbar_publicationarticleid != -1)
            sDeleteAction = "javascript:if (confirmDelete()) { location.href='" + changeKey(sURL, "em", "3") + "' };" ;
        else
            sDeleteAction = sListingAction;

        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        blkContainer.AddButton(eWare.Button("Preview ","componentpreview.gif", "javascript:previewArticle('" + sPreviewAction.replace("'", "''") + "')"));
        blkContainer.AddButton(eWare.Button("BBOS","componentpreview.gif", "javascript:openBBOS('" + bbos_url.replace("'", "''") + "')"));
        blkContainer.AddButton(eWare.Button("Delete","delete.gif", sDeleteAction));
        blkContainer.AddButton(eWare.Button("Change","edit.gif", "javascript:document.EntryForm.action='" + sSummaryAction(prpbar_publicationarticleid) + "'; document.EntryForm.submit();"));
        blkContainer.AddButton(eWare.Button("Associate Company","new.gif", eWare.URL("PRPublication/PRPublicationArticleCompany.asp") + "&prpbarc_PRPublicationArticleCompanyId=-1&prpbar_PublicationArticleId="+ prpbar_publicationarticleid));
        
        Session("PublicationArticleCompanyReturn") = sURL;
    }


	blkContainer.AddBlock(blkContent);
    blkContainer.AddBlock(blkEntry);

    if (eWare.Mode == View) {
        var blkContent2 = eWare.GetBlock("Content");

        var sBBOSImg = "EmptyCheck.gif";
        var sBBOSLumberImg = "EmptyCheck.gif";
        if (recNewsArticle.prpbar_IndustryTypeCode.indexOf(',P,T,S,') > -1) {
            sBBOSImg = "FilledCheck.gif";
        }

        if (recNewsArticle.prpbar_IndustryTypeCode.indexOf(',L,') > -1) {
            sBBOSLumberImg = "FilledCheck.gif";
        }
        blkContent2.Contents = "<table style='display:none'><tr id='IndustryCode'><td><span class=VIEWBOXCAPTION>Publish for Produce Users:<br/><IMG SRC=\"/CRM/img/Bullets/" + sBBOSImg + "\" HSPACE=0 BORDER=0 ALIGN=TOP></span></td><td><span class=VIEWBOXCAPTION>Publish for Lumber Users:<br/><IMG SRC=\"/CRM/img/Bullets/" + sBBOSLumberImg + "\" HSPACE=0 BORDER=0 ALIGN=TOP></span></td></tr></table>";

        blkContent2.Contents += "\n<script type=\"text/javascript\">";
        blkContent2.Contents += "\n    function initBBSI()";
        blkContent2.Contents += "\n    {";
        blkContent2.Contents += "\n        AppendRow('_Captprpbar_abstract', 'IndustryCode', true);";     // Runtime Updates
        blkContent2.Contents += "\n    }";
        blkContent2.Contents += "\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }";
        blkContent2.Contents += "\n</script>";
        blkContainer.AddBlock(blkContent2);
        
        
        var grdCompanies = eWare.GetBlock("PRPublicationArticleCompanyGrid");
        grdCompanies.ArgObj = "prpbarc_PublicationArticleID = " + prpbar_publicationarticleid;
        grdCompanies.PadBottom = false;
        blkContainer.AddBlock(grdCompanies);
        
    }    
    
    if (eWare.Mode == Edit) {
	    var blkContent2 = eWare.GetBlock("Content");

	    var sBBOSChecked = "";
	    var sBBOSLumberChecked = "";
	    if (prpbar_publicationarticleid == -1) {
	        sBBOSChecked = " checked ";
	    } else {
            if (recNewsArticle.prpbar_IndustryTypeCode.indexOf(',P,T,S,') > -1) {
                sBBOSChecked = " checked ";
            }

            if (recNewsArticle.prpbar_IndustryTypeCode.indexOf(',L,') > -1) {
                sBBOSLumberChecked = " checked ";
            }
	    }


	    blkContent2.Contents = "<table style='display:none'><tr id='IndustryCode'><td><span class=VIEWBOXCAPTION><label for=cbBBOS>Publish for Produce Users:</label><br/><input type=checkbox value=\",P,T,S\" name=cbBBOS id=cbBBOS onclick=toggleRSS(); " + sBBOSChecked + "> </span></td><td><span class=VIEWBOXCAPTION><label for=cbBBOSLumber>Publish for Lumber Users:</label><br/><input type=checkbox value=\",L\" name=cbBBOSLumber id=cbBBOSLumber onclick=toggleRSS(); " + sBBOSLumberChecked + "></span></td></tr></table>";
        blkContent2.Contents += "<table style='display:none'><tr id='LinkMsg'><td colspan=3 class=VIEWBOXCAPTION align=center>When adding a link to an external web site, use the following<br />format to ensure we track when users click on these links:<br /><strong>&lta href='ExternalLink.aspx?BBOSID=#ID#&BBOSType=PA&BBOSURL=http://[insert url here]' target='_blank' /&gt;[Insert words for your hyperlink here]&lt;/a&gt;</strong></td></tr></table>";

        blkContent2.Contents += "\n<script type=\"text/javascript\">";
        blkContent2.Contents += "\n    function initBBSI()";
        blkContent2.Contents += "\n    {";
        blkContent2.Contents += "\n       NewsArticleFormUpdates();";
        blkContent2.Contents += "\n    }";
        blkContent2.Contents += "\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }";
        blkContent2.Contents += "\n</script>";
        blkContainer.AddBlock(blkContent2);
    }
    
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("New"));
}

function sSummaryAction(PublicationArticleId)
{
    if (String(PublicationArticleId).length > 0)
        return eWare.URL("PRPublication/PRNewsArticle.asp") + "&prpbar_PublicationArticleID=" + String(PublicationArticleId);
    else
        return eWare.URL("PRPublication/PRNewsArticle.asp");
}
%>
