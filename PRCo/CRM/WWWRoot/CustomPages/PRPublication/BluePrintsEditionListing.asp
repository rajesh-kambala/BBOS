<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc.  2013

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
    var blkArticleList = eWare.GetBlock("PRBlueprintEditionListingGrid");

    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkArticleList);
    blkContainer.AddButton(eWare.Button("New Edition", "new.gif", eWare.URL("PRPublication/PRPublicationEdition.asp")));

    eWare.AddContent(blkContainer.Execute(""));
    Response.Write(eWare.GetPage("New"));
}
%>