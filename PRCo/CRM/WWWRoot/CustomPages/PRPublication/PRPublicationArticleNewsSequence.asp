<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2015

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
    // bDebug = true;

    var sql;
    var EditionOptions = [ ];
    var sContents = "";
    var sEditionKeyName = "prpbar_PublicationEditionID";
    var sReturnURL = ((F.length > 0) ? eWare.URL(F) : eWare.URL(J));
    
    if ( eWare.Mode < Edit ) {
        eWare.Mode = Edit;
    } else if (eWare.Mode == Save) {
        // DumpFormValues();

        var lst = String(Request.Form.Item("lst_articles"));
        if (lst != "undefined") {
           user_id = eWare.GetContextInfo("User","User_UserId");

            var id = lst.split(",");
            for (var i = 0; i < id.length; i++) {
                sql = "UPDATE PRPublicationArticle SET prpbar_UpdatedBy = " + String(user_id) + ", prpbar_UpdatedDate = GetDate(), prpbar_TimeStamp = GetDate(), prpbar_NewsSequence = " + String(i + 1) + " WHERE prpbar_PublicationArticleID = " + String(id[i]);
                var qry = eWare.CreateQueryObj(sql);
                qry.ExecSQL();
            }
        }
    
        Response.Redirect(sReturnURL);
        return;
    }

    Response.Write("<LINK REL=\"stylesheet\" HREF=\"../../prco.css\">");
    var sNewsGrouping = GetPRPublicationSequenceParam("NewsGrouping");
    if (isEmpty(sNewsGrouping)) {
        var sCategoryCode = GetPRPublicationSequenceParam("CategoryCode");
        sql = "SELECT capt_code FROM custom_captions WHERE CAST(capt_US AS VARCHAR(MAX))='" + sCategoryCode + "'";
        var qryCategoryCode = eWare.CreateQueryObj(sql);
        qryCategoryCode.SelectSQL();
        if (! qryCategoryCode.Eof) {
		    sNewsGrouping = qryCategoryCode("capt_code");
        }
    }

	// Get the title text
	var sTitle = "";
	sql = "SELECT dbo.ufn_GetCustomCaptionValue('NewsGroupingCode', '" + sNewsGrouping + "', 'en-us') As Capt_US";
    var qryCustomCaptions = eWare.CreateQueryObj(sql);
    qryCustomCaptions.SelectSQL();
    if (! qryCustomCaptions.Eof) {
		sTitle = "Sequence " + qryCustomCaptions("Capt_US") + " Articles";
    }
    qryCustomCaptions = null;

    // Get the records of interest
    sql = "SELECT prpbar_PublicationArticleID, dbo.ufn_GetCustomCaptionValue('prpbar_CategoryCode', prpbar_CategoryCode, 'en-us') As Category, prpbar_Name , dbo.ufn_GetCustomCaptionValueList('comp_PRIndustryType', prpbar_IndustryTypeCode) As IndustryType  " +
            "FROM PRPublicationArticle WITH (NOLOCK) " 
                + " WHERE (prpbar_ExpirationDate IS NULL OR  prpbar_ExpirationDate >= GETDATE()) "  
                + "   AND prpbar_News='Y' " 
                + "   AND prpbar_CategoryCode IN (SELECT CAST(capt_us as VARCHAR(40)) FROM Custom_Captions WHERE capt_family = 'NewsGrouping' AND capt_code = '" + sNewsGrouping + "') "
                + " ORDER BY prpbar_NewsSequence";
    DEBUG("SQL: " + sql);
    
//Response.Write("<br/>" + sql);
    
    var qryPublicationArticles = eWare.CreateQueryObj(sql);
    qryPublicationArticles.SelectSQL();
    var RecordCount = qryPublicationArticles.RecordCount;
    
    sContents += "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>This page includes all publication articles that have the news flag checked.  While all 'News Articles' are included, it may also be other publication types that have the news flag checked.  The sequence being set on this page for news items is different from the sequence that is set for the other publication types.</td></tr></table><p></p>"
    
    sContents += createAccpacBlockHeader("", sTitle, "100%");
	sContents += "<script type=\"text/javascript\" src='../PRCoGeneral.js'></script>";
	sContents += "<script type=\"text/javascript\" src='PRPublicationArticleSequence.js'></script>";
    sContents += "<script type=\"text/javascript\" src=\"../SelectSequence.js\"></script>"
    
    sContents += "<table width='100%' height='100%'>";

    // Create a listbox with the items of interest within.
    sContents += "<tr><td width='75%'><select style='width:100%' name=lst_articles size=" + RecordCount + "  multiple=multiple>"

    while (! qryPublicationArticles.eof) {
        sContents += "<option value=" + String(qryPublicationArticles("prpbar_PublicationArticleID")) + ">" + qryPublicationArticles("prpbar_Name");

        sContents += " - " + qryPublicationArticles("Category");
        sContents += " - " + qryPublicationArticles("IndustryType");
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
