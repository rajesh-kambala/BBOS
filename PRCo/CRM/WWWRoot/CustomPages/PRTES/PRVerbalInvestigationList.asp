<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyHeaders.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    var recInvestigations = eWare.FindRecord("vPRVerbalInvestigations", "prvi_CompanyID=" + comp_companyid);
    var grdInvestigations = eWare.GetBlock("PRVerbalInvestigationsGrid");
    grdInvestigations.ArgObj = recInvestigations;
    grdInvestigations.PadBottom = true;
    grdInvestigations.DeleteGridCol("comp_Name");
    blkContainer.AddBlock(grdInvestigations);
    blkContainer.AddButton(eWare.Button("Continue", "Continue.gif", eWare.Url("PRCompany/PRCompanyTradeActivityListing.asp") + "&comp_companyID=" + comp_companyid + "&T=Company&Capt=Trade+Activity"));
    

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));
%>
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->