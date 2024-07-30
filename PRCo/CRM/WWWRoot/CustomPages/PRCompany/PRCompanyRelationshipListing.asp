<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->

<!-- #include file ="..\PRTES\PRTESCustomRequestFunctions.asp" -->

<%

    Server.ScriptTimeout = 300;
    Session("RelationshipReturnURL") = null;

    Session.Contents.Remove("LastEntryType");

    blkContainer.CheckLocks = false;

    var blkGeneralContent = eWare.GetBlock("content");
    blkGeneralContent.Contents = "\n\n<!-- " + new Date().toString()  + " -->\n";
    blkGeneralContent.Contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
    //blkGeneralContent.Contents += "<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n\n";
    blkContainer.AddBlock(blkGeneralContent);

    if(getFormValue("_hiddenDelete") == "Y") {
        var SCRList = getFormValue("_hiddenDeleteSCRList");
        var RCRList = getFormValue("_hiddenDeleteRCRList");
        var UniqueList = getFormValue("_hiddenDeleteUniqueList");
        
        var qrySCR = "UPDATE PRCompanyRelationship SET prcr_Active=NULL WHERE prcr_RightCompanyID IN (" + SCRList +") AND prcr_LeftCompanyID=" + comp_companyid;
        var qryRCR = "UPDATE PRCompanyRelationship SET prcr_Active=NULL WHERE prcr_LeftCompanyID IN (" + RCRList +") AND prcr_RightCompanyID=" + comp_companyid;
        
        //Response.Write("SCR: " + qrySCR + "<br/>");
        //Response.Write("RCR: " + qryRCR + "<br/>");

        if(SCRList != "")
        {	    
            var recSCR = eWare.CreateQueryObj(qrySCR);
    	    recSCR.ExecSql();
            //Response.Write("qrySCR executed<br/>");
        }

        if(RCRList != "")
        {	
            var recRCR = eWare.CreateQueryObj(qryRCR);
	        recRCR.ExecSql();
            //Response.Write("qryRCR executed<br/>");
        }

        if(UniqueList != "")
        {	
            var arrUnique = UniqueList.split(",");
            for(var i=0; i<arrUnique.length; i++)
            {
                var c = arrUnique[i];
                var qryUnique = "UPDATE PRCompanyRelationship SET prcr_Active=NULL WHERE (prcr_LeftCompanyID=" + c + " OR prcr_RightCompanyID=" + c +") AND (prcr_LeftCompanyID=" + comp_companyid + " OR prcr_RightCompanyID=" + comp_companyid + ")";
                
                //Response.Write("Unique: " + qryUnique + "<br/>");
                var recUnique = eWare.CreateQueryObj(qryUnique);
	            recUnique.ExecSql();
            }

            //Response.Write("qryUnique executed<br/>");
        }
    }

	/*
	 * Build the Filter block resetting a few captions
	 */
	var blkFilter = eWare.GetBlock("PRCompanyRelationshipFilterBox");
    blkFilter.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.submit();" ));
    blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:clear();"));
	blkFilter.Title = "Filter By:"
	
    blkFilter.GetEntry("prcr_ReportingCompanyType").caption = "Reporting Company:";
    blkFilter.GetEntry("comp_PRListingStatus").caption = "Related Company Listing Status:";
    blkFilter.GetEntry("comp_PRIndustryType").caption = "Related Company Industry Type:";
    blkFilter.GetEntry("CategoryType").caption = "Category Type:";
    blkFilter.GetEntry("prcr_Type").caption = "Relationship Type:";
    blkFilter.GetEntry("prcr_Type").LookupFamily = "prcr_TypeFilter";
    blkFilter.GetEntry("prcr_Type").DefaultValue = "";
    blkFilter.GetEntry("prcr_Active").caption = "Active Relationships Only";
    blkFilter.GetEntry("prcr_InvestigationType").DefaultValue = "M";
    blkContainer.AddBlock(blkFilter);


    /*
     * Build the Relationship Info block
     */
	var recRelationshipInfo = eWare.FindRecord("vPRCompanyRelationshipInfo", "comp_CompanyId=" + comp_companyid);
	blkRelationshipInfo = eWare.GetBlock("PRCompanyRelationshipInfo");
	blkRelationshipInfo.Title = "Relationship Info";
	blkRelationshipInfo.ArgObj = recRelationshipInfo;
    blkContainer.AddBlock(blkRelationshipInfo);

    /*
     * This is a special block just used to get our 
     * hidden sort fields on the form
     */
    var blkSorting = eWare.GetBlock("content");
    blkSorting.Contents = "<input type=\"hidden\" name=\"_hiddenSortColumn\"><input type=\"hidden\" name=\"_hiddenSortGrid\"><input type=\"hidden\" name=\"_hiddenInvestigationType\"><input type=\"hidden\" name=\"_hiddenCreateTES\" id=\"_hiddenCreateTES\"><input type=\"hidden\" name=\"_hiddenTESInteractionStatus\" id=\"_hiddenTESInteractionStatus\" value=\"Pending\"><input type=\"hidden\" name=\"_hiddenFirstTime\" value=\"N\"><input type=\"hidden\" name=\"_hiddenDelete\" id=\"_hiddenDelete\" value=\"N\"><input type='hidden' name='_hiddenDeleteSCRList' id='_hiddenDeleteSCRList' value=''><input type='hidden' name='_hiddenDeleteRCRList' id='_hiddenDeleteRCRList' value=''><input type='hidden' name='_hiddenDeleteUniqueList' id='_hiddenDeleteUniqueList' value=''>"
    blkContainer.AddBlock(blkSorting);

    var blkDialog = eWare.GetBlock("Content");
    var sDialog = "\n\n<div id=\"pnlEdit\" class=\"Popup\" style=\"width:400px;display:none;\">\n";
    sDialog += "<span style=\"font-family:Tahoma,Arial;font-size:12px;font-weight:bold;\">Are you sure you want to send a TES to the selected companies?</span>\n";
    sDialog += "<p style=\"text-align:center;font-family:Tahoma,Arial;font-size:12px;\"><input type=\"checkbox\" id=\"cbCloseIneteraction\" /><label for=\"cbCloseIneteraction\">Close custom investigation interaction?</label></p>\n"
    sDialog += "<p style=\"text-align:center;\"><button onclick=\"createTES();return false;\">Create TES</button> <button onclick=\"cancelTES();return false;\">Cancel</button></p>\n";
    sDialog += "</div>\n\n";
    blkDialog.contents = sDialog;
    blkContainer.AddBlock(blkDialog);

    if (getFormValue("_hiddenCreateTES") == "Y") {
        var szCompanyIDs = Request.Form.Item("cbInvestigation").item;

         if (getFormValue("prcr_InvestigationType") == "M") {
            var szMessage = createTES3(comp_companyid, szCompanyIDs, null, null, user_userid, "", getFormValue("_hiddenTESInteractionStatus"));
         } else {
            Session("VICompanyIDs") = szCompanyIDs;         
            Response.Redirect(eWare.Url("PRTES/PRVerbalInvestigationSelect.asp")+ "&comp_CompanyID="+ comp_companyid);
         }
    }

    if ((getFormValue("uniquerelationshipsonly") == "NotChecked") ||
        (isEmpty(getFormValue("uniquerelationshipsonly")))) {

        /*
         * Build the Subject Company Reported grid
         */
        lstSCR = eWare.GetBlock("content");
        lstSCR.Contents = GetSCRGrid();
        blkContainer.AddBlock(lstSCR);
     	
        /*
         * Build the Related Company Reported grid
         */
        lstRCR = eWare.GetBlock("content");
        lstRCR.Contents = GetRCRGrid();
        blkContainer.AddBlock(lstRCR);
    } else {
        lstUnique = eWare.GetBlock("content");
        lstUnique.Contents = GetUniqueGrid();
        blkContainer.AddBlock(lstUnique);
    }
    
    
    // this button is intentionally not protected by transaction management
    // the type of relationship that is available will change based upon if the trx is open or not
    tabContext = "&T=Company&Capt=Relationships";

    blkContainer.AddButton(eWare.Button("New Relationship", "New.gif", eWare.URL("PRCompany/PRCompanyRelationship.asp") + tabContext));
    blkContainer.AddButton(eWare.Button("Manage Reference List", "Continue.gif", eWare.URL("PRCompany/PRConnectionListListing.asp") + tabContext));
    blkContainer.AddButton(eWare.Button("New Reference List","new.gif",  eWare.Url("PRCompany/PRConnectionListAdd.asp") + tabContext));
    blkContainer.AddButton(eWare.Button("Ownership", "ShowCampaigns.gif", eWare.URL("PRCompany/PRCompanyOwnership.asp") + tabContext));
    

    if (recCompany.comp_PRLocalSource !=  "Y") {
        if ((getFormValue("prcr_InvestigationType") == "M") ||
            (getFormValue("_hiddenFirstTime") != "N")) {
            blkContainer.AddButton(eWare.Button("Create TES Request","new.gif","javascript:confirmTES();"));
            blkContainer.AddButton(eWare.Button("TES Second Requests", "new.gif", eWare.URL("PRTES/PRTESCustomRequest.asp") + "&prte_customtesrequest=6" + tabContext) );
        }

        if (getFormValue("prcr_InvestigationType") == "V") {
            blkContainer.AddButton(eWare.Button("Verbal Investigation","new.gif","javascript:confirmTES();"));
        }
    }

    if (recCompany("comp_PRIndustryType") != "S") {
        var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
        var recSSRS = eWare.CreateQueryObj(sSQL);
        recSSRS.SelectSQL();                
        var SSRSURL = getValue(recSSRS("SSRSURL"));
        blkContainer.AddButton(eWare.Button("Reference List Report","componentpreview.gif", "javascript:openConnectionListReport(" + comp_companyid + ", '" + recCompany("comp_PRIndustryType") + "')"));
    }

    blkContainer.AddButton(eWare.Button("Delete","delete.gif", "javascript:DeleteRelationships();"));

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));
    Response.Write("<!-- " + new Date().toString()  + " -->");

%>

        <script type="text/javascript">
            function initBBSI() {
                RemoveDropdownItemByName("DateTimeModesprcr_lastreporteddate", "Relative");
                RemoveDropdownItemByName("DateTimeModeslastformsent", "Relative");
                RemoveDropdownItemByName("DateTimeModeslastformresponse", "Relative");

                // finish setting properties that cannot be set through accpac functions
                RemoveDropdownItemByName("prcr_reportingcompanytype", "--None--");
                RemoveDropdownItemByName("prcr_type", "--None--");
                RemoveDropdownItemByValue("prcr_type", "27");
                RemoveDropdownItemByValue("prcr_type", "28");
                RemoveDropdownItemByValue("prcr_type", "29");
                
                
                RemoveDropdownItemByName("categorytype", "--None--");
                RemoveDropdownItemByName("comp_prlistingstatus", "--None--");
                RemoveDropdownItemByName("comp_prindustrytype", "--None--");
                
                RemoveDropdownItemByName("prcr_InvestigationType", "--All--");
                
                eUniqueOnly = document.getElementsByName("uniquerelationshipsonly");
                eUniqueOnly[2].parentElement.style.display = 'none';

                eUniqueOnly[0].onclick = toggleUniqueOnly;
                eUniqueOnly[1].onclick = toggleUniqueOnly;                

<% if (getFormValue("_hiddenFirstTime") != "N") { %>                
                clear();
                eUniqueOnly[1].checked = true;
                document.getElementsByName("prcr_active")[0].checked = true;                
<% } %>                
                

                toggleUniqueOnly();                
<% if (szMessage != null) { %>                
                alert("<% =szMessage %>");
<% } %>                

            }
            
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }

            function clear() {
                document.EntryForm.prcr_rightcompanyid.value= "";
                document.EntryForm.categorytype.value= "";
                document.EntryForm.prcr_type.value= "";
                document.EntryForm.prcr_reportingcompanytype.value= "";
                document.EntryForm.uniquerelationshipsonly.checked = false;
                document.EntryForm.comp_prlistingstatus.value= "";
                document.EntryForm.comp_prindustrytype.value= "";
                document.EntryForm.lastformsent_start.value= "";
                document.EntryForm.lastformsent_end.value= "";
                document.EntryForm.lastformresponse_start.value= "";
                document.EntryForm.lastformresponse_end.value= "";
                document.EntryForm.prcr_lastreporteddate_start.value= "";
                document.EntryForm.prcr_lastreporteddate_end.value= "";
                document.getElementsByName("prcr_active")[0].checked = true;
                document.EntryForm.prcr_investigationtype.value= "M";
                
                Clearprcr_rightcompanyid();
                toggleUniqueOnly();
            }

            function toggleUniqueOnly() {
           
                eUniqueOnly = document.getElementsByName("uniquerelationshipsonly");
                eAciveOnly = document.getElementsByName("prcr_active");
                            
                if (eUniqueOnly[0].checked) {
                    document.getElementById("prcr_reportingcompanytype").disabled = false;
                    //document.all.categorytype.disabled = true;
                    document.getElementById("prcr_type").disabled = true; 
                    eAciveOnly[0].checked = true; 
                    eAciveOnly[1].disabled = true; 
                    eAciveOnly[0].disabled = true; 
                } else {
                    document.getElementById("prcr_reportingcompanytype").disabled = true;
                    //document.all.categorytype.disabled = false;
                    document.getElementById("prcr_type").disabled = false; 
                    eAciveOnly[0].disabled = false; 
                    eAciveOnly[1].disabled = false; 
                }
            }

            // Determines if any checkboxes on the current
            // page with the specified name prefix are checked.
            function confirmTES() {
                var oCheckboxes = document.body.getElementsByTagName("INPUT");

                var bChecked = false;
                for (var i = 0; i < oCheckboxes.length; i++) {
                    if ((oCheckboxes[i].type == "checkbox") &&
		                (oCheckboxes[i].name.indexOf("cbInvestigation") == 0)) {

                        if (oCheckboxes[i].checked) {
                            bChecked = true;
                            break;
                        }
                    }
                }

                document.getElementById("_hiddenCreateTES").value = "";
                if (!bChecked) {
                    alert("Please select a company to send a TES to.");
                    return;

                } 
                
                if (document.EntryForm.prcr_investigationtype.value == "V") {
                    document.getElementById("_hiddenCreateTES").value = "Y";
                    document.EntryForm.submit();
                } else {
                    document.getElementById("pnlEdit").style.display = "";
                    document.getElementById('pnlEdit').style.position = "fixed";
                    document.getElementById('pnlEdit').style.top = "50%";
                    document.getElementById('pnlEdit').style.left = "50%";
                    document.getElementById('pnlEdit').style.display = 'block';
                }
            }            

            function createTES() {
                document.getElementById("_hiddenCreateTES").value = "Y";

                if (document.getElementById("cbCloseIneteraction").checked) {
                    document.getElementById("_hiddenTESInteractionStatus").value = "Complete";
                }

                document.EntryForm.submit();
            }

            function cancelTES() {
                document.getElementById("pnlEdit").style.display = "none";
            }

            function openConnectionListReport(companyID, industryType) {
                var sReportURL = "<% =SSRSURL %>";

                switch(industryType) {
                    case "P":
                        sReportURL += "/Rating Metrics/Connection List - Produce";
                        break;
                    case "T":
                        sReportURL += "/Rating Metrics/Connection List - Transportation";
                        break;
                    case "L":
                        sReportURL += "/Rating Metrics/Connection List - Lumber";
                        break;
                }
                sReportURL += "&rc:Parameters=false";
                sReportURL += "&rs:Format=PDF";
                sReportURL += "&CompanyID=" + companyID;
                //sReportURL += "&x:dummy=" + getUniqueString();

                window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=1000,height=600", true);
            }

            function DeleteRelationships() {
                var oCheckboxes = document.body.getElementsByTagName("INPUT");
                var SCRList = "";
                var RCRList = "";
                var UniqueList = "";

                for (var i = 0; i < oCheckboxes.length; i++) {
                    if ((oCheckboxes[i].type == "checkbox") &&
                        (oCheckboxes[i].name.indexOf("cbInvestigation") == 0)) {

                        if (oCheckboxes[i].checked) {
                            if (oCheckboxes[i].getAttribute("grid") == "RCRGrid")
                                RCRList = RCRList + oCheckboxes[i].value + ",";
                            else if (oCheckboxes[i].getAttribute("grid") == "SCRGrid")
                                SCRList = SCRList + oCheckboxes[i].value + ",";
                            else if (oCheckboxes[i].getAttribute("grid") == "UniqueGrid") {
                                UniqueList = UniqueList + oCheckboxes[i].value + ",";
                            }
                        }
                    }
                }

                var len = SCRList.length;
                if (SCRList.substr(len - 1, 1) == ",") {
                    SCRList = SCRList.substring(0, len - 1);
                }

                len = RCRList.length;
                if (RCRList.substr(len - 1, 1) == ",") {
                    RCRList = RCRList.substring(0, len - 1);
                }

                len = UniqueList.length;
                if (UniqueList.substr(len - 1, 1) == ",") {
                    UniqueList = UniqueList.substring(0, len - 1);
                }

                if (SCRList.length > 0 || RCRList.length > 0 || UniqueList.length > 0) {
                    document.getElementById("_hiddenDelete").value = "Y";
                    document.getElementById("_hiddenDeleteRCRList").value = RCRList;
                    document.getElementById("_hiddenDeleteSCRList").value = SCRList;
                    document.getElementById("_hiddenDeleteUniqueList").value = UniqueList;
                }
                else {
                    document.getElementById("_hiddenDelete").value = "N";
                    document.getElementById("_hiddenDeleteRCRList").value = "";
                    document.getElementById("_hiddenDeleteSCRList").value = "";
                    document.getElementById("_hiddenDeleteUniqueList").value = "";
                }

                document.EntryForm.submit();
            }
        </script>

<!-- #include file="CompanyFooters.asp" -->

<%


/*
 * Helper function that sets both the caption and a
 * default value for a field
 */
function SetFieldDefault(entry, szDefaultValue, szCaption) {
    if (szCaption != null) 
        entry.Caption = szCaption + ":";
            
    if (!isEmpty(szDefaultValue))
	    entry.DefaultValue = szDefaultValue;
}

/*

function GetUniqueRelationshipCount() {

    var whereClause = "";
    if (getFormValue("prcr_Active") == "Checked") {
        whereClause += " WHERE Active='Y' ";
    }

    recCount = eWare.CreateQueryObj("SELECT COUNT(DISTINCT CompanyID) As Cnt FROM dbo.ufn_GetCompanyRelationships(" + comp_companyid + ") " + whereClause);
    recCount.SelectSQL();

    var iCount = 0;    
    if (!recCount.eof)  {
        iCount = recCount("Cnt");
    }    

    return iCount;
}
*/


/*
 * Helper function that builds a WHERE clause from the Filter block.  Note that
 * the Related Company is not included in this as it is applied to different
 * columns depending upon the grid.
 */
function GetFilterClause(isUnique) {
    var szWhereClause = "";

    szWhereClause += addCondition("prcr_Type", getFormValue("prcr_Type"));

    // This criteria is applied elsewhere.
    if (!isUnique) {
        szWhereClause += addCondition("prcr_CategoryType", getFormValue("categorytype"));
    }
    szWhereClause += addCondition("comp_PRListingStatus", getFormValue("comp_prlistingstatus"));
    szWhereClause += addCondition("comp_PRIndustryType", getFormValue("comp_prindustrytype"));
    szWhereClause += addDateRangeCondition("LastFormSent", getFormValue("lastformsent_start"), getFormValue("lastformsent_end"));
    szWhereClause += addDateRangeCondition("LastFormResponse", getFormValue("lastformresponse_start"), getFormValue("lastformresponse_end"));
    szWhereClause += addDateRangeCondition("prcr_LastReportedDate", getFormValue("prcr_lastreporteddate_start"), getFormValue("prcr_lastreporteddate_end"));

    // If this is a unique list, the active filter is applied
    // to an inner SQL clause in the unique SQL statement.
    if (!isUnique) {
        if ((getFormValue("prcr_Active") == "Checked") ||
            (getFormValue("_hiddenFirstTime") != "N")) {
            szWhereClause += " AND prcr_Active='Y'";
        }
    }

    return szWhereClause;
} 

function GetSCRGrid() {

    var szWhereClause = ""
    var prcr_RightCompanyId = getFormValue("prcr_RightCompanyId");
	if (!isEmpty(prcr_RightCompanyId))
        szWhereClause += " AND prcr_RightCompanyId=" + prcr_RightCompanyId;

    szWhereClause += GetFilterClause(false);
  
    sSQL = "SELECT prcr_RightCompanyID As CompanyID, dbo.ufn_GetClassificationAbbrForList(prcr_RightCompanyID, 3) As ClassifAbbr, * " +
             "FROM vPRCompanyRelationshipSCR " +
            "WHERE prcr_LeftCompanyID = " + comp_companyid;
    if (szWhereClause != "") {
        sSQL += szWhereClause;
    }
    sSQL += GetSortClause("SCRGrid", "CompanyName", "ASC");
    
    //Response.Write("SCRGrid: " + sSQL);

    recCompanyRelationships = eWare.CreateQueryObj(sSQL);
    recCompanyRelationships.SelectSQL();
   
    return buildRelationshipGrid(recCompanyRelationships,
                                 "SCRGrid",
                                 " Subject Company Reported Relationships");
}   
 

 
function GetRCRGrid() {

    var szWhereClause = ""
    var prcr_RightCompanyId = getFormValue("prcr_RightCompanyId");
	if (!isEmpty(prcr_RightCompanyId))
        szWhereClause += " AND prcr_LeftCompanyId=" + prcr_RightCompanyId;

    szWhereClause += GetFilterClause(false);

    sSQL = "SELECT prcr_LeftCompanyID As CompanyID, dbo.ufn_GetClassificationAbbrForList(prcr_LeftCompanyID, 3) As ClassifAbbr, * " +
             "FROM vPRCompanyRelationshipRCR " +
            "WHERE prcr_RightCompanyID = " + comp_companyid;
    if (szWhereClause != "") {
        sSQL += szWhereClause;
    }
    sSQL += GetSortClause("RCRGrid", "CompanyName", "ASC");
   
   
    //Response.Write("RCRGrid: " + sSQL);
    
    recCompanyRelationships = eWare.CreateQueryObj(sSQL);
    recCompanyRelationships.SelectSQL();
   
    return buildRelationshipGrid(recCompanyRelationships,
                                 "RCRGrid",
                                 " Related Company Reported Relationships");
}  

function GetUniqueGrid() {
    var szCompanyRelationshipClause = ""
    var szCompanyRelationshipType = getFormValue("prcr_ReportingCompanyType");
    if (szCompanyRelationshipType == "1") {
        szCompanyRelationshipClause = "prcr_RightCompanyID=" + comp_companyid;
    }
    if (szCompanyRelationshipType == "2") {
        szCompanyRelationshipClause = " prcr_LeftCompanyID=" + comp_companyid;
    }

    var prcr_RightCompanyId = getFormValue("prcr_RightCompanyId");
    if (!isEmpty(prcr_RightCompanyId)) {
        if (szCompanyRelationshipClause != "") {
            szCompanyRelationshipClause = " AND ";
        }
    
        szCompanyRelationshipClause += "(prcr_LeftCompanyID=" + prcr_RightCompanyId + " OR prcr_RightCompanyID=" + prcr_RightCompanyId + ")";
    }
    
    if (getFormValue("prcr_Active") == "Checked") {
        if (szCompanyRelationshipClause != "") {
            szCompanyRelationshipClause = " AND ";
        }

        szCompanyRelationshipClause += " Active='Y' ";
    }
    
    if (szCompanyRelationshipClause != "") {
        szCompanyRelationshipClause = "WHERE " + szCompanyRelationshipClause;
    }

    sSQL = "SELECT CompanyID, " + 
                  "prcse_FullName as CompanyName, " +
                  "LastFormSent,  " +
                  "LastFormResponse,  " +
                  "prcr_LastReportedDate,  " +
                  "comp_PRListingStatus, " +
                  "comp_PRIndustryType, " +
                  "tes_e.DeliveryAddress as TES_E_DeliveryAddress, " +
                  "tes_v.DeliveryAddress as TES_V_DeliveryAddress, " +
                  "comp_PRReceiveTES, " +
                  "comp_PRReceiveTESCode, " +
                  "dbo.ufn_IsEligibleForManualTES(CompanyID, " + comp_companyid + ") As EligibleForTES, " +
                  "dbo.ufn_GetClassificationAbbrForList(CompanyID, 3) As ClassifAbbr, " +
                  "comp_PRTESNonresponder " +
             "FROM (SELECT CompanyID, MAX(LastReportedDate) as [prcr_LastReportedDate] FROM dbo.ufn_GetCompanyRelationships(" + comp_companyid + ") " + szCompanyRelationshipClause + " GROUP BY CompanyID) TableA  " +
		           "INNER JOIN PRCompanySearch WITH (NOLOCK) on prcse_CompanyID = CompanyID  " +
		           "INNER JOIN Company WITH (NOLOCK) on comp_CompanyID = CompanyID  " +
		           "LEFT OUTER JOIN vPRCompanyAttentionLine tes_e WITH (NOLOCK) ON tes_e.prattn_CompanyID = CompanyID AND tes_e.prattn_ItemCode = 'TES-E' AND tes_e.prattn_Disabled IS NULL " +
                   "LEFT OUTER JOIN vPRCompanyAttentionLine tes_v WITH (NOLOCK) ON tes_v.prattn_CompanyID = CompanyID AND tes_v.prattn_ItemCode = 'TES-V' AND tes_v.prattn_Disabled IS NULL " +
                   "LEFT OUTER JOIN vPRTESLastFormSent ON prtesr_ResponderCompanyID = CompanyID AND prtesr_SubjectCompanyID = " + comp_companyid + " " +
                   "LEFT OUTER JOIN vPRTradeReportLastResponse ON prtr_ResponderID = CompanyID AND prtr_SubjectID = " + comp_companyid;

    var szWhereClause = GetFilterClause(true);    
    if (szWhereClause != "") {
        sSQL += " WHERE 1=1 " + szWhereClause;
    }
    
    sSQL += GetSortClause("UniqueGrid", "CompanyName", "ASC");    

    //Response.Write("Unique: " + sSQL);

    recCompanyRelationships = eWare.CreateQueryObj(sSQL);
    recCompanyRelationships.SelectSQL();
   
    return buildRelationshipGrid(recCompanyRelationships,
                                 "UniqueGrid",
                                 " Unique Relationships");
}
 
function buildRelationshipGrid(recCompanyRelationships,
                               sGridName,
                               sGridTitle) {  

    var sWorkContent = "";
    var Content01 = "";
    var Content02 = "";
    var Content03 = "";
    var Content04 = "";
    var Content05 = "";
    var Content06 = "";
    var Content07 = "";
    var Content08 = "";
    var Content09 = "";
    var Content10 = "";
    var Content11 = "";
    var Content12 = "";
    var Content13 = "";
    var Content14 = "";
    var Content15 = "";
    var Content16 = "";
    var Content17 = "";
    var Content18 = "";
    var Content19 = "";
    var Content20 = "";    

    var Content21 = "";
    var Content22 = "";
    var Content23 = "";
    var Content24 = "";
    var Content25 = "";
    var Content26 = "";
    var Content27 = "";
    var Content28 = "";
    var Content29 = "";
    var Content30 = "";
    var Content31 = "";
    var Content32 = "";
    var Content33 = "";
    var Content34 = "";
    var Content35 = "";
    var Content36 = "";
    
    //Response.Write("<br/>" + sGridName + " Start: " + new Date());
   
    var sContent;
    sContent = createAccpacBlockHeader("SCRGrid", recCompanyRelationships.RecordCount + sGridTitle);

    sContent += "\n\n<table class=\"CONTENT\" border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width='100%' >" +
                "\n<thead>" +
                "\n<tr>" +
                "\n<td class=\"GRIDHEAD\" align=\"center\">Select<br><input type=\"checkbox\" id=\"cbAll\" onclick=\"CheckAll2('" + sGridName + "', 'cbInvestigation', this.checked);\"></TD> " +
                "<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Company", "CompanyName") + "</TD> " +
                "<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Classifications", "ClassifAbbr") + "</TD> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Receive TES", "comp_PRReceiveTES") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Last TES<br/>Form Sent", "LastFormSent") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Last Trade Report<br/>Received", "LastFormResponse") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Last Relationship<br/>Reported Date", "prcr_LastReportedDate") + "</td> ";

    if (sGridName != "UniqueGrid") {
        sContent += "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Relationship Type", "TypeDisplay") + "</td> ";
        sContent += "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Active", "prcr_Active") + "</td>";
    }
    
    sContent += "\n</tr>";
    sContent += "\n</thead>";

    var sInvestigationType = getFormValue("prcr_InvestigationType")
    if ((sInvestigationType == "undefined") &&
        (getFormValue("_hiddenFirstTime") != "N")) {
        sInvestigationType = "M";
    }

    sClass = "ROW2";
    var iCount = 0;
    while (!recCompanyRelationships.eof)
    {
        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }
    
        sWorkContent += "\n<tr>";
        
        var sSelect = "<td class=\"" + sClass + "\"></td>";

        if (sInvestigationType == "M") {
            if ((!isEmpty(recCompanyRelationships("TES_E_DeliveryAddress"))) &&
                (recCompanyRelationships("comp_PRReceiveTES") == "Y") &&
                (isEmpty(recCompanyRelationships("comp_PRReceiveTESCode"))) && 
                (recCompanyRelationships("EligibleForTES") == 1)) {
                sSelect = "<td class=\"" + sClass + "\" align=\"center\"><input type=\"checkbox\" name=\"cbInvestigation\" class=\"smallcheck\"  value=" + recCompanyRelationships("CompanyID") + " grid=" + sGridName + "></td>";
            }
        }

        if (sInvestigationType == "V") {
            if ((!isEmpty(recCompanyRelationships("TES_V_DeliveryAddress"))) &&
                (recCompanyRelationships("EligibleForTES") == 1)) {
                sSelect = "<td class=\"" + sClass + "\" align=\"center\"><input type=\"checkbox\" name=\"cbInvestigation\" class=\"smallcheck\"  value=" + recCompanyRelationships("CompanyID") + " grid=" + sGridName + "></td>";
            }
        }
        
        sWorkContent += sSelect;

        sWorkContent += "<td class=\"" + sClass + "\"><a href=\"" + eWareUrl("PRCompany/PRCompanySummary.asp") + "&comp_CompanyID=" + recCompanyRelationships("CompanyID") + "\">" + recCompanyRelationships("CompanyName") + "</a></td>";
        sWorkContent += "<td class=\"" + sClass + "\">" + getValue(recCompanyRelationships("ClassifAbbr")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recCompanyRelationships("comp_PRReceiveTES")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getDateValue(recCompanyRelationships("LastFormSent")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getDateValue(recCompanyRelationships("LastFormResponse")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getDateValue(recCompanyRelationships("prcr_LastReportedDate")) + "</td>";
        
        if (sGridName != "UniqueGrid") {
            sWorkContent += "<td class=" + sClass + "><a href=" + eWareUrl("PRCompany/PRCompanyRelationship.asp") + "&Key0=1&Key1=" + comp_companyid + "&prcr_CompanyRelationshipId=" + recCompanyRelationships("prcr_CompanyRelationshipId") + ">" + getValue(recCompanyRelationships("TypeDisplay")) + "</a></td>";
            sWorkContent += "<td class=" + sClass + " align=center>" + getValue(recCompanyRelationships("prcr_Active")) + "</td>";
        }            
        sWorkContent += "</tr>";
        
        iCount++;
        
        // This is to deal with large numbers of records.  We keep appending to the same string, but since
        // string are immutable, we are allocating memory at an exponential pace, thus the last 500 records
        // can take 10 times as long to process as the first 500 records.  This is purposely not in an array.
        switch(iCount) {
            case 50: 
                Content01 = sWorkContent;
                sWorkContent = "";
                break;
            case 100: 
                Content02 = sWorkContent;
                sWorkContent = "";
                break;
            case 150: 
                Content03 = sWorkContent;
                sWorkContent = "";
                break;
            case 200: 
                Content04 = sWorkContent;
                sWorkContent = "";
                break;
            case 250: 
                Content05 = sWorkContent;
                sWorkContent = "";
                break;
            case 300: 
                Content06 = sWorkContent;
                sWorkContent = "";
                break;
            case 350: 
                Content07 = sWorkContent;
                sWorkContent = "";
                break;
            case 400: 
                Content08 = sWorkContent;
                sWorkContent = "";
                break;
            case 450: 
                Content09 = sWorkContent;
                sWorkContent = "";
                break;
            case 500: 
                Content10 = sWorkContent;
                sWorkContent = "";
                break;
            case 550: 
                Content11 = sWorkContent;
                sWorkContent = "";
                break;
            case 600: 
                Content12 = sWorkContent;
                sWorkContent = "";
                break;
            case 650: 
                Content13 = sWorkContent;
                sWorkContent = "";
                break;
            case 700: 
                Content14 = sWorkContent;
                sWorkContent = "";
                break;
            case 750: 
                Content15 = sWorkContent;
                sWorkContent = "";
                break;
            case 800: 
                Content16 = sWorkContent;
                sWorkContent = "";
                break;
            case 800: 
                Content17 = sWorkContent;
                sWorkContent = "";
                break;
            case 900: 
                Content18 = sWorkContent;
                sWorkContent = "";
                break;
            case 1500: 
                Content19 = sWorkContent;
                sWorkContent = "";
                break;
            case 2000: 
                Content20 = sWorkContent;
                sWorkContent = "";
                break;
            case 2500: 
                Content21 = sWorkContent;
                sWorkContent = "";
                break;
            case 3000: 
                Content22 = sWorkContent;
                sWorkContent = "";
                break;
            case 35000: 
                Content23 = sWorkContent;
                sWorkContent = "";
                break;
            case 4000: 
                Content24 = sWorkContent;
                sWorkContent = "";
                break;
            case 4500: 
                Content25 = sWorkContent;
                sWorkContent = "";
                break;
            case 5000: 
                Content26 = sWorkContent;
                sWorkContent = "";
                break;
            case 5500: 
                Content27 = sWorkContent;
                sWorkContent = "";
                break;
            case 6000: 
                Content28 = sWorkContent;
                sWorkContent = "";
                break;
            case 6500: 
                Content29 = sWorkContent;
                sWorkContent = "";
                break;
            case 7000: 
                Content30 = sWorkContent;
                sWorkContent = "";
                break;
            case 7500: 
                Content31 = sWorkContent;
                sWorkContent = "";
                break;
            case 8000: 
                Content32 = sWorkContent;
                sWorkContent = "";
                break;
            case 8500: 
                Content33 = sWorkContent;
                sWorkContent = "";
                break;
            case 9000: 
                Content34 = sWorkContent;
                sWorkContent = "";
                break;
            case 9500: 
                Content35 = sWorkContent;
                sWorkContent = "";
                break;
            case 10000: 
                Content36 = sWorkContent;
                sWorkContent = "";
                break;

        }        
        recCompanyRelationships.NextRecord();
    }      
    
    sContent += Content01 + Content02 + Content03 + Content04 + Content05 + Content06 + Content07 + Content08 + Content09 + Content10 + 
                Content11 +  Content12 +  Content13 +  Content14 +  Content15 +  Content16 +  Content17 +  Content18 +  Content19 +  Content20 + 
                Content21 +  Content22 +  Content23 +  Content24 +  Content25 +  Content26 +  Content27 +  Content28 +  Content29 +  Content30 +
                Content31 + Content32 + Content33 + Content34 + Content35 + Content36 + sWorkContent;
    
    while (iCount < 10) {

        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }

        sContent += "\n<tr><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td>";
        if (sGridName != "UniqueGrid") {
            sContent += "<td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td>";
        }            
        sContent += "</tr>";
    
        iCount ++;
    }
    
    sContent += "\n</table>";
    sContent += createAccpacBlockFooter();
    
    //Response.Write("<br/>" + sGridName + " End: " + new Date());    
    return sContent;
}

%>