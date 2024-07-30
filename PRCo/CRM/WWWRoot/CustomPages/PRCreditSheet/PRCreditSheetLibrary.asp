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

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

Container=eWare.GetBlock("container");

List=eWare.GetBlock("LibraryList");
List.prevURL=sURL;
var Id = Request.Querystring("prcs_CreditSheetId");

eWare.SetContext("PRCreditSheet", Id);

Container.AddBlock(List);
Container.AddButton(eWare.Button("New", "new.gif", eWare.URL(343)+"&Key-1=" + iKey_CustomEntity + "&PrevCustomURL="+List.prevURL+"&E=PRCreditSheet"));
Container.DisplayButton(1)=false;

if( Id != '') {
  eWare.AddContent(Container.Execute("Libr_PRCreditSheetId=" + Id));
}

Response.Write(eWare.GetPage());

%>




