<%

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
//Response.Write("URL: " + sURL); 
//Response.Write("<br>Mode: " + eWare.Mode);

var Now=new Date();
// make sure we're in edit mode
if (eWare.Mode<Edit) eWare.Mode=Edit;

record = eWare.CreateRecord(sEntityName);

record.SetWorkFlowInfo(sEntityName, "New");

EntryGroup=eWare.GetBlock(sEntityName + "NewEntry");
EntryGroup.Title=sEntityTitle;

container=eWare.GetBlock("container");
container.AddBlock(EntryGroup);

container.AddButton(
   eWare.Button("Cancel", "cancel.gif",
      eWare.Url(sEntityName + "/" + sEntityName + "Find.asp")+"&T=find&E="+ sEntityName));

eWare.AddContent(container.Execute(record));

if(eWare.Mode==Save) {
  Response.Redirect(sEntityName+"Summary.asp?" + 
                    "J="+sEntityName+"/"+sEntityName+"Summary.asp&E="+sEntityName+"&"
                        +sEntityIdField+"="+record(sEntityIdField)+"&"+Request.QueryString);
}
else {
  Response.Write(eWare.GetPage('New'));
}

%>
