<!-- #include file ="../accpaccrm.js" -->
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

<!-- #include file ="../PRCoGeneral.asp" -->

<%
function doPage()
{
    sGridFilterWhereClause = "";
    
    //bDebug=true;
    DEBUG(sURL);
	DEBUG("Mode:" + eWare.Mode);

    //Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;

    var blkProcessingFlags = eWare.GetBlock('content');
    blkProcessingFlags.contents = "\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";
    blkContainer.AddBlock(blkProcessingFlags); 

    blkContainer.AddButton( "<br/>" + eWare.Button("New Special Services File","New.gif", 
                            eWare.URL("PRSSFile/PRSSFile.asp")) );

    blkFilter = eWare.GetBlock("PRSSFileSearchBox");
    blkFilter.Title = "Filter By";
    blkFilter.AddButton(eWare.Button("Apply Filter", "Search.gif", "javascript:document.EntryForm.em.value='2';document.EntryForm.submit();"));
    blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

      
    entry = blkFilter.GetEntry("ssfileid");
    entry.Caption = "SS File ID:";

    var keyValue = "-1";
	var keyField = "";
	var keyEntity = "";
    var isCompany = false;
	
    var key0 = Request.QueryString("Key0");
    if (key0 == 1){
		%><!-- #include file ="../PRCompany/CompanyIdInclude.asp" --><%
		keyEntity = "Company";
		keyValue = comp_companyid;
		keyField = "prss_ClaimantCompanyId";
        isCompany = true;
    } else if (key0 == 2){
		%> <!-- #include file ="../PRPerson/PersonIdInclude.asp" --><%
		keyEntity = "Person";
		keyValue = pers_personid;
		keyField = "ClaimantPrimaryContactId";
    } else if (key0 == 4){
		keyEntity = "User";
		keyValue = Request.QueryString("Key4");
		keyField = "prss_assigneduserid";
    } else if (key0 == 5){
		keyEntity = "Channel";
		keyValue = Request.QueryString("Key5");
		keyField = "prss_ChannelId";
    }

	entry = blkFilter.GetEntry(keyField);
    if (!isCompany) {
    	if (!isEmpty(entry))
	    	entry.Hidden = true;
    }
    
    blkContainer.AddBlock(blkFilter);    
    grid=eWare.GetBlock("PRSSFileGrid");

    if (!isCompany) {
    	entry = grid.DeleteGridCol(keyField);
    }
    grid.ArgObj = blkFilter;
    blkContainer.AddBlock(grid);
    
    DEBUG("<br>keyValue: " + keyValue);


    if (isCompany) {
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "(prss_ClaimantCompanyId = " + keyValue + " OR prss_RespondentCompanyId = " + keyValue + " OR prss_3rdPartyCompanyId = " + keyValue + ")";
    } else {
        if (!isEmpty(keyValue) && keyValue != "-1") {
            sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + keyField + "="+ keyValue;
        }
    }

    //Response.Write("<BR>Filter: " + sGridFilterWhereClause);
    eWare.AddContent(blkContainer.Execute(sGridFilterWhereClause)); 
    
    //Response.Write("<p>keyEntity:" + keyEntity + "</p>");
    Response.Write(eWare.GetPage(keyEntity));
%>
   <script type="text/javascript">
       function initBBSI()
        {
            document.EntryForm.onkeydown = SubmitFormOnEnterKeyPress;
       }
       if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
    </script>
<%    
    if (key0 == 1 || key0 == 2) {
%>
	<!-- #include file ="../RedirectTopContent.asp" -->
<%
	}	
}
doPage();
%>