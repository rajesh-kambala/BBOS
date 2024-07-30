<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of  Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="../PRCoGeneral.asp" -->

<%

    doPage();

function doPage() {
    var key58Redirect = handleKey58();
    if (key58Redirect != null) {
        //Response.Redirect(Request.ServerVariables("URL")+ "?" + key58Redirect);
        //return;

        Response.Write("key58Redirect:" + key58Redirect + "<br/>");
        Response.Write("Query String:" + new String(Request.QueryString) + "<br/>");
    }


    //bDebug=true;
    DEBUG(sURL);
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    var blkContainer = eWare.GetBlock("Container");
    blkContainer.ButtonTitle="Search";
    blkContainer.ButtonImage="Search.gif";
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
    blkContainer.AddButton(eWare.Button("Continue", "Continue.gif",  eWare.URL("PROpportunity/PROpportunityListing.asp")));       

    var szFirstTime = Request("hidFirstTime");
    var blkProcessingFlags = eWare.GetBlock('content');
    blkProcessingFlags.contents = "<input type=\"hidden\" name=\"hidFirstTime\" value=\"N\" />";
    blkContainer.AddBlock(blkProcessingFlags);    

    var keyValue = "-1";
	var keyField = "";
	var keyEntity = "";
	
    var context = Request.QueryString("Key0");
    
    if (context == 1){
		%><!-- #include file ="../PRCompany/CompanyIdInclude.asp" --><%
		keyEntity = "Company";
		keyValue = comp_companyid;
		keyField = "oppo_PrimaryCompanyId";
    } else if (context == 2){
		%> <!-- #include file ="../PRPerson/PersonIdInclude.asp" --><%
		keyEntity = "Person";
		keyValue = pers_personid;
		keyField = "oppo_PrimaryPersonId";
    } else if (context == 4){
		%> <!-- #include file ="../PRPerson/PersonIdInclude.asp" --><%
		keyEntity = "User";
		keyValue = Request.QueryString("Key4");
		keyField = "oppo_assigneduserid";
    } else if (context == 5){
		%> <!-- #include file ="../PRPerson/PersonIdInclude.asp" --><%
		keyEntity = "Channel";
		keyValue = Request.QueryString("Key5");
		keyField = "oppo_ChannelId";
    }

    blkFilter = eWare.GetBlock("PROpportunitySearchBoxBBOSInquiry");
    blkFilter.Title = "Filter By";

    var sGridFilterWhereClause = "";
    var sFormLoadCommands = "";
		
	gridOpp=eWare.GetBlock("PROpportunityGridBBOSInquiry");
	entry = gridOpp.DeleteGridCol(keyField);
    
    entry = blkFilter.GetEntry("oppo_Status");
    entry.LookupFamily = "oppo_PRStatus";
    entry.DefaultValue = "Open";

    entry = blkFilter.GetEntry("oppo_PRType");
    entry.LookupFamily = "oppo_PRType_Mem";

    if (eWare.Mode != 6)
    {  
        // get the form variables that may or may not exist
        var sFormStartDate = String(Request.Form.Item("oppo_opened_start"));
        if (sFormStartDate != null && !isEmpty(sFormStartDate)) {
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "oppo_Opened >='" + getDBDate(sFormStartDate) + "'";
        }
        
        var sFormEndDate = String(Request.Form.Item("oppo_opened_end"));
        if (sFormEndDate != null && !isEmpty(sFormEndDate)) {
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "oppo_Opened <='" + getDBDate(sFormEndDate) + " 23:59:59'";
        }
        
        var prwu_Email = getValue(Request.Form.Item("prwu_email"));
        if (!isEmpty(prwu_Email))
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "prwu_Email LIKE '" + prwu_Email + "'";

        var PersonName = getValue(Request.Form.Item("personname"));
        if (!isEmpty(PersonName))
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "PersonName LIKE '" + PersonName + "'";

        var CityStateCountryShort = getValue(Request.Form.Item("citystatecountryshort"));
        if (!isEmpty(prwu_CompanyName))
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "CityStateCountryShort LIKE '" + CityStateCountryShort + "'";

        var prwu_CompanyName = getValue(Request.Form.Item("prwu_companyname"));
        if (!isEmpty(prwu_CompanyName))
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "prwu_CompanyName LIKE '" + prwu_CompanyName + "'";

        var oppo_stage = getValue(Request.Form.Item("oppostage"));
        if (!isEmpty(oppo_stage))
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"OppoStage = '" + oppo_stage + "'";

        var Oppo_PRType = getValue(Request.Form.Item("oppo_prtype"));
        if (!isEmpty(Oppo_PRType)) {
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"Oppo_PRType = '" + Oppo_PRType + "'";
        }

        var oppo_certainty = getValue(Request.Form.Item("oppo_prcertainty"));
        if (!isEmpty(oppo_certainty)) {
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_prcertainty = '" + oppo_certainty + "'";
        }

        var oppo_status = getValue(Request.Form.Item("oppo_status"));
        if (szFirstTime != "N") 
            oppo_status = "Open";

        if (!isEmpty(oppo_status)) {
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_status = '" + oppo_status + "'";
        }


        // now create the formload section to reload all the values with the submitted values
        sFormLoadCommands += "SelectDropdownItemByValue('oppostage', '" + oppo_stage + "');\n";
        sFormLoadCommands += "SelectDropdownItemByValue('oppo_prcertainty', '" + oppo_certainty + "');\n";
        sFormLoadCommands += "SelectDropdownItemByValue('oppo_status', '" + oppo_status + "');\n";
    }

    sFormLoadCommands += "RemoveDropdownItemByName('oppostage', '--None--');\n";
    sFormLoadCommands += "RemoveDropdownItemByName('oppo_prcertainty', '--None--');\n";            
    sFormLoadCommands += "RemoveDropdownItemByName('oppo_prtype', '--None--');\n";         
    sFormLoadCommands += "RemoveDropdownItemByName('oppo_status', '--None--');\n";         
    sFormLoadCommands += "RemoveDropdownItemByName('DateTimeModesoppo_opened', 'Relative');\n";

    
    if (!isEmpty(keyValue) && keyValue != "-1")
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + keyField + "="+ keyValue;

    blkContainer.AddBlock(blkFilter);    
    blkContainer.AddBlock(gridOpp);
    
    //Response.Write("<br/>Filter: " + sGridFilterWhereClause);

    eWare.AddContent(blkContainer.Execute(sGridFilterWhereClause)); 
    Response.Write(eWare.GetPage(keyEntity));
%>
   <script type="text/javascript">
       function initBBSI() 
        {
            <%= sFormLoadCommands %>
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
    </script>
<%    
    if (context == 1 || context == 2) {
%>
	<!-- #include file ="../RedirectTopContent.asp" -->
<%
	}	
}


%>