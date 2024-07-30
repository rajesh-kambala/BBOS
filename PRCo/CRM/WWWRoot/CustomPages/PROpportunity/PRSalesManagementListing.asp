<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2016

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

<%

    var key0 = Request.QueryString("Key0");
    doPage();
  

function doPage() {

    var message = "";
    if (getFormValue("_hiddenUpdate") == "Y") {
    
        //DumpFormValues();
    
        var oppoIDs = Request.Form.Item("cbOpportunity").item;

        var setClause = "SET oppo_UpdatedBy=" + user_userid + ", oppo_UpdatedDate=GETDATE(), oppo_Timestamp=GETDATE()";
        setClause += getSetClause("update_prlostreason", "oppo_PRLostReason");
        setClause += getSetClause("update_assignedto", "oppo_AssignedUserId");
        setClause += getSetClause("update_status", "oppo_Status");
        setClause += getSetClause("update_stage", "oppo_Stage");
        setClause += getSetClause("update_certainty", "oppo_PRCertainty");
        setClause += getSetClause("update_priority", "oppo_Priority");
                
        var fieldValue = getFormValue("oppo_note")
         if (!isEmpty(fieldValue)) {
            setClause += ", oppo_Note= CASE WHEN oppo_Note IS NULL THEN '' ELSE  CAST(oppo_Note AS VARCHAR(MAX)) + CHAR(10) + CHAR(13) + CHAR(10) + CHAR(13) END  + '" + fieldValue + "'";
        }

        var sSQL = "UPDATE Opportunity " + setClause + " WHERE oppo_OpportunityID IN (" + oppoIDs + ")";
        recQuery = eWare.CreateQueryObj(sSQL);
        recQuery.ExecSql()
        //Response.Write("<br/>" + sSQL + "<br/>");
        
        var arrOppoIds = new String(oppoIDs).split(",");
        message = "alert(\"" + arrOppoIds.length.toString() + " Sales Management Records Updated." + "\");";
    }

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.CheckLocks = false;
    blkContainer.DisplayButton(Button_Default) = false;
    
    Response.Write("<!-- " + new Date().toString()  + " -->");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    
	/*
	 * Build the Filter block resetting a few captions
	 */
	var blkFilter = eWare.GetBlock("PRSalesManagementFilter");
    blkFilter.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.submit();" ));
    blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:clear();"));
	blkFilter.Title = "Filter By:"
    blkFilter.GetEntry("oppo_status").LookupFamily = "oppo_PRStatus";
    blkFilter.GetEntry("oppo_status").DefaultValue = "Open";
    blkFilter.GetEntry("oppo_Stage").LookupFamily = "oppo_PRStage";
    blkContainer.AddBlock(blkFilter);    


	/*
	 * Build the Update block resetting a few captions
	 * A few fields need to be build manually in order to have unique
	 * field names in the resulting HTML
	 */
    var sCurrentURL = eWare.URL("PROpportunity/PRSalesManagementListing.asp");
    
    var blkUpdate = eWare.GetBlock("Content");
    var sTempTable = "<table width=\"100%\" id=tblUpdate><tr>\n";
    sTempTable += buildDataCell("update_status", "Status", buildDropDown("oppo_PRStatus", "update_status", ""), 1, 1, "22%");
    sTempTable += buildDataCell("update_stage", "Stage", buildDropDown("oppo_PRStage", "update_stage", ""), 1, 1, "");
    sTempTable += buildDataCell("update_certainty", "Certainty", buildDropDown("oppo_PRCertainty", "update_certainty", ""), 1, 1, "");
    sTempTable += buildDataCell("update_Note", "Note", "<textarea class=EDIT name=oppo_note rows=6 cols=70></textarea>", 1, 3, "34%");
    sTempTable += "\n</tr><tr>\n";        
    sTempTable += buildDataCell("update_priority", "Priority", buildDropDown("oppo_Priority", "update_priority", ""), 1, 1, "");
    sTempTable += buildDataCell("update_assignedto", "Assigned To", buildUserDropDown("6,7", "update_assignedto", ""), 1, 1, "");
    sTempTable += buildDataCell("update_prlostreason", "Close Reason", buildDropDown("oppo_PRLostReason", "update_prlostreason", ""), 1, 1, "22%");
    sTempTable += "\n</tr><tr><td>&nbsp;</td></tr></table>\n";
    blkUpdate.Contents = createAccpacBlockHeader("updSalesInfo", 
                                                 "<a onclick=toggleUpdateBlock(); style=\"text-decoration:underline;color:blue;cursor:pointer;\">Update Sales Information</a>",
                                                 "",
                                                 "") +
                         sTempTable +
                         createAccpacBlockFooter(eWare.Button("Save","save.gif","javascript:document.EntryForm.action='" + changeKey(sCurrentURL, "em", "95") + "';confirmSave();"));

    blkContainer.AddBlock(blkUpdate);     
    
    sSQL = "SELECT oppo_OpportunityID, " +
           "oppo_PrimaryCompanyID, " +
           "prcse_FullName, " +
           "oppo_opened, " +
           "oppo_Type, " +
           "dbo.ufn_GetCustomCaptionValue('oppo_Type', oppo_Type, 'en-us') As Type, " +
           "oppo_Stage, " +
           "dbo.ufn_GetCustomCaptionValue('oppo_PRStage', oppo_Stage, 'en-us') As Stage, " +
           "oppo_Status, " +
           "dbo.ufn_GetCustomCaptionValue('oppo_PRStatus', oppo_Status, 'en-us') As Status, " +
           "dbo.ufn_FormatUserName(oppo_AssignedUserId) As AssignedToUser " +
      "FROM Opportunity WITH (NOLOCK)  " +
           "INNER JOIN PRCompanySearch WITH (NOLOCK) ON oppo_PrimaryCompanyID = prcse_CompanyID " +
           "LEFT OUTER JOIN Users WITH (NOLOCK) ON oppo_AssignedUserId = user_UserID ";
   
    sSQL += buildWhereClause();
    sSQL += GetSortClause("gridOppo", "oppo_opened", "ASC");   
    
//Response.Write("<p>" +  sSQL + "</p>");   
    
    recOpportunities = eWare.CreateQueryObj(sSQL);
    recOpportunities.SelectSQL();
            
    var grid = eWare.GetBlock("content");
    grid.Contents = buildOpportunityGrid(recOpportunities, "gridOppo", "Sales Management Records");
    blkContainer.AddBlock(grid);    

    /*
     * This is a special block just used to get our 
     * hidden sort fields on the form
     */
    blkSorting = eWare.GetBlock("content");
    blkSorting.Contents = "<input type=hidden id=\"_hiddenSortColumn\" name=\"_hiddenSortColumn\"><input type=\"hidden\" name=\"_hiddenSortGrid\"><input type=\"hidden\" name=\"_hiddenUpdate\" id=\"_hiddenUpdate\"><input type=\"hidden\" name=\"_hiddenFirstTime\" id=\"_hiddenFirstTime\" value=\"N\">"
    blkContainer.AddBlock(blkSorting);       
       
    blkContainer.AddButton(eWare.Button("Continue", "Continue.gif",  eWare.URL("PROpportunity/PROpportunityListing.asp")));       
       
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage(''));

%>   
    <script type="text/javascript">
        function initBBSI() {
            toggleUpdateBlock();
            toggleStatus();

            document.getElementById("update_status").onchange = toggleStatus;

            RemoveDropdownItemByName("oppo_status", "--None--");
            RemoveDropdownItemByName("oppo_stage", "--None--");
            RemoveDropdownItemByName("oppo_prtargetissue", "--None--");
            RemoveDropdownItemByName("oppo_prpipeline", "--None--");
            RemoveDropdownItemByName("oppo_prcertainty", "--None--");

            <% = message %>

<%    if (getFormValue("_hiddenFirstTime") != "N")   { %>
            setFieldValue("oppo_status", "Open");
<%    }  %>
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }

        function clear() {
            Clearoppo_primarycompanyid();
            document.EntryForm.oppo_status.value= "";
            document.EntryForm.oppo_type.value= "";
            document.EntryForm.oppo_prcertainty.value= "";            
            document.EntryForm.oppo_stage.value= "";
            document.EntryForm.oppo_prtargetissue.value= "";
            document.EntryForm.oppo_opened_start.value= "";
            document.EntryForm.oppo_opened_end.value= "";
            document.EntryForm.oppo_opened_end.value= "";
            Clearoppo_waveitemid();
        }
            
        var tblUpdateBlock = null;
        function getUpdateBlock() {
            var field = document.all("tblUpdate");

            while ((field != null) && (field.tagName != "TABLE"))
                field = field.parentElement;

            if (field != null)
                tblUpdateBlock = field;
        }

        function toggleUpdateBlock() {
            if (tblUpdateBlock == null) {
                getUpdateBlock();
            }

            if (tblUpdateBlock.style.display == "none") {
                tblUpdateBlock.style.display = "inline";
                toggleButton("/Buttons/save.gif", "TR", "inline");
            } else {
                tblUpdateBlock.style.display = "none";
                toggleButton("/Buttons/save.gif", "TR", "none");
            }

        }

        // Determines if any checkboxes on the current
        // page with the specified name prefix are checked.
        function confirmSave() {
            var oCheckboxes = document.body.getElementsByTagName("INPUT");

            var bChecked = false;
            for (var i = 0; i < oCheckboxes.length; i++) {
                if ((oCheckboxes[i].type == "checkbox") &&
		                (oCheckboxes[i].name.indexOf("cbOpportunity") == 0)) {

                    if (oCheckboxes[i].checked) {
                        bChecked = true;
                        break;
                    }
                }
            }

            if (!bChecked) {
                alert("Please select an opportunity to update.");
                return;
            } 
            
           if ((document.getElementById("update_status").options[document.getElementById("update_status").selectedIndex].value == "") &&
               (document.getElementById("update_stage").options[document.getElementById("update_stage").selectedIndex].value == "") &&
               (document.getElementById("update_priority").options[document.getElementById("update_priority").selectedIndex].value == "") &&
               (document.getElementsByName("oppo_note")[0].value  == "") &&
               (document.getElementById("update_prlostreason").options[document.getElementById("update_prlostreason").selectedIndex].value == "") &&
               (document.getElementById("update_assignedto").options[document.getElementById("update_assignedto").selectedIndex].value == "") &&
               (document.getElementById("update_certainty").options[document.getElementById("update_certainty").selectedIndex].value == "")) {
                alert("Please specify new values to apply to the selected opportunties.");
                return;
            }


            fld = document.getElementById("update_status");
            if ((fld[fld.selectedIndex].value == "NotSold") &&
                (document.getElementById("update_prlostreason").options[document.getElementById("update_prlostreason").selectedIndex].value == "")) {

                alert("Close Reason is required if the opportunity is not sold.");
                return;

            }
            
            if (confirm("Are you sure you want to update the selected opportunities?")) {
                document.getElementById("_hiddenUpdate").value = "Y";
                document.EntryForm.submit();
            }
        }
        
        function toggleStatus() {
            fld = document.getElementById("update_status");
            
            if (fld[fld.selectedIndex].value == "NotSold") {
                document.getElementById("update_prlostreason").disabled = false;
            } else {
                document.getElementById("update_prlostreason").disabled = true;
            }
        }            
    </script> 
<%    
    
    Response.Write("<!-- " + new Date().toString()  + " -->");
}    



function buildOpportunityGrid(recOpportunities,
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
    
  
    var sContent;
    sContent = createAccpacBlockHeader(sGridName, recOpportunities.RecordCount + " " + sGridTitle);

    sContent += "\n\n<table class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width='100%' >" +
                "\n<thead>" +
                "\n<tr>" +
                "\n<td class=GRIDHEAD align=center width=50>Select<br><input type=checkbox id=cbAll onclick=\"CheckAll2('" + sGridName + "', 'cbOpportunity', this.checked);\"></td> " +
                "<td class=GRIDHEAD >" + getColumnHeader(sGridName, "Company", "prcse_FullName") + "</td> " +
                "<td class=GRIDHEAD align=center>" + getColumnHeader(sGridName, "Type", "Type") + "</td> " +
                "<td class=GRIDHEAD align=center>" + getColumnHeader(sGridName, "Status", "Status") + "</td> " +
                "<td class=GRIDHEAD align=center>" + getColumnHeader(sGridName, "Stage", "Stage") + "</td> " +
                "<td class=GRIDHEAD align=center>" + getColumnHeader(sGridName, "Date Opened", "oppo_opened") + "</td> ";
                
    if (key0 == 5) {
        sContent += "<td class=GRIDHEAD align=center>" + getColumnHeader(sGridName, "Assigned To", "user_lastname") + "</td> ";
    }
                    
    sContent += "\n</tr>" +
                "\n</thead>";

    sClass = "ROW2";
    var iCount = 0;
    while (!recOpportunities.eof)
    {
        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }
    
        sWorkContent += "\n<tr class=" + sClass + ">";
        sWorkContent += "<td align=center class=" + sClass + "><input type=checkbox name=cbOpportunity class=smallcheck  value=" + recOpportunities("oppo_OpportunityID") + " grid=" + sGridName + "></td>";
        sWorkContent += "<td class=" + sClass + "><a href=\"" + eWareUrl("PRCompany/PRCompanySummary.asp") + "&comp_CompanyID=" + recOpportunities("oppo_PrimaryCompanyID") + "\">" + recOpportunities("prcse_FullName") + "</a></td>";
        sWorkContent += "<td align=center class=" + sClass + "><a href=\"" + eWareUrl("PROpportunity/PROpportunitySummary.asp") + "&Key0=7&Key7=" + recOpportunities("oppo_OpportunityID") + "\">" + recOpportunities("Type") + "</a></td>";
        sWorkContent += "<td align=center class=" + sClass + ">" + getValue(recOpportunities("Status")) + "</td>";
        sWorkContent += "<td align=center class=" + sClass + ">" + getValue(recOpportunities("Stage")) + "</td>";
        sWorkContent += "<td align=center class=" + sClass + ">" + getDateValue(recOpportunities("oppo_opened")) + "</td>";

        if (key0 == 5) {
            sWorkContent += "<td class=" + sClass + ">" + getValue(recOpportunities("AssignedToUser")) + "</td>";
        }

        sWorkContent += "</tr>";
        
        iCount++;
        
        // This is to deal with large numbers of records.  We keep appending to the same string, but since
        // string are immutable, we are allocating memory at an exponential pace, thus the last 500 records
        // can take 10 times as long to process as the first 500 records.  This is purposely not in an array.
        switch(iCount) {
            case 25: 
                Content01 = sWorkContent;
                sWorkContent = "";
                break;
        	case 50: 
            	Content02 = sWorkContent;
                sWorkContent = "";
                break;
        	case 75: 
            	Content03 = sWorkContent;
                sWorkContent = "";
                break;
        	case 100: 
            	Content04 = sWorkContent;
                sWorkContent = "";
                break;
        	case 150: 
            	Content05 = sWorkContent;
                sWorkContent = "";
                break;
        	case 200: 
            	Content06 = sWorkContent;
                sWorkContent = "";
                break;
        	case 250: 
            	Content07 = sWorkContent;
                sWorkContent = "";
                break;
        	case 300: 
            	Content08 = sWorkContent;
                sWorkContent = "";
                break;
        	case 350: 
            	Content09 = sWorkContent;
                sWorkContent = "";
                break;
        	case 400: 
            	Content10 = sWorkContent;
                sWorkContent = "";
                break;
        	case 450: 
            	Content11 = sWorkContent;
                sWorkContent = "";
                break;
        	case 500: 
            	Content12 = sWorkContent;
                sWorkContent = "";
                break;
        	case 550: 
            	Content13 = sWorkContent;
                sWorkContent = "";
                break;
        	case 600: 
            	Content14 = sWorkContent;
                sWorkContent = "";
                break;
        	case 650: 
            	Content15 = sWorkContent;
                sWorkContent = "";
                break;
        	case 700: 
            	Content16 = sWorkContent;
                sWorkContent = "";
                break;
        }        
        recOpportunities.NextRecord();
    }      
    
    sContent += Content01 + Content02 + Content03 + Content04 + Content05 + Content06 + Content07 + Content08 + Content09 + Content10 + 
                Content11 +  Content12 +  Content13 +  Content14 +  Content15 +  Content16 + sWorkContent;
    
    
    while (iCount < 10) {

        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }

        sContent += "\n<tr class=" + sClass + "><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
        if (key0 == 5) {
            sContent += "<td>&nbsp;</td>";
        }
        sContent += "</tr>";
    
        iCount ++;
    }
    
    sContent += "\n</table>";
    sContent += createAccpacBlockFooter();
    
//Response.Write("<br/>" + sGridName + " End: " + new Date());    
    return sContent;
}

function buildWhereClause() {

    var szWhere = "WHERE ";

    if (key0 == 4) { // User context
        szWhere += "oppo_AssignedUserId=" + user_userid; 
    } else if (key0 == 5) {
        keyValue = Request.QueryString("Key5");
        if (keyValue == "-1") {
            szWhere += " 1=1"; 
        } else {
            szWhere += " Oppo_ChannelId=" + keyValue; 
        }
    } else {
        szWhere += " 0=0"; 
    }

    if (getFormValue("_hiddenFirstTime") != "N")   {
        szWhere += addCondition("oppo_Status", "Open");
    } else {
        szWhere += addCondition("oppo_PrimaryCompanyID", getFormValue("oppo_primarycompanyid"));
        szWhere += addCondition("oppo_Status", getFormValue("oppo_status"));
        szWhere += addCondition("oppo_Type", getFormValue("oppo_type"));
        szWhere += addCondition("oppo_Stage", getFormValue("oppo_stage"));
        szWhere += addCondition("oppo_PRTargetIssue", getFormValue("oppo_prtargetissue"));
        szWhere += addCondition("oppo_WaveItemId", getFormValue("oppo_waveitemid"));
        szWhere += addCondition("oppo_PRPipeline", getFormValue("oppo_prpipeline"));
        szWhere += addCondition("oppo_PRCertainty", getFormValue("oppo_prcertainty"));
        szWhere += addDateRangeCondition("oppo_Opened", getFormValue("oppo_opened_start"), getFormValue("oppo_opened_end"));
    }    

    
    return szWhere;
}
%>    