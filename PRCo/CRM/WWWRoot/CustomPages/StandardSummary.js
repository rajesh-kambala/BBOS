<%

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
//Response.Write("URL: " + sURL); 
//Response.Write("<br>nMode: " + eWare.Mode);


// Not sure what this block is meant to do - RAO
if( eWare.Mode != Save )
{
  F=Request.QueryString("F");
  if( F == sEntityName + ".asp" ) 
    eWare.Mode=Edit;
}

Container=eWare.GetBlock("container");
Container.CheckLocks = false;
Entry=eWare.GetBlock(sEntityName + "NewEntry");
Entry.Title=sEntityTitle;

Container.AddBlock(Entry);
// This action hides the default "Change" button
Container.DisplayButton(1)=false;

// Determine the key id for this entity type
var Id = new String(Request.Querystring(sEntityIdField));
if (Id.toString() == 'undefined') {
   Id = new String(Request.Querystring("Key58"));
}
var UseId = 0;

if (Id.indexOf(',') > 0) 
{
   var Idarr = Id.split(",");
   UseId = Idarr[0];
}
else if (Id != '')
{
  UseId = Id;
}

if (UseId != 0) 
{
   // set the context to show the tabs
   //eWare.SetContext(sEntityName, UseId);

   // find the record based upon the ID
   record = eWare.FindRecord(sEntityName, sEntityIdField+"="+UseId);

   //if we were deleting
   if( Request.Querystring("em") == PreDelete )
   {
  
        //Perform a physical delete of the record
        sql = "DELETE FROM " + sEntityName + " WHERE " + sEntityIdField + "="+ UseId;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

     // need to redirect back to the place where we got to the summary from
     // -- but we cant refresh the top frame easily so just go back to find
     // -- every time
     sPrevCustomURL = new String(Request.QueryString("PrevCustomURL"));
     if (sPrevCustomURL.toString()=="undefined" || sPrevCustomURL == '')
     {
		Response.Redirect(eWare.URL(sEntityName+"/"+sEntityName+"Find.asp"));
	 }
	 else
	 {
		Response.Redirect(sPrevCustomURL);
     }
   }
   else
   {
     deleteURL = sURL;
     ndx=deleteURL.search("&em=");
     if (ndx >= 0) 
     {   
       deleteURL=deleteURL.substr(0,ndx) + deleteURL.substr(ndx+2+3,deleteURL.length);
     }
     deleteURL = deleteURL + "&em=" + PreDelete;
     
     sURLWithId = sURL;
     // does the url already have the key value
     if (sURLWithId.search(sEntityIdField+"=") < 0)
     {
       // if not, append it
       if (sURLWithId.indexOf("?") >= 0)
         sURLWithId = sURLWithId + "&";
       else
         sURLWithId = sURLWithId + "?";
       // now append the id name value pair
       sURLWithId = sURLWithId + sEntityName+"=" + UseId;
     }
    
     if(eWare.Mode == Edit)
     {
       Container.DisplayButton(Button_Continue) = true;
       Container.AddButton(eWare.Button("Delete", "delete.gif", deleteURL));
       Container.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.action='"+sURLWithId+"';document.EntryForm.submit();"));
     }
     else
     {     
	   Container.DisplayButton(Button_Continue) = false;
       Container.AddButton(eWare.Button("Continue","continue.gif",eWare.URL(sEntityName+"/"+sEntityName+"Find.asp")));

       if (isUserInGroup(sUserGroups)) { 
            Container.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='"+sURLWithId+"';document.EntryForm.submit();"));
        }
     }
    
    Container.ShowWorkflowButtons = true;
    Container.WorkflowTable = sEntityName;

    eWare.AddContent(Container.Execute(record));
  }

  Response.Write(eWare.GetPage(sEntityName));
}

%>
