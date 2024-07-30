<!-- #include file ="..\accpaccrm.js" -->

<%

if( eWare.Mode != Save ){
  F=Request.QueryString("F");
  if( F == "PRGeneralInfoNew.asp" ) eWare.Mode=Edit;
}

Container=eWare.GetBlock("container");
Entry=eWare.GetBlock("PRGeneralInformationNewEntry");
Entry.Title="General Information";
Container.AddBlock(Entry);
Container.DisplayButton(1)=false;

var Id = new String(Request.Querystring("prgi_GeneralInfoId"));

if (Id.toString() == 'undefined') {
   Id = new String(Request.Querystring("Key58"));
}

var UseId = 0;

if (Id.indexOf(',') > 0) {
   var Idarr = Id.split(",");
   UseId = Idarr[0];
}
else if (Id != '') 
  UseId = Id;


if (UseId != 0) {

   var Idarr = Id.split(",");

   //eWare.SetContext("PRGeneralInfo", "1");

   record = eWare.FindRecord("PRGeneralInformation", "prgi_GeneralInformationId=1");

   //if were deleting
   if( Request.Querystring("em") == 3 ) {
     record.DeleteRecord = true;
     record.SaveChanges();

     // need to redirect back to the place where we got to the summary from
     // -- but we cant refresh the top frame easily so just go back to find
     // -- every time
     PrevCustomURL = new String(Request.QueryString("F"));
     URLarr=PrevCustomURL.split(",");
     if(URLarr[0].toUpperCase() != "PRGeneralInfoNew.asp")
       Response.Redirect(eWare.URL("PRGeneralInfo/PRGeneralInfoFind.asp?J=PRGeneralInfo/PRGeneralInfoFind.asp&E=PRGeneralInfo"));
     else
       Response.Redirect(eWare.URL("PRGeneralInfoNew.asp?J=PRGeneralInfoNew.asp&E=PRGeneralInfo"));
   } else {
     if(eWare.Mode == Edit) {
       Container.DisplayButton(Button_Continue) = true;
       Container.AddButton(eWare.Button("Delete", "delete.gif", "javascript:x=location.href;i=x.search('&em=');if (i >= 0) {   x=x.substr(0,i)+x.substr(i+2+3,x.length);}x=x+'&'+'em'+'='+'3';location.href=x", "PRGeneralInfo", "DELETE"));
       Container.AddButton(eWare.Button("Save", "save.gif", "javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prgi_GeneralInfoId="+UseId+"';document.EntryForm.action=x;document.EntryForm.submit();", "PRGeneralInfo", "EDIT"));
     } else {
       Container.DisplayButton(Button_Continue) = true;
       Container.AddButton(eWare.Button("Change","edit.gif","javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prgi_GeneralInfoId="+UseId+"';document.EntryForm.action=x;document.EntryForm.submit();", "PRGeneralInfo", "EDIT"));
     }

     eWare.AddContent(Container.Execute(record));
  }
  
  Response.Write(eWare.GetPage());
}

%>
