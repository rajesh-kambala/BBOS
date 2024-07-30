<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2020

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

<!-- #include file ="../PRCoGeneral.asp" -->

<%

    doPage();

function doPage() {
    var key58Redirect = handleKey58();
    if (key58Redirect != null) {
        Response.Redirect(Request.ServerVariables("URL")+ "?" + key58Redirect);
        return;

        //Response.Write("key58Redirect:" + key58Redirect + "<br/>");
        //Response.Write("Query String:" + new String(Request.QueryString) + "<br/>");
    }

    //Defect 4586
    //Redirect without Key1 if Key0 is 4 or 5, so that no company name defaults
    var Key0 = new String(Request.QueryString("Key0"));
    var Key1 = new String(Request.QueryString("Key1"));

    if (!isEmpty(Key1))
    {
        if(!isEmpty(Key0) && (Key0=="4" || Key0=="5"))
        {
            var queryString = new String(Request.QueryString);
            queryString = removeKey(queryString, "Key1");

            Response.Redirect(Request.ServerVariables("URL")+ "?" + queryString);
            return;
        }
    }    

    //bDebug=true;
    DEBUG(sURL);
    //Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    var blkContainer = eWare.GetBlock("Container");
    blkContainer.ButtonTitle="Search";
    blkContainer.ButtonImage="Search.gif";
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

    var szFirstTime = Request("hidFirstTime");
    var blkProcessingFlags = eWare.GetBlock('content');
    blkProcessingFlags.contents = "\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";
    blkProcessingFlags.contents += "\n<input type=\"hidden\" name=\"hidFirstTime\" value=\"N\" />\n";
    blkContainer.AddBlock(blkProcessingFlags);    

    var sFormLoadCommands = "";
%>
<!-- #include file ="../PROpportunity/PROpportunityFilterInclude.asp" --> 
<%
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

/*
Response.Write("keyEntity: " + keyEntity + "<br/>"); 
Response.Write("keyValue: " + keyValue + "<br/>"); 
Response.Write("keyField: " + keyField + "<br/>"); 
*/

	entry = blkFilter.GetEntry(keyField);
	if (!isEmpty(entry))
		entry.Hidden = true;
		
	gridOpp=eWare.GetBlock("PROpportunityGrid");
	entry = gridOpp.DeleteGridCol(keyField);
    
    blkContainer.AddBlock(blkFilter);    
    blkContainer.AddBlock(gridOpp);

    tabContext = "&Capt=Sales+Mgmt";

    if ((context == 4) ||
        (context == 5) ||
        (context == 7)) {
        blkContainer.AddButton(eWare.Button("Bulk Management","Continue.gif", eWare.URL("PROpportunity/PRSalesManagementListing.asp") + tabContext));    
    }
        
    if (context != 1){
        blkContainer.AddButton(eWare.Button("BBOS Inquiry Leads","Continue.gif", eWare.URL("PROpportunity/PROpportunityListingBBOSInquiry.asp") + tabContext) );            
    }

    var newOpportunityURL = removeKey(eWare.URL("PROpportunity/PROpportunitySummary.asp"), "Key7");

    // Remove the person context because it can mess up the users.
    if (context == 5)
        newOpportunityURL = removeKey(eWare.URL("PROpportunity/PROpportunitySummary.asp"), "Key2");

    blkContainer.AddButton(eWare.Button("New Blueprints Advertising Opportuntiy", "NewOpportunity.gif", newOpportunityURL + "&Type=BP" + tabContext));
    blkContainer.AddButton(eWare.Button("New Digital Advertising Opportuntiy", "NewOpportunity.gif", newOpportunityURL + "&Type=DA" + tabContext));
    blkContainer.AddButton(eWare.Button("New Membership Opportuntiy", "NewOpportunity.gif", newOpportunityURL + "&Type=NEWM" + tabContext));
    blkContainer.AddButton(eWare.Button("New Upgrade Opportuntiy", "NewOpportunity.gif", newOpportunityURL + "&Type=UPG" + tabContext));

    if (context != 1){
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "ISNULL(oppo_PRPipeline, '') <> 'M:BBOS'";
    }

    DEBUG("<br>keyValue: " + keyValue);
    if (!isEmpty(keyValue) && keyValue != "-1")
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + keyField + "="+ keyValue;
    DEBUG("<BR>Filter: " + sGridFilterWhereClause);
    
    //Response.Write("<br/>" + sGridFilterWhereClause + "<br/>");
    
    eWare.AddContent(blkContainer.Execute(sGridFilterWhereClause)); 
    Response.Write(eWare.GetPage(keyEntity));
%>
   <script type="text/javascript">
       function initBBSI() 
        {
            setPipeline();
            <%= sFormLoadCommands %>
        }
       if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }

        function setPipeline() {
            var cbo = document.getElementById("oppo_type");
            var sType = cbo.options[cbo.selectedIndex].value; 
            
            document.getElementById("oppo_prpipeline").options.length = 0;
            AddDropdownItem('oppo_prpipeline', '--All--', '');

            if ((sType == "BP") || (sType == "sagecrm_code_all")) {
                <% =sLoadPipelineAd %>
            }
            if ((sType == "NEWM") || (sType == "sagecrm_code_all")) {
                <% =sLoadPipelineM %>
                RemoveDropdownItemByValue('oppo_prpipeline', 'M:BBOS');
            }
            if ((sType == "UPG") || (sType == "sagecrm_code_all")) {
                <% =sLoadPipelineUp %>
            }        
        }
        
        var cbo = document.getElementById("oppo_type");
        cbo.onchange = setPipeline;
        
    </script>
<%    
    if (context == 1 || context == 2) {
%>
	<!-- #include file ="../RedirectTopContent.asp" -->
<%
	}	
}	
%>