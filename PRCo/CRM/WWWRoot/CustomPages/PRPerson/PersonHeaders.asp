<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

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
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="PersonIdInclude.asp" -->
<%
    if (pers_personid == -1)
    {
        recPerson = eWare.CreateRecord("Person");
    }
    DEBUG("<br>PersonId: " + pers_personid);
%>
<!-- #include file ="PersonTrxInclude.asp" -->

<%
    var f_value = new String(Request.QueryString("F"));
    if (isEmpty(f_value))
    {
        f_value = "PRPerson/PRPersonSummary.asp";
    }
    // Default Actions
    var sCancelAction = new String(f_value);
    var sContinueAction = new String("PRPerson/PRPersonSummary.asp");
    var tabContext = "";

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkTrxHeader);

    // default button actions
    var btnContinue = eWare.Button("Continue","continue.gif", eWare.URL(sContinueAction));
    var btnCancel = eWare.Button("Cancel","cancel.gif", eWare.URL(sCancelAction));

    var bIncludeInverseRelationship = false;
%>    
