<!-- #include file ="..\accpaccrm.js" -->

<%

CurrentCompanyID=eWare.GetContextInfo("company", "Comp_CompanyId");

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

List=eWare.GetBlock("PRCompanyInvestigationGrid");
List.prevURL=sURL;

container = eWare.GetBlock('container');
container.AddBlock(List);

container.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRInvestigation/PRInvestigationNew.asp") + "&E=PRInvestigation", 'PRInvestigation', 'insert'));
container.DisplayButton(Button_Default) = false;

if( CurrentCompanyID != null && CurrentCompanyID != '' ) {
  eWare.AddContent(container.Execute("priv_CompanyId="+CurrentCompanyID));
} else {
  eWare.AddContent(container.Execute("priv_CompanyId IS NULL"));
}

Response.Write(eWare.GetPage('Company'));

%>





