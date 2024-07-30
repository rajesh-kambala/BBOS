<!-- #include file ="..\accpaccrm.js" -->

<%

CurrentUser=eWare.GetContextInfo("selecteduser", "User_UserId");

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

List=eWare.GetBlock("PRTransactionUserGrid");
List.prevURL=sURL;

container = eWare.GetBlock('container');
container.AddBlock(List);

container.DisplayButton(Button_Default) = false;

// new button
if( true )
{
  container.WorkflowTable = 'PRTransaction';
  container.ShowNewWorkflowButtons = true;
}
else {
  // remove this code to remove the standard new button
  NewButton = eWare.GetBlock("content");
  NewButton.contents = eWare.Button("New", "new.gif", eWare.URL("PRTransaction/PRTransactionNew.asp")+"&E=PRTransaction", 'PRTransaction', 'insert');
  NewButton.NewLine = false;
  container.AddBlock( NewButton );
}


if( CurrentUser != null && CurrentUser != '' )
{
  eWare.AddContent(container.Execute("prtx_CreatedBy="+CurrentUser));
}
else
{
  eWare.AddContent(container.Execute("prtx_CreatedBy IS NULL"));
}

Response.Write(eWare.GetPage('User'));

%>






