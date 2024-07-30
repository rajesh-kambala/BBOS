<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013-2015

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
    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;

    sSummaryAction = eWare.Url("PRCompany/PRCompanyRelationshipListing.asp") + "&T=Company&Capt=Relationships";
    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sSummaryAction));

    blkContainer.AddButton(eWare.Button("New Reference List","new.gif",  eWare.Url("PRCompany/PRConnectionListAdd.asp")));

    var grid=eWare.GetBlock("PRConnectionListGrid");
    blkContainer.AddBlock(grid);

    eWare.AddContent(blkContainer.Execute("prcl2_CompanyID=" + comp_companyid)); 
   
    Response.Write(eWare.GetPage("Company"));
}
%>

<!-- #include file ="../PRCompany/CompanyFooters.asp" -->