<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PCGLibrary.asp" -->

<%

eWare.SetContext("Find");

// Need to set mode to edit automatically
if (eWare.Mode < Edit) {
   eWare.Mode = Edit;
}

var sURL = new String(Request.ServerVariables("URL")() + "?" + Request.QueryString);

blkSearch = eWare.GetBlock("PRInvestigationSearchBox");
blkSearch.Title = eWare.GetTrans("Tabnames", "Search");

lstSearch = eWare.GetBlock("PRInvestigationGrid");
lstSearch.ArgObj = blkSearch;
lstSearch.prevURL = sURL;

cntSearch = eWare.GetBlock("container");
cntSearch.ButtonTitle = "Search";
cntSearch.ButtonImage = "Search.gif";
cntSearch.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
cntSearch.AddBlock(blkSearch);

// Add in the search results if in Save mode
if (eWare.Mode == Save) {
   cntSearch.AddBlock(lstSearch);
}

// Clear all of the fields if Clear button was clicked
if (eWare.Mode == 6) {

}

eWare.AddContent(cntSearch.Execute(blkSearch));

Response.Write(eWare.GetPage());

%>
