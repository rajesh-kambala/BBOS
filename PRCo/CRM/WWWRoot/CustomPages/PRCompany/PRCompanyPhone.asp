<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2018

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
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%

doPage();

function doPage() {
    //bDebug = true;

    //Response.Write("URL: " + sURL); 
    //Response.Write("<br>Mode: " + eWare.Mode);
    //Response.Write("<br>CompanyId: " + comp_companyid);

    var sSecurityGroups = "1,2,3,4,5,6,10";
    var phon_phoneid = getIdValue("phon_PhoneId");
    var recPhone;
    var recPhoneLink;
    
    var blkEntry=eWare.GetBlock("PhoneNewEntry");
    blkEntry.Title="Company Phone";
    var fldType = blkEntry.GetEntry("plink_Type");
    fldType.LookupFamily = "Phon_TypeCompany";
    blkContainer.CheckLocks = false; 

    // indicate that this is new
    if (phon_phoneid == -1 )
    {
        recPhone = eWare.CreateRecord("Phone");
        blkEntry.GetEntry("phon_PRDescription").DefaultValue = "Phone";
        fld = blkEntry.GetEntry("phon_CountryCode");
        if (!isEmpty(fld))
            fld.DefaultValue = "1";

        recPhoneLink = eWare.CreateRecord("PhoneLink");
        recPhoneLink("PLink_RecordID") = comp_companyid;
        recPhoneLink("PLink_EntityID") = 5;


        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    else
    {
        recPhone = eWare.FindRecord("vPRPhone", "phon_PhoneId=" + phon_phoneid);
    }

    var phon_type = recPhone("plink_Type");

    sListingAction = eWare.Url("PRCompany/PRCompanyContactInfoListing.asp") + "&T=Company&Capt=Contact+Info";
    sSummaryAction = eWare.Url("PRCompany/PRCompanyPhone.asp") + "&phon_PhoneId=" + phon_phoneid + "&T=Company&Capt=Contact+Info";

    bValidationError = false;
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

            sType = getFormValue("plink_Type");
            var sTypeCondition = "";
            if (sType == "PF")
                sTypeCondition = " AND phon_PRIsFax = 'Y' AND phon_PRIsPhone = 'Y'";
            else if (sType == "F" || sType == "SF" || sType == "EFAX" )
                sTypeCondition = " AND phon_PRIsFax = 'Y'";
            else
                sTypeCondition = " AND phon_PRIsPhone = 'Y'";	        
                        
            // Determine if the Default flag is on; if so,clear any others
            sPreferredInternal = getFormValue("phon_prpreferredinternal");
            if (sPreferredInternal == "on")
            {
                var sSQL = "UPDATE Phone SET phon_PRPreferredInternal = null FROM PhoneLink WHERE plink_PhoneID = phon_PhoneID AND PLink_EntityID = 5 AND PLink_RecordID = " + comp_companyid + sTypeCondition + " AND phon_PhoneID <> " + phon_phoneid;
                var qry = eWare.CreateQueryObj(sSQL);
                qry.ExecSQL();
            } else {
                var sSQL = "SELECT COUNT(1) As Phone_Count FROM vPRCompanyPhone WITH (NOLOCK) WHERE phon_PRPreferredInternal = 'Y' AND PLink_RecordID = " + comp_companyid + sTypeCondition + " AND phon_PhoneID <> " + phon_phoneid;
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
                var sSQL = "UPDATE Phone SET phon_PRPreferredPublished = null FROM PhoneLink WHERE plink_PhoneID = phon_PhoneID AND PLink_EntityID = 5 AND PLink_RecordID = " + comp_companyid + sTypeCondition + " AND phon_PhoneID <> " + phon_phoneid;
                var qry = eWare.CreateQueryObj(sSQL);
                qry.ExecSQL();
            } else {
                if (getFormValue("phon_prpublish") == "on") {
                    var sSQL = "SELECT Count(1) As Phone_Count FROM vPRCompanyPhone WITH (NOLOCK) WHERE phon_PRPreferredPublished = 'Y' AND PLink_RecordID = " + comp_companyid + sTypeCondition + " AND phon_PhoneID <> " + phon_phoneid;
                    var qry = eWare.CreateQueryObj(sSQL);
                    qry.SelectSQL();
                    var cnt = qry("Phone_Count");

                    if (cnt == 0) {
                       sPreferredPublished = "on";                        
                    }             
                }                    
            } 
            
            if (sPreferredInternal == "on")
                recPhone.phon_PRPreferredInternal = "Y";
            else
                recPhone.phon_PRPreferredInternal  = "";
                
            if (getFormValue("phon_prpublish") == "on")
                recPhone.phon_PRPublish = "Y";
            else
                recPhone.phon_PRPublish = "";

            if (sPreferredPublished == "on") {
                recPhone.phon_PRPreferredPublished = "Y";
            } else {
                recPhone.phon_PRPreferredPublished = "";
            }

            recPhone.phon_AreaCode = getFormValue("phon_areacode");
            recPhone.phon_Number = getFormValue("phon_number");
            recPhone.phon_PRExtension = getFormValue("phon_prextension");
            recPhone.phon_PRDescription = getFormValue("phon_prdescription");
            recPhone.phon_CountryCode = getFormValue("phon_countrycode");

            if (getFormValue("phon_prdisconnected") == "on")
                recPhone.phon_PRDisconnected = "Y";
            else
                recPhone.phon_PRDisconnected  = "";
            
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

    /// show our replication message
    var sReplicateString = "";
    if (!isEmpty(recPhone("phon_PRReplicatedFromId")) )
    {
        var recLink = eWare.FindRecord("vPRCompanyPhone", "phon_PhoneId="+recPhone("phon_PRReplicatedFromId"));
        sMsg = "This phone was replicated"

        if (!recLink.eof)
            sMsg = sMsg + " from BBID " + recLink("PLink_RecordID");
        Response.Write("<table><tr ID=\"_trReplicated\"><td colspan=\"5\" class=\"InfoContent\">"+ sMsg +"</td></tr></table>");
        sReplicateString = "InsertRow(\"_Captplink_type\", \"_trReplicated\");"; 
    }

    // hide the accpac company field.
    blkEntry.GetEntry("phon_CompanyID").Hidden = true;

    if (eWare.Mode == Edit || bValidationError)
    {
        Response.Write("<script type=\"text/javascript\" src=\"companyClient.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyPhone.js\"></script>");

        /*
         * This is a special block just used to get our 
         * hidden msg field.
         */
        var dupPhoneMsg = "";
        var sql = "SELECT dbo.ufn_GetDuplicatePhoneList(" + phon_phoneid + ") as DupPhoneMsg";
        var qryTemp = eWare.CreateQueryObj(sql);
        qryTemp.SelectSql();

        if (!qryTemp.eof) {
            var dupPhoneMsg = qryTemp("DupPhoneMsg");

            if (!isEmpty(dupPhoneMsg)) {
                var sInnerMsg = "This phone number appears on the following company/person records.  Please review to determine if those records should be updated as well.<br/><br/>" + dupPhoneMsg;
                var blkBanners = eWare.GetBlock('content');
                sBannerMsg = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>" + sInnerMsg + "</td></tr></table> ";
                blkBanners.contents = sBannerMsg;
                blkContainer.AddBlock(blkBanners);
            }
        }

        fldType = blkEntry.GetEntry("plink_Type");
        fldType.AllowBlank = false;
        fldType.DefaultValue = "P";
        fldType.OnChangeScript = "onPhoneTypeChange();"

        if (phon_phoneid == -1 )
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        }

        // get the bbos url path from custom captions
        qry = eWare.CreateQueryObj("Select Capt_US From Custom_Captions WHERE Capt_FamilyType = 'Choices' And Capt_Family = 'IntlPhoneFormatFile' And Capt_Code = 'URL'");
        qry.SelectSQL();

        var sIntlPhoneFileUrl = "";
        if (!qry.eof) {
            sIntlPhoneFileUrl = qry("Capt_US");
        }

        blkContainer.AddButton(eWare.Button("Intl Phone Formats", "info.gif", sIntlPhoneFileUrl + "\" target=\"_blank"));

        blkContainer.AddBlock(blkEntry);
        eWare.AddContent(blkContainer.Execute(recPhone)); 
        eWare.Mode = Edit;        
        Response.Write(eWare.GetPage('Company'));
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

        Response.Redirect(sListingAction);
    }
    else // view mode
    {
        var bAttentionLine = false;
        recAttnLine = eWare.FindRecord("PRAttentionLine", "prattn_PhoneID="+ phon_phoneid);
        if (!recAttnLine.eof) {
            bAttentionLine = true;
        
            var sAttnLineURL = eWare.Url("PRCompany/PRCompanyAttentionLine.asp")+ "&comp_CompanyId=" + comp_companyid;
            var sBannerMsg = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>This phone number is associated with an <a href=\"" + sAttnLineURL + "\">attention line</a>.</td></tr></table>";
            
            var blkBanners = eWare.GetBlock('content');
            blkBanners.contents = sBannerMsg;
            blkContainer.AddBlock(blkBanners);            
        }

        var blkFullNumber = eWare.GetBlock('content');
        blkFullNumber.contents = "<table><tr id=\"trFullNumber\"><td><span class=\"VIEWBOXCAPTION\">Full Phone Number:</span><br/><span class=\"VIEWBOX\">" + recPhone("phon_FullNumber") + "</span></td></tr></table>";;
        blkContainer.AddBlock(blkFullNumber); 

        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
            {
                if (bAttentionLine) {
                    sDeleteUrl="javascript:alert('Please reassign the attention line to another number prior to removing this record.');";
                } else {
                    sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
                }
                
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
                sReplicateAction = eWare.Url("PRCompany/PRCompanyReplicate.asp")+ "&RepType=1&RepId=" + phon_phoneid + "&comp_CompanyId=" + comp_companyid;
                blkContainer.AddButton(eWare.Button("Replicate", "includeall.gif", "javascript:location.href='"+sReplicateAction+"';"));
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
                sResequenceAction = eWare.Url("PRCompany/PRCompanyPhoneResequence.asp") + "&phon_PhoneId=" + phon_phoneid + "&phon_type=" + phon_type + "&comp_CompanyId=" + comp_companyid;
                blkContainer.AddButton(eWare.Button("Resequence", "forecastrefresh.gif", "javascript:location.href='"+sResequenceAction+"';"));
            }
        }
               
        blkEntry.ArgObj = recPhone;
        blkContainer.AddBlock(blkEntry);
    
        eWare.AddContent(blkContainer.Execute()); 
        Response.Write(eWare.GetPage('Company'));
    }
    
    if (eWare.Mode==Edit || eWare.Mode==View)
    {
        Response.Write("\n\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("\n<link rel=\"stylesheet\" href=\"/" + sInstallName + "/prco.css\">"); 
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI()"); 
        Response.Write("\n    { ");
        Response.Write("\n        " + sReplicateString);
        
        if (eWare.Mode==Edit)
        {        
            Response.Write("\n      document.getElementById('_IDphon_prpublish').onclick = togglePreferredPublished; ");
            Response.Write("\n      document.getElementById('_IDphon_prpreferredpublished').onclick = togglePublished; ");
        }
        
        if (eWare.Mode==View)
        {  
            Response.Write("\n      InsertRow(\"_Captplink_type\", \"trFullNumber\"); " ); 
        }

        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");

        //Special handling for ENTER key because other methods didn't permit suppression of the default form submit and was bypassing validation
        //Prevent default but call save()
        Response.Write("\n    window.addEventListener(\"keydown\", function(e){if(e.keyIdentifier=='U+000A'||e.keyIdentifier=='Enter'||e.keyCode==13){e.preventDefault();save();return false;}},true);");

        Response.Write("\n</script>");

        Response.Write("\n</script>");
    }
}
%>
<!-- #include file="CompanyFooters.asp" -->