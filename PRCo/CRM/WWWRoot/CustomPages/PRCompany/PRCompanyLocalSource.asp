<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2016

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

doPage();
    

function doPage()
{

    var blkMain=eWare.GetBlock("PRLocalSourceSummary");
    blkMain.Title="Local Source Data";

    if (eWare.Mode > View)
        eWare.Mode = View;
    
    var sContinueAction = eWare.Url("PRCompany/PRCompanyProfile.asp") + "&T=Company&Capt=Profile";
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueAction));

    recLocalSource = eWare.FindRecord("PRLocalSource", "prls_CompanyID=" + comp_companyid);

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recLocalSource));
    Response.Write(eWare.GetPage());
}
%>
<!-- #include file="CompanyFooters.asp" -->
