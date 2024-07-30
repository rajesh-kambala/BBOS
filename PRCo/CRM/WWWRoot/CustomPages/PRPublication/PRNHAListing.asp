<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
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
    var blkContainer = eWare.GetBlock("container");

    
    var lstTraining = eWare.GetBlock("PRNHAGrid");
    blkContainer.AddBlock(lstTraining);
    blkContainer.DisplayButton(Button_Default) = false;

    blkContainer.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRPublication/PRNHA.asp")));
    blkContainer.AddButton(eWare.Button("Sequence Produce NHA Articles", "forecastrefresh.gif", eWare.URL("PRPublication/PRPublicationArticleSequence.asp") + "&prpbar_PublicationCode=NHA&prpbar_IndustryTypeCode=P")); 
    blkContainer.AddButton(eWare.Button("Sequence Lumber NHA Articles", "forecastrefresh.gif", eWare.URL("PRPublication/PRPublicationArticleSequence.asp") + "&prpbar_PublicationCode=NHA&prpbar_IndustryTypeCode=L")); 

    eWare.AddContent(blkContainer.Execute("prpbar_PublicationCode = 'NHA'"));
    Response.Write(eWare.GetPage("Find"));
}
%>