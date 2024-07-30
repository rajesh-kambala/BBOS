<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
try {
	var HQId = recCompany.comp_PRHQId;
//Response.Write("HQ ID: " + HQId);

	var PromoteAct = new String(Request.Querystring('prmact'));
	if (PromoteAct != "undefined" && PromoteAct != "")
	{
		// We have to take some action
		if (PromoteAct == "promote")
		{
			
			// call the stored proc to promte the company
			var querySQL = "EXEC usp_ElevateBranch " + comp_companyid + ", " + user_userid;

			//<!--Create a Query Object-->
			var myQuery = eWare.CreateQueryObj(querySQL,'');  //if system database just use empty quotes
			myQuery.SelectSQL(); //Execute Select SQL;
			// if we're successful, navigate back to company summary with the 
			// id of the previous HQ; This company should now be the HQ
			var sRedirect = eWare.URL("PRCompany/PRCompanySummary.asp");
			sRedirect = changeKey(sRedirect, "Key1", HQId);
			//Response.Write("\nURL: " + sRedirect);
			Response.Redirect(sRedirect);
		}
	}



	cntMain = eWare.GetBlock("container");
	cntMain.DisplayButton(1) = false;

	var contText = eWare.GetBlock("content");
	contText.contents = "<DIV Class=PANEREPEAT>Click Confirm to promote " + recCompany.comp_Name + " to HQ.</>";

	cntMain.AddBlock(contText);

	if (comp_companyid != "undefined" && comp_companyid != '') {
		cntMain.AddButton(eWare.Button("Confirm", "save.gif", eWare.URL("PRCompany/PRCompanyHQPromotion.asp")+"&comp_companyid=" + comp_companyid + "&prmact=promote"));
		cntMain.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRCompany/PRCompanySummary.asp")+"&comp_companyid=" + comp_companyid));

		eWare.AddContent(cntMain.Execute());
	}

	Response.Write(eWare.GetPage('Company'));
}	
catch(exception) {
   //Your Error handling code code goes here
   Response.Write('<table class=content><tr><td colspan=2 class=gridhead><b>There has been an error</b></td></tr>');
   Response.Write("<tr><td class=row1><b>Error Name:</b> </td><td class=row1>"+exception.name+"</td></tr>")
   Response.Write("<tr><td class=row1><b>Error Number:</b> </td><td class=row1>"+exception.number+"</td></tr>")
   Response.Write("<tr><td class=row1><b>Error Number:</b> </td><td class=row1>"+(exception.number & 0xFFFF)+"</td></tr>")
   Response.Write("<tr><td class=row2><b>Error Description:</b></td><td class=row2>"+exception.description+"</td></tr></table>");
}

%>
<!-- #include file="CompanyFooters.asp" -->
