<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2018

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

    //
    //  Leave this code commented out for now.  We're not sure if the users
    //  really need it.  
    //
    // Unlock any records this user might have locked.  If the user is on
    // this page, then no records should be locked.
    //var sSQL = "UPDATE PRTESRequest SET prtesr_ProcessedByUserID=NULL FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID WHERE prtesr_SentMethod = 'VI' AND prtesr_ProcessedByUserID= " + user_userid;
    //var recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
    //recUpdatePRTESRequest.ExecSql();

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
    var blkFilter=eWare.GetBlock("PRVICallQueueSearchBox");
    blkFilter.Title = "Filter By:"
    blkContainer.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.submit();" ));
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
    blkContainer.AddBlock(blkFilter);

    var grdCallQueue = eWare.GetBlock("PRVICallQueue");
    blkContainer.AddBlock(grdCallQueue);

    eWare.AddContent(blkContainer.Execute(blkFilter));
    Response.Write(eWare.GetPage(''));
%>