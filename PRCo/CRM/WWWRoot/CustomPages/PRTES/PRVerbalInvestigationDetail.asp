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
    var sTESRequestID = getIdValue("prtesr_TESRequestID");

    var sSQL = "SELECT prtesr_ResponderCompanyID, prtesr_VerbalInvestigationID FROM PRTESRequest WITH (NOLOCK) WHERE prtesr_TESRequestID=" + sTESRequestID;
    var recPRTESRequest = eWare.CreateQueryObj(sSQL);
    recPRTESRequest.SelectSQL();
    var sCompanyID = recPRTESRequest("prtesr_ResponderCompanyID");
    var sVerbalInvestigationID = recPRTESRequest("prtesr_VerbalInvestigationID");

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var recVIResponder = eWare.FindRecord("vPRVIResponder", "comp_CompanyID=" + sCompanyID);
    var blkEntry=eWare.GetBlock("PRVIResponder");
    blkEntry.Title="TES Responder";
    blkEntry.ArgObj = recVIResponder;
    blkContainer.AddBlock(blkEntry);


	var recPhone = eWare.FindRecord("vPRCompanyPhone","plink_RecordID=" + sCompanyID);
    var grdPhone = eWare.GetBlock("CompanyPhoneGrid");
    //grdPhone.DeleteGridCol("phon_companyid");
    grdPhone.DisplayForm=false;
    grdPhone.ArgObj = recPhone;
    grdPhone.PadBottom = false;
    blkContainer.AddBlock(grdPhone);


    var recCallAttempts = eWare.FindRecord("vPRVIDetailCallAttempts", "prtesr_TESRequestID=" + sTESRequestID);
    var grdCallAttempts=eWare.GetBlock("PRVIDetailCallAttempts");
    grdCallAttempts.ArgObj = recCallAttempts;
    grdCallAttempts.PadBottom = false;
    blkContainer.AddBlock(grdCallAttempts);


    blkContainer.AddButton(eWare.Button("Continue", "Continue.gif", eWare.Url("PRTES/PRVerbalInvestigationView.asp") + "&prvi_VerbalInvestigationID=" + sVerbalInvestigationID + "&T=Company&Capt=Trade+Activity"));
    
    eWare.AddContent(blkContainer.Execute()); 
    Response.Write(eWare.GetPage(''));     
}    
%>
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->