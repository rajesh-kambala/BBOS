<!-- #include file ="..\accpaccrm.js" -->

<%

if( eWare.Mode != Save ){
  F=Request.QueryString("F");
  if( F == "PRServiceNew.asp" ) eWare.Mode=Edit;
}

var lId = new String(Request.Querystring("prse_ServiceId"));

var sURL = new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

if (lId.toString() == 'undefined') {
   lId = new String(Request.Querystring("Key58"));
}

var UseId = 0;

if (lId.indexOf(',') > 0) {
   var Idarr = lId.split(",");
   UseId = Idarr[0];
} else if (lId != '')
  UseId = lId;

lId = UseId;

var recHeader = eWare.FindRecord('PRService','prse_ServiceId=' + lId);
blkHeader = eWare.GetBlock("PRServiceNewEntry");
blkHeader.Title = "Service Header";
blkHeader.ArgObj = recHeader;

var recDetail = eWare.FindRecord('PRServicePayment','prsp_ServiceId=' + lId);
grdDetail = eWare.GetBlock("PRServicePaymentGrid");
grdDetail.prevURL = sURL;
grdDetail.RowsPerScreen = 8;
//grdDetail.PadBottom = false;
grdDetail.ArgObj = recDetail;

container = eWare.GetBlock('container');
container.AddBlock(blkHeader);
container.AddBlock(grdDetail);
container.DisplayButton(Button_Default) = false;

if (UseId != 0) {
   //if were deleting
   if( Request.Querystring("em") == 3 ){
     recHeader.DeleteRecord = true;
     recHeader.SaveChanges();

     Response.Redirect(eWare.URL("PRCompany/PRCompanyService.asp?J=PRService/PRServiceNew.asp&E=PRService"));
   } else {
     if(eWare.Mode == Edit) {
		var btnServices = eWare.Button("Return to Services","MMLogList.gif", eWare.URL("PRCompany/PRCompanyService.asp"));
		container.AddButton(btnServices);
		container.AddButton(eWare.Button("Delete", "delete.gif", "javascript:x=location.href;i=x.search('&em=');if (i >= 0) {   x=x.substr(0,i)+x.substr(i+2+3,x.length);}x=x+'&'+'em'+'='+'3';location.href=x", "PRService", "DELETE"));
		container.AddButton(eWare.Button("Save", "save.gif", "javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prse_ServiceId=" + UseId + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRService", "EDIT"));
     } else {
		var btnServices = eWare.Button("Return to Services","MMLogList.gif", eWare.URL("PRCompany/PRCompanyService.asp"));
		container.AddButton(btnServices);
     }

     eWare.AddContent(container.Execute());
  }

  Response.Write(eWare.GetPage());
}

%>
