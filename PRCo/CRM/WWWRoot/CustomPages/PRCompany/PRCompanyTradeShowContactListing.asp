<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2018-2019

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
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<%
function doPage()
{
    sGridFilterWhereClause = "";
    
    //bDebug=true;
    DEBUG(sURL);
	DEBUG("Mode:" + eWare.Mode);
    
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;

    blkContainer.AddButton( "<br/>" + eWare.Button("New Trade Show Contact","New.gif", 
    eWare.URL("PRCompany/PRCompanyTradeShowContact.asp?comp_companyid=" + comp_companyid)) );

    blkFilter = eWare.GetBlock("PRCompanyTradeShowContactSearchBox");

    var recCompany = null;
    recCompany = eWare.FindRecord("company","comp_companyid=" + comp_companyid);

    if(recCompany.comp_PRIndustryType == "L")
    {
        blkFilter.GetEntry("prctsc_TradeShowCode").LookupFamily = "prctsc_TradeShowCode_L";
    }
    else
    {
        blkFilter.GetEntry("prctsc_TradeShowCode").LookupFamily = "prctsc_TradeShowCode_PTS";
    }

    blkFilter.Title = "Filter By";
    blkFilter.AddButton(eWare.Button("Apply Filter", "Search.gif", "javascript:document.EntryForm.em.value='2';document.EntryForm.submit();"));
    blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

	blkContainer.AddBlock(blkFilter);

    sGridFilterWhereClause += "prctsc_CompanyId = " + comp_companyid;
   
    grid=eWare.GetBlock("PRCompanyTradeShowContactGrid");
    
    grid.ArgObj = blkFilter;
    
    blkContainer.AddBlock(grid);
    
    //DEBUG("<br>keyValue: " + keyValue);

    //Response.Write("<BR>Filter: " + sGridFilterWhereClause);

    eWare.AddContent(blkContainer.Execute(sGridFilterWhereClause)); 
    
    //Response.Write("<p>keyEntity:" + keyEntity + "</p>");
    Response.Write(eWare.GetPage("Company"));
%>
   <script type="text/javascript">
       function initBBSI()
        {
            document.EntryForm.onkeydown = SubmitFormOnEnterKeyPress;
       }
       if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
    </script>
<%
}
doPage();
%>
<!-- #include file="CompanyFooters.asp" -->