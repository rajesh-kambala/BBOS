var sBRRootUrl = null;

function viewListing(sCompanyId, sURL, sOptions)
{	
	if (sOptions == null)
	    sOptions = 'resizable=yes,scrollbars=yes';
	window.open(sURL, null, sOptions);

}

// provide one of the two parameters:
// - sCompanyId: A specific company to show the BR for
// - sCompanyIdField: A field on the document that holds the comapny id to show the BR for
function viewBusinessReport(sCompanyId, sCompanyIdField, sRequestingCompanyId, bIncludeBalanceSheet, bIncludeSurvey )
{
    generateBusinessReport(sCompanyId, sCompanyIdField, sRequestingCompanyId, bIncludeBalanceSheet, bIncludeSurvey, false )
}
function generateBusinessReport(sCompanyId, sCompanyIdField, sRequestingCompanyId, bIncludeBalanceSheet, bIncludeSurvey, bWaitAndClose )
{
    if (sCompanyId == null)
    {
        if (sCompanyIdField == null)
        {
            alert ("Cannot determine the company to show the business report for.");
            return;
        }
        // determine if a companyid has been selected
        txtCompanyId = document.all(sCompanyIdField);
        if (txtCompanyId == null)
        {
            alert("A CompanyIDField specified was not found on the current page.");
            return;
        }
        sCompanyId = txtCompanyId.value;
        if (sCompanyId == null || sCompanyId == "undefined" || sCompanyId == "")
        {
            alert("A requested company for the business report has not been selected.");
            return;
        }
    }
    sReportUrl = sBRRootUrl + "&comp_companyid=" + sCompanyId + "&SaveToFile=1";
    if (sRequestingCompanyId != null && sRequestingCompanyId != "undefined" && sRequestingCompanyId != "")
        sReportUrl += "&RequestingCompanyId=" + sRequestingCompanyId;
    // include balance sheet is the default, so only add if we do not want the balance sheet
    if (bIncludeBalanceSheet != null && bIncludeBalanceSheet == false)
        sReportUrl += "&IncBalanceSheet=0" ;
    // do not include survey is the default, so only add if we want to include
    if (bIncludeSurvey != null && bIncludeSurvey == true)
        sReportUrl += "&IncSurvey=0" ;

    // this has to be last to allow the .pdf to end the url
    sOptions = "directories=no,menubar=no,toolbar=no,resizable=yes"
        sReportUrl += "&dummy=x.pdf";
        viewListing(null, sReportUrl, sOptions  );    
}

function viewServiceArchiveReport(szURL) {
    window.open(szURL, null, "directories=no,menubar=no,toolbar=no,resizable=yes,height=600,width=1024");
}

function viewReport(szURL) {
    window.open(szURL, null, "directories=no,menubar=no,toolbar=no,resizable=yes,height=600,width=1024");
}