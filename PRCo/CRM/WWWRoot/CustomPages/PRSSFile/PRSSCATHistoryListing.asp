<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

    doPage();

function doPage()
{
    var prss_ssfileid = getIdValue("prss_ssfileid");

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;

    sSummaryAction = eWare.Url("PRSSFile/PRSSFile.asp")+ "&prss_ssfileid="+ prss_ssfileid;
    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sSummaryAction));


    var grid=eWare.GetBlock("PRSSCATHistoryGrid");
    blkContainer.AddBlock(grid);

    eWare.AddContent(blkContainer.Execute("prcath_SSFileID=" + prss_ssfileid)); 
   
    Response.Write(eWare.GetPage("Company"));
}
%>

<!-- #include file ="../PRCompany/CompanyFooters.asp" -->