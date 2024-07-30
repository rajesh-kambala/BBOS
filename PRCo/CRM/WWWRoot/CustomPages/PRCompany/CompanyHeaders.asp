<!-- #include file ="..\PRCoGeneral.asp" -->

<!DOCTYPE html>

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
%>
<!-- #include file ="CompanyIdInclude.asp" -->

<%
    if (comp_companyid != -1)
    {
%>
<!-- #include file ="CompanyTrxInclude.asp" -->
<%
    }
    
    //Response.Write("<br>URL: " + sURL); 
    //Response.Write("<br>Mode: " + eWare.Mode);
    //Response.Write("<br>CompanyId: " + comp_companyid);

    var f_value = String(Request.QueryString("F"));
    if (isEmpty(f_value))
    {
        f_value = "PRCompany/PRCompanySummary.asp";
    }
    // Default Actions
    var sCancelAction = f_value;
    var sContinueAction = String("PRCompany/PRCompanySummary.asp");
    var tabContext = "";
    
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    if (comp_companyid != -1)
    {
        blkContainer.AddBlock(blkTrxHeader);
    }
    
    // default button actions
    var btnContinue = eWare.Button("Continue","continue.gif", eWare.URL(sContinueAction));
    var btnCancel = eWare.Button("Cancel","cancel.gif", eWare.URL(sCancelAction));

%>    