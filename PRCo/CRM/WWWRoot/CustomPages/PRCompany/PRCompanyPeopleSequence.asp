<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2015-2024

  The use, disclosure, reproduction, modification, transfer, or
  transmittal of  this work for any purpose in any form or by any
  means without the written  permission of Blue Book Services, Inc.  is
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
    bDebug = false;

    var sql;
    var sContents = "";

    var companyID = getIdValue("Key1");

    if (companyID == -1) {
        companyID = getIdValue("comp_companyid");
    }

    var sListingAction = eWare.Url("PRCompany/PRCompanyPeople.asp") + "&T=Company&Capt=Contact+Info";

    sListingAction = changeKey(sListingAction, "Key0", "1");
    sListingAction = changeKey(sListingAction, "Key1", companyID);

    if ( eWare.Mode < Edit ) {
        eWare.Mode = Edit;
     } else if (eWare.Mode == Save) {
        // DumpFormValues();

        var lst = String(Request.Form.Item("lst_items"));
        if (lst != "undefined") {
           user_id = eWare.GetContextInfo("User","User_UserId");

            var id = lst.split(",");
            for (var i = 0; i < id.length; i++) {
                sql = "UPDATE Person_Link SET peli_UpdatedBy = " + String(user_id) + ", peli_UpdatedDate = GetDate(), peli_TimeStamp = GetDate(), peli_PRSequence = " + String(i + 1) + " WHERE peli_PersonLinkID = " + String(id[i]);
                var qry = eWare.CreateQueryObj(sql);
                Response.Write(sql + "<br/>");
                qry.ExecSQL();
            }

            // Flag this company as having a custom
            // sort order.
            recCompany("comp_PRHasCustomPersonSort") = "Y";
            recCompany.SaveChanges();
        }

        Response.Redirect(sListingAction);
        return;
    } else if (eWare.Mode == 95) {
        sql = "UPDATE Person_Link SET peli_PRSequence = TitleCodeOrder FROM (" +
                 "SELECT peli_CompanyID, peli_PersonLinkID, peli_PRTitleCode, tcc.capt_order as TitleCodeOrder " +
		           "FROM Person_Link WITH (NOLOCK) " +
 			            "INNER JOIN custom_captions tcc WITH (NOLOCK) ON tcc.capt_family = 'pers_TitleCode' and tcc.capt_code = peli_PRTitleCode " +
		          "WHERE peli_PRStatus = '1' " +
		            "AND peli_PREBBPublish = 'Y' " +
		            "AND peli_CompanyID = " + companyID + ") T1 " +
                  "WHERE Person_Link.peli_PersonLinkID = T1.peli_PersonLinkID ";
        var qry = eWare.CreateQueryObj(sql);    
        qry.ExecSQL();

        // Flag this company as having a custom
        // sort order.
        recCompany("comp_PRHasCustomPersonSort") = "";
        recCompany.SaveChanges();

        Response.Redirect(sListingAction);
        return;
    }

	// Get the title text
	var sTitle = "BBOS Person Sequence";

    sql = "SELECT peli_PersonLinkID, PersonName, GenericTitle " + 
            "FROM vPRBBOSPersonList WITH (NOLOCK) " +
          " WHERE peli_CompanyID = " + companyID +
       " ORDER BY peli_PRSequence";
    DEBUG("SQL: " + sql);


    var qryContacts = eWare.CreateQueryObj(sql);
    qryContacts.SelectSQL();
    var RecordCount = qryContacts.RecordCount;

    sContents += createAccpacBlockHeader("", sTitle, "100%");
    sContents += "\n\n<link href=\"/CRM/prco.css\" type=\"text/css\" rel=\"stylesheet\" />\n";
    sContents += "\n\n<link href=\"/CRM/prco_compat.css\" type=\"text/css\" rel=\"stylesheet\" />\n";
	sContents += "<script type=\"text/javascript\" src='../PRCoGeneral.js'></script>\n";
    sContents += "<script type=\"text/javascript\" src=\"../SelectSequence.js\"></script>\n"

    sContents += "<table width=\"100%\" height=\"100%\">\n";

    // Create a listbox with the items of interest within.
    sContents += "<tr><td style=\"width:75%\"><select style=\"width:100%\" name=\"lst_items\" size=\"" + RecordCount + "\" multiple=\"multiple\">\n"
    while (! qryContacts.eof) {
        sContents += "\t<option value=" + String(qryContacts("peli_PersonLinkID")) + ">" + qryContacts("PersonName") +  " - " + qryContacts("GenericTitle") + "</option>\n";
        qryContacts.NextRecord();
    }

    qryContacts = null;

    sContents += "</select>\n</td><td style=\"width:25%\">\n" + 
                 "<button style=\"width:100px;\" onclick=\"MoveItem(true, document.forms[0].lst_items);return false;\">Move Up</button><br\>\n" + 
                 "<button style=\"width:100px;\" onclick=\"MoveItem(false, document.forms[0].lst_items);return false;\">Move Down</button>\n" + 
                 "</td></tr>\n" + 
                 "</table>\n<input type=\"hidden\" id=\"hdn_items\"/>\n\n";
    sContents += createAccpacBlockFooter();

    var blkResequence = eWare.GetBlock("Content");
    blkResequence.contents = sContents;

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.AddBlock(blkResequence);

    // Set the buttons
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:SelectAllInList(document.EntryForm.lst_items); document.EntryForm.submit();"));

    if (recCompany("comp_PRHasCustomPersonSort") == "Y") {
        var defaultSequence = changeKey(sURL, "em", "95");
        blkContainer.AddButton(eWare.Button("Use Default Sequence", "save.gif", defaultSequence));
    }



    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));



    // Add Block to Container to build screen.
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage());
}
%>
<!-- #include file="CompanyFooters.asp" -->