<!-- #include file ="..\accpaccrm.js" -->

<%

lID = eWare.GetContextInfo("company", "Comp_CompanyId");

var sURL = new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

List = eWare.GetBlock("PRServiceUnitUsageGrid");
//List = eWare.GetBlock("PRCompanyBusinessReportGrid");
List.prevURL = sURL;
col=List.GetGridCol("prsuu_CreatedDate");
col.OrderByDesc = true;
container = eWare.GetBlock('container');
container.AddBlock(List);
//container.AddButton(eWare.Button("Link", "new.gif", eWare.URL("PRCompany/PRCompanyTerminalMarketLink.asp")+"&E=PRCompany", 'PRCompany', 'insert'));
var btnServices = eWare.Button("Return to Services","MMLogList.gif", eWare.URL("PRCompany/PRCompanyService.asp"));
container.AddButton(btnServices);
var btnProvideBR = eWare.Button("Provide B/R to Strube","edit.gif", eWare.URL("PRBusinessReportRequest/PRBusinessReportRequestFind.asp"));
container.AddButton(btnProvideBR);

container.DisplayButton(Button_Default) = false;

if (lID != null && lID != '') {
   eWare.AddContent(container.Execute("prsuu_CompanyId=" + lID));
}

Response.Write(eWare.GetPage('Company'));

%>
