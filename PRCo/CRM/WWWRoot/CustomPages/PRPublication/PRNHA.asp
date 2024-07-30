<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012-2018

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
    blkContent.Contents += "<script type=\"text/javascript\" src=\"PRNHA.js\"></script>";

    // TODO: reset these to something reasonable.
    var sSecurityGroups = "1,2,3,4,5,6,10";
    
    var prpbar_publicationarticleid = getIdValue("prpbar_PublicationArticleID");
    DEBUG(prpbar_publicationarticleid);
    
    
    var blkContainer = eWare.GetBlock("container");
    blkContainer.CheckLocks = false;
        
    var blkEntry = eWare.GetBlock("PRNHA");
    blkEntry.Title = "BBOS New Hire Academy Article";
    
    // Get the current record for the entry
    var recNHA;
    if (prpbar_publicationarticleid != -1) {
        recNHA = eWare.FindRecord("PRPublicationArticle", "prpbar_PublicationArticleID=" + prpbar_publicationarticleid);
    } else {
        // get a new record and edit it.
        recNHA = eWare.CreateRecord("PRPublicationArticle");

        if (eWare.Mode < Edit) {
            eWare.Mode = Edit;
        }
    }
    blkEntry.ArgObj=recNHA
    
    
   
    var sListingAction = eWare.URL("PRPublication/PRNHAListing.asp");

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
            recNHA.prpbar_PublicationCode = "NHA";

            if (prpbar_publicationarticleid == -1)
                recNHA.prpbar_Sequence = 999;

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
            recNHA.prpbar_IndustryTypeCode = sPublicationCode;
            
            
            blkEntry.Execute(recNHA);
            
            if (prpbar_publicationarticleid == -1)  // this won't happen. Put it here while testing.
                Response.Redirect(sListingAction);
            else
                Response.Redirect(sSummaryAction(prpbar_publicationarticleid));

            return;

        } else {
            // Reset some of the defaults
            blkEntry.GetEntry("prpbar_Name").DefaultValue = String(Request.Form("prpbar_Name"));
            blkEntry.GetEntry("prpbar_PublishDate").DefaultValue = String(Request.Form("prpbar_PublishDate"));
            blkEntry.GetEntry("prpbar_Abstract").DefaultValue = String(Request.Form("prpbar_Abstract"));
            eWare.Mode = Edit;
        }
    }
    
    var blkContent2 = eWare.GetBlock("Content");
    blkContent2.Contents = "";

    if ( eWare.Mode == Edit ) {
        var fldPublishDate = blkEntry.GetEntry("prpbar_PublishDate");
        fldPublishDate.Required = true;
        fldPublishDate.DefaultValue =  getDateAsString(null);

        blkEntry.GetEntry("prpbar_FileName").Caption = "Video URL";

        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", eWare.URL("PRPublication/PRNHAListing.asp")));

        blkContent2.Contents = "<table>";
        blkContent2.Contents += "\t<tr id='_tr_publication_upload'>";
        blkContent2.Contents += "\t\t<td colspan=4><span id='_DataPublication_Upload'><iframe id='_frmPublication_Upload' style='width:75%; height:150px' frameborder='0' src='PRPublicationUpload.aspx?IsTraining=Y'></iframe></span></td>";
        blkContent2.Contents += "\t</tr>";
        blkContent2.Contents += "</table>";

        var sBBOSChecked = "";
        var sBBOSLumberChecked = "";
        if (prpbar_publicationarticleid == -1) {
            sBBOSChecked = " checked ";
        } else {
            if (recNHA.prpbar_IndustryTypeCode.indexOf(',P,T,S,') > -1) {
                sBBOSChecked = " checked ";
            }

            if (recNHA.prpbar_IndustryTypeCode.indexOf(',L,') > -1) {
                sBBOSLumberChecked = " checked ";
            }
        }
        blkContent2.Contents += "<table style='display:none'><tr id='IndustryCode'><td><span class=VIEWBOXCAPTION><input type=checkbox value=\",P,T,S\" name=cbBBOS id=cbBBOS " + sBBOSChecked + "><label for=cbBBOS>Publish for Produce Users:</label> </span></td><td><span class=VIEWBOXCAPTION> <input type=checkbox value=\",L\" name=cbBBOSLumber id=cbBBOSLumber " + sBBOSLumberChecked + "><label for=cbBBOSLumber>Publish for Lumber Users:</label></span></td></tr></table>";

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

    if (eWare.Mode == View) {
        var blkContent2 = eWare.GetBlock("Content");

        var sBBOSImg = "EmptyCheck.gif";
        var sBBOSLumberImg = "EmptyCheck.gif";
        if (recNHA.prpbar_IndustryTypeCode.indexOf(',P,T,S,') > -1) {
            sBBOSImg = "FilledCheck.gif";
        }

        if (recNHA.prpbar_IndustryTypeCode.indexOf(',L,') > -1) {
            sBBOSLumberImg = "FilledCheck.gif";
        }
        blkContent2.Contents = "<table style='display:none'><tr id='IndustryCode'><td><span class=VIEWBOXCAPTION>Publish for Produce Users:<br/><IMG SRC=\"/CRM/img/Bullets/" + sBBOSImg + "\" HSPACE=0 BORDER=0 ALIGN=TOP></span></td><td><span class=VIEWBOXCAPTION>Publish for Lumber Users:<br/><IMG SRC=\"/CRM/img/Bullets/" + sBBOSLumberImg + "\" HSPACE=0 BORDER=0 ALIGN=TOP></span></td></tr></table>";
    }    
    
    blkContent2.Contents += "\n<script type=\"text/javascript\">";
    blkContent2.Contents += "\n    function initBBSI()";
    blkContent2.Contents += "\n    { ";
    blkContent2.Contents += "\n        AppendRow('_Captprpbar_publishdate', 'IndustryCode', true);";     // Runtime Updates
    blkContent2.Contents += "\n        formLoad('" + eWare.Mode + "'); ";            
    blkContent2.Contents += "\n        document.forms['EntryForm'].onsubmit=Form_OnSubmit;";
    blkContent2.Contents += "\n    } ";
    blkContent2.Contents += "\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }";
    blkContent2.Contents += "\n</script>";
    blkContainer.AddBlock(blkContent2);

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("New"));
}

function sSummaryAction(PublicationArticleId)
{
    if (String(PublicationArticleId).length > 0)
        return eWare.URL("PRPublication/PRNHA.asp") + "&prpbar_PublicationArticleID=" + String(PublicationArticleId);
    else
        return eWare.URL("PRPublication/PRNHA.asp");
}
%>
