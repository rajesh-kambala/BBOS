<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->

<%
    var sSecurityGroups = "1,2,3,5,6,10";

    lstMain = eWare.GetBlock("PRBusinessEventGrid");
    var f_value = new String(Request.QueryString("F"));
    if (isEmpty(f_value))
    {
        f_value = "PRCompany/PRCompanySummary.asp";
    }

    lstMain.prevURL = eWare.URL(f_value);;

    blkContainer = eWare.GetBlock('container');

	var blkPeopleBackground = eWare.GetBlock("PRPeopleBackground");
	blkPeopleBackground.Title = "Original Background Text Migrated from Old BB System ";
	blkPeopleBackground.NewLine = true;
	blkPeopleBackground.ArgObj = recCompany;
    blkContainer.AddBlock(blkPeopleBackground);

    blkContainer.AddBlock(lstMain);
    blkContainer.DisplayButton(Button_Default) = false;

    if (isUserInGroup(sSecurityGroups))
        blkContainer.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRCompany/PRCompanyBusinessEvent.asp")));
    
    
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute("prbe_CompanyId=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->
