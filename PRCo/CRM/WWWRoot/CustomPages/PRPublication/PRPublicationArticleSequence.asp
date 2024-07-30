<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2015

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


/********************************************
  Filename: PRPublicationArticleSequence.asp
  Author:           Tad M. Eness 
********************************************/
function doPage()
{
    // bDebug = true;

    var sql;
    var EditionOptions = [ ];
    var sContents = "";
    var sEditionKeyName = "prpbar_PublicationEditionID";
    
    var prpbar_publicationcode = GetPRPublicationSequenceParam("prpbar_PublicationCode");


    var prpbar_publicationeditionid = GetPRPublicationSequenceParam("prpbar_PublicationEditionID", true);
    if (prpbar_publicationeditionid == -1) {
        prpbar_publicationeditionid = GetPRPublicationSequenceParam("prpbed_PublicationEditionID", true);
        sEditionKeyName = "prpbed_PublicationEditionID";
    }

    var prpbar_categorycode = GetPRPublicationSequenceParam("prpbar_CategoryCode");
    var prpbar_publicationarticleid = GetPRPublicationSequenceParam("prpbar_PublicationArticleID", true);
    var bEnableEditions = (prpbar_publicationcode.toUpperCase() == 'BP');


    var prpbar_mediatypecode = GetPRPublicationSequenceParam("prpbar_MediaTypeCode");
    var prpbar_industrytypecode = GetPRPublicationSequenceParam("prpbar_IndustryTypeCode");


    var sReturnURL = ((F.length > 0) ? eWare.URL(F) : eWare.URL(J));
    
    if (prpbar_publicationcode.length > 0) 
        sReturnURL = changeKey(sReturnURL, "prpbar_PublicationCode", prpbar_publicationcode);


    if (prpbar_publicationeditionid != -1) {
        sReturnURL = changeKey(sReturnURL, sEditionKeyName, prpbar_publicationeditionid);
    }
    
    if (prpbar_categorycode.length > 0)
        sReturnURL = changeKey(sReturnURL, "prpbar_CategoryCode", prpbar_categorycode);

    if (prpbar_publicationarticleid != -1)
        sReturnURL = changeKey(sReturnURL, "prpbar_PublicationArticleID", prpbar_publicationarticleid);

    if ( eWare.Mode < Edit ) {
        eWare.Mode = Edit;
    } else if (eWare.Mode == Save) {
        // DumpFormValues();

        var lst = String(Request.Form.Item("lst_articles"));
        if (lst != "undefined") {
           user_id = eWare.GetContextInfo("User","User_UserId");

            var id = lst.split(",");
            for (var i = 0; i < id.length; i++) {
                sql = "Update PRPublicationArticle SET prpbar_UpdatedBy = " + String(user_id) + ", prpbar_UpdatedDate = GetDate(), prpbar_TimeStamp = GetDate(), prpbar_Sequence = " + String(i + 1) + " Where prpbar_PublicationArticleID = " + String(id[i]);
                var qry = eWare.CreateQueryObj(sql);
                qry.ExecSQL();
            }
        }
    
        Response.Redirect(sReturnURL);
        return;
    }

	// Get the title text
	var sTitle = "Unknown Publication";
	sql = "SELECT dbo.ufn_GetCustomCaptionValue('prpbar_PublicationCode', '" + prpbar_publicationcode + "', 'en-us') As Capt_US";
    var qryCustomCaptions = eWare.CreateQueryObj(sql);
    qryCustomCaptions.SelectSQL();
    if (! qryCustomCaptions.Eof) {
		sTitle = "Sequence " + qryCustomCaptions("Capt_US");
    }
    qryCustomCaptions = null;
    if (sTitle.search(/Articles\s*$/i) < 0) {
		sTitle += " Articles";
	}

    // Create a dropdown with editions (for bp articles)
    if (bEnableEditions) {
		sql = "SELECT prpbed_PublicationEditionID, prpbed_Name FROM PRPublicationEdition WITH (NOLOCK) ORDER BY prpbed_PublicationEditionID DESC";
		var qryEditions = eWare.CreateQueryObj(sql);
		qryEditions.SelectSQL();
		
		while (! qryEditions.eof) {
			EditionOptions.push({value:String(qryEditions("prpbed_PublicationEditionID")), text:String(qryEditions("prpbed_Name"))});
			qryEditions.NextRecord();
		}
		qryEditions = null;

		if (prpbar_publicationeditionid < 0 && EditionOptions.length > 0) {
			prpbar_publicationeditionid = EditionOptions[0].value;
		}
    }

    // Get the records of interest
    if (prpbar_publicationcode == "BP") {
        sql = "SELECT prpbar_PublicationArticleID, Replicate('- ', ISNULL(prpbar_Level, 0)) + ' ' + Coalesce(prpbar_Name, '') AS \"List_Item\", dbo.ufn_GetCustomCaptionValueList('comp_PRIndustryType', prpbar_IndustryTypeCode) As IndustryType  FROM PRPublicationArticle WITH (NOLOCK) "
                    + " WHERE (prpbar_ExpirationDate IS NULL OR  prpbar_ExpirationDate >= GETDATE()) "  
                    + " AND prpbar_PublicationCode IN ('BP', 'BPS')"
                    + " AND prpbar_PublicationEditionID = " + prpbar_publicationeditionid 
                    + " ORDER BY prpbar_Sequence";

    } else {
        sql = "SELECT prpbar_PublicationArticleID, Replicate('- ', ISNULL(prpbar_Level, 0)) + ' ' + Coalesce(prpbar_Name, '') AS \"List_Item\", dbo.ufn_GetCustomCaptionValueList('comp_PRIndustryType', prpbar_IndustryTypeCode) As IndustryType  FROM PRPublicationArticle WITH (NOLOCK) "
                    + " WHERE (prpbar_ExpirationDate IS NULL OR  prpbar_ExpirationDate >= GETDATE()) "  
                    + ((prpbar_publicationcode.length > 0) ? " AND prpbar_PublicationCode='" + prpbar_publicationcode + "'" : "")
                    + ((prpbar_publicationeditionid != -1) ? " AND prpbar_PublicationEditionID = " + prpbar_publicationeditionid : "")
                    + ((prpbar_categorycode.length > 0) ? " AND prpbar_CategoryCode='" + prpbar_categorycode + "'" : "")
                    + ((prpbar_mediatypecode.length > 0) ? " AND prpbar_mediatypecode='" + prpbar_mediatypecode + "'" : "")
                    + ((prpbar_industrytypecode.length > 0) ? " AND prpbar_industrytypecode LIKE'%," + prpbar_industrytypecode + ",%'" : "")
                    + " ORDER BY prpbar_Sequence";
    }
    DEBUG("SQL: " + sql);
    

    Response.Write("<LINK REL=\"stylesheet\" HREF=\"../../prco.css\">");

    if ((prpbar_publicationcode != "TRN") &&
        (prpbar_publicationcode != "NHA")) {
        sContents += "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>This page includes only those articles for the selected publication.  The sequence being set on this page for this publication type is different from the sequence set for news items.</td></tr></table><p></p>"    
    }

    var qryPublicationArticles = eWare.CreateQueryObj(sql);
    qryPublicationArticles.SelectSQL();
    var RecordCount = qryPublicationArticles.RecordCount;
    
    sContents += createAccpacBlockHeader("", sTitle, "100%");
	sContents += "<script type=\"text/javascript\" src='../PRCoGeneral.js'></script>";
	sContents += "<script type=\"text/javascript\" src='PRPublicationArticleSequence.js'></script>";
    sContents += "<script type=\"text/javascript\" src=\"../SelectSequence.js\"></script>"
    
    sContents += "<table width='100%' height='100%'>";

	// Create a dropdown of editions (for blueprints)
    if (bEnableEditions) {
		sContents += "<tr><td width='100%'><span class=\"VIEWBOXCAPTION\" id=\"_Captprbed_edition\">Edition:</span><br /><select id='_prbed_edition' >";
		for (i in EditionOptions) {
			sContents += "<option value='" + EditionOptions[i].value + "'" + (EditionOptions[i].value == prpbar_publicationeditionid ? " selected " : "") + ">" + EditionOptions[i].text + "</option>";
		}
		sContents += "</select></td></tr>";
    }

    // Create a listbox with the items of interest within.
    sContents += "<tr><td width='75%'><select style='width:100%' name=lst_articles size=" + RecordCount + "  multiple=multiple>"

    while (! qryPublicationArticles.eof) {
        sContents += "<option value=" + String(qryPublicationArticles("prpbar_PublicationArticleID")) + ">" + qryPublicationArticles("List_Item");

        if (prpbar_publicationcode == "BBS") {
            sContents += " (" + qryPublicationArticles("IndustryType") + ")";
        }
        
        sContents += "</option>";
        qryPublicationArticles.NextRecord();
    }
    qryPublicationArticles = null;

    sContents += "</select></td><td width='25%'>"
			     + "<button style=\"width:100;\" onclick=\"MoveItem(true, document.forms[0].lst_articles);return false;\">Move Up</button><br>"
			     + "<button style=\"width:100;\" onclick=\"MoveItem(false, document.forms[0].lst_articles);return false;\">Move Down</button>"
		         + "</td></tr>"
		         + "</table></select><input type='hidden' id='hdn_articles' />";
    sContents += createAccpacBlockFooter();

    var blkResequence = eWare.GetBlock("Content");
    blkResequence.contents = sContents;

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.AddBlock(blkResequence);
    
    // Set the buttons
    blkContainer.DisplayButton(Button_Default) = false;
    if (bEnableEditions) {
		var sRefresh = eWare.URL("PRPublication/PRPublicationArticleSequence.asp");
		sRefresh = changeKey(sRefresh, "F", F);
		sRefresh = changeKey(sRefresh, "J", J);
		sRefresh = changeKey(sRefresh, "prpbar_PublicationCode", prpbar_publicationcode);
		blkContainer.AddButton(eWare.Button("Refresh", "refresh.gif", "javascript:RefreshArticleList('" + Server.URLEncode(sRefresh) + "')"));
    }
    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:SelectAllInList(document.EntryForm.lst_articles); document.EntryForm.submit();"));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sReturnURL));

    // Add Block to Container to build screen.
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("New"));
}

function GetPRPublicationSequenceParam(sParamName, bNumeric) {

    // sParamName -- name of parameter to get
    if (bNumeric == undefined)
    {
        bNumeric = false;
    }
    var oParam = Request.QueryString(sParamName);
    
    var result;
    if (String(oParam) == "undefined") {
        result = ((bNumeric == true) ? -1 : "");
    } else {
        var sParam = trim(String(oParam));
        if (bNumeric == true)
        {
            try {
                result =  Number(sParam);
            } catch (e) {
                result = -1;
            }
        } else {
            result = sParam;
        }
    }

    return result;
}
%>
