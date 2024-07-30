<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Reporter Company 2006-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Reporter Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Reporter Company .
  Use and distribution limi ted solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\PRPerson\PersonIdInclude.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
    doPage();

function doPage() {
    var sSecurityGroups = "10";
    var sReplicateString = "";

    var fldCompany;
    var recEmail;
    var recEmailLink;
    var sListingAction;
    var sSummaryAction;
    var sql;
    var sMsg;
    var sInnerMsg = "";
    var bAttentionLine = false;

    var sValidationError = "";
    var bError = false;
    var bIsPerson = false;
    var entity = "";

    var sTopContentUrl = "";

    if (pers_personid != -1)
    {
        %> 
        <!-- #include file ="..\PRPerson\PersonTrxInclude.asp" --> <%
        sSecurityGroups = "1,2,3,4,5,6,10";
        bIsPerson = true;
        entity = "Person";
        // This is normally set in the "*IDInclude.asp" pages, but since this 
        // page is shared by both the company and a person, we are setting it
        // here to be explicit.
        sTopContentUrl = "PersonTopContent.asp";
    } else if (comp_companyid != -1) {
        %> 
        <!-- #include file ="..\PRCompany\CompanyTrxInclude.asp" --><%
        sSecurityGroups = "1,2,3,4,5,6,10";
        entity = "Company";
        // This is normally set in the "*IDInclude.asp" pages, but since this 
        // page is shared by both the company and a person, we are setting it
        // here to be explicit.
        sTopContentUrl = "CompanyTopContent.asp"; 
    }

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    if (comp_companyid != -1 || pers_personid != -1)
    {
        blkContainer.AddBlock(blkTrxHeader);
    }

    var emai_emailid = getIdValue("emai_emailid");
    
    var blkEntry = eWare.GetBlock("EmailNewEntry");
    blkEntry.Title = "Email";

    blkContainer.CheckLocks = false; 

    // indicate that this is new
    if (emai_emailid == -1)
    {
	    recEmail = eWare.CreateRecord("Email");
        recEmailLink = eWare.CreateRecord("EmailLink");
	    if (bIsPerson) {
		    recEmailLink("ELink_RecordID") = pers_personid;
            recEmailLink("ELink_EntityID") = 13;
		} else {
		    recEmailLink("ELink_RecordID") = comp_companyid;
            recEmailLink("ELink_EntityID") = 5;
        }
        
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    else
    {
        // This should work for both person and company emails.
        recEmail = eWare.FindRecord("vPREmail", "emai_EmailId=" + emai_emailid);
        
        recAttnLine = eWare.FindRecord("PRAttentionLine", "prattn_EmailID="+ emai_emailid);
        if (!recAttnLine.eof) {
            bAttentionLine = true;
            var sAttnLineURL = eWare.Url("PRCompany/PRCompanyAttentionLine.asp")+ "&comp_CompanyId=" + recAttnLine("prattn_CompanyID");
            sInnerMsg += "<tr><td>This E-mail address is associated with an <a href=\"" + sAttnLineURL + "\">attention line</a>.</td></tr>";
        }
        
    }
    
    var emai_type = recEmail("elink_Type");

    if (bIsPerson) {
        sListingAction = eWare.Url("PRPerson/PRPersonContactInfoListing.asp") + "&T=Person&Capt=Contact+Info";
    } else {
        sListingAction = eWare.Url("PRCompany/PRCompanyContactInfoListing.asp") + "&T=Company&Capt=Contact+Info";
    }
    sSummaryAction = eWare.Url("PRGeneral/PREmail.asp") + "&emai_EmailId=" + emai_emailid;


    // based upon the mode determine the buttons and actions
	// DumpFormValues();
    if ((eWare.Mode == Save))
    {

            // This screen is based off a view; therefore, we cannot 
            // just call execute to save our changes.  Instead, take the fields from
            // the screen and update the real recPhone object
        if (emai_emailid > -1)
        {
            recEmail = eWare.FindRecord("Email", "emai_EmailId=" + emai_emailid);
            recEmailLink = eWare.FindRecord("EmailLink", "elink_EmailId=" + emai_emailid);
        }

        if (blkEntry.Validate())
        {
            var sType = String(Request.Form.Item("elink_type"));
	            
            // Take a look at the PRWebUser table to look for
            // duplicate email addresses.  Email address can be entered
            // in that table by registered users independent of the
            // CRM system.	            
            if ((bIsPerson) &&
                (sType == "E")) {
             
                var sDupSQL = "SELECT ISNULL(peli_PersonID, 0) as PersonID, ISNULL(peli_CompanyID, 0) As CompanyID " +
                               " FROM PRWebUser LEFT OUTER JOIN Person_Link ON prwu_PersonLinkID = peli_PersonLinkID " + 
                               "WHERE prwu_Email = '" + Request.Form.Item("emai_emailaddress") + "' AND prwu_Disabled IS NULL " +
                                 "AND peli_CompanyID NOT IN (SELECT prcr_LeftCompanyId FROM PRCompanyRelationship WHERE prcr_Type = '36' AND prcr_Active = 'Y') " +
                                 "AND peli_CompanyID NOT IN (SELECT prcr_RightCompanyId FROM PRCompanyRelationship WHERE prcr_Type = '36' AND prcr_Active = 'Y')";
                //Response.Write("<p>sDupSQL == on:" + sDupSQL + "</p>");
                var qryDup = eWare.CreateQueryObj(sDupSQL);
                qryDup.SelectSQL();
             
                if (!qryDup.eof) {
                    var dupPersonID = qryDup("PersonID");
                    var dupCompanyID = qryDup("CompanyID");
                 
                    var bDupFound = false;
                    if (dupPersonID != pers_personid) {
                        //sMsg = "PersonID: " + dupPersonID + "!=" + pers_personid + "<br/>";
                        bDupFound = true;               
                    } else if (dupCompanyID != Request.Form.Item("emai_companyid")){
                        //sMsg = "CompanyID: " + dupCompanyID + "!=" + Request.Form.Item("emai_companyid") + "<br/>";
                        bDupFound = true;               
                    }
                                        
                    if (bDupFound) {
                        //Response.Write("Adding Dup Message");
                        Session("sUserMsg") = "WARNING: A BBOS User record was found for another user that has an email address of '" + Request.Form.Item("emai_emailaddress") + "'.  This could be for a registered user that is not linked to this person, or it could be for a member that is sharing this email address.";
                    }
                }
            }

            // If this is a person email, then this flag
            // spans companies.  Build our condition accordingly.
            var sCompanyFilter = "";
            if (bIsPerson) {
                sFilter = " AND ELink_EntityID = 13 AND ELink_RecordID = " + pers_personid;
                sCompanyFilter = " AND emai_CompanyID = " + getFormValue("emai_companyid_a");
            }  else {
                sFilter = " AND ELink_EntityID = 5 AND ELink_RecordID = " + comp_companyid;
            }

           if (!bError) {
        
                var sIDClause = "";
                if (recEmail("emai_EmailID") != null) {
                    sIDClause = " AND emai_EmailID <> " + recEmail("emai_EmailID");
                }

	            var sPreferredInternal = String(Request.Form.Item("emai_prpreferredinternal"));
	            if (sPreferredInternal == "on")
	            {



                    // Make sure no other records for this company or person
                    // has this flag set
                    sql = "UPDATE Email SET emai_PRPreferredInternal = NULL, emai_UpdatedBy=" + user_userid + " FROM EmailLink WHERE elink_EmailID = emai_EmailID AND elink_Type = '" + sType + "'" + sCompanyFilter + sFilter + sIDClause;
                    
                    //Response.Write("<p>sPreferredInternal == on:" + sql + "</p>");
                    var qryUpdate = eWare.CreateQueryObj(sql);
                    qryUpdate.ExecSql();
                } 
                
	            var sPreferredPublished = String(Request.Form.Item("emai_prpreferredpublished"));
	            if (sPreferredPublished == "on")
	            {
                    // Make sure no other records for this company or company/person
                    // has this flag set

                    sql = "UPDATE Email SET emai_PRPreferredPublished = NULL, emai_UpdatedBy=" + user_userid + " FROM EmailLink WHERE elink_EmailID = emai_EmailID AND elink_Type = '" + sType + "' " + sCompanyFilter + sFilter + sIDClause;
                    //Response.Write("<p>sPreferredPublished == on:" + sql + "</p>");
                    var qryUpdate = eWare.CreateQueryObj(sql);
                    qryUpdate.ExecSql();
                } 


                if (sPreferredInternal == "on")
                    recEmail.emai_PRPreferredInternal = "Y";
                else
                    recEmail.emai_PRPreferredInternal  = "";
                
                if (getFormValue("emai_prpublish") == "on")
                    recEmail.emai_PRPublish = "Y";
                else
                    recEmail.emai_PRPublish = "";

                if (sPreferredPublished == "on") {
                    recEmail.emai_PRPreferredPublished = "Y";
                } else {
                    recEmail.emai_PRPreferredPublished = "";
                }

                //Defect 4358 - clear out opposite address when saving
                if (sType == "E") {
                    recEmail.emai_EmailAddress = getFormValue("emai_emailaddress");
                    recEmail.emai_PRWebAddress = "";
                } else {
                    recEmail.emai_PRWebAddress = getFormValue("emai_prwebaddress");
                    recEmail.emai_EmailAddress = "";
                }

                recEmail.emai_PRDescription = getFormValue("emai_prdescription");

                if (bIsPerson) {
                    recEmail.emai_CompanyID = getFormValue("emai_companyid_a");
                }

                recEmail.SaveChanges();

                recEmailLink.ELink_EmailId = recEmail.emai_EmailID;
                recEmailLink.ELink_Type = sType;
                recEmailLink.SaveChanges();


                // If this email address is published, we need to make sure at
                // least one email address is also marked "Preferred Published"
                var sPublish = String(Request.Form.Item("emai_prpublish"));       
                if (sPublish == "on") {
                
                        var sSQL = "SELECT Count(1) As Email_Count FROM vCompanyEmail WITH (NOLOCK) WHERE elink_Type = '" + sType + "' AND emai_PRPreferredPublished = 'Y' "  + sFilter;
                        Response.Write("<p>sPublish == on:" + sSQL + "</p>");
                        var qry = eWare.CreateQueryObj(sSQL);
                        qry.SelectSQL();
                        var cnt = qry("Email_Count");
       
                        if (cnt == 0) {
                            //Response.Write("<p>Setting emai_PRPreferredPublished='Y'</p>");
                            recEmail.emai_PRPreferredPublished = "Y";
                            recEmail.SaveChanges();
                        } 
                }

                // If this email address is not marked preferred internal, we
                // need to make sure at least one email address for the company
                // or company/person has this flag set.
                if (sPreferredInternal != "on") {

                    if (sType == "E") {
                
                        var sSQL = "SELECT Count(1) As Email_Count FROM vCompanyEmail WITH (NOLOCK) WHERE elink_Type = 'E' AND emai_PRPreferredInternal = 'Y' "  + sFilter;
                        //Response.Write("<p>sPreferredInternal != on:" + sSQL + "</p>");
                        var qry = eWare.CreateQueryObj(sSQL);
                        qry.SelectSQL();
                        var cnt = qry("Email_Count");
       
                        if (cnt == 0) {
                            //Response.Write("<p>Setting emai_PRPreferredInternal='Y'</p>");
                            recEmail.emai_PRPreferredInternal = "Y";
                            recEmail.SaveChanges();
                        } 
                    }
                }


                if (emai_emailid == -1)
                    Response.Redirect(sListingAction);
               else
                    Response.Redirect(sSummaryAction);

                return;
            }
        } 
        else
        {
            eWare.Mode = Edit;
        }       
    }

    if (!isEmpty(recEmail("emai_PRReplicatedFromId")))
    {
        var recLink = eWare.FindRecord("vPREmail", "emai_EmailId=" + recEmail("emai_PRReplicatedFromId"));
        sMsg = "This web site/email was replicated";
        if (!recLink.eof) {
         
            if (recLink("ELink_EntityID")  == 5) {
                sMsg = sMsg + " from BBID " + recLink("ELink_RecordID");
            } 

            if (recLink("ELink_EntityID")  == 13) {
                sMsg = sMsg + " from Person ID  " + recLink("ELink_RecordID");
            } 
        }
        Response.Write("<table><tr ID=\"_trReplicated\"><td colspan=\"4\" class=\"InfoContent\">" + sMsg + "</td></tr></table>");
        sReplicateString = "InsertRow(\"_Captelink_type\", \"_trReplicated\");"; 
    }

    if ((!bIsPerson) ||
        (eWare.Mode == Edit)) {
        blkEntry.GetEntry("emai_CompanyId").Hidden = true;
    }

    if (eWare.Mode == Edit)
    {
        if (sValidationError != "") {
            var blkBanners = eWare.GetBlock('content'); 
            blkBanners.contents = sValidationError;
            blkContainer.AddBlock(blkBanners);
        }
        
        var fldType = blkEntry.GetEntry("elink_Type");
        fldType.AllowBlank = false;
        fldType.DefaultValue = "E";
        fldType.OnChangeScript = "onTypeChange();";

        blkEntry.GetEntry("emai_emailaddress").OnChangeScript = "trimString(this);";

        var dispalySaveButton = true;        
        if (bIsPerson)
        {
            // draw the select box based upon the companies this person is linked to (only when entering user emails)
            var sCompanySelectDisplay = "<table><tr id=\"tr_emai_companyid_a\"><td colspan=2 valign=top>" + 
                "<span ID=\"_Captemai_companyid_a\" class=VIEWBOXCAPTION>Company:</span><br/>" +
                "<span><select class=EDIT size=1 id=\"emai_companyid_a\" name=\"emai_companyid_a\" onchange=\"document.getElementById('emai_companyid').value = (this.options[this.selectedIndex].value != -1 ? this.options[this.selectedIndex].value : null);\">" ;

            // get the list of companies
            var sSQL = "SELECT peli_PersonId, comp_companyid, prcse_FullName " 
                     + "  FROM Person_Link WITH (NOLOCK) " 
                     + "       INNER JOIN Company WITH (NOLOCK) ON peli_CompanyId = comp_CompanyId "
                     + "       INNER JOIN PRCompanySearch WITH (NOLOCK) ON prcse_CompanyId = comp_CompanyId "
                     + " WHERE peli_PRStatus != 3 "
                     + "   AND comp_CompanyId NOT IN " 
                     + " (SELECT ISNULL(emai_CompanyId, -1) FROM vPersonEmail WHERE elink_RecordID = " + pers_personid + ((recEmail.emai_CompanyId == undefined) ? "" : "AND emai_CompanyId != " + String(recEmail.emai_CompanyId)) + ") "
                     + " AND peli_PersonId = " + pers_personid; 
            
            
        
            dispalySaveButton = false;
            var recCompanies = eWare.CreateQueryObj(sSQL);
            recCompanies.SelectSQL();
            while (!recCompanies.eof) 
            {
                dispalySaveButton = true;
                var sSelected = "";
                if (recCompanies("comp_companyid") == recEmail("emai_CompanyId"))
                    sSelected = " selected ";
                sCompanySelectDisplay += "<option " + sSelected + "value=\""+ recCompanies("comp_companyid") + "\" >"+ recCompanies("prcse_FullName") + "</option> ";
                recCompanies.NextRecord();

            }
            sCompanySelectDisplay += "</select></td></tr></table>";
            Response.Write(sCompanySelectDisplay);
            sCompanySelectDraw = "\nAppendRow(\"_Captelink_type\", \"tr_emai_companyid_a\", true);";

            if (!dispalySaveButton) {

                var unableToSaveMsg = "\n<link rel=\"stylesheet\" href=\"../../prco.css\">";
                unableToSaveMsg += "\n<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>A person can only have a single e-mail address per company and this person already has an e-mail address for each associated company.</td></tr></table>\n";
                var blkUunableToSaveMsg = eWare.GetBlock('content');
                blkUunableToSaveMsg.contents = unableToSaveMsg;
                blkContainer.AddBlock(blkUunableToSaveMsg);
            }
        }
        
        if (emai_emailid == -1)
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if ((isUserInGroup(sSecurityGroups)) &&
                (dispalySaveButton)) {
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        	}
        }
        blkEntry.ShowValidationErrors = false;
        blkContainer.AddBlock(blkEntry);
        eWare.AddContent(blkContainer.Execute(recEmail)); 
        eWare.Mode = Edit;        
        Response.Write(eWare.GetPage(entity));
    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the Email
        var sql = "DELETE FROM EmailLink WHERE ELink_EmailId=" + emai_emailid;
        var qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        sql = "DELETE FROM Email WHERE emai_emailId=" + emai_emailid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

	    Response.Redirect(sListingAction);
    }
    else // view mode
    {
        if (sInnerMsg != "")
        {
            sBannerMsg = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\">" + sInnerMsg + "</table> ";
            var blkBanners = eWare.GetBlock('content');
            blkBanners.contents = sBannerMsg;
            blkContainer.AddBlock(blkBanners);
        }

        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sListingAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
            {
                if (bAttentionLine) {
                    sDeleteUrl="javascript:alert('Please reassign the attention line to another e-mail address prior to deleting this record.');";
                } else {
                    sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
                }                            
                    
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
                blkContainer.AddButton(eWare.Button("Change", "edit.gif", "javascript:document.EntryForm.submit();"));
                
                // RSH: Allow resequencing if entity is Company
                if (!bIsPerson)
                {
                    var sResequenceAction = eWare.Url("PRCompany/PRCompanyEmailResequence.asp") + "&emai_EmailId=" + emai_emailid + "&emai_type=" + emai_type + "&comp_CompanyId=" + comp_companyid;
                    blkContainer.AddButton(eWare.Button("Resequence", "forecastrefresh.gif", "javascript:location.href='" + sResequenceAction + "';"));
                }
            }
    	}

        blkEntry.ArgObj = recEmail;
        blkContainer.AddBlock(blkEntry);
    
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        
        eWare.AddContent(blkContainer.Execute()); 
        // this doesn't necesarily have to be called in form load... just after PRGeneral.js is loaded
        eWare.AddContent("\n<script type=\"text/javascript\">transformAllDocumentCRMEmailLinks();</script>");

        Response.Write(eWare.GetPage(entity));
    }
    
    if (eWare.Mode == Edit || eWare.Mode == View)
    {
		var szInit;
        if (emai_emailid == -1) {
            szInit = "false";
        } else {
            szInit = "true";
        }

        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PREmailInclude.js\"></script>");

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI()"); 
        Response.Write("\n    { ");
        if (eWare.Mode == Edit)
        {
            Response.Write("\n      forceTableCellsToLeftAlign(\"elink_type\");");
            Response.Write("\n      selType = document.getElementById(\"elink_type\");");
            Response.Write("\n      handleOnTypeChange(selType," + szInit + ");");

            Response.Write("\n      document.getElementById('_IDemai_prpublish').onclick = togglePreferredPublished; ");
            Response.Write("\n      document.getElementById('_IDemai_prpreferredpublished').onclick = togglePublished; ");

            if (bIsPerson)
            {
                Response.Write(sCompanySelectDraw);
                Response.Write("\n      if (document.getElementById('emai_companyid_a').options.count > 0) document.getElementById('emai_companyid').value = document.getElementById('emai_companyid_a').options[document.getElementById('emai_companyid_a').selectedIndex].value");
                Response.Write("\n          RemoveDropdownItemByValue(\"elink_type\", \"W\");");
            }
        } 

        Response.Write("\n    " + sReplicateString);
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");

        //Special handling for ENTER key because other methods didn't permit suppression of the default form submit and was bypassing validation
        //Prevent default but call save()
        Response.Write("\n    window.addEventListener(\"keydown\", function(e){if(e.keyIdentifier=='U+000A'||e.keyIdentifier=='Enter'||e.keyCode==13){e.preventDefault();save();return false;}},true);");

        Response.Write("\n</script>");

        displayUserMsg();
    }
            
    %> <!-- #include file ="../RedirectTopContent.asp" --> <%
}
%>
