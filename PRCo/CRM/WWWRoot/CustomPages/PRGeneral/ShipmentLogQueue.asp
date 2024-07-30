<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012

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

    lstMain = eWare.GetBlock("PRShipmentLogQueueGrid");

	blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;    
    blkContainer.AddBlock(lstMain);

    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage());
%>


