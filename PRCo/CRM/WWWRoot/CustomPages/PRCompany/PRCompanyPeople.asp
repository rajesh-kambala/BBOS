<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->

<%

    var blkGeneralContent = eWare.GetBlock("content");
    blkGeneralContent.Contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
    blkContainer.AddBlock(blkGeneralContent);

    blkSearch = eWare.GetBlock("CompanyPersonnelSearchBox");
    blkSearch.Title = "Search";
    entry = blkSearch.GetEntry("peli_PRRole");
    entry.Size = 6;
    
    List = eWare.GetBlock("PRPersonList");
    List.prevURL = sURL;
    List.ArgObj = blkSearch;

    blkContainer.AddBlock(blkSearch);
    blkContainer.AddBlock(List);

    blkContainer.AddButton(eWare.Button("Search", "Search.gif", "javascript:EvaluateName();document.EntryForm.submit();"));
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
    
    if (recCompany.comp_PRLocalSource !=  "Y") {

        var sWebAccessURL = eWare.URL("PRCompany/PRCompanyWebAccessUsers.asp")+ "&comp_companyid=" + recCompany("comp_companyid") + "&T=Company&Capt=Personnel";
        blkContainer.AddButton(eWare.Button("BBOS Access", "list.gif", sWebAccessURL));

        sWebAccessURL = eWare.URL("PRCompany/PRWebUserLocalSource.asp")+ "&comp_companyid=" + recCompany("comp_companyid") + "&T=Company&Capt=Personnel";
        blkContainer.AddButton(eWare.Button("BBOS Local Source Access", "list.gif", sWebAccessURL));
    
    
        if (!isUserInGroup("7"))
        {
            blkContainer.AddButton(eWare.Button("Quick Edit", "edit.gif", eWare.URL("PRCompany/PRCompanyPeopleQuickEdit.asp")+ "&comp_companyid=" + recCompany("comp_companyid") + "&T=Company&Capt=Personnel"));
            blkContainer.AddButton(eWare.Button("Quick Add", "new.gif", eWare.URL("PRCompany/PRCompanyPeopleQuickAdd.asp")+ "&Mode=1&CLk=T&NormalRec=Y&comp_companyid=" + recCompany("comp_companyid") + "&T=Company&Capt=Personnel"));
            blkContainer.AddButton(eWare.Button("BBOS Sequence", "forecastrefresh.gif", eWare.URL("PRCompany/PRCompanyPeopleSequence.asp") + "&comp_companyid=" + recCompany("comp_companyid") + "&T=Company&Capt=Personnel"));
        }
    }
    
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute("peli_CompanyId=" + comp_companyid));
    }

    Response.Write(eWare.GetPage("Company"));
%>
<script type="text/javascript">
    colA = document.getElementsByTagName("A");
    for (var i = 0; i < colA.length; i++) {
        if (colA[i].className == "GRIDHEAD") {
            if (colA[i].innerText == "Publish") {
                colA[i].innerText = "Email Publish"
            }
        }
    }

    function EvaluateName() {
        var fullName = document.getElementById("pers_fullname");
        var fullNameValue = new String(fullName.value);


        if (fullNameValue.substr(0, 1) != "%") {
            fullNameValue = "%" + fullNameValue;
        }

        if (fullNameValue.substr(fullNameValue.length - 1, 1) != "%") {
            fullNameValue = fullNameValue + "%";
        }

        fullName.value = fullNameValue;
    }
</script>

<!-- #include file="CompanyFooters.asp" -->
