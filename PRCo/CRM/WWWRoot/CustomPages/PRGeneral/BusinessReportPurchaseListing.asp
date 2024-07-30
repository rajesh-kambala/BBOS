<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2014

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

    blkContainer = eWare.GetBlock('container');

    blkSearch = eWare.GetBlock("PRBusinessReportPurchaseFilterBox");
    blkSearch.Title = "Search";

    lstMain = eWare.GetBlock("PRBusinessReportPurchaseGrid");
    lstMain.prevURL = eWare.URL(F);
    lstMain.ArgObj = blkSearch;

    blkContainer.AddBlock(blkSearch);
    blkContainer.AddBlock(lstMain);

    blkContainer.DisplayButton(Button_Default) = true;
    blkContainer.ButtonTitle="Search";
    blkContainer.ButtonImage="Search.gif";
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
    


    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage("PRBusinessReportPurchase"));
%>


