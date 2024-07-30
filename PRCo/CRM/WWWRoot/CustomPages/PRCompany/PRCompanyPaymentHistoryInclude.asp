<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012-2023

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

function getPaymentHistoryTable(companyID, masterSalesOrderNo) {

    var bHasEBillAttnLine = false;

    var recEBillAttnLine = eWare.CreateQueryObj("SELECT 'x' FROM PRAttentionLine WITH (NOLOCK) WHERE prattn_CompanyID= " + comp_companyid + " AND prattn_ItemCode IN ('BILL', 'ADVBILL') AND (prattn_EmailID IS NOT NULL OR prattn_PhoneID IS NOT NULL) AND prattn_Deleted IS NULL");
    recEBillAttnLine.SelectSQL();
    if (!recEBillAttnLine.EOF) {
        bHasEBillAttnLine = true;
    }

    var stripeEnabled = "false";
    var rec = eWare.CreateQueryObj("SELECT Capt_US FROM custom_captions WHERE capt_Family = 'StripeInvoice' AND capt_Code = 'StripeInvoiceEnabled'");
    rec.SelectSQL();
    if (!rec.EOF) {
        stripeEnabled = rec("Capt_US")
    }

    var paymentHistoryContent = "<table id=\"tblPaymentHistory\" class=\"CONTENT\" border=\"1px\" cellspacing=\"0\" cellpadding=\"1\" bordercolordark=\"#ffffff\" bordercolorlight=\"#ffffff\" width=\"100%\" >\n" ;
    paymentHistoryContent += "<tr><td class=\"GRIDHEAD\" style=\"text-align:center\">Transaction Date</td><td class=\"GRIDHEAD\" style=\"text-align:center\">Invoice Number</td><td class=\"GRIDHEAD\" style=\"text-align:center\">Transaction Type</td><td class=\"GRIDHEAD\" style=\"text-align:right\">Transaction Amt</td><td class=\"GRIDHEAD\" style=\"text-align:right\">Balance</td><td class=\"GRIDHEAD\" style=\"text-align:right\">Days to Pay</td><td class=\"GRIDHEAD\" style=\"text-align:center\">Check No</td><td class=\"GRIDHEAD\" style=\"text-align:center\">Action</td></tr>\n";

    var paymentHistorySQL;
    if (isEmpty(masterSalesOrderNo)) {
        paymentHistorySQL = "SELECT * FROM dbo.ufn_GetPaymentHistory(" + comp_companyid + ", NULL) ORDER BY Sequence";
    } else {
        paymentHistorySQL = "SELECT * FROM dbo.ufn_GetPaymentHistory(" + comp_companyid + ",'" + masterSalesOrderNo + "') ORDER BY Sequence";
    }
    recPaymentHistory = eWare.CreateQueryObj(paymentHistorySQL);
    recPaymentHistory.SelectSQL();
    var sClass = "ROW1";
    
    if (recPaymentHistory.EOF) {
        paymentHistoryContent += "<tr class=\"ROW1\"><td colspan=7>No Payment History Records Found.</td></tr>\n";
    }

    while (!recPaymentHistory.EOF) {
        
        if (sClass == "ROW2")
            sClass="ROW1"; 
        else
            sClass = "ROW2"

        paymentHistoryContent += "<tr class=\"" + sClass + "\">";
        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + getDateAsString(recPaymentHistory("TransactionDate")) + "</td>";  

        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:center\">";
        if (isEmpty(recPaymentHistory("UDF_MASTER_INVOICE"))) {
            paymentHistoryContent += "&nbsp;";
        } else {
            paymentHistoryContent += "<a href=\"javascript:openInvoiceReport('" + recPaymentHistory("UDF_MASTER_INVOICE") + "', '" + stripeEnabled + "')\">" + recPaymentHistory("UDF_MASTER_INVOICE") + "</a>";
        }
        paymentHistoryContent += "</td>";
        
        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + recPaymentHistory("TransactionTypeDesc") + "</td>";  
        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:right\">" + formatDollar(recPaymentHistory("TransactionAmt")) + "</td>";  
        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:right\">" + formatDollar(recPaymentHistory("Balance")) + "</td>";  

        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:right\">";
        if (isEmpty(recPaymentHistory("DaysToPay"))) {
            paymentHistoryContent += "&nbsp;";
        } else {
            paymentHistoryContent += recPaymentHistory("DaysToPay")
        }
        paymentHistoryContent += "</td>";
        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + getEmpty(recPaymentHistory("CheckNo")) + "</td>";  



        paymentHistoryContent += "<td class=\"" + sClass + "\" style=\"text-align:center\">";
        if ((bHasEBillAttnLine) &&
            (recPaymentHistory("TransactionType") == "I")) {
            paymentHistoryContent += "<a href=\"javascript:sendInvoice('" + recPaymentHistory("UDF_MASTER_INVOICE") + "', " + user_userid + ")\">Send Invoice</a>"
        } else {
            paymentHistoryContent += "&nbsp;";
        }

        paymentHistoryContent += "</td>";
        paymentHistoryContent += "</tr>\n" ;

        recPaymentHistory.NextRecord();
    }
    paymentHistoryContent += "</table>";

    return paymentHistoryContent;
}
 %>