<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2011

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
    }
    
    //bDebug=true;
    DEBUG(sURL);
    //Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;

    var blkScript = eWare.GetBlock("content");
    blkScript.contents = "\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";
    blkContainer.AddBlock(blkScript);    

    var blkFilter = eWare.GetBlock("PRCasesFilter");
    blkFilter.Title = "Filter By";
    blkFilter.AddButton(eWare.Button("Search", "Search.gif", "javascript:document.EntryForm.em.value='" + Find + "';document.EntryForm.submit();"));
    blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='" + Clear + "';document.EntryForm.submit();"));

	var gridCases=eWare.GetBlock("PRCasesGrid");
    gridCases.ArgObj = blkFilter;
        
    var keyValue = "-1";
	var keyField = "";
	var keyEntity = "";


    var key0 = Request.QueryString("Key0");
    if ((key0 == 1) || 
        (!isEmpty(Request.QueryString("comp_CompanyID")))) {

		%><!-- #include file ="../PRCompany/CompanyIdInclude.asp" --><%

		keyEntity = "Company";
		keyValue = comp_companyid;
		keyField = "comp_CompanyId";
        gridCases.DeleteGridCol("prcse_FullName");

        // It seems that if we recently visited a case, that CRM adds
        // that Case key to the URL on this call
        var url = removeKey(eWare.Url("PRCase/PRCaseSummary.asp"), "Key8");
        blkContainer.AddButton(eWare.Button("New","new.gif","javascript:location.href='" + url + "';"));
		
    } else if (key0 == 2){
		%> <!-- #include file ="../PRPerson/PersonIdInclude.asp" --><%
		keyEntity = "Person";
		keyValue = pers_personid;
		keyField = "case_PrimaryPersonId";
    } else if (key0 == 4){
		%> <!-- #include file ="../PRPerson/PersonIdInclude.asp" --><%
		keyEntity = "User";
		keyValue = Request.QueryString("Key4");
		keyField = "case_assigneduserid";
    } else if (key0 == 5){
		%> <!-- #include file ="../PRPerson/PersonIdInclude.asp" --><%
		keyEntity = "Channel";
		keyValue = Request.QueryString("Key5");
		keyField = "case_ChannelId";
    }

    
    
    
    blkContainer.AddBlock(blkFilter);    
    blkContainer.AddBlock(gridCases);
    
    sGridFilterWhereClause = "";
    DEBUG("<br>keyValue: " + keyValue);
    if (!isEmpty(keyValue) && keyValue != "-1")
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + keyField + "="+ keyValue;
    DEBUG("<BR>Filter: " + sGridFilterWhereClause);

    eWare.AddContent(blkContainer.Execute(sGridFilterWhereClause)); 
    Response.Write(eWare.GetPage(keyEntity));
%>
   <script type="text/javascript">
       document.body.onload = function() {

           RemoveDropdownItemByName("DateTimeModesprsp_invoicedate", "Relative");
           RemoveDropdownItemByName("DateTimeModeslastcontactdate", "Relative");
           RemoveDropdownItemByName("case_status", "--None--");
           RemoveDropdownItemByName("case_priority", "--None--");

           //LoadComplete('');
       }
    </script>
<%    
    if (key0 == 1 || key0 == 2) {
%>
	<!-- #include file ="../RedirectTopContent.asp" -->
<%
	}	
}	
%>