<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc.

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

function doPage() {

    var szBoxTitle = "Houston, we had a problem!";
    var szBoxMessage = "It seems some how while you were blissfully clicking your way through CRM, we got confused and lost track of which company you were viewing.  Sorry about that.  We're afraid you are going to have to start over by either using Company Find or by using the Recent List.  For what it's worth, this problem seems to manifest primarily when a company is selected from the Recent List.  Just food for thought.  Good Luck!";

    var dialogBox = "<table width=\"500px\" style=\"border: 1px outset #C0C0C0;\" align=\"center\" cellspacing=\"0\" cellpadding=\"0\">\n";
    dialogBox += "<tr><td class=\"errorHeader\">" + szBoxTitle + "</td></tr>\n";
    dialogBox += "<tr><td class=\"errorMessage\">\n";
    dialogBox += szBoxMessage + "\n";
    dialogBox += "</td></tr>\n";
    dialogBox += "</table>\n";
    
    var blkBanners = eWare.GetBlock('content');
    blkBanners.contents = dialogBox;

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkBanners);
    eWare.AddContent(blkContainer.Execute());

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write(eWare.GetPage());
}
%>