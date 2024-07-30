<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyHeaders.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2014-2015

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

	var sCancelAction = Session("ReturnURL");
	if (isEmpty(sCancelAction)) {
	    sCancelAction = eWare.Url(Request.QueryString("F"));
	}

    var recOpenInvestigations = eWare.FindRecord("vPRVerbalInvestigations", "prvi_CompanyID=" + comp_companyid + " AND prvi_Status='O'");

    // If we don't have any open verbal investigations to add these companies too, then just
    // take the user to the new verbal investigation page.
    if (recOpenInvestigations.eof) {
    
        // Reset our "F" parameter to point to the page that got us here.
        var sRedirectUrl = eWare.Url("PRTES/PRVerbalInvestigationEdit.asp") + "&prvi_VerbalInvestigationID=-1" + "&T=Company&Capt=Trade+Activity";
        sRedirectUrl = removeKey(sRedirectUrl, "F"); 
        sRedirectUrl += "&F=" + Request.QueryString("F");
        Response.Redirect(sRedirectUrl);
        return;
    } 
    
    var grdOpenInvestigations = eWare.GetBlock("PROpenVerbalInvestigationsGrid");
    grdOpenInvestigations.ArgObj = recOpenInvestigations;
    grdOpenInvestigations.PadBottom = false;
    grdOpenInvestigations.DeleteGridCol("comp_Name");
    blkContainer.AddBlock(grdOpenInvestigations);


    var recCompanies = eWare.FindRecord("vPRCompanyLocation", "comp_CompanyID IN (" + Session("VICompanyIDs") + ")");
    var grdCompanyLocation = eWare.GetBlock("PRCompanyLocationGrid");
    grdCompanyLocation.ArgObj = recCompanies;
    grdCompanyLocation.PadBottom = false;
    blkContainer.AddBlock(grdCompanyLocation);

    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
    blkContainer.AddButton(eWare.Button("New Verbal Investigation", "New.gif", eWare.Url("PRTES/PRVerbalInvestigationEdit.asp") + "&prvi_VerbalInvestigationID=-1" + "&T=Company&Capt=Trade+Activity"));
    

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));
%>

    <!-- #include file="..\PRCompany\CompanyFooters.asp" -->

<%    
}
%>
