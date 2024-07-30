<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2021

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
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.CheckLocks = false;
    
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

	/*
	 * Build the Filter block resetting a few captions
	 */
	var blkFilter = eWare.GetBlock("PRCreditSheetPublishFilterBox");
    blkFilter.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.submit();" ));
    blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:clear();"));
	blkFilter.Title = "Filter By:"
    blkContainer.AddBlock(blkFilter);

    if (isUserInGroup("4,5,10"))
    {
        blkContainer.AddButton( eWare.Button("Daily Report", "ComponentPreview.gif", "javascript:openPreviewReport();"));
        blkContainer.AddButton( eWare.Button("Publish Selected", "Save.gif", "javascript:confirmPublish();"));
        blkContainer.AddButton( eWare.Button("Export Credit Sheet", "Continue.gif", eWare.URL("PRCreditSheet/PRCreditSheetExportRedirect.asp")));
    }

    /*
     * This is a special block just used to get our 
     * hidden sort fields on the form
     */
    blkSorting = eWare.GetBlock("content");
    blkSorting.Contents = "<input type=\"hidden\" name=\"_hiddenSortColumn\" id=\"_hiddenSortColumn\"><input type=\"hidden\" name=\"_hiddenSortGrid\" id=\"_hiddenSortGrid\"><input type=\"hidden\" name=\"_hiddenPublish\" id=\"_hiddenPublish\"><input type=\"hidden\" name=\"_hiddenFirstTime\" id=\"_hiddenFirstTime\" value=\"N\">"
    
    
    var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
    var recSSRS = eWare.CreateQueryObj(sSQL);
    recSSRS.SelectSQL();                
    blkSorting.Contents += "<input type=\"hidden\" id=\"hidSSRSURL\" value=\"" + getValue(recSSRS("SSRSURL")) + "\">";
    blkContainer.AddBlock(blkSorting);

    var szMessage;
    if (getFormValue("_hiddenPublish") == "Y") {
        var szCreditSheetIDs = Request.Form.Item("cbCreditSheetID");
        
        sSQL = "UPDATE PRCreditSheet SET prcs_Status = 'P', prcs_PublishableDate = GETDATE() WHERE prcs_CreditSheetID IN (" + szCreditSheetIDs + ");";
        qryPublishCSItems = eWare.CreateQueryObj(sSQL);
        qryPublishCSItems.ExecSql()
        
        var arrCSItemIds = new String(szCreditSheetIDs).split(",");
        szMessage = "Published " + arrCSItemIds.length.toString() + " Credit Sheet Items";
    }


 
    sSQL = "SELECT prcs_CreditSheetID, prcs_CreatedDate, comp_Name, prcse_FullName, prcs_Status, comp_PRIndustryType, ListingSpecialist, prcs_ApprovalDate, ApprovedBy FROM vPRCreditSheet INNER JOIN PRCompanySearch WITH (NOLOCK) ON prcs_CompanyID = prcse_CompanyID WHERE prcs_Status = 'A' ";

    var szWhereClause = addDateRangeCondition("prcs_ApprovalDate", getFormValue("prcs_approvaldate_start"), getFormValue("prcs_approvaldate_end"));
    if (szWhereClause != "") {
        sSQL += szWhereClause;
    }
    
    var sGridName = "CreditSheetGrid";
    sSQL += GetSortClause(sGridName, "prcs_CreatedDate", "ASC");
    
    recCSItems = eWare.CreateQueryObj(sSQL);
    recCSItems.SelectSQL();
    
    
    var sContent;
    sContent = createAccpacBlockHeader(sGridName, "Publish Credit Sheet Items");

    sContent += "\n\n<table class=\"CONTENT\" border=\"1px \"cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width=\"100%\">" +
                "\n<thead>" +
                "\n<tr>" +
                "\n<td class=\"GRIDHEAD\" align=\"center\">Select<br/><input type=\"checkbox\" id=\"cbAll\" onclick=\"CheckAll('" + sGridName + "', this.checked);\"></td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Credit<br/>Sheet ID", "prcs_CreditSheetID") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Created<br/>Date", "prcs_CreatedDate") + "</td> " +
                "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Company Name", "comp_Name") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Status", "prcs_Status") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Industry<br/>Type", "comp_PRIndustryType") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Listing<br/>Specialist Rep", "ListingSpecialist") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Approved<br/>Date", "prcs_ApprovalDate") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Approved<br/>By", "ApprovedBy") + "</td> ";

    sContent += "\n</tr>";
    sContent += "\n</thead>";

    var sWorkContent = "";
    sClass = "ROW2";
    var iCount = 0;
    while (!recCSItems.eof)
    {
        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }
    
        sWorkContent += "\n<tr class=" + sClass + ">";
        
        sWorkContent += "<td align=\"center\" class=" + sClass + "><input type=\"checkbox\" name=\"cbCreditSheetID\" name=\"cbCreditSheetID\"  value=\"" + recCSItems("prcs_CreditSheetID") + "\" grid=\"" + sGridName + "\"></td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + "><a href=\"" +  eWareUrl("PRCreditSheet/PRCreditSheet.asp") + "&prcs_CreditSheetId=" + recCSItems("prcs_CreditSheetID") + "\" >" + getValue(recCSItems("prcs_CreditSheetID")) + "</a></td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getDateValue(recCSItems("prcs_CreatedDate")) + "</td>";
        sWorkContent += "<td class=" + sClass + ">" + getValue(recCSItems("prcse_FullName")) + "</td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getValue(recCSItems("prcs_Status")) + "</td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getValue(recCSItems("comp_PRIndustryType")) + "</td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getValue(recCSItems("ListingSpecialist")) + "</td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getDateValue(recCSItems("prcs_ApprovalDate")) + "</td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getValue(recCSItems("ApprovedBy")) + "</td>";
        
        sWorkContent += "</tr>";
        
        iCount++;
        

        recCSItems.NextRecord();
    }          
    
    sContent += sWorkContent + "\n</table>";
    sContent += createAccpacBlockFooter();    
   
    var lstCreditSheet = eWare.GetBlock("content");
    lstCreditSheet.Contents = sContent;
    blkContainer.AddBlock(lstCreditSheet);   
    
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('PRCreditSheet'));

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
%>
    <script type="text/javascript">
            function CheckAll(sGridName, bChecked) {
            
	            var oCheckboxes = document.body.getElementsByTagName("INPUT");
	            for(var i = 0; i < oCheckboxes.length; i++) {
		            if ((oCheckboxes[i].type == "checkbox") &&
		                (oCheckboxes[i].name.indexOf("cbCreditSheetID") == 0) &&
		                (oCheckboxes[i].getAttribute("grid") == sGridName)) {
		                if (oCheckboxes[i].disabled == false) {
				            oCheckboxes[i].checked = bChecked;
			            }
		            }
	            }
	        }

	        function clear() {
	            document.EntryForm.prcs_approvaldate_start.value = "";
	            document.EntryForm.prcs_approvaldate_end.value = "";
	        }


	        function openPreviewReport(sReportType) {
	            var sReportURL = document.getElementById("hidSSRSURL").value;
	            sReportURL += "/Content/DailyCreditSheetReport";
                sReportURL += "&rs:ClearSession=true&rs:format=PDF";

                //var sTimeStamp = new Date().getTime().toString(); 
                //sReportURL += "&rs:ignore=" + sTimeStamp;
                //alert(sReportURL);

                location = sReportURL;
	            //window.open(sReportURL,
				//"Reports",
				//"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=600,height=300", true);

	        }

	        function confirmPublish() {
	            var oCheckboxes = document.body.getElementsByTagName("INPUT");

	            var bChecked = false;
	            for (var i = 0; i < oCheckboxes.length; i++) {
	                if ((oCheckboxes[i].type == "checkbox") &&
		                (oCheckboxes[i].name.indexOf("cbCreditSheetID") == 0)) {

	                    if (oCheckboxes[i].checked) {
	                        bChecked = true;
	                        break;
	                    }
	                }
	            }

	            document.getElementById("_hiddenPublish").value = "";
	            if (!bChecked) {
	                alert("Please select Credit Sheet Items to publish.");
	            } else {
	                if (confirm("Are you sure you want to publish these Credit Sheet Items?")) {
	                    document.getElementById("_hiddenPublish").value = "Y";
	                    document.EntryForm.submit();
	                }
	            }
	        }        	        
	        
<% if (szMessage != null) { %>                
                alert("<% =szMessage %>");
<% } %>     	        
    </script>