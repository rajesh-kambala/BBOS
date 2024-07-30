<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2023

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
    //bDebug = true;
    
    var fld;  // working storage for fields

    var prpbar_publicationarticleid = getIdValue("prpbar_PublicationArticleID");
    if ((prpbar_publicationarticleid == -1) && (eWare.Mode < Edit)) {
        eWare.Mode = Edit;
    }

    var sBorder = (eWare.Mode == Edit) ? "1px" : "0px";
    
    var blkContent = eWare.GetBlock("Content");
    blkContent.Contents = "";
    blkContent.Contents += "<script type=\"text/javascript\" src=\"PRPublicationArticle.js\"></script>";
    blkContent.Contents += "<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";

    blkContent.Contents += "<table style=\"display:none\">";
    blkContent.Contents += "<tr id=\"_tr_PublicationTopics\">";
    blkContent.Contents += "<td id=\"_td_Spacer\">&nbsp;</td>";
    blkContent.Contents += "<td valign=\"top\" rowspan=\"20\" id=\"_td_PublicationTopics\">";
    blkContent.Contents += "<input id=\"HIDDEN_PUBTOPICS\" name=\"HIDDEN_PUBTOPICS\" type=\"hidden\" value=\"\"/>";
    blkContent.Contents += "<table border=\"" + sBorder + "\" cellspacing=\"0\" cellpadding=\"1\" >";
    blkContent.Contents += "<tr><td style=white-space:nowrap;>";
    //blkContent.Contents += LoadTopicList(prpbar_publicationarticleid, eWare.Mode);
    blkContent.Contents += "</td></tr></table></td></tr></table>";

    // TODO: reset these to something reasonable.
    var sSecurityGroups = "1,2,3,4,5,6,10";

    var blkContainer = eWare.GetBlock("container");
    blkContainer.CheckLocks = false;

    var blkEntry = eWare.GetBlock("PRPublicationArticleEntry");
    blkEntry.Title = "Publication Article";
    
    var blkError;
    var bError = false;
    var sErrMsg;
    var blkCoverArt;

    var isBluePrintsArticle = false;
    var blueprintsEditionID;
    
    var recPublicationArticle;
    if (prpbar_publicationarticleid != -1) {
        recPublicationArticle = eWare.FindRecord("PRPublicationArticle", "prpbar_PublicationArticleID=" + prpbar_publicationarticleid);
        
        if ((recPublicationArticle("prpbar_PublicationEditionID") > 0) &&
            (recPublicationArticle("prpbar_PublicationCode") != "BPO")) {
            isBluePrintsArticle = true;
            blueprintsEditionID = recPublicationArticle("prpbar_PublicationEditionID");
        }

    } else {
        recPublicationArticle = eWare.CreateRecord("PRPublicationArticle");

        if (getIdValue("prpbed_PublicationEditionID") != -1) {
            isBluePrintsArticle = true;
            blueprintsEditionID = getIdValue("prpbed_PublicationEditionID");
        }
    }

    var recBluePrintsEdition = null;
    if (isBluePrintsArticle) {
        recBluePrintsEdition = eWare.FindRecord("PRPublicationEdition", "prpbed_PublicationEditionID=" + blueprintsEditionID);
    }

    // Some constants
    var sDeleteAction = changeKey(eWare.URL("PRPublication/PRPublicationArticle.asp"), "em", "3");
    var sListingAction = eWare.URL("PRPublication/PRPublicationArticleListing.asp");
    if (isBluePrintsArticle) {
        sListingAction = eWare.URL("PRPublication/PRPublicationEdition.asp") + "&prpbed_PublicationEditionID=" + blueprintsEditionID;
    }


    if (eWare.Mode == Save) {
        // Handle the custom Industry Type checkboxes
        var sIndustryCodes = "";
        var sIndustryType = new String(Request.Form("cbBBOS"));
        if (sIndustryType != "undefined") {
            sIndustryCodes += sIndustryType;
        }

        sIndustryType = new String(Request.Form("cbBBOSLumber"));
        if (sIndustryType != "undefined") {
            sIndustryCodes += sIndustryType;
        }

        if (sIndustryCodes.length > 0) {
            sIndustryCodes += ",";
        }
    
    
        // Validate the name to be unique within the publication type.
        // If type == Blueprints, then must be unique within the edition as well
        var sName = (Request.Form("prpbar_Name").Count > 0 ? String(Request.Form("prpbar_Name")) : "");
		var sPubCode = (Request.Form("prpbar_PublicationCode").Count > 0 ? String(Request.Form("prpbar_PublicationCode")) : "");
        var sEditionID = (Request.Form("prpbar_PublicationEditionID").Count > 0 ? String(Request.Form("prpbar_PublicationEditionID")) : "");
		sEditionID = (sEditionID > 0 ? sEditionID : -1);

        // Note: Added the Industry Type to this dup name check. Currently in practice there is P,T,S and L.  If the P,T,S is 
        // ever allowed to be split up, this SQL will need to be addressed.  - CHW 12/29/09
		sql = "SELECT Count(1) As Cnt " +
		        "FROM PRPublicationArticle WITH (NOLOCK) " +
		       "WHERE prpbar_Name = '" + sName.replace(/\'/g, "''") + "' " +
		         "AND prpbar_PublicationCode = '" + sPubCode + "' " +
		         "AND prpbar_IndustryTypeCode = '" + sIndustryCodes + "'";
		         
        if (sPubCode.toUpperCase() == "BP") {
            sql += " And prpbar_PublicationEditionID = " + sEditionID;
        }
        sql += " And prpbar_PublicationArticleID != " + String(prpbar_publicationarticleid);
        
        qry = eWare.CreateQueryObj(sql);
        qry.SelectSQL();
        var cnt = Number(qry("Cnt"));
        if (cnt > 0) {
            bError = true;
            sErrMsg = getErrorHeader("The article name must be unique within the publication type.");
        }
        
        // Check the Cover art file name for uniquness. must be unique Accross Publication type and edition (if edition == blueprints)
        var sCoverArtFileName = String(Request.Form("prpbar_CoverArtFileName"));
        sCoverArtFileName = (sCoverArtFileName != "undefined") ? trim(sCoverArtFileName) : "";
        if (sCoverArtFileName.length > 0) {
            var sql = "Select Count(1) As Cnt From PRPublicationArticle WITH (NOLOCK) Inner Join PRPublicationEdition WITH (NOLOCK) On (prpbar_PublicationEditionID = prpbed_PublicationEditionID) Where prpbar_CoverArtFileName = '" + sCoverArtFileName + "' And prpbed_PublicationCode = '" + sPubCode + "' And prpbar_PublicationArticleID != " + String(prpbar_publicationarticleid);
            if (sPubCode.toUpperCase() == "BP") {
                sql += " And prpbar_PublicationEditionID = " + sEditionID;
            }
            qry.SelectSQL();
            cnt = qry("Cnt");
            if (cnt > 0) {
                bError = true;
                sErrMsg += getErrorHeader(Server.HTMLEncode("Cover Art Filename must be unique within the publication type (and Edition if publication type is 'Blueprints')"));
            }
        }


        if (! bError) {

            sMsg = blkEntry.Execute(recPublicationArticle);

            recPublicationArticle.prpbar_IndustryTypeCode = sIndustryCodes;
            
            if(recPublicationArticle.prpbar_publicationcode == "BPFB" || recPublicationArticle.prpbar_publicationcode == "BPFBS")
            {
                var sFileName = (recPublicationArticle.prpbar_FileName != "undefined") ? recPublicationArticle.prpbar_FileName.toLowerCase() : "";
                if(sFileName.substring(0,4) == "http")
                {
                    recPublicationArticle.prpbar_MediaTypeCode = "URL";
                }
            }

            recPublicationArticle.SaveChanges();

            var id = String(recPublicationArticle("prpbar_PublicationArticleID"));
            if (! isEmpty(id)) {
                SavePublicationTopics(id);
                Response.Redirect(changeKey(eWare.URL(J), "prpbar_PublicationArticleID", String(id)));
                
            } else {
                // populate the fields and indicate an error
                // Do not do this because regular eware validation errors were problematic
                //bError = true;
                //sErrMsg += "Error while saving Article";
            }
        }
        if (bError) {
            blkError = eWare.GetBlock('content');
            blkError.Contents = sErrMsg;
            eWare.Mode = Edit;
        }
    }

    blkEntry.ArgObj=recPublicationArticle;

    var blkContent2 = eWare.GetBlock("Content");
    blkContent2.Contents = "";

    blkEntry.GetEntry("prpbar_CategoryCode").LookUpFamily = "prpbar_CategoryCodeBBS";

    if (eWare.Mode == PreDelete) {
        if (prpbar_publicationarticleid > 0) {

            // Delete the record from the database, prpbar_PublicationArticleID
            sql = "Delete From PRPublicationArticle Where prpbar_PublicationArticleID = " + prpbar_publicationarticleid;
            qry = eWare.CreateQueryObj(sql);
            qry.ExecSql();
        }
        Response.Redirect(sListingAction);

    } else if (eWare.Mode == Edit) {


        var fldBPEdition = blkEntry.GetEntry("prpbar_PublicationEditionID");

        if (prpbar_publicationarticleid == -1) {
            // New record, default the level
            fld = blkEntry.GetEntry("prpbar_Level");
            fld.DefaultValue = 1;
            
            if (isBluePrintsArticle) {
                fldBPEdition.DefaultValue = blueprintsEditionID;
            }
        }


        var fldPublicationCode = blkEntry.GetEntry("prpbar_PublicationCode");
        fldPublicationCode.AllowBlank = false;
        if (isBluePrintsArticle) {
            fldPublicationCode.LookUpFamily = "BluePrintsPublicationCode";
        } else {
            fldPublicationCode.LookUpFamily = "GeneralPublicationCode";
        }

        var fldCommunicationLanguage = blkEntry.GetEntry("prpbar_CommunicationLanguage");
        fldCommunicationLanguage.AllowBlank = false;
        fldCommunicationLanguage.DefaultValue = "E";

        
        if (isBluePrintsArticle) {
            blkEntry.GetEntry("prpbar_PublishDate").hidden = true;
            blkEntry.GetEntry("prpbar_Level").hidden = true;
        } else {
            fldBPEdition.hidden = true;
        }

        if (recPublicationArticle.prpbar_publicationcode != "BBR") {
            blkEntry.GetEntry("prpbar_MediaTypeCode").Hidden = true;
        } else {
            var fldMediaType = blkEntry.GetEntry("prpbar_MediaTypeCode");
            fldMediaType.DefaultValue = "Doc";
            fldMediaType.AllowBlank = false;
        }

        blkEntry.GetEntry("prpbar_Abstract").Size = 125;

        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", sListingAction));

  } else if (eWare.Mode == View) {

        var qry = eWare.CreateQueryObj("SELECT RTrim(Cast(Capt_US As nvarchar(max))) As Capt_US FROM Custom_Captions WHERE Capt_Family = 'BBOS' And Capt_Code = 'URL'");
        qry.SelectSQL();
        if (!qry.Eof) {
            bbos_url = String(qry("Capt_US"));
        }

        if (recPublicationArticle.prpbar_publicationcode != "BBR") {
            blkEntry.GetEntry("prpbar_MediaTypeCode").Hidden = true;
        }

        //var fldCatCode = blkEntry.GetEntry("prpbar_CategoryCode");
        //fldCatCode.Hidden = true;

        blkContainer.DisplayButton(Button_Default) = false;

        var sPreviewAction = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "GetPublicationFile.aspx?PublicationArticleID=" + prpbar_publicationarticleid;
        blkContainer.AddButton(eWare.Button("Preview ","componentpreview.gif", sPreviewAction + "\" target=\"_blank"));

        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        sDeleteAction = changeKey(sDeleteAction, "prpbar_PublicationArticleID", prpbar_publicationarticleid);
        blkContainer.AddButton(eWare.Button("Delete","delete.gif", sDeleteAction));
        blkContainer.AddButton(eWare.Button("Change", "edit.gif", "javascript:document.EntryForm.action='" + sSummaryAction(prpbar_publicationarticleid) + "'; document.EntryForm.submit();"));

        if ((recPublicationArticle.prpbar_publicationcode == "BP") ||
            (recPublicationArticle.prpbar_publicationcode == "BPS")||
            (recPublicationArticle.prpbar_publicationcode == "BPO")) {
            blkContainer.AddButton(eWare.Button("Associate Company","new.gif", eWare.URL("PRPublication/PRPublicationArticleCompany.asp") + "&prpbarc_PRPublicationArticleCompanyId=-1&prpbar_PublicationArticleId="+ prpbar_publicationarticleid));
            Session("PublicationArticleCompanyReturn") = sURL;
        }
        
        if (isBluePrintsArticle) {
            blkEntry.GetEntry("prpbar_PublishDate").hidden = true;
            blkEntry.GetEntry("prpbar_Level").hidden = true;
        }

        if ((recPublicationArticle.prpbar_publicationcode == "BP") ||
            (recPublicationArticle.prpbar_publicationcode == "BPS")) {
            blkEntry.GetEntry("prpbar_CoverArtFileName").hidden = true;
            blkEntry.GetEntry("prpbar_CoverArtThumbFileName").hidden = true;
        }

        if ((recPublicationArticle.prpbar_publicationcode == "BPFB") ||
            (recPublicationArticle.prpbar_publicationcode == "BPFBS")) {
            blkEntry.GetEntry("prpbar_CoverArtThumbFileName").hidden = true;
        }

        
        if (recPublicationArticle.prpbar_publicationcode == "BBS") {
            var sBBOSImg = "EmptyCheck.gif";
            var sBBOSLumberImg = "EmptyCheck.gif";

            if (recPublicationArticle.prpbar_IndustryTypeCode.indexOf(',P,T,S,') > -1) {
                sBBOSImg = "FilledCheck.gif";
            }

            if (recPublicationArticle.prpbar_IndustryTypeCode.indexOf(',L,') > -1) {
                sBBOSLumberImg = "FilledCheck.gif";
            }
            blkContent2.Contents += "<table style='display:none'><tr id='IndustryCode'><td><span class=VIEWBOXCAPTION>Publish for Produce Users:<br/><IMG SRC=\"/CRM/img/Bullets/" + sBBOSImg + "\" HSPACE=0 BORDER=0 ALIGN=TOP></span></td></tr><tr id='IndustryCode2'><td><span class=VIEWBOXCAPTION>Publish for Lumber Users:<br/><IMG SRC=\"/CRM/img/Bullets/" + sBBOSLumberImg + "\" HSPACE=0 BORDER=0 ALIGN=TOP></span></td></tr></table>";
        } else {
            blkEntry.GetEntry("prpbar_CommunicationLanguage").hidden = true;
            blkEntry.GetEntry("prpbar_CategoryCode").hidden = true;
        }


        if (recPublicationArticle.ItemAsString("prpbar_CoverArtFileName").length > 0) {
            blkCoverArt = eWare.GetBlock("Content");
            blkCoverArt.NewLine = false;
            blkCoverArt.Width = "220px";
            blkCoverArt.Contents = createAccpacBlockHeader("CoverArt", "Cover Art", "220px");
            blkCoverArt.Contents += "<table><tr>";

            var sImgURL = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "LearningCenter/" + recPublicationArticle("prpbar_CoverArtFileName")
            blkCoverArt.Contents += "<td><img src = \"" + sImgURL + "\" /></td>";

            if (recPublicationArticle.ItemAsString("prpbar_CoverArtThumbFileName").length > 0) {
                sImgURL = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "LearningCenter/" + recPublicationArticle("prpbar_CoverArtThumbFileName")
                blkCoverArt.Contents += "<td><img src = \"" + sImgURL + "\" /></td>";
            }

            blkCoverArt.Contents += "</tr></table>";
            blkCoverArt.Contents += createAccpacBlockFooter();
        }

        if ((recPublicationArticle.prpbar_publicationcode == "BP")  ||
            (recPublicationArticle.prpbar_publicationcode == "BPS") ||
            (recPublicationArticle.prpbar_publicationcode == "BPO")) {

            var grdCompanies = eWare.GetBlock("PRPublicationArticleCompanyGrid");
            grdCompanies.ArgObj = "prpbarc_PublicationArticleID = " + prpbar_publicationarticleid;
            grdCompanies.PadBottom = false;
        }            
    }
 
    if (blkError) {
        blkContainer.AddBlock(blkError);
    }   
    blkContainer.AddBlock(blkContent);
    blkContainer.AddBlock(blkEntry);
    
    if (blkCoverArt) {
        blkContainer.AddBlock(blkCoverArt);
    }
    
    if (eWare.Mode == Edit) {



        blkContent2.Contents += "<table>";
        blkContent2.Contents += "\t<tr id='_tr_publication_upload'>";
        blkContent2.Contents += "\t\t<td colspan=2><span id='_DataPublication_Upload'><iframe id='_frmPublication_Upload' style='width:750px; height:150px' frameborder='0' src='PRPublicationUpload.aspx'></iframe></span></td>";
        blkContent2.Contents += "\t</tr>";
        blkContent2.Contents += "</table>";

        var sBBOSChecked = "";
        var sBBOSLumberChecked = "";
        if (prpbar_publicationarticleid == -1) {
            sBBOSChecked = " checked ";
        } else {
            if (recPublicationArticle.prpbar_IndustryTypeCode.indexOf(',P,T,S,') > -1) {
                sBBOSChecked = " checked ";
            }

            if (recPublicationArticle.prpbar_IndustryTypeCode.indexOf(',L,') > -1) {
                sBBOSLumberChecked = " checked ";
            }
        }
        blkContent2.Contents += "<table style='display:none'><tr id='IndustryCode'><td><span class=VIEWBOXCAPTION><input type=checkbox value=\",P,T,S\" name=cbBBOS id=cbBBOS " + sBBOSChecked + "><label for=cbBBOS>Publish for Produce Users:</label> </span></td></tr><tr id='IndustryCode2'><td><span class=VIEWBOXCAPTION> <input type=checkbox value=\",L\" name=cbBBOSLumber id=cbBBOSLumber " + sBBOSLumberChecked + "><label for=cbBBOSLumber>Publish for Lumber Users:</label></span></td></tr></table>";

        if (isBluePrintsArticle) {
            blkContent2.Contents += "<input type=\"hidden\" id=\"FPFBSCount\" value =\"" + GetArticleCount("BPFBS", blueprintsEditionID) + "\">"
            blkContent2.Contents += "<input type=\"hidden\" id=\"prpbed_name\" value =\"" + recBluePrintsEdition("prpbed_Name") + "\">"
        }        
    }
    
    blkContent2.Contents += "\n<script type=\"text/javascript\">";
    blkContent2.Contents += "\n    function initBBSI()";
    blkContent2.Contents += "\n    { ";
    blkContent2.Contents += "\n        document.forms['EntryForm'].onsubmit=Form_OnSubmit;";
    blkContent2.Contents += "\n        PublicationArticleFormUpdates(" + eWare.Mode + "); ";

    if (eWare.Mode == Edit) {
        blkContent2.Contents += "\n        RemoveDropdownItemByName('prpbar_communicationlanguage', '--None--');";
    }

    if(prpbar_publicationarticleid == -1) {
        blkContent2.Contents += "\n   bIsNew = true;";
    }

    blkContent2.Contents += "\n    } ";
    blkContent2.Contents += "\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }";
    blkContent2.Contents += "\n</script>";
    
   	blkContainer.AddBlock(blkContent2);
   	
   	if ((eWare.Mode == View) &&
        ((recPublicationArticle.prpbar_publicationcode == "BP") ||
         (recPublicationArticle.prpbar_publicationcode == "BPS") ||
         (recPublicationArticle.prpbar_publicationcode == "BPO"))) {
        blkContainer.AddBlock(grdCompanies);
    }   	

    if ((eWare.Mode == View) &&
        (!isBluePrintsArticle)) {
        blkEntry.GetEntry("prpbar_PublicationEditionID").Hidden = true;
    }
   	
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("New"));
}

function sSummaryAction(PublicationArticleId)
{
    if (String(PublicationArticleId).length > 0)
        return eWare.URL("PRPublication/PRPublicationArticle.asp") + "&prpbar_PublicationArticleID=" + String(PublicationArticleId);
    else
        return eWare.URL("PRPublication/PRPublicationArticle.asp");
}

// Create a table of publication topics to be inserted into the page.
function LoadTopicList(PublicationArticleID, Mode)
{
    var sTopicList;
    var qry;
    var sBorder = (Mode == Edit) ? "1px" : "0px";
    var sScrollStyle = (Mode == Edit) ? "overflow:scroll;" : "";
    var sHeight = (Mode == Edit) ? "400px" : "200px";

    sPubTopicTable = "\n<div style=\"height:" + sHeight + ";width:250px;" + sScrollStyle + "\">\n<table width=\"100%\" ID=\"_PublicationTopicListing\" " + 
                "onclick='TopicList_OnClick();' class=\"CONTENT\" border=\"" + sBorder + "\" cellspacing=\"0\" cellpadding=\"1\" bordercolordark=\"#ffffff\" bordercolorlight=\"#ffffff\"> "+
                "\n<thead><tr><td class=\"GRIDHEAD\" width=\"100%\" white-space:nowrap;>Publication Topics</td></tr></thead><tbody>\n";
    sTableFooter = "\n</tbody></table>\n</div>";

    if (Mode != Edit) {
        sTopicList = "";
        qry = eWare.CreateQueryObj("Select prpbt_Name From PRPublicationTopic Inner Join PRPublicationArticleTopic On (prpbart_PublicationTopicID = prpbt_PublicationTopicID) And prpbart_PublicationArticleID = " + PublicationArticleID);
        qry.SelectSQL();
        while (! qry.eof) {
            sTopicList += "<tr><td><span class=VIEWBOX style=white-space:nowrap;>" + qry("prpbt_Name") + "</span></td></tr>";
            qry.NextRecord();
        }
        sTopicList = sPubTopicTable + sTopicList + sTableFooter;
    } else {
        var oTopicNode;                                     // Current topic read from the database
        var oTopicList = new TopicNode(0, null, "Master List", 0, false, false);   // Holds the master list.
        var ParentTopics = [ oTopicList ];              // Current Parents
        var CurrTopics = new Array();                   // Current Topics at this level
        var CurrLevel = 1;

        var sql = "Select prpbt_PublicationTopicID, prpbt_Level, coalesce(prpbt_ParentID, 0) As prpbt_ParentID, prpbt_Name, prpbart_PublicationArticleTopicID From PRPublicationTopic WITH (NOLOCK) Left Outer Join PRPublicationArticleTopic WITH (NOLOCK) On (prpbart_PublicationTopicID = prpbt_PublicationTopicID And prpbart_PublicationArticleID = " + PublicationArticleID + ") Order By prpbt_Level";
        qry = eWare.CreateQueryObj(sql);
        qry.SelectSQL();
        while (! qry.eof) {
            var recTopicID = Number(qry("prpbt_PublicationTopicID"));
            var recLevel = Number(qry("prpbt_Level"));
            var recParentID = Number(qry("prpbt_ParentID"));
            var recName = String(qry("prpbt_Name"));
            var bChecked = ! isEmpty(qry("prpbart_PublicationArticleTopicID"));

            if (recLevel != CurrLevel) {
                SortTopics(ParentTopics);
                ParentTopics = CurrTopics;
                CurrTopics = new Array();
                CurrLevel = recLevel;
            }

            try {
	            oTopicNode = new TopicNode(recTopicID, recParentID, recName, recLevel, bChecked, ParentTopics[recParentID].Checked);
                ParentTopics[recParentID].Children[recTopicID] = oTopicNode;
            } catch (e) {
                // Do nothing if there is a broken link in the input data.
            }
            CurrTopics[recTopicID] = oTopicNode;

            qry.NextRecord();
        }
        // Sort the last level
        SortTopics(ParentTopics);

        oRowClass = new Object;  // Objects are passed by reference
        oRowClass.Name = "ROW1";
        sTopicList = sPubTopicTable + CreateTopicList(oTopicList.Children, 1, oRowClass) + sTableFooter;
    }
    return sTopicList;
}

// This function will sort an array of topic nodes alphabetically
function SortTopics(aTopicList) {
	var i, j;
	var temp;
	
    for (i in aTopicList) {
		// first, close up the gaps in the list
		temp = [ ];
		for (j in aTopicList[i].Children) {
			temp.push(aTopicList[i].Children[j]);
		}
		aTopicList[i].Children = temp;
        aTopicList[i].Children.sort(function(a, b) { if (a.Name.toLowerCase() < b.Name.toLowerCase()) return -1; if (a.Name.toLowerCase() > b.Name.toLowerCase()) return 1; return 0; });
    }
}

function CreateTopicList(aTopicList, nLevel, oRowClass) {
    if (aTopicList.length < 1) return "";

    var i;
    var sSpaces = "";
    for (i = 0; i < nLevel; i++) {
        sSpaces += "&nbsp;&nbsp;&nbsp;&nbsp;";
    }
    
    var sTopicList = "";
    for (i in aTopicList) {
        sTopicList += "<tr id='_PTRow_" + String(aTopicList[i].TopicID) + "' class='" + oRowClass.Name + "'>\n";
        sTopicList += "\t<td id='_PTData_" + String(aTopicList[i].TopicID) + "'>" + sSpaces + "<input type='checkbox' class='smallcheck' " + ((aTopicList[i].Checked)? "checked " : "") + ((aTopicList[i].Disabled) ? "disabled " : "") + "id='_PTSelect_" + String(aTopicList[i].TopicID) + "_" + String(aTopicList[i].Level) + "' value='" + aTopicList[i].TopicID + "' />";
        sTopicList += "<span id='_PTDisplay_" + String(aTopicList[i].TopicID) + "'>" + aTopicList[i].Name;
        sTopicList += "</span></td>\n</tr>\n";
        oRowClass.Name = (oRowClass.Name == "ROW1") ? "ROW2" : "ROW1";
        sTopicList += CreateTopicList(aTopicList[i].Children, nLevel + 1, oRowClass);
    }
    return sTopicList;
}

function TopicNode(nTopicID, nParentID, sTopicName, nLevel, bChecked, bDisabled)
{
    this.TopicID = nTopicID;
    this.ParentID = nParentID;
    this.Name = sTopicName;
    this.Level = nLevel;
    this.Checked = bChecked;
    this.Disabled = bDisabled;
    this.Children = new Array();
}

function SavePublicationTopics(PublicationArticleID)
{
	if (PublicationArticleID < 1) {
        throw "SavePublicationTopics - Invalid PublicationArticleID";
    }

    // Hidden_pubtopics holds a comma delimited array of id's that are checked.
    var sql;
    var qry;
    var sPubTopics = String(Request.Form("HIDDEN_PUBTOPICS"));

    sPubTopics = sPubTopics.replace(/^\s*/, "").replace(/\s*$/, "");
    if (sPubTopics.length > 0 && sPubTopics != "undefined") {
        var aPubTopics = String(sPubTopics).split(",");
        
        // Delete all items that don't belong
        sql = "Delete From PRPublicationArticleTopic Where prpbart_PublicationArticleID = " + String(PublicationArticleID) + " And prpbart_PublicationTopicID Not In (" + sPubTopics + ");";
        qry = eWare.CreateQueryObj(sql);
        qry.ExecSQL();
        
        // Add items that need to be added
        for (i = 0; i < aPubTopics.length; i++) {
            var recPubArtTopic = eWare.FindRecord("PRPublicationArticleTopic", "prpbart_PublicationArticleID = " + String(PublicationArticleID) + " And prpbart_PublicationTopicID = " + aPubTopics[i]);
            if (recPubArtTopic.eof) {
                recPubArtTopic = eWare.CreateRecord("PRPublicationArticleTopic");
            }
            recPubArtTopic("prpbart_PublicationArticleID") = PublicationArticleID;
            recPubArtTopic("prpbart_PublicationTopicID") = aPubTopics[i];
            recPubArtTopic.SaveChanges();
        }
    } else {
        // All items are unchecked, delete these from the database.
        sql = "Delete From PRPublicationArticleTopic Where prpbart_PublicationArticleID = " + String(PublicationArticleID);
        qry = eWare.CreateQueryObj(sql);
        qry.ExecSQL();
    }
}



function GetArticleCount(publicationCode, editionID)
{
    var qry = eWare.CreateQueryObj("SELECT COUNT(1) as CNT FROM PRPublicationArticle WITH (NOLOCK) WHERE prpbar_PublicationCode='" + publicationCode + "' AND prpbar_PublicationEditionID=" + editionID);
    qry.SelectSQL();
    return qry("CNT");
}
%>