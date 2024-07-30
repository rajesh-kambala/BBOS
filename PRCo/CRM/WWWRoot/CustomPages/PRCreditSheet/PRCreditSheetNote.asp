<!-- #include file ="..\accpaccrm.js" -->
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

//Define Variables
var lId = new String(Request.Querystring("prcs_CreditSheetId"));
var sURL = new String(Request.ServerVariables("URL")() + "?" + Request.QueryString);

if (lId.toString() == 'undefined') {
   lId = new String(Request.Querystring("Key58"));
}

//Call Set the Page Context to the current entity and entity item context
eWare.SetContext("PRCreditSheet", lId);

//Set and Add List
lstMain = eWare.GetBlock("NoteList");
lstMain.prevURL = sURL;

//Call GetBlock to create a container
cntMain = eWare.GetBlock("container");
cntMain.AddBlock(lstMain);

if (lId.toString() == 'undefined') {
   lId = new String(Request.Querystring("Key58"));
}

cntMain.DisplayButton(1) = false;

eWare.AddContent(cntMain.Execute());

Response.Write(eWare.GetPage());

%>









