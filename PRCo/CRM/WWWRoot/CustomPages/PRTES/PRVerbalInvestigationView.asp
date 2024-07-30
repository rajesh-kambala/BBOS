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


doPage();


function doPage() {

    var sVerbalInvestigationID = getIdValue("prvi_VerbalInvestigationID");

    recVerbalInvestigation = eWare.FindRecord("PRVerbalInvestigation", "prvi_VerbalInvestigationID=" + sVerbalInvestigationID);
    blkEntry=eWare.GetBlock("PRVerbalInvestigationEntry");
    blkEntry.Title="Verbal Investigation";
    blkEntry.ArgObj = recVerbalInvestigation;
    blkContainer.AddBlock(blkEntry);


    recVerbalInvestigationResponse = eWare.FindRecord("vPRVerbalInvestigationResponse", "prtesr_VerbalInvestigationID=" + sVerbalInvestigationID);
    blkResults=eWare.GetBlock("PRVerbalInvestigationResults");
    blkResults.Title="Verbal Investigation Results";
    blkResults.ArgObj = recVerbalInvestigationResponse;
    blkContainer.AddBlock(blkResults);


    var recCompanies = eWare.FindRecord("vPRTESVICompanies", "prtesr_VerbalInvestigationID=" + sVerbalInvestigationID);
    var grdCompanyLocation = eWare.GetBlock("PRTESVICompaniesGrid");
    grdCompanyLocation.ArgObj = recCompanies;
    grdCompanyLocation.PadBottom = false;
    blkContainer.AddBlock(grdCompanyLocation);


    blkContainer.AddButton(eWare.Button("Continue", "Continue.gif", eWare.Url("PRTES/PRVerbalInvestigationList.asp") + "&comp_companyid=" + comp_companyid) + "&T=Company&Capt=Trade+Activity");
    blkContainer.AddButton(eWare.Button("Edit", "Edit.gif", eWare.Url("PRTES/PRVerbalInvestigationEdit.asp") + "&prvi_VerbalInvestigationID=" + sVerbalInvestigationID) + "&T=Company&Capt=Trade+Activity");


    eWare.AddContent(blkContainer.Execute()); 
    Response.Write(eWare.GetPage(''));  
}
%>
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->