<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="PRCompanyPaymentHistoryInclude.asp" -->
<!-- #include file ="PRCompanyServiceInclude.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<script type="text/javascript" src="PRCompanyService.js"></script>
<script type="text/javascript" src="../PRCoGeneral.js"></script>

<%

    doPage();

function doPage() {

    var salesOrderNo = Request("SalesOrderNo");

    var blkRepeatOrder = eWare.GetBlock("content");
    blkRepeatOrder.Contents += createAccpacBlockHeader("blkRepeatOrder" + salesOrderNo, "Repeat Order #" + salesOrderNo + "&nbsp;&nbsp;&nbsp;<a style=\"font-size:9pt\" href=\"javascript:CopyStringToClipboard('" + salesOrderNo + "');\" title=\"This copies the sales order number to the clipboard.\">(Copy to Clipboard)</a>");
    blkRepeatOrder.Contents += getRepeatOrderHeader(salesOrderNo);
    blkRepeatOrder.Contents += getRepeatOrderDetails(salesOrderNo);
    blkRepeatOrder.Contents += createAccpacBlockFooter();

    blkContainer.AddBlock(blkRepeatOrder);

    var blkPaymentHistory = eWare.GetBlock("Content");
    var sContent = createAccpacBlockHeader("blkPaymentHistory", "Payment History");
    sContent += getPaymentHistoryTable(comp_companyid, salesOrderNo);
    sContent += createAccpacBlockFooter();
    blkPaymentHistory.contents = sContent;
    blkContainer.AddBlock(blkPaymentHistory);

    var btnContinue = eWare.Button("Continue","continue.gif", eWare.URL("PRCompany/PRCompanyService.asp") + "&T=Company&Capt=Services");
    blkContainer.AddButton(btnContinue);

    blkFlags = eWare.GetBlock("content");
    var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
    var recSSRS = eWare.CreateQueryObj(sSQL);
    recSSRS.SelectSQL();                
    blkFlags.Contents += "<input type=\"hidden\" id=\"hidSSRSURL\" value=\"" + getValue(recSSRS("SSRSURL")) + "\">";
    blkContainer.AddBlock(blkFlags);

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("Company"));
}
%>
<!-- #include file="CompanyFooters.asp" -->