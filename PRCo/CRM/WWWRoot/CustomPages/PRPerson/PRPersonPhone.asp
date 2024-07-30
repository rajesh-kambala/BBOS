<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2016

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
%>

<!-- #include file ="PersonHeaders.asp" -->
<%
	doPage();

function doPage()
{
	var sSQL = "";
	var sCompanyId = "";
    var sSecurityGroups = sDefaultPersonSecurity;

    var phon_phoneid = getIdValue("phon_PhoneId");
    var recPhone;
    var recPhoneLink;    

    var blkEntry = eWare.GetBlock("PhoneNewEntry");
    blkEntry.Title = "Person Phone";
    var fldType = blkEntry.GetEntry("plink_Type");
    fldType.LookupFamily = "Phon_TypePerson";

    blkContainer.CheckLocks = false; 

    // indicate that this is new
    var recPhone;
    if (phon_phoneid == -1 )
    {
	    recPhone = eWare.CreateRecord("Phone");
        fldDesc = blkEntry.GetEntry("phon_PRDescription");
        fldDesc.DefaultValue = "Direct Office Phone";
        var fld = blkEntry.GetEntry("phon_CountryCode");
        if (!isEmpty(fld))
            fld.DefaultValue = "1";
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;

        recPhoneLink = eWare.CreateRecord("PhoneLink");
        recPhoneLink("PLink_RecordID") = pers_personid;
        recPhoneLink("PLink_EntityID") = 13;
    }
    else
    {
        recPhone = eWare.FindRecord("vPRPhone", "phon_PhoneId=" + phon_phoneid);
    }
    var sListingAction = eWare.Url("PRPerson/PRPersonContactInfoListing.asp")+ "&pers_PersonId=" + pers_personid + "&T=Person&Capt=Contact+Info";
    var sSummaryAction = eWare.Url("PRPerson/PRPersonPhone.asp")+ "&phon_PhoneId="+ phon_phoneid + "&T=Person&Capt=Contact+Info";

    var bValidationError = false;
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Save)
    {
        if (blkContainer.Validate())
        {
            //DumpFormValues();

            // This screen is based off a view; therefore, we cannot 
            // just call execute to save our changes.  Instead, take the fields from
            // the screen and update the real recPhone object
            if (phon_phoneid != -1 )
            {
                recPhone = eWare.FindRecord("Phone", "phon_PhoneId=" + phon_phoneid);
                recPhoneLink = eWare.FindRecord("PhoneLink", "plink_PhoneId=" + phon_phoneid);
            }
	        
            sCompanyId = String(Request.Form.Item("phon_companyid_a"));

	        sType = getFormValue("plink_Type");
            var sTypeCondition = "";
            if (sType == "PF")
                sTypeCondition = " AND phon_PRIsFax = 'Y' AND phon_PRIsPhone = 'Y'";
            else if (sType == "F" || sType == "SF" || sType == "EFAX" )
                sTypeCondition = " AND phon_PRIsFax = 'Y'";
            else
                sTypeCondition = " AND phon_PRIsPhone = 'Y'";	

            sPreferredInternal = getFormValue("phon_prpreferredinternal");
	        if (sPreferredInternal == "on")
	        {

                var sSQL = "UPDATE Phone SET phon_PRPreferredInternal = null FROM PhoneLink WHERE phon_PhoneID = plink_PhoneID AND plink_EntityID=13 AND plink_RecordID = " + pers_personid + sTypeCondition + " AND phon_CompanyID = " + sCompanyId + " AND phon_PhoneID <> " + phon_phoneid;
                var qry = eWare.CreateQueryObj(sSQL);
                qry.ExecSQL();
            } else {
                var sSQL = "SELECT COUNT(1) As Phone_Count FROM vPRPersonPhone WITH (NOLOCK) WHERE phon_PRPreferredInternal = 'Y' AND plink_RecordID = " + pers_personid + sTypeCondition + " AND phon_CompanyID = " + sCompanyId + " AND phon_PhoneID <> " + phon_phoneid;
                var qry = eWare.CreateQueryObj(sSQL);
                qry.SelectSQL();
                var cnt = qry("Phone_Count");
                if (cnt == 0) {
                   sPreferredInternal = "on";
                }
            }
            
	        sPreferredPublished = getFormValue("phon_prpreferredpublished");
	        if (sPreferredPublished == "on")
	        {
                var sSQL = "UPDATE Phone SET phon_PRPreferredPublished = null FROM PhoneLink WHERE phon_PhoneID = plink_PhoneID AND plink_EntityID=13 AND plink_RecordID = " + pers_personid + sTypeCondition + " AND phon_CompanyID = " + sCompanyId + " AND phon_PhoneID <> " + phon_phoneid;
                var qry = eWare.CreateQueryObj(sSQL);
                qry.ExecSQL();
            } else {
                if (getFormValue("phon_prpublish") == "on") {
                    var sSQL = "SELECT Count(1) As Phone_Count FROM vPRPersonPhone WITH (NOLOCK) WHERE phon_PRPreferredPublished = 'Y' AND plink_RecordID = " + pers_personid + sTypeCondition + " AND phon_CompanyID = " + sCompanyId + " AND phon_PhoneID <> " + phon_phoneid;
                    var qry = eWare.CreateQueryObj(sSQL);
                    qry.SelectSQL();
                    var cnt = qry("Phone_Count");

                    if (cnt == 0) {
                       sPreferredPublished = "on";                        
                    }             
                }                    
            }            

Response.Write("C<br/>");

	        if (sPreferredInternal == "on")
                recPhone.phon_PRPreferredInternal = "Y";
            else
                recPhone.phon_PRPreferredInternal  = "";

	        if (getFormValue("phon_prpublish") == "on")
                recPhone.phon_PRPublish = "Y";
            else
                recPhone.phon_PRPublish  = "";                
                
            if (sPreferredPublished == "on") {
                recPhone.phon_PRPreferredPublished = "Y";
            } else {
                recPhone.phon_PRPreferredPublished = "";
            }
                            
            recPhone.phon_AreaCode      = getFormValue("phon_areacode");
            recPhone.phon_Number        = getFormValue("phon_number");
            recPhone.phon_PRExtension   = getFormValue("phon_prextension");
            recPhone.phon_PRDescription = getFormValue("phon_prdescription");
            recPhone.phon_CountryCode   = getFormValue("phon_countrycode");
            recPhone.phon_CompanyID     = getFormValue("phon_companyid_a");
            recPhone.SaveChanges();
            
            recPhoneLink.PLink_PhoneId = recPhone.phon_PhoneID;
            recPhoneLink.PLink_Type = sType;
            recPhoneLink.SaveChanges();


	        if (phon_phoneid == -1 )
	            Response.Redirect(sListingAction);
	        else
	            Response.Redirect(sSummaryAction);
	            
	        return;
        }
        else
        {
            bValidationError = true;
        }
        
    }

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    if (eWare.Mode == Edit || bValidationError)
    {
        Response.Write("\n<script type=\"text/javascript\" src=\"PRPersonInclude.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\"> var sPersonName = \"" + recPerson.pers_FirstName + " " + recPerson.pers_LastName + "\";"); 
        Response.Write("\nfunction handleEnterKey() { var keycode = (event.keyCode ? event.keyCode : event.which); if (keycode == '13') { return false; } }"); 
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"keypress\", handleEnterKey); } else { window.attachEvent(\"onkeypress\", handleEnterKey); }</script>"); 
        fldType = blkEntry.GetEntry("plink_Type");
        fldType.AllowBlank = false;
        fldType.DefaultValue = "P";
        fldType.OnChangeScript = "onPhoneTypeChange();";
        
        // hide the accpac company field.
        blkEntry.GetEntry("Phon_CompanyID").Hidden = true;
        
        // draw the select box based upon the companies this person is linked to (only when entering user phone #'s)
        var sCompanySelectDisplay = "<div style={display:none}> <div ID=\"div_phon_companyid\" >" + 
            "<span ID=\"_Captphon_companyid\" CLASS=VIEWBOXCAPTION>&nbsp;Company:</span><br/>" +
            "<span>&nbsp;<select CLASS=EDIT SIZE=1 NAME=\"phon_companyid_a\">" ;
        // get the list of companies
        sSQL = "SELECT peli_PersonId, comp_companyid, prcse_FullName " 
                    + " FROM Person_Link WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON peli_CompanyId = comp_CompanyId "
                    + " INNER JOIN PRCompanySearch ON prcse_CompanyId = comp_CompanyId "
                    + " WHERE peli_PRStatus != 3 "
                    + " AND peli_PersonId = " + pers_personid; 
                    
        var recCompanies = eWare.CreateQueryObj(sSQL);
        recCompanies.SelectSQL();
        while (!recCompanies.eof) 
        {
            var sSelected = "";
            if (recCompanies("comp_companyid") == recPhone("Phon_CompanyId"))
                sSelected = " SELECTED ";
            sCompanySelectDisplay += "<option " + sSelected + " value=\""+ recCompanies("comp_companyid") + "\" >"+ recCompanies("prcse_FullName") + "</option> ";
            recCompanies.NextRecord();
        }
        sCompanySelectDisplay += "</select></span><span>&nbsp;&nbsp;</span></div></div>";
        Response.Write(sCompanySelectDisplay);
        var sCompanySelectDraw = " AppendCell(\"_Captplink_type\", \"div_phon_companyid\", false);";

        if (phon_phoneid == -1 )
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:savePhone();"));
        }
        blkContainer.AddBlock(blkEntry);
        eWare.AddContent(blkContainer.Execute(recPhone)); 
        eWare.Mode = Edit;        
        Response.Write(eWare.GetPage('Person'));
    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the recPhoneord
        var sql = "DELETE FROM PhoneLink WHERE plink_phoneId="+ phon_phoneid;
        var qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        sql = "DELETE FROM Phone WHERE phon_phoneId="+ phon_phoneid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();


        // Check the Person/Company combo to see if the only remaining record needs to be 
        // reset as the default
        sCompanyId = recPhone("phon_CompanyId");
        var sType = recPhone("phon_Type");
        //if ((sCompanyId != undefined) && (sType.search(/^(F|P)$/i) >= 0)) {
        //    if (PhoneNbrCount(pers_personid, sCompanyId, sType) == 1) {
        //        sql = "UPDATE Phone SET phon_Default = 'Y' WHERE phon_PersonId = " + pers_personid + " AND phon_CompanyId = " + sCompanyId + " AND phon_Type = '" + sType + "'";
        //        var qryUpdate = eWare.CreateQueryObj(sql);
        //        qryUpdate.ExecSql();
        //    }
        //}
	    Response.Redirect(sListingAction);
    }
    else // view mode
    {
        var bAttentionLine = false;
        recAttnLine = eWare.FindRecord("PRAttentionLine", "prattn_PhoneID="+ phon_phoneid);
        if (!recAttnLine.eof) {
            bAttentionLine = true;

            var sAttnLineURL = eWare.Url("PRCompany/PRCompanyAttentionLine.asp") + "&comp_CompanyId=" + recAttnLine("prattn_CompanyId");
            var sBannerMsg = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>This phone number is associated with an <a href=\"" + sAttnLineURL + "\">attention line</a>.</td></tr></table>";
            
            var blkBanners = eWare.GetBlock('content');
            blkBanners.contents = sBannerMsg;
            blkContainer.AddBlock(blkBanners);            
        }

        var blkFullNumber = eWare.GetBlock('content');
        blkFullNumber.contents = "<table><tr><td id=\"tdFullNumber\"><span class=\"VIEWBOXCAPTION\">Full Phone Number:</span><br/><span class=\"VIEWBOX\">" + recPhone("phon_FullNumber") + "</span></td></tr></table>";;
        blkContainer.AddBlock(blkFullNumber);     
    
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
            {
                var sDeleteUrl = "";
                if (bAttentionLine) {
                    sDeleteUrl="javascript:alert('Please reassign the attention line to another fax number prior to removing this record.');";
                } else {
                    sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
                }
                
                
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
            }
    	}
        blkEntry.ArgObj = recPhone;
        blkContainer.AddBlock(blkEntry);
    
        eWare.AddContent(blkContainer.Execute()); 
        Response.Write(eWare.GetPage('Person'));
    }

    if (eWare.Mode == Edit || bValidationError)
    {
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n" + sCompanySelectDraw);
        Response.Write("\n        document.getElementById('_IDphon_prpublish').onclick = togglePreferredPublished;");
        Response.Write("\n        document.getElementById('_IDphon_prpreferredpublished').onclick = togglePublished;");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("</script>");
    }

    if (eWare.Mode == View)
    {
        Response.Write("\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        //Response.Write("\n        AppendCell('_Captphon_companyid', 'tdFullNumber', false);");
        Response.Write("\n        InsertRow(\"_Captplink_type\", \"tdFullNumber\"); " ); 
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("</script>");
    }
}
    
function PhoneNbrCount(sPersonId, sCompanyId, sType)
{
    var sSQL = "SELECT Count(*) As Phone_Count FROM vPRPersonPhone WITH (NOLOCK) WHERE PLink_RecordID = " + pers_personid + " AND phon_Type = '" + sType + "'";
    var qry = eWare.CreateQueryObj(sSQL);
    qry.SelectSQL();
    var cnt = qry("Phone_Count");
    return cnt;
}
%>

<!-- #include file ="../RedirectTopContent.asp" -->
