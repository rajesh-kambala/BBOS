<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2023

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
    
    bDebug=false;
    DEBUG(sURL);
	DEBUG("Mode:" + eWare.Mode);

    //Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;

    var blkProcessingFlags = eWare.GetBlock('content');
    blkProcessingFlags.contents = "\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";
    blkContainer.AddBlock(blkProcessingFlags); 

    blkFilter = eWare.GetBlock("PRSalesOrderAuditTrailSearchBox");
    blkFilter.Title = "Filter By";
    blkFilter.AddButton(eWare.Button("Apply Filter", "Search.gif", "javascript:document.EntryForm.em.value='2';document.EntryForm.submit();"));
    blkFilter.AddButton(eWare.Button("Apply 7-Day Filter", "Search.gif", "javascript:document.EntryForm.em.value='2'; apply_7_day_filter(); document.EntryForm.submit();"));
    blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

    //entry = blkFilter.GetEntry("prsoat_SalesOrderAuditTrailID");
    //entry.Caption = "SO Audit Trail ID:";

	entry = blkFilter.GetEntry("prsoat_SalesOrderAuditTrailID");
    blkContainer.AddBlock(blkFilter);    
    
    grid=eWare.GetBlock("PRSalesOrderAuditTrailGrid");
    grid.ArgObj = blkFilter;
    blkContainer.AddBlock(grid);
    
    eWare.AddContent(blkContainer.Execute(sGridFilterWhereClause)); 
    Response.Write(eWare.GetPage(""));
%>
   <script type="text/javascript">
       function apply_7_day_filter() {
           var sixDaysAgo = new Date(Date.now() - 6 * 24 * 60 * 60 * 1000);
           $("#prsoat_createddate_start").val(sixDaysAgo.toLocaleDateString());
           $("#prsoat_createddate_end").val(new Date(Date.now()).toLocaleDateString());
       }

       function initBBSI() {
           document.EntryForm.onkeydown = SubmitFormOnEnterKeyPress;
       }
       if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
   </script>
<%    
}
doPage();
%>