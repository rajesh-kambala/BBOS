<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2011-2016

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
    var sql;
    var sContents = "";
    
    if ( eWare.Mode < Edit ) {
        eWare.Mode = Edit;
    } else if (eWare.Mode == Save) {

        var lst = String(Request.Form.Item("lst_records"));
        user_id = eWare.GetContextInfo("User","User_UserId");

        var id = lst.split(",");
        for (var i = 0; i < id.length; i++) {
            sql = "UPDATE PRCompanyBrand SET prc3_Sequence = " + String(i + 1) + ", prc3_UpdatedBy = " + String(user_id) + ", prc3_UpdatedDate = GetDate(), prc3_TimeStamp = GetDate() WHERE prc3_CompanyBrandId = " + String(id[i]);
            var qry = eWare.CreateQueryObj(sql);
            qry.ExecSQL();
        }
    
        Response.Redirect(eWare.Url("PRCompany/PRCompanyBrandListing.asp"));
        return;
    }

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

	// Get the title text
	var sTitle = "Sequence Brands";

    // Get the records of interest
    sql = "SELECT prc3_CompanyBrandId, prc3_Brand " +
            "FROM PRCompanyBrand WITH (NOLOCK) " +
           "WHERE prc3_CompanyId = " + comp_companyid + " " +
        "ORDER BY prc3_Sequence";
    DEBUG("SQL: " + sql);
    
//Response.Write("<br/>" + sql);
    
    var qryRecords = eWare.CreateQueryObj(sql);
    qryRecords.SelectSQL();
    var RecordCount = qryRecords.RecordCount;
    
    sContents += createAccpacBlockHeader("", sTitle, "100%");
	sContents += "<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";
    sContents += "<script type=\"text/javascript\" src=\"../SelectSequence.js\"></script>"
    
    sContents += "<table>";

    // Create a listbox with the items of interest within.
    sContents += "<tr><td width=\"300px\"><select style=\"width:100%\" name=\"lst_records\" size=\"" + RecordCount + "\"  multiple=\"multiple\">"

    while (! qryRecords.eof) {
        sContents += "<option value=" + String(qryRecords("prc3_CompanyBrandId")) + ">" + qryRecords("prc3_Brand") + "</option>";
        qryRecords.NextRecord();
    }
    qryRecords = null;

    sContents += "</select></td><td>"
			     + "<button style=\"width:100px;\" onclick=\"MoveItem(true, document.forms[0].lst_records);return false;\">Move Up</button><br>"
			     + "<button style=\"width:100px;\" onclick=\"MoveItem(false, document.forms[0].lst_records);return false;\">Move Down</button>"
		         + "</td></tr>"
		         + "</table></select><input type='hidden' id='hdn_items' />";
    sContents += createAccpacBlockFooter();

    var blkResequence = eWare.GetBlock("Content");
    blkResequence.contents = sContents;

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.AddBlock(blkResequence);
    
    // Set the buttons
    blkContainer.DisplayButton(Button_Default) = false;

    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:SelectAllInList(document.EntryForm.lst_records); document.EntryForm.submit();"));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRCompany/PRCompanyDLView.asp")));

    // Add Block to Container to build screen.
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("New"));
}
%>
