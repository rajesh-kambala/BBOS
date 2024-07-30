function findOrder(orderNo, tableName) {

    var parentTable = null;
    var tables = document.getElementsByTagName("table");
    for (j = 0; j < tables.length; j++) {

        if (parentTable != null) {
            break;
        }

        var controls = tables[j].getElementsByTagName("td");
        var orderTD = null;
        for (i = 0; i < controls.length; i++) {
            if (controls[i].innerHTML.indexOf("Repeat Order #" + orderNo) == 0) {
                orderTD = controls[i];
                parentTable = tables[j];
                break;
            }
        }
    }

    // Now find the second parent table node
    var tableNode = null;
    var tableCount = 0;
    parentN = orderTD.parentNode;
    while (parentN != null) {
        if (parentN.tagName == "TABLE") {
            tableCount++;
            if (tableCount == 2) {
                tableNode = parentN;
                break;
            }
        }
        parentN = parentN.parentNode;
    }

    // Now we need to navigate down to the correct table cell
    // Table.TableBody.SecondRow.SecondCell
    var detailTable = document.getElementById(tableName);
    tableNode.childNodes[0].childNodes[1].childNodes[1].appendChild(detailTable);
    detailTable.style.display = "";
}

function openInvoiceReport(invoiceNo, stripeEnabled) {
    var sReportURL = document.getElementById("hidSSRSURL").value;

    if (stripeEnabled == "true")
        sReportURL += "/Accounting/InvoiceStripe";
    else
        sReportURL += "/Accounting/Invoice";

    sReportURL += "&rc:Parameters=false";
    sReportURL += "&InvoiceNo=" + invoiceNo;
    sReportURL += "&rs:format=PDF";
    sReportURL += "&x:dummy=" + getUniqueString();

    window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=800,height=600", true);
}

function openSubscriptionChangesReport(companyID) {
    var sReportURL = document.getElementById("hidSSRSURL").value;
    //sReportURL += "/Sales/Sales Company Subscription Changes";
    sReportURL += "/Accounting/Performance/Company Subscription Changes";
    sReportURL += "&rc:Parameters=false";
    sReportURL += "&StartDate=1/1/2001";
    sReportURL += "&EndDate=1/1/3001";
    sReportURL += "&CompanyID=" + companyID;
    sReportURL += "&x:dummy=" + getUniqueString();
    //sReportURL += "&rs:format=EXCEL";

    window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=800,height=600", true);
}

function openAccountingChangesReport(companyID) {
    var sReportURL = document.getElementById("hidSSRSURL").value;
    sReportURL += "/Accounting/Performance/Company Subscription Changes";
    sReportURL += "&rc:Parameters=false";
    sReportURL += "&StartDate=1/1/2001";
    sReportURL += "&EndDate=1/1/3001";
    sReportURL += "&CompanyID=" + companyID;
    sReportURL += "&x:dummy=" + getUniqueString();
    //sReportURL += "&rs:format=EXCEL";

    window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=800,height=600", true);
}

function openServiceExplorerReport(companyID) {
    var sReportURL = document.getElementById("hidSSRSURL").value;
    sReportURL += "/Customer Service/Service Explorer Report";
    sReportURL += "&rc:Parameters=false";
    sReportURL += "&CompanyID=" + companyID;
    sReportURL += "&x:dummy=" + getUniqueString();

    window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=800,height=600", true);
}

function openCompanyOutstandingARReport(companyID) {
    var sReportURL = document.getElementById("hidSSRSURL").value;
    sReportURL += "/Accounting/Performance/Company Outstanding AR";
    sReportURL += "&rc:Parameters=false";
    sReportURL += "&CompanyID=" + companyID;
    sReportURL += "&x:dummy=" + getUniqueString();

    window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=700,height=500", true);
}

function getUniqueString() {
    var d = new Date();
    return d.getMilliseconds().toString() + "-" +
           d.getSeconds().toString() + "-" +
           d.getMinutes().toString() + "-" +
           d.getHours().toString() + "-" +
           d.getDay().toString();
}

function sendInvoice(invoiceNo, userID) {

    if (!confirm('Are you sure you want to send this invoice?')) {
        return;
    }

    var sURL = "../PRGeneral/SendInvoice.aspx?user_userid=" + userID + "&InvoiceNo=" + invoiceNo;
    window.open(sURL,
				"SendInvoice",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=600,height=600", true);
}