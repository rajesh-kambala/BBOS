<!-- #include file ="..\accpaccrm.js" -->

<%

if( eWare.Mode != Save ){
  F=Request.QueryString("F");
  if( F == "PRLicenseNew.asp" ) eWare.Mode=Edit;
}

Container=eWare.GetBlock("container");
Entry=eWare.GetBlock("PRLicenseNewEntry");
Entry.Title="License";
Container.AddBlock(Entry);
Container.DisplayButton(1)=false;

var Id = new String(Request.Querystring("prli_LicenseId"));

if (Id.toString() == 'undefined') {
   Id = new String(Request.Querystring("Key58"));
}

var UseId = 0;

if (Id.indexOf(',') > 0) {
   var Idarr = Id.split(",");
   UseId = Idarr[0];
} else if (Id != '')
  UseId = Id;

if (UseId != 0) {
   var Idarr = Id.split(",");

   eWare.SetContext("PRLicense", UseId);

   record = eWare.FindRecord("PRLicense", "prli_LicenseId=" + UseId);

   //if were deleting
   if( Request.Querystring("em") == 3 ) {
//     record.DeleteRecord = true;
//     record.SaveChanges();

//     Response.Redirect(eWare.URL("PRCompany/PRCompanyLicense.asp?J=PRLicense/PRLicenseNew.asp&E=PRLicense"));
   } else {
     if(eWare.Mode == Edit) {
       Container.DisplayButton(Button_Continue) = true;
       Container.AddButton(eWare.Button("Delete", "delete.gif", "javascript:x=location.href;i=x.search('&em=');if (i >= 0) {   x=x.substr(0,i)+x.substr(i+2+3,x.length);}x=x+'&'+'em'+'='+'3';location.href=x", "PRLicense", "DELETE"));
       Container.AddButton(eWare.Button("Save", "save.gif", "javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prli_LicenseId=" + UseId + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRLicense", "EDIT"));
     } else {
       Container.DisplayButton(Button_Continue) = true;
       Container.AddButton(eWare.Button("Change","edit.gif","javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prli_LicenseId=" + UseId + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRLicense", "EDIT"));
     }

     eWare.AddContent(Container.Execute(record));
  }

  Response.Write(eWare.GetPage());
}

%>
