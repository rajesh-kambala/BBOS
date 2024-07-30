<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
    blkContainer = eWare.GetBlock('container');

    blkSearch = eWare.GetBlock("PRCitySearchBox");
    blkSearch.Title = "Search";

    lstMain = eWare.GetBlock("PRCityGrid");
    lstMain.prevURL = eWare.URL(F);
    lstMain.ArgObj = blkSearch;

    blkContainer.AddBlock(blkSearch);
    blkContainer.AddBlock(lstMain);

    blkContainer.DisplayButton(Button_Default) = true;
    blkContainer.ButtonTitle="Search";
    blkContainer.ButtonImage="Search.gif";
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
    
    // add a "new" button
    if (isUserInGroup("4,5,10")) {
        blkContainer.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRCity/PRCity.asp")));
        blkContainer.AddButton(eWare.Button("New International", "new.gif", eWare.URL("PRCity/PRInternationalCity.asp")));
    }


    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage(''));

%>
