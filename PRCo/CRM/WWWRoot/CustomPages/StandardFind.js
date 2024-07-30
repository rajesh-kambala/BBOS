<%


// For search screens the content is set to "Find" to match the Custom_Tabs tab entity 
eWare.SetContext("Find");


var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
//Response.Write("URL: " + sURL); 
//Response.Write("<br>Mode: " + eWare.Mode);
searchEntry=eWare.GetBlock(sEntityName + "SearchBox");
searchEntry.Title=eWare.GetTrans("Tabnames","Search");

searchList=eWare.GetBlock(sEntityName + "Grid");
searchContainer=eWare.GetBlock("container");

searchContainer.ButtonTitle="Search";
searchContainer.ButtonImage="Search.gif";

searchContainer.AddBlock(searchEntry);
if( eWare.Mode == Find || eWare.Mode == View)
  searchContainer.AddBlock(searchList);

searchContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

if (isUserInGroup(sUserGroups)) {        
    searchContainer.AddButton(eWare.Button("New", "new.gif", eWare.Url(sEntityName + "/"+ sEntityName + "New.asp")));
}

searchList.ArgObj=searchEntry;
searchList.prevURL=sURL;
eWare.AddContent(searchContainer.Execute(searchEntry));

Response.Write(eWare.GetPage());

%>
