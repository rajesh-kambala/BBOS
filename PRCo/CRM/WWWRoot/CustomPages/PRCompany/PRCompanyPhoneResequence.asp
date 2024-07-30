<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<% 

phon_phoneid = Request.Querystring("phon_phoneid");
phon_type = Request.Querystring("phon_type");
sSummaryAction = eWare.Url("PRCompany/PRCompanyPhone.asp")+ "&phon_phoneid="+ phon_phoneid;

if (eWare.Mode == Save) {

    var szlstSequenceValues = "" + Request("phonelist");
    var aszPhoneIDS = szlstSequenceValues.split(',');
    
    lUserId = eWare.GetContextInfo("User","User_UserId");

    for(i=1; i<=aszPhoneIDS.length; i++) {
        sSQL = "UPDATE Phone set phon_PRSequence = " + i.toString()
        + ", phon_CreatedBy = " + lUserId + ", phon_UpdatedBy = " + lUserId
        + ", phon_CreatedDate = getdate(), phon_UpdatedDate = getdate(), phon_TimeStamp = getdate()"
        + " where phon_PhoneID = " + aszPhoneIDS[i-1];
        qryUpdate = eWare.CreateQueryObj(sSQL);
        qryUpdate.ExecSQL(); 
    }
    Response.Redirect(sSummaryAction);
}

if (eWare.Mode == View)
    eWare.mode = Edit;

sSQL = "select Capt_US from custom_captions where capt_Family = 'Phon_TypeCompany' and capt_Code = '" + phon_type + "'";
rec = eWare.CreateQueryObj(sSQL);
rec.SelectSQL();
var PhoneTypeCaption = rec("capt_US");

sSQL = "SELECT Phon_PhoneId, Phon_PRDescription, CRM.dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) "
+ " as PhoneNumber FROM vPRCompanyPhone WHERE plink_RecordId = " + comp_companyid + " AND plink_Type = '" + phon_type + "' ORDER BY phon_PRSequence";
rsPhone = eWare.CreateQueryObj(sSQL);
rsPhone.SelectSQL();
var RecordCount = rsPhone.RecordCount;

blkPhoneResequence = eWare.GetBlock("Content");

var sContents = createAccpacBlockHeader("","Resequence " + PhoneTypeCaption + " Numbers", "100%");
sContents += "<script type=\"text/javascript\" language=\"JavaScript\" src=\"../SelectSequence.js\"></script>"
 + "<form><table><tr><td colspan=2><select name=phonelist size=" + RecordCount + "  multiple=multiple>";
while (!rsPhone.eof) {
	sContents += ("<option value=" + rsPhone("phon_PhoneId") + ">" 
        + rsPhone("phon_PRDescription") + " " +rsPhone("PhoneNumber") + "</option>");
	rsPhone.NextRecord();
}
sContents += "<select></td><td>"
			+ "<button style=\"width:100;\" onclick=\"MoveItem(true, document.forms[0].phonelist);return false;\">Move Up</button><br>"
			+ "<button style=\"width:100;\" onclick=\"MoveItem(false, document.forms[0].phonelist);return false;\">Move Down</button>"
		    + "</td></tr>"
		    + "</table></select></form>";

sContents += createAccpacBlockFooter();
blkPhoneResequence.contents = sContents;

blkContainer.AddBlock(blkPhoneResequence);

blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:SelectAllInList(document.forms[0].phonelist);document.EntryForm.submit();"));
blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

eWare.AddContent(blkContainer.Execute());

Response.Write(eWare.GetPage());

%>

