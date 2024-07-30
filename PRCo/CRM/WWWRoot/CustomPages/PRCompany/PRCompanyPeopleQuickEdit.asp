<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCOGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009-2021

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

    if (eWare.Mode == View) {
        eWare.Mode = Edit;
    }

    var sCellPhoneID;
    var sCellPreferredInternal;
    var sCellPreferredPublished;
    
    var sWorkPhoneID;
    var sWorkPreferredInternal;
    var sWorkPreferredPublished;    

    var sOrderByField = "pers_FullName";
    if (isEmpty(Request.QueryString("OrderBy")) == false) {
        sOrderByField = Request.QueryString("OrderBy");
        //Response.Write("<br/>Request.QueryString(\"OrderBy\"):" + Request.QueryString("OrderBy"));
    }

    var sSQL = "SELECT DISTINCT pers_PersonID, " +
               "dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName, " +
               "Emai_EmailId, " +
               "emai_EmailAddress, " +
               "emai_PRPublish, " +
               "emai_PRPreferredInternal, " +
               "emai_PRPreferredPublished, " +
               "CASE WHEN prattn_AttentionLineID IS NOT NULL THEN 'Y' ELSE '' END as OnAttnLine " +
          "FROM Person_Link WITH (NOLOCK) " +
               "INNER JOIN PRTransaction WITH (NOLOCK)  ON peli_PersonID = prtx_PersonID " +
               "INNER JOIN Person WITH (NOLOCK)  ON peli_PersonID = pers_PersonID " +
               "INNER JOIN custom_captions WITH(NOLOCK) ON capt_family = 'pers_TitleCode' and capt_code = peli_PRTitleCode " +
               "LEFT OUTER JOIN vPersonEmail WITH (NOLOCK)  ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND elink_Type = 'E' " +
               "LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON peli_CompanyID = prattn_CompanyID AND peli_PersonID = prattn_PersonID AND emai_EmailID = prattn_EmailID " +
         "WHERE prtx_Status = 'O' " +
           "AND peli_PRStatus IN (1,2) " +
           "AND prtx_CreatedBy = " + user_userid + " " +
           "AND peli_CompanyID = " + comp_companyid + " " +
      "ORDER BY " + sOrderByField;

    recPersons = eWare.CreateQueryObj(sSQL);
    recPersons.SelectSQL();

    if (eWare.Mode == Edit) {
        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyPeopleQuickEdit.js\"></script>");
       
        // Build our Sort URL.  Make sure the mode stays in "Edit" and remove
        // any previous order by key.
        var sSortUrl = changeKey(removeKey(sURL, "OrderBy"), "em", Edit) + "&OrderBy=";
        
        if (sOrderByField == "pers_FullName") {
            sURLSortByField = "capt_order";
            sURLSortByLabel = "LRL Order";
        } else {
            sURLSortByField = "pers_FullName";
            sURLSortByLabel = "Name";
        }       
       
       
        // Create a block to hold the custom grid/table
        blkPersons = eWare.GetBlock("Content");
        var sContent = "";
        sContent = createAccpacBlockHeader("PersonGrid", "Company Personnel Quick Edit");

        sContent = sContent + "\n<table id=tbl_PersonGrid width=100% cellpadding=1 cellspacing=1 border=0>";

        sContent = sContent + "\n<tr>";
        sContent = sContent + "\n<th width=100% class=\"GRIDHEAD\" align=\"center\" rowspan=2>Person";
        sContent = sContent + "\n &nbsp; Sort By: <a class=\"GRIDHEAD\" href=\"javascript:Sort('" + sURLSortByField + "');\">" + sURLSortByLabel + "</a>";
        sContent = sContent + "<input type=\"hidden\" id=\"hidCurrentOrderBy\" value=\"" + sOrderByField + "\" />";
        sContent = sContent + "<input type=\"hidden\" id=\"hidSortURL\" value=\"" + sSortUrl + "\" />";
        sContent = sContent + "</th>";
        
        sContent = sContent + "\n<th class=\"GRIDHEAD\" colspan=3>Email</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" colspan=8>Direct Office Phone</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" colspan=7>Cell Phone</th>";
        sContent = sContent + "\n</tr>";
        sContent = sContent + "\n<tr>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\">Address</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"Publish\">P</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"On an Attention Line\">Attn</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\">Cntry<br />Code</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\">Area<br />Code</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" nowrap>Phone Number</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\">Ext</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"Publish\">P</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"Preferred Published\">PP</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"Preferred Internal\">PI</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"On an Attention Line\">Attn</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\">Cntry<br />Code</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\">Area<br />Code</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" nowrap>Phone Number</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"Publish\">P</th>";        
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"Preferred Published\">PP</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"Preferred Internal\">PI</th>";
        sContent = sContent + "\n<th class=\"GRIDHEAD\" align=\"center\" title=\"On Attention Line\">Attn</th>";
        sContent = sContent + "\n</tr>";

        var sClass = "ROW1";

        if (recPersons.eof) {
            sContent = sContent + "\n<tr><td class=ROW2 colspan=15><em>No persons found with open transactions.</em></td></tr>";
        }

        while (!recPersons.eof){
            var iPersonID = recPersons("pers_PersonID")
            sClassTag = " CLASS=\"" + sClass + "\" ";

            
            sContent = sContent + "\n<tr>";
            sContent = sContent + "\n<input name=\"txtPersonID\" value=\"" + iPersonID + "\" id=txtPersonID value=\"" + iPersonID + "\" type=\"hidden\" />";
            sContent = sContent + "\n<input name=\"txtEmailID_" + iPersonID + "\" id=\"txtEmailID_" + iPersonID + "\" value=\"" + getString(recPersons("Emai_EmailId")) + "\" type=\"hidden\" />";
            
            sContent = sContent + "\n<td style=\"vertical-align:middle\" " + sClassTag + ">" + recPersons("pers_FullName") + "</td> ";
            sContent = sContent + "\n<td style=\"vertical-align:middle\" " + sClassTag + "><input name=\"txtEmail_" + iPersonID + "\" id=\"txtEmail_" + iPersonID + "\" value=\"" + getString(recPersons("emai_EmailAddress")) + "\" type=\"text\" maxlength=\"255\" size=\"30\" /></td>";

            sContent = sContent + "\n<td style=\"vertical-align:middle\" align=\"center\" " + sClassTag + "><input type=\"checkbox\" value=\"on\" name=\"cbEmailPublish_" + iPersonID + "\" id=\"cbEmailPublish_" + iPersonID + "\" " + GetChecked(recPersons("emai_PRPublish")) + " /></td>";
            sContent = sContent + "\n<td style=\"vertical-align:middle\" align=\"center\" " + sClassTag + ">" + getString(recPersons("OnAttnLine")) + "</td>";

            sContent = sContent + WritePhoneControls(comp_companyid, iPersonID, "P", sClassTag);
            sContent = sContent + WritePhoneControls(comp_companyid, iPersonID, "C", sClassTag);

            sContent = sContent + "\n</tr>";
            
            if (sClass=="ROW1")
                sClass = "ROW2";
            else
                sClass = "ROW1";

            recPersons.NextRecord();
        }

        sContent = sContent + "\n</TABLE>";

        sContent = sContent + createAccpacBlockFooter();
        blkPersons.Contents=sContent;
        blkContainer.AddBlock(blkPersons);
        
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRCompany/PRCompanyPeople.asp") + "&T=Company&Capt=Personnel"));
    
        sSaveUrl = changeKey(sURL, "em", Save);
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"document.EntryForm.action='" + sSaveUrl + "';return save();"));
    
        eWare.AddContent(blkContainer.Execute()); 
        Response.Write(eWare.GetPage("Company"));           

    }

    var sRecordID = null;
    var sEmail = null;
    var sDefault = null;
    var Record = null;

    if (eWare.Mode == Save) {
        while (!recPersons.eof){
            var iPersonID = recPersons("pers_PersonID")
            


            //Process Email First
            sRecordID = getFormValue("txtEmailID_" + iPersonID);
            sEmail = getFormValue("txtEmail_" + iPersonID);
            sPublish = getFormValue("cbEmailPublish_" + iPersonID);
    
//Response.Write("iPersonID: " + iPersonID + "<br/>");
//Response.Write("sRecordID: " + sRecordID + "<br/>");
//Response.Write("sEmail: " + sEmail + "<br/>");
//Response.Write("sPublish: " + sPublish + "<br/>");
            
            // If we have a record id, but no email
            // address, then delete the record.
            if ((sRecordID.length > 0) &&
                (sEmail.length == 0)) {

                //Perform a physical delete of the Email
                var sql = "DELETE FROM EmailLink WHERE ELink_EmailId=" + sRecordID;
                var qryDelete = eWare.CreateQueryObj(sql);
                qryDelete.ExecSql();

                sql = "DELETE FROM Email WHERE emai_emailId=" + sRecordID;
                qryDelete = eWare.CreateQueryObj(sql);
                qryDelete.ExecSql();
            } 
            
            // Only create/update if we have an 
            // email address
            if (sEmail.length > 0) {
            
                if (sRecordID.length > 0) {
                    Record = eWare.FindRecord("Email", "emai_EmailId=" + sRecordID)
                } else if (sEmail.length > 0) {
                    Record = eWare.CreateRecord("Email");
                    Record.emai_CompanyID = comp_companyid;
                    Record.emai_PRDescription = "E-Mail";
                    Record.SaveChanges();

                    var recEmailLink= eWare.CreateRecord("EmailLink");
                    recEmailLink.ELink_EmailId = Record.emai_EmailID;
                    recEmailLink.ELink_EntityID = 13;
                    recEmailLink.ELink_RecordID = iPersonID;
                    recEmailLink.ELink_Type = "E";
                    recEmailLink.SaveChanges();
                }

                // A person can have only one email address per comany
                // so that address must be marked "Preferred Internal"
                // and if it's published, must be marked "Preferred Published".

                Record.emai_PRPreferredInternal = "Y";
                Record.emai_PRPublish = GetBoolValue(sPublish);
                Record.emai_PRPreferredPublished = GetBoolValue(sPublish);
                Record.emai_EmailAddress = sEmail;
                
                Record.SaveChanges();
            }            
            

            sCellPhoneID = null;
            sCellPreferredInternal = null;
            sCellPreferredPublished = null;

            sWorkPhoneID = null;
            sWorkPreferredInternal = null;
            sWorkPreferredPublished = null;
            
            SavePhone(comp_companyid, iPersonID, "P");
            SavePhone(comp_companyid, iPersonID, "C");
            
            if ((sCellPreferredInternal == "Y") ||
                (sWorkPreferredInternal == "Y")) {

                sExclusion = "";
                if (sCellPhoneID != null) {
                    sExclusion += " AND phon_PhoneID != " +  sCellPhoneID;
                }
                if (sWorkPhoneID != null) {
                    sExclusion += " AND phon_PhoneID != " +  sWorkPhoneID;
                }
	             
                var sSQL = "UPDATE Phone SET phon_PRPreferredInternal = null FROM PhoneLink WHERE phon_PhoneID = plink_PhoneID AND plink_Type != 'F' AND plink_EntityID=13 AND plink_RecordID = " + iPersonID + sExclusion;
                var qry = eWare.CreateQueryObj(sSQL);
                qry.ExecSQL();
                
            }

            if ((sCellPreferredPublished == "Y") ||
                (sCellPreferredPublished == "Y")) {

                sExclusion = "";
                if (sCellPhoneID != null) {
                    sExclusion += " AND phon_PhoneID != " +  sCellPhoneID;
                }
                if (sWorkPhoneID != null) {
                    sExclusion += " AND phon_PhoneID != " +  sWorkPhoneID;
                }
	             
                var sSQL = "UPDATE Phone SET phon_PRPreferredPublished = null FROM PhoneLink WHERE phon_PhoneID = plink_PhoneID AND plink_Type != 'F' AND plink_EntityID=13 AND plink_RecordID = " + iPersonID + sExclusion;
                var qry = eWare.CreateQueryObj(sSQL);
                qry.ExecSQL();
                
            }   
  
            recPersons.NextRecord();
        }
        
        Response.Redirect(eWare.Url("PRCompany/PRCompanyPeople.asp") + "&T=Company&Capt=Personnel");
    }



function SavePhone(sCompanyID, sPersonID, sType) {


    sRecordID = getFormValue("txt" + sType + "ID_" + iPersonID);
    sCountryCode = getFormValue("txt" + sType + "CountryCode_" + iPersonID);
    sAreaCode = getFormValue("txt" + sType + "AreaCode_" + iPersonID);
    sPhone = getFormValue("txt" + sType + "Phone_" + iPersonID);
    sPublish = getFormValue("cb" + sType + "Publish_" + iPersonID);
    sPreferredInternal = getFormValue("cb" + sType + "PreferredInternal_" + iPersonID);
    sPreferredPublished = getFormValue("cb" + sType + "PreferredPublished_" + iPersonID);
    
    if (sType != "C") {
        sExtension = getFormValue("txt" + sType + "Ext_" + iPersonID);
    }
    
    // Note: Instead of always checking the three main components of the phone 
    // number, we will rely on the client-side JS checking and instead just 
    // focus on the main Phone field.
    

    // If we have a record id, but no phone
    // number, then delete the record.
    if ((sRecordID.length > 0) &&
        (sPhone.length == 0)) {

        sql = "DELETE FROM PhoneLink WHERE plink_PhoneId=" + sRecordID;
        var qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        sql = "DELETE FROM Phone WHERE phon_PhoneId=" + sRecordID;
        var qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        return;
    } 

    // Only if we have a phone value should we create/update
    // the phone record
    if (sPhone.length > 0) {
        if (sRecordID.length > 0) {
            Record = eWare.FindRecord("Phone", "phon_PhoneId=" + sRecordID)
        } else {
            Record = eWare.CreateRecord("Phone");
            Record.phon_CompanyID = comp_companyid;
            if (sType == "P") {
                Record.phon_PRDescription = "Direct Office Phone";
            } else {
                Record.phon_PRDescription = "Cell";
            }
            Record.SaveChanges();

            var recPhoneLink = eWare.CreateRecord("PhoneLink");
            recPhoneLink.PLink_EntityID = 13;
            recPhoneLink.PLink_RecordID = sPersonID;
            recPhoneLink.PLink_PhoneId = Record.phon_PhoneID;
            recPhoneLink.PLink_Type = sType;
            recPhoneLink.SaveChanges();
        }
        
        Record.Phon_CountryCode = sCountryCode;
        Record.Phon_AreaCode = sAreaCode;
        Record.Phon_Number = sPhone;
        Record.phon_PRPublish = GetBoolValue(sPublish);
        Record.phon_PRPreferredInternal = GetBoolValue(sPreferredInternal);
        Record.phon_PRPreferredPublished = GetBoolValue(sPreferredPublished);
        
        
        if (sType != "C") {
            Record.phon_PRExtension = sExtension;
        }        

        Record.SaveChanges();
        
        sRecordID = Record.phon_PhoneID;
        
        if (sType == "P") {
            sWorkPhoneID = sRecordID;
            sWorkPreferredInternal = GetBoolValue(sPreferredInternal);        
            sWorkPreferredPublished = GetBoolValue(sPreferredPublished);        
        } else {
            sCellPhoneID = sRecordID;
            sCellPreferredInternal = GetBoolValue(sPreferredInternal);
            sCellPreferredPublished = GetBoolValue(sPreferredPublished);
        }
    }
}


function WritePhoneControls(sCompanyID, sPersonID, sType, sClassTag) {
   
    var sSQL = "SELECT TOP 1 " +
                "phon_PhoneID, " +
                "phon_CountryCode, " +
                "phon_AreaCode, " +
                "phon_Number, " +
                "phon_PRExtension, " +
                "phon_PRPublish, " +
                "phon_PRPreferredInternal, " +
                "phon_PRPreferredPublished, " +
                "CASE WHEN prattn_AttentionLineID IS NOT NULL THEN 'Y' ELSE '' END as OnAttnLine " +
           "FROM vPRPersonPhone WITH (NOLOCK) " +
                "LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON phon_CompanyID = prattn_CompanyID AND plink_RecordID = prattn_PersonID AND phon_PhoneID = prattn_PhoneID " +
          "WHERE plink_RecordID=" + sPersonID + " " +
            "AND phon_CompanyID=" + sCompanyID + " " +
            "AND plink_Type = '" + sType + "' " +
         "ORDER BY phon_Default DESC ";
//Response.Write("<br/>" + sSQL);
    recPhone = eWare.CreateQueryObj(sSQL);
    recPhone.SelectSQL();
    
    var sPhoneID = "";
    var sCountryCode = "";
    var sAreaCode = "";
    var sNumber = "";
    var sExt = "";
    var sPublish = "";
    var sPreferredInternal = "";
    var sPreferredPublished = "";
    var sOnAttnLine = "";

    if (!recPhone.EOF) {
        sPhoneID = recPhone("phon_PhoneID").toString();
        sCountryCode = getString(recPhone("phon_CountryCode"));
        sAreaCode = getString(recPhone("phon_AreaCode"));
        sNumber = getString(recPhone("phon_Number"));
        sExt = getString(recPhone("phon_PRExtension"));        
        sPublish = GetChecked(recPhone("phon_PRPublish"));
        sPreferredInternal = GetChecked(recPhone("phon_PRPreferredInternal"));        
        sPreferredPublished = GetChecked(recPhone("phon_PRPreferredPublished"));    
        sOnAttnLine = getString(recPhone("OnAttnLine"));    
    }
    
    var sPhoneControls = "";
    sPhoneControls = sPhoneControls + "\n<input name=\"txt" + sType + "ID_" + iPersonID + "\" id=\"txt" + sType + "ID_" + iPersonID + "\" value=\"" + sPhoneID + "\" type=\"hidden\" />";
    sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" " + sClassTag + "><input value=\"" + sCountryCode + "\" name=txt" + sType + "CountryCode_" + iPersonID + " id=txt" + sType + "CountryCode_" + iPersonID + " type=\"text\" maxlength=\"3\" size=\"3\" /></td>";
    sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" " + sClassTag + "><input value=\"" + sAreaCode + "\" name=txt" + sType + "AreaCode_" + iPersonID + " id=txt" + sType + "AreaCode_" + iPersonID + " type=\"text\" maxlength=\"5\" size=\"5\" /></td>";
    sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" " + sClassTag + "><input value=\"" + sNumber + "\" name=txt" + sType + "Phone_" + iPersonID + " id=txt" + sType + "Phone_" + iPersonID + " type=\"text\" maxlength=\"10\" size=\"10\" /></td>";

    if (sType != "C") {
        sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" " + sClassTag + "><input value=\"" + sExt + "\" name=txt" + sType + "Ext_" + iPersonID + " id=txt" + sType + "Ext_" + iPersonID + " type=\"text\" maxlength=\"5\" size=\"5\" /></td>";
    } 

    sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" align=\"center\" " + sClassTag + "><input " + sPublish + " type=checkbox value=\"on\" name=\"cb" + sType + "Publish_" + iPersonID + "\" id=\"cb" + sType + "Publish_" + iPersonID + "\" /></td>";
    sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" align=\"center\" " + sClassTag + "><input " + sPreferredPublished + " type=checkbox value=\"on\" name=\"cb" + sType + "PreferredPublished_" + iPersonID + "\" id=\"cb" + sType + "PreferredPublished_" + iPersonID + "\" onclick=\"validatePhonePreferredPublished(this);\" /></td>";
    sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" align=\"center\" " + sClassTag + "><input " + sPreferredInternal + " type=checkbox value=\"on\" name=\"cb" + sType + "PreferredInternal_" + iPersonID + "\" id=\"cb" + sType + "PreferredInternal_" + iPersonID + "\" onclick=\"validatePhonePreferredInternal(this);\" /></td>";
 
    sPhoneControls = sPhoneControls + "\n<input name=\"txt" + sType + "PreferredInternal_" + iPersonID + "\" id=\"txt" + sType + "PreferredInternal_" + iPersonID + "\" value=\"" + sPreferredInternal + "\" type=\"hidden\" />";
    sPhoneControls = sPhoneControls + "\n<input name=\"txt" + sType + "PreferredPublished_" + iPersonID + "\" id=\"txt" + sType + "PreferredPublished_" + iPersonID + "\" value=\"" + sPreferredPublished + "\" type=\"hidden\" />";
    sPhoneControls = sPhoneControls + "\n<td style=\"vertical-align:middle\" align=\"center\" " + sClassTag + ">" + sOnAttnLine + "</td>";

    return sPhoneControls;           
}



function GetChecked(sBoolVal) {
    if (sBoolVal == "Y") {
        return "checked";
    }
    
    return "";
}

function GetBoolValue(sCheckboxValue) {
    if (sCheckboxValue == "on") {
        return "Y";
    }
    
    return "";
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
<!-- #include file="CompanyFooters.asp" -->

