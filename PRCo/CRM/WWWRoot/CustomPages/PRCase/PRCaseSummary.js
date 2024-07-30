function save() {

    var sAlertString = "";

    var masterInvoiceFld = document.getElementById("case_prmasterinvoicenumber");
    if (masterInvoiceFld.value == "") {
        sAlertString += " - Master Invoice Number";
    }

    if (sAlertString != "") {
        alert("The following fields are required:\n\n" + sAlertString);
        return;
    }


    masterInvoiceFld.disabled = false;
    document.EntryForm.submit();
}

function RedirectCase() {
    var sUrl = String(location.href);

    iEWare = sUrl.indexOf("eware.dll");
    var sApp = String(sUrl.substring(0, iEWare));

    iQMark = sUrl.indexOf("?");
    var sQuery = String(sUrl.slice(iQMark, sUrl.length));

    // We will have a "RecentValue" if the user clicked on an entry
    // in the "Recent" list.  In this case, grab the key values from
    // CRM
    var recentValue = getKey(sQuery, "RecentValue");
    if (recentValue != null) {
        sQuery = removeKey(sQuery, "RecentValue");
        sQuery = sQuery + GetKeys();
    }


    var url = sApp + "CustomPages/PRCase/PRCaseSummary.asp" + sQuery + "&T=Case&J=PRCase/PRCaseSummary.asp"
    //alert(url);

    location.href = url;
    return;
}

