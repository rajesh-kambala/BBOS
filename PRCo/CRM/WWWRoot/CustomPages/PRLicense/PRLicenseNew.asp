<!-- #include file ="..\accpaccrm.js" -->

<%

if (eWare.Mode < Edit) {
	eWare.Mode = Edit;
}

lId = eWare.GetContextInfo("company", "Comp_CompanyId");

recMain = eWare.CreateRecord("PRLicense");

blkEntry = eWare.GetBlock("PRLicenseNewEntry");
blkEntry.Title = "License";

fldMain = blkEntry.GetEntry("prli_CompanyId");
fldMain.DefaultValue = lId;

if (!false) {
	eWare.SetContext("New");
}

cntMain = eWare.GetBlock("container");
cntMain.AddBlock(blkEntry);
cntMain.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRCompany/PRCompanyLicense.asp")+"&T=find&E=PRLicense"));
eWare.AddContent(cntMain.Execute(recMain));

if (eWare.Mode == Save) {
	Response.Redirect("PRLicenseSummary.asp?J=PRLicense/PRLicenseSummary.asp&E=PRLicense&prli_LicenseId=" + recMain("prli_LicenseId") + "&" + Request.QueryString);
} else {

	RefreshTabs = Request.QueryString("RefreshTabs");

	if (RefreshTabs ='Y') {
		Response.Write(eWare.GetPage('New'));
	} else {
		Response.Write(eWare.GetPage());
	}
}

%>
