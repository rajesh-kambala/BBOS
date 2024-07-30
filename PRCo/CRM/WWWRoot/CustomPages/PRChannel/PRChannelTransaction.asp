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

CurrentChannelID=eWare.GetContextInfo("channel", "chan_ChannelId");

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

List=eWare.GetBlock("PRTransactionChannelGrid");
List.prevURL=sURL;

container = eWare.GetBlock('container');
container.AddBlock(List);


container.DisplayButton(Button_Default) = false;

if( true )
{
  container.WorkflowTable = 'PRTransaction';
  container.ShowNewWorkflowButtons = true;
}
else {
  // remove this line to remove the standard new button
  container.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRTransaction/PRTransactionNew.asp")+"&E=PRTransaction", 'PRTransaction', 'insert'));
}


if( CurrentChannelID != null && CurrentChannelID != '' )
{
  eWare.AddContent(container.Execute("prtx_ChannelId="+CurrentChannelID));
}
else
{
  eWare.AddContent(container.Execute("prtx_ChannelId IS NULL"));
}

Response.Write(eWare.GetPage('Channel'));

%>






