<% 
function getRepeatOrderHeader(salesOrderID) {

    var value = "";
    var buffer = "\n\n<table class=\"CONTENT\" id=\"tblHeader" + salesOrderID +  "\" style=\"displayz:none;width:100%\"><tr>\n";

    var qryOrder = eWare.CreateQueryObj("SELECT * FROM vPRRepeatOrders WHERE SalesOrderNo = '" + salesOrderID + "'");
    qryOrder.SelectSQL();
    if  (!qryOrder.eof) {

        var enteredURL = changeKey(eWare.URL("PRCompany/PRCompanySummary.asp"), "Key1", qryOrder("EnteredCompanyID") )
        var billedURL = changeKey(eWare.URL("PRCompany/PRCompanySummary.asp"), "Key1", qryOrder("BillToCompanyID") )

        buffer += "<td valign=\"top\" rowspan=\"3\"><span class=\"VIEWBOXCAPTION\">Billed To:</span><br/><span class=\"VIEWBOX\"><a href=\"" + billedURL + "\">"  + qryOrder("BillToCompanyName") + "</a><br/>"  + qryOrder("BilledAddress") + "</span></td>\n";
        buffer += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Order Location:</span><br/><span class=\"VIEWBOX\"><a href=\"" + enteredURL + "\">"  + qryOrder("EnteredCompanyName") + "</a></span></td>\n";
        buffer += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Billing Month:</span><br/><span class=\"VIEWBOX\">" + qryOrder("CycleCode") + "</span></td>\n";
        
        buffer += "</tr><tr>\n";

        value = "&nbsp;";
        if (!isEmpty(qryOrder("InvoiceDate"))) {
            value = getDateAsString(qryOrder("InvoiceDate"));
        }
        buffer += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Invoice Date:</span><br/><span class=\"VIEWBOX\">" + value + "</span></td>\n";

        value = "&nbsp;";
        if (!isEmpty(qryOrder("AmtInvoiced"))) {
            value = "$" + formatDollar(qryOrder("AmtInvoiced"));
        }
        buffer += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Amount Billed:</span><br/><span class=\"VIEWBOX\">" + value + "</span></td>\n";
        buffer += "</tr><tr>\n";
        
        buffer += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Terms Code:</span><br/><span class=\"VIEWBOX\">" + qryOrder("TermsCode") + "</span></td>\n";

        value = "&nbsp;";
        if (!isEmpty(qryOrder("AmtDue"))) {
            value = "$" + formatDollar(qryOrder("AmtDue"));
        }
        buffer += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Amt Due:</span><br/><span class=\"VIEWBOX\">" + value + "</span></td>\n";
        buffer += "</tr></table>\n";

    }

    return buffer;
}

function getRepeatOrderDetails(salesOrderID) {

    var sClass = "ROW2";
    var buffer = "<table width=\"98%\" class=\"CONTENT\" id=\"tblDetails" + salesOrderID + "\" style=\"displayz:none;margin-top:10px;margin-bottom:5px;margin-left:auto;margin-right:auto;\" align=center ><tr><th class=\"GRIDHEAD\" align=left>Service Code</th><th class=\"GRIDHEAD\" align=left>Service</th><th class=\"GRIDHEAD\" align=center>Tax Class</th><th class=\"GRIDHEAD\" align=right>Tax Rate</th><th class=\"GRIDHEAD\" align=right>Quantity</th><th class=\"GRIDHEAD\" align=right>Discount</th><th class=\"GRIDHEAD\" align=right>Price</th></tr>";

    var qryOrderDetails = eWare.CreateQueryObj("SELECT prse_ServiceCode, ItemCodeDescExt, QuantityOrdered, ExtensionAmt, SalesKitItem, prse_DiscountPct, TaxClass, TaxRate FROM PRService WHERE SalesOrderNo = '" + salesOrderID + "' ORDER BY LineSeqNo");
    qryOrderDetails.SelectSQL();
    while (!qryOrderDetails.eof) {

        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }

        buffer += "<tr>";
    
        buffer += "<td class=\"" + sClass + "\">" + qryOrderDetails("prse_ServiceCode") + "</td>";

        buffer += "<td class=\"" + sClass + "\">" 
        if (qryOrderDetails("SalesKitItem") == "Y") {
            buffer += "&nbsp;&nbsp;&nbsp;";
        }
        
        buffer += qryOrderDetails("ItemCodeDescExt") + "</td>";

        if (qryOrderDetails("SalesKitItem") != "Y") {
            buffer += "<td class=\"" + sClass + "\" align=\"center\" width=\"125px\">" + qryOrderDetails("TaxClass") + "</td>";
            sValue = String(parseFloat(qryOrderDetails("TaxRate")).toFixed(2));
            buffer += "<td class=\"" + sClass + "\" align=\"right\" width=\"125px\">" + sValue+ "%</td>";
        } else {
            buffer += "<td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td>";
        }

		buffer += "<td class=\"" + sClass + "\" align=\"right\" width=\"125px\">" + formatCommaSeparated(qryOrderDetails("QuantityOrdered")) + "</td>";
        buffer += "<td class=\"" + sClass + "\" align=\"right\" width=\"125px\">" + qryOrderDetails("prse_DiscountPct") + "%</td>";
		buffer += "<td class=\"" + sClass + "\" align=\"right\" width=\"125px\">$" + formatDollar(qryOrderDetails("ExtensionAmt")) + "</td>";
        buffer += "</tr>";
        qryOrderDetails.NextRecord();
    }
    
    buffer += "</table>";
    return buffer;
}
%>