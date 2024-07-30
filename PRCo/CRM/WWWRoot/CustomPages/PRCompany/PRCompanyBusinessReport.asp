<!-- #include file ="..\accpaccrm.js" -->

<%

lID = eWare.GetContextInfo("company", "Comp_CompanyId");

var sURL = new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

List = eWare.GetBlock("PRCompanyBusinessReportGrid");
List.prevURL = sURL;

container = eWare.GetBlock('container');
container.AddBlock(List);
container.AddButton(eWare.Button("Request Business Report", "new.gif", eWare.URL("PRBusinessReportRequest/PRBusinessReportRequestFind.asp") + "&E=PRCompany", 'PRCompany', 'insert'));

container.DisplayButton(Button_Default) = false;

// First check for the BuyingOp key
//var lId = "18";

//if (lId != 0) {
//   eWare.AddContent(container.Execute("prbr_CompanyId=" + lId));
   eWare.AddContent(container.Execute());
//}

Response.Write(eWare.GetPage("Company"));

%>
