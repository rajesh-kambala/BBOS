<!-- #include file ="..\accpaccrm.js" -->

<%

if( eWare.Mode != Save ){
  F=Request.QueryString("F");
  if( F == "PROpenDataNew.asp" ) eWare.Mode=Edit;
}

var lId = new String(Request.Querystring("prod_OpenDataId"));

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

var recHeader = eWare.FindRecord('PROpenData','prod_OpenDataId=' + lId);
blkHeader = eWare.GetBlock("PROpenDataNewEntry");
blkHeader.Title = "Open Data Information";
blkHeader.ArgObj = recHeader;

container = eWare.GetBlock('container');
container.AddBlock(blkHeader);
container.DisplayButton(Button_Default) = false;

if (UseId != 0) {
   //if were deleting
   if( Request.Querystring("em") == 3 ){
     recHeader.DeleteRecord = true;
     recHeader.SaveChanges();

     Response.Redirect(eWare.URL("PRCompany/PRCompanyRating.asp?J=PRRating/PRRating.asp&E=PRRating"));
	} else {
		if(eWare.Mode == Edit) {
			container.DisplayButton(Button_Continue) = true;
			container.AddButton(eWare.Button("Delete", "delete.gif", "javascript:x=location.href;i=x.search('&em=');if (i >= 0) {   x=x.substr(0,i)+x.substr(i+2+3,x.length);}x=x+'&'+'em'+'='+'3';location.href=x", "PRRating", "DELETE"));
			container.AddButton(eWare.Button("Save", "save.gif", "javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prra_RatingId=" + UseId + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRRating", "EDIT"));
		} else {
			container.DisplayButton(Button_Continue) = true;
			container.AddButton(eWare.Button("Change","edit.gif","javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prra_RatingId=" + UseId + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRRating", "EDIT"));
		}

     eWare.AddContent(container.Execute());
  }

  Response.Write(eWare.GetPage());
}

%>
