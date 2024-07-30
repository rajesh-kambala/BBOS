<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<% 

emai_emailid = Request.Querystring("emai_emailid");
emai_type = Request.Querystring("emai_type");
sSummaryAction = eWare.Url("PRGeneral/PREmail.asp")+ "&emai_emailid="+ emai_emailid;

if (eWare.Mode == Save) {

    var szlstSequenceValues = "" + Request("emaillist");
    var aszEmailIDS = szlstSequenceValues.split(',');
    
    lUserId = eWare.GetContextInfo("User","User_UserId");

    for(i=1; i<=aszEmailIDS.length; i++) {
        sSQL = "update Email set emai_PRSequence = " + i.toString()
        + ", emai_CreatedBy = " + lUserId + ", emai_UpdatedBy = " + lUserId
        + ", emai_CreatedDate = getdate(), emai_UpdatedDate = getdate(), emai_TimeStamp = getdate()"
        + " where emai_EmailID = " + aszEmailIDS[i-1];
        qryUpdate = eWare.CreateQueryObj(sSQL);
        qryUpdate.ExecSQL(); 
    }
    Response.Redirect(sSummaryAction);
}

if (eWare.Mode == View)
    eWare.mode = Edit;

sSQL = "select Capt_US from custom_captions where capt_Family = 'emai_Type' and capt_Code = '" + emai_type + "'";
rec = eWare.CreateQueryObj(sSQL);
rec.SelectSQL();
var EmailTypeCaption = rec("capt_US");

sSQL = "SELECT emai_EmailId, emai_PRDescription, elink_Type, emai_EmailAddress, emai_PRWebAddress "
      + "FROM vCompanyEmail WHERE elink_RecordID = " + comp_companyid + " and elink_Type = '"  + emai_type + "' order by emai_PRSequence";
rsEmail = eWare.CreateQueryObj(sSQL);
rsEmail.SelectSQL();
var RecordCount = rsEmail.RecordCount;

blkEmailResequence = eWare.GetBlock("Content");

var sContents = createAccpacBlockHeader("","Resequence " + EmailTypeCaption + " Addresses", "100%");
sContents += "<script type=\"text/javascript\" language=\"JavaScript\" src=\"../SelectSequence.js\"></script>"
 + "<form><table><tr><td colspan=2><select name=emaillist size=" + RecordCount + "  multiple=multiple>";
while (!rsEmail.eof) {
	sContents += "<option value=" + rsEmail("emai_EmailId") + ">" 
        + rsEmail("emai_PRDescription") + ": ";
    if (rsEmail("elink_Type") == "E")
        sContents += rsEmail("emai_EmailAddress") 
    else
        sContents += rsEmail("emai_PRWebAddress");     
    sContents += "</option>";
	rsEmail.NextRecord();
}
sContents += "<select></td><td>"
			+ "<button style=\"width:100;\" onclick=\"MoveItem(true, document.forms[0].emaillist);return false;\">Move Up</button><br/>"
			+ "<button style=\"width:100;\" onclick=\"MoveItem(false, document.forms[0].emaillist);return false;\">Move Down</button>"
		    + "</td></tr>"
		    + "</table></select></form>";

//sContents += "SelectFirstInList(document.forms[0].emaillist)";

sContents += createAccpacBlockFooter();
blkEmailResequence.contents = sContents;

blkContainer.AddBlock(blkEmailResequence);

blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:SelectAllInList(document.forms[0].emaillist);document.EntryForm.submit();"));
blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

eWare.AddContent(blkContainer.Execute());

Response.Write(eWare.GetPage());

%>

