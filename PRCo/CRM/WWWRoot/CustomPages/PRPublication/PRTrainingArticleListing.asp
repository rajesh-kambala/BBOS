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

    // Search Box
    var blkSearch = eWare.GetBlock("PRTrainingSearchBox");
    blkSearch.Title = "Find Training Articles";
    blkSearch.GetBlock("prpbar_IndustryTypeCode").Size = 6;
    blkSearch.AddButton(eWare.Button("Search", "search.gif", "javascript:document.EntryForm.submit();"));
    blkSearch.AddButton(eWare.Button("Clear", "clear.gif", "javascript:clear();"));
    
    var lstTraining = eWare.GetBlock("PRTrainingGrid");
    lstTraining.ArgObj = blkSearch;

    blkContainer.AddBlock(blkSearch);
    blkContainer.AddBlock(lstTraining);
    blkContainer.DisplayButton(Button_Default) = false;

    blkContainer.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRPublication/PRTraining.asp")));
    blkContainer.AddButton(eWare.Button("Sequence Produce Training Documents", "forecastrefresh.gif", eWare.URL("PRPublication/PRPublicationArticleSequence.asp") + "&prpbar_PublicationCode=TRN&prpbar_IndustryTypeCode=P&prpbar_MediaTypeCode=Doc")); 
    blkContainer.AddButton(eWare.Button("Sequence Produce Training Videos", "forecastrefresh.gif", eWare.URL("PRPublication/PRPublicationArticleSequence.asp") + "&prpbar_PublicationCode=TRN&prpbar_IndustryTypeCode=P&prpbar_MediaTypeCode=Video")); 
    blkContainer.AddButton(eWare.Button("Sequence Lumber Training Documents", "forecastrefresh.gif", eWare.URL("PRPublication/PRPublicationArticleSequence.asp") + "&prpbar_PublicationCode=TRN&prpbar_IndustryTypeCode=L&prpbar_MediaTypeCode=Doc")); 
    blkContainer.AddButton(eWare.Button("Sequence Lumber Training Videos", "forecastrefresh.gif", eWare.URL("PRPublication/PRPublicationArticleSequence.asp") + "&prpbar_PublicationCode=TRN&prpbar_IndustryTypeCode=L&prpbar_MediaTypeCode=Video")); 

    eWare.AddContent(blkContainer.Execute("prpbar_PublicationCode = 'TRN'"));
    Response.Write(eWare.GetPage("Find"));
}
%>