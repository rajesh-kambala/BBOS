<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCOGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    doPage();

function doPage() {

    var sURL = "PRCreditSheetGenerateFiles.aspx?SID=" + Request.QueryString("SID") + "&user_userid=" + user_userid;
    var blkCustom = eWare.GetBlock('Content');
    blkCustom.contents = '<iframe ID="ifrmCustom" FRAMEBORDER="0" MARGINHEIGHT="0" NORESIZE SCROLLING="AUTO" style="height:800px;width:100%;border:none;" src="'+sURL +'"></iframe>';

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkCustom);
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage(""));
}
%>