<!-- #include file ="..\accpaccrm.js" -->

<%

// lID = Request.ServerVariables("ServiceId");

var sURL = new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

List = eWare.GetBlock("PRServicePaymentGrid");
List.prevURL = sURL;

container = eWare.GetBlock('container');
container.AddBlock(List);

container.DisplayButton(Button_Default) = false;

// if (lID != null && lID != '') {
   eWare.AddContent(container.Execute("prsp_ServiceId= 1"));
// }

Response.Write(eWare.GetPage('PRService'));

%>
