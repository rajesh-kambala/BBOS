<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009

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

    lstMain = eWare.GetBlock("PRLRLBatchGrid");
    lstMain.GetGridCol("prlrlb_CreatedDate").OrderByDesc = true;
    lstMain.GetGridCol("prlrlb_Count").Alignment = "right";
    lstMain.GetGridCol("prlrlb_MemberCount").Alignment = "right";
    lstMain.GetGridCol("prlrlb_NonMemebrCount").Alignment = "right";
    lstMain.GetGridCol("prlrlb_TotalSentCount").Alignment = "right";
    lstMain.GetGridCol("prlrlb_RemainingCount").Alignment = "right";


	blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;    
    blkContainer.AddBlock(lstMain);

    sContinueAction = eWare.Url("PRGeneral/GenerateLRLRedirect.asp");
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueAction));

    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage());
%>

