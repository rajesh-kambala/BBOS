<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->

<%
	doPage();

function doPage()
{
    var sSecurityGroups = sDefaultPersonSecurity;
    var lErrorMsg = [];
    var blkErrorMsg = null;
    var recQuery;

    processMessages(); //handle message flags from EmailImage.cs

    if (eWare.Mode >= Edit)
        eWare.Mode = View;
    
    // get the list of companies
    var sSQL = "SELECT peli_PersonId, comp_companyid, comp_Name FROM Person_Link " + 
            "INNER JOIN Company ON peli_CompanyId = comp_CompanyId " + 
            "WHERE peli_PRStatus = 1 And peli_PersonId = " + pers_personid;
    recQuery = eWare.CreateQueryObj(sSQL);
    recQuery.SelectSQL();
	if (recQuery.RecordCount < 1) {
		lErrorMsg.push(getErrorHeader("No Company Links"));
	}

	// Multiple active Person_Link records
	sSQL = "Select Count(PeLi_CompanyID) As \"CompanyCount\" From Person_Link Where PeLi_PersonID=" + pers_personid + " And PeLi_PRStatus = 1 Group By PeLi_PersonID, PeLi_CompanyID Having Count(PeLi_CompanyID) > 1";
	recQuery = eWare.CreateQueryObj(sSQL);
	recQuery.SelectSQL();
	if (recQuery.RecordCount > 0) {
		lErrorMsg.push(getErrorHeader("User has multiple active Company Links (for the same company), but can only have one."));
	}
	recQuery = null;

    if (lErrorMsg.length > 0) {
        blkErrorMsg = eWare.GetBlock("Content");
        blkErrorMsg.Contents = lErrorMsg.join("<br/>");
        blkContainer.AddBlock(blkErrorMsg);
    } else {
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups)) {
                blkContainer.AddButton(eWare.Button("Add Monitored Company", "new.gif", eWare.URL("PRPerson/PRPersonAUS.asp") + "&T=Person&Capt=AUS+List"));
                blkContainer.AddButton(CRM.Button("Import Alerts List", "new.gif", CRM.Url("TravantCRM.dll-RunPersonAlertImport")));
            }
	    }
		// only show these if the page is in view mode
		var recAUSs = eWare.FindRecord("vPRWebUserAUSCompanyList","PeLi_PersonID=" + pers_personid);
		grdAUS = eWare.GetBlock("PRWebUserAUSGrid");
		grdAUS.DisplayForm=false;
		grdAUS.ArgObj = recAUSs;
		blkAUS = eWare.GetBlock("Content");
		blkAUS.contents = grdAUS.Execute();

		blkContainer.AddBlock(blkAUS);
	}

	eWare.AddContent(blkContainer.Execute(recPerson));
    Response.Write(eWare.GetPage('Person'));
}

function processMessages()
{
    //handle message flags from EmailImage.cs
    var flagClear = new String(Request.QueryString("CLEAR"));
    var flagInsertedCount = new String(Request.QueryString("INSERTEDCOUNT"));

    //flags incoming could be CLEAR and INSERTEDCOUNT
    if(flagClear=="undefined")
        flagClear="";
    if(flagInsertedCount=="undefined")
        flagInsertedCount="";

    var flags = "";
    if(flagClear != "" || flagInsertedCount != "")
    {
        flags += "<table class='InfoContent'><tbody><tr><td><b><label style='color:green'>";

        if(flagClear != "")
            flags += "List cleared.&nbsp;&nbsp;";
        if(flagInsertedCount != "")
            flags += flagInsertedCount + " records added.&nbsp;&nbsp;&nbsp;";
        flags += "</label></b></td></tr></tbody></table>";
        eWare.AddContent(flags);
    }
}
%>

<!-- #include file ="../RedirectTopContent.asp" -->
