<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
%>
<!-- #include file ="../PRCOGeneral.asp" -->
<%

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    lstMain = eWare.GetBlock("PRARAgingImportFormatGrid"); //ES Component Name 
    lstMain.prevURL = eWare.URL(F);
    blkContainer.AddBlock(lstMain);

    blkContainer.AddButton( eWare.Button("New A/R Aging Import Format","New.gif", 
                            eWare.URL("PRGeneral/PRARAgingImportFormat.asp")) );

    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage("Find"));

%>