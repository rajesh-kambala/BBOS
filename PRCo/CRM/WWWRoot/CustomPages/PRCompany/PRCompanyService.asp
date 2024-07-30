<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="PRCompanyServiceInclude.asp" -->

<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
<script type="text/javascript" src="PRCompanyService.js"></script>
<script type="text/javascript" src="../PRCoGeneral.js"></script>

<%
    doPage();

function doPage() {

    var sSecurityGroups = "1,2,3,4,5,6,9,10,11";
    var sTabs = "Company";
    lId = comp_companyid;

    if ((comp_companyid == "-1") ||
        (isEmpty(comp_companyid))) {
        Response.Redirect(eWare.URL("PRCompany/CompanyError.asp"));
        return;
    }

    var onLoadScript = "";

    var sSummaryAction = eWare.URL("PRCompany/PRCompanyService.asp");
    var sListingAction = sSummaryAction;

    if ((eWare.Mode == "95") || (eWare.Mode == "96"))
    {

        var sql = "EXEC usp_RemoveServiceItems " + comp_companyid + ", '" + recCompany("comp_PRIndustryType") + "', " + user_userid;
        if (eWare.Mode == "96") {
            sql += ", 0";
        }

        qryMerge = eWare.CreateQueryObj(sql);
        qryMerge.ExecSql();

        Response.Write("<script>alert('The service items have been removed successfully.');</script>");
        eWare.Mode = View;
    }

    if (eWare.Mode == 99) {
        addCompanyChangeRecord(comp_companyid, user_userid);
        eWare.Mode = View;
        Response.Write("<script>alert('This company\\'s data will be sent to MAS shortly.');</script>");
    }

    if (eWare.Mode == View)
    {
        Response.Write("<script type=\"text/javascript\" src=\"ViewReport.js\"></script>");
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");

        var context = Request("Context");
        if (isEmpty(context)) {
            context = "Entered";
        }

        var condition = ""
        var prep = ""
        if (context == "Entered") {
            condition = "EnteredCompanyID"
            prep = "for"
        } else {
            condition = "BillToCompanyID"
            prep = "to"
        }

        var blkBanner = eWare.GetBlock("content");
        blkBanner.Contents = "<table width=\"100%\" class=\"WarningContent\"><tr><td>Viewing Orders " + context + " " + prep + " " + recCompany("comp_Name") + "</td></tr></table>";

        var sInnerMsg = "";
        var cols = 3;
        var i = 0
        var qry = eWare.CreateQueryObj("SELECT * FROM dbo.ufn_GetCompanyMessages(" + comp_companyid +  ", '" + recCompany("comp_PRIndustryType") + "') WHERE MessageType='Accounting'");
        qry.SelectSQL();

        while (!qry.eof) {
            if (i % cols == 0) {
                sInnerMsg += "<tr>\n";
            }

            var msg = qry("Message");
            if(msg == "This company's Membership Service has been suspended due to non-payment.")
                sInnerMsg += "\t<td width=\"33%\" align=\"center\" class=\"MessageContent4\">" + qry("Message") + "</td>\n";
            else
                sInnerMsg += "\t<td width=\"33%\" align=\"center\">" + qry("Message") + "</td>\n";

            if ((i+1) % cols == 0) {
                sInnerMsg += "</tr>\n";
            }

            i++;
            qry.NextRecord();
        }

        if (sInnerMsg != "") {
            if (i % cols != 0) {
                sInnerMsg += "</tr>\n";
            }

            sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
            sBannerMsg += "<table class=\"MessageContent\" align=\"center>\"\n";
            sBannerMsg += sInnerMsg;
            sBannerMsg += "</table>\n";
            sBannerMsg += "</td></tr></table>\n\n";

            blkBanner.contents += sBannerMsg;
        }
        blkContainer.AddBlock(blkBanner);

        var membershipSummary = eWare.GetBlock("content");
        membershipSummary.Contents = buildMembershipSummaryBlock(recCompany("comp_PRHQID"), recCompany("comp_CompanyID"));
        blkContainer.AddBlock(membershipSummary);


        var qryRepeatOrders = eWare.CreateQueryObj("SELECT SalesOrderNo FROM vPRRepeatOrders WHERE " + condition + " = " + recCompany("comp_CompanyID"));
        qryRepeatOrders.SelectSQL();
        while (!qryRepeatOrders.eof) {

            var blkRepeatOrder = eWare.GetBlock("content");
            var btnViewPaymentHistory = eWare.Button("View Payment History","Continue.gif", eWare.URL("PRCompany/PRCompanyServicePayment.asp") + "&SalesOrderNo=" + qryRepeatOrders("SalesOrderNo"));

            blkRepeatOrder.Contents += createAccpacBlockHeader("blkRepeatOrder" + qryRepeatOrders("SalesOrderNo"), "Repeat Order #" + qryRepeatOrders("SalesOrderNo") + "&nbsp;&nbsp;&nbsp;<a style=\"font-size:9pt\" href=\"javascript:CopyStringToClipboard('" + qryRepeatOrders("SalesOrderNo") + "');\" title=\"This copies the sales order number to the clipboard.\">(Copy to Clipboard)</a>");
            blkRepeatOrder.Contents += getRepeatOrderHeader(qryRepeatOrders("SalesOrderNo"));
            blkRepeatOrder.Contents += getRepeatOrderDetails(qryRepeatOrders("SalesOrderNo"));
            blkRepeatOrder.Contents += createAccpacBlockFooter(btnViewPaymentHistory);

            blkContainer.AddBlock(blkRepeatOrder);
            qryRepeatOrders.NextRecord();
        }


        var blkStandardOrders = eWare.GetBlock("PRStandardOrderGrid");
        blkStandardOrders.prevURL = eWare.URL(f_value);
        blkStandardOrders.PadBottom=false;
        blkStandardOrders.ArgObj = eWare.FindRecord("vPRStandardOrders", condition + " = " + recCompany("comp_CompanyID"));
        blkContainer.AddBlock(blkStandardOrders);


        var blkFlags = eWare.GetBlock("content");
        var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
        var recSSRS = eWare.CreateQueryObj(sSQL);
        recSSRS.SelectSQL();                
        blkFlags.Contents += "<input type=\"hidden\" id=\"hidSSRSURL\" value=\"" + getValue(recSSRS("SSRSURL")) + "\">";
        blkContainer.AddBlock(blkFlags);


        if (recCompany.comp_PRLocalSource !=  "Y") {
            tabContext = "&T=Company&Capt=Services";

            if (iTrxStatus == TRX_STATUS_EDIT)
            {
                if (isUserInGroup(sSecurityGroups))
                    blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));
            }

            var btnContextParm
            if (context == "Entered") {
                btnContextParm = "Billed"
            } else {
                btnContextParm = "Entered"
            }
            var btnContext = eWare.Button("Orders " + btnContextParm + " Here","Continue.gif", eWare.URL("PRCompany/PRCompanyService.asp") + "&Context=" + btnContextParm + tabContext);
            blkContainer.AddButton(btnContext);

            var btnPaymentHistory = eWare.Button("Payment History","Continue.gif", eWare.URL("PRCompany/PRCompanyPaymentHistory.asp") + tabContext);
            blkContainer.AddButton(btnPaymentHistory);

            var btnRequestBR = eWare.Button("Bus Report Usage","Continue.gif", eWare.URL("PRCompany/PRCompanyServiceUnitUsageListing.asp") + tabContext);
            blkContainer.AddButton(btnRequestBR);

            var btnAllocation = eWare.Button("Bus Report Allocation","Continue.gif", eWare.URL("PRCompany/PRCompanyServiceUnitAllocationListing.asp") + tabContext);
            blkContainer.AddButton(btnAllocation);

            var btnAllocation = eWare.Button("Background Check Allocation","Continue.gif", eWare.URL("TravantCRM.dll-RunBackgroundCheckAllocationListing"));
            blkContainer.AddButton(btnAllocation);


            var btnShipmentLog = eWare.Button("Shipment Log","Continue.gif", eWare.URL("PRCompany/PRCompanyShippingLogList.asp") + tabContext);
            blkContainer.AddButton(btnShipmentLog);

            blkContainer.AddButton(eWare.Button("Send to MAS", "continue.gif", changeKey(sURL, "em", "99")));

            var confirm = "javascript:if (confirm('Are you sure you want to remove all BBOS licenses and service related attention lines from this company?')) { location.href='" + changeKey(sURL, "em", "95") + "';}";
            blkContainer.AddButton(eWare.Button("Remove Company Service Items", "delete.gif", confirm));

            confirm = "javascript:if (confirm('Are you sure you want to remove all BBOS licenses and service related attention lines from this enterprise?')) { location.href='" + changeKey(sURL, "em", "96") + "';}";
            blkContainer.AddButton(eWare.Button("Remove Enterprise Service Items", "delete.gif", confirm));

            var btnSubscriptinChangesReport = eWare.Button("Subscription Changes Report","componentpreview.gif", "javascript:openSubscriptionChangesReport('" + recCompany("comp_CompanyID") + "');");
            blkContainer.AddButton(btnSubscriptinChangesReport);

            var btnServiceExplorerReport = eWare.Button("Service Explorer Report","componentpreview.gif", "javascript:openServiceExplorerReport('" + recCompany("comp_CompanyID") + "');");
            blkContainer.AddButton(btnServiceExplorerReport);

            var recArchiveURL = eWare.FindRecord("custom_SysParams", "Parm_Name='ServiceArchiveReportURL'");
            var szArchiveURL =  recArchiveURL("Parm_Value") + comp_companyid;
            var btnArchiveReport = eWare.Button("Archive Report","componentpreview.gif", "javascript:viewServiceArchiveReport('" + szArchiveURL + "');");
            blkContainer.AddButton(btnArchiveReport);

            var btnSubscriptinChangesReport = eWare.Button("Accounting Changes Report","componentpreview.gif", "javascript:openAccountingChangesReport('" + recCompany("comp_CompanyID") + "');");
            blkContainer.AddButton(btnSubscriptinChangesReport);
        }

    }
    else if (eWare.Mode == Edit)
    {
        blkContainer.CheckLocks = false;
        sTabs = 'New';
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }
    }

    var blkBillingInfo = eWare.GetBlock("PRBillingInfo");
    blkBillingInfo.Title = "Billing Settings";

    recPRCompanyIndicators = eWare.FindRecord("PRCompanyIndicators", "prci2_CompanyID=" + comp_companyid);

    if(recPRCompanyIndicators.eof)
    {
        //Not found - create record
        var createDate = getDBDateTime(new Date());

        recPRCompanyIndicators = eWare.CreateRecord("PRCompanyIndicators");
        recPRCompanyIndicators.prci2_CompanyId = comp_companyid;
        recPRCompanyIndicators.prci2_CreatedBy = -1;
        recPRCompanyIndicators.prci2_CreatedDate = createDate;
        recPRCompanyIndicators.prci2_UpdatedBy = -1;
        recPRCompanyIndicators.prci2_UpdatedDate = createDate;
        recPRCompanyIndicators.prci2_Timestamp = createDate;
        recPRCompanyIndicators.SaveChanges();
    }

    blkBillingInfo.ArgObj = eWare.FindRecord("PRCompanyIndicators", "prci2_CompanyID=" + comp_companyid);
    blkContainer.AddBlock(blkBillingInfo);

    //Hide/disable fields
    var sSecurityGroupsSuspended = "6,10,15"; //ryd also has access userid 1027
    if (user_userid != 1027 && !isUserInGroup(sSecurityGroupsSuspended))
    {
        entry = blkBillingInfo.GetEntry("prci2_Suspended");
        entry.ReadOnly = true;
        entry.Hidden = true;
    }

    eWare.AddContent(blkContainer.Execute());
    if (eWare.Mode == Save)
    {
        Response.Redirect(eWare.Url("PRCompany/PRCompanyService.asp"));
    }
    else {
        Response.Write(eWare.GetPage(sTabs));

        if (eWare.Mode == View)
        {
           Response.Write("<script type=\"text/javascript\">" + onLoadScript + "</script>");
        }
    }

        //************************
    //Script Section BEGIN
    //************************
    Response.Write("\n<script type='text/javascript'>");
	Response.Write("\nfunction initBBSI()"); 
	Response.Write("\n{ ");
    Response.Write("\n\t$('#Button_OrdersBilledHere').focus(); ");
	Response.Write("\n} ");
    Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
	Response.Write("\n</script>");
    //************************
    //Script Section END
    //************************
%>
    <!-- #include file="CompanyFooters.asp" -->
<%
}

function buildMembershipSummaryBlock(HQID, companyID) {

    var repeatOrderCount = 0;
    var buffer = "";
    var value = "";

    buffer =  createAccpacBlockHeader("MembershipSummary", "Membership Summary");
    buffer += "<table class=\"CONTENT\" width=\"100%\"><tr>\n";
    value = "";
    var qry = eWare.CreateQueryObj("SELECT ItemCode,ItemCodeDesc FROM vPRPrimaryService WHERE EnteredHQID = " + HQID);
    qry.SelectSQL();
    if (!qry.eof) {
        value = qry("ItemCode") + " - " + qry("ItemCodeDesc");
    }
    buffer += addField("Enterprise Primary Service Code/Description", value);

    qry = eWare.CreateQueryObj("SELECT COUNT(1) As Cnt FROM vPRRepeatOrders WHERE BillToCompanyID = " + companyID);
    qry.SelectSQL();
    if (!qry.eof) {
        repeatOrderCount = qry("Cnt");
    }

    var value = 0;
    qry = eWare.CreateQueryObj("SELECT ISNULL(SUM(o.Balance), 0) As Amt FROM MAS_PRC.dbo.AR_OpenInvoice o INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader h ON h.InvoiceNo = o.InvoiceNo AND h.HeaderSeqNo = o.InvoiceHistoryHeaderSeqNo WHERE o.Balance > 0 AND CAST(o.CustomerNo AS INT) = " + companyID);
    qry.SelectSQL();
    if (!qry.eof) {
        value = new Number(qry("Amt"));
    }

    buffer += "<td width=\"50%\"><span class=\"VIEWBOXCAPTION\">Total Amount Outstanding for This Location:</span><br/><span class=\"VIEWBOX\">";
    buffer += "<a href=\"javascript:openCompanyOutstandingARReport('" + companyID + "')\">";
    buffer += "$" + formatDollar(value);
    buffer += "</a>";
    buffer += "</span></td>";

    buffer += "</tr><tr>\n";

    value = "0";
    qry = eWare.CreateQueryObj("SELECT SUM(QuantityOrdered) As Cnt FROM PRService WHERE Category2 = 'License' AND prse_HQID = " + HQID);
    qry.SelectSQL();
    if (!qry.eof) {
        value = qry("Cnt");
    }
    buffer += addField("Enterprise # BBOS Licenses", value);

    buffer += addField("# Repeat Orders Billed to This Location", repeatOrderCount);

    buffer += "</tr><tr>\n";

    value = "0";
    qry = eWare.CreateQueryObj("SELECT COUNT(1) As Cnt FROM PRWebUser WITH (NOLOCK) WHERE CAST(prwu_AccessLevel as INT) >= 100 AND prwu_HQID = " + HQID);
    qry.SelectSQL();
    if (!qry.eof) {
        value = qry("Cnt");
    }
    buffer += addField("Enterprise # BBOS Licenses Assigned", value);


    value = "0";
    qry = eWare.CreateQueryObj("SELECT COUNT(1) As Cnt FROM vPRRepeatOrders WHERE EnteredCompanyID = " + companyID);
    qry.SelectSQL();
    if (!qry.eof) {
        value = qry("Cnt");
    }
    buffer += addField("# Orders Entered for This Location", value);


    buffer += "</tr><tr>\n";

    tmp = ""
    if (!isEmpty(recCompany("comp_PRServiceStartDate"))) {
        tmp = getDateAsString(recCompany("comp_PRServiceStartDate"));
    }
    buffer += addField("Current Service Start Date", tmp);

    tmp = ""
    if (!isEmpty(recCompany("comp_PRServiceEndDate"))) {
        tmp = getDateAsString(recCompany("comp_PRServiceEndDate"));
    }
    buffer += addField("Current Service End Date", tmp);

    buffer += "</tr><tr>\n";

    tmp = ""
    if (!isEmpty(recCompany("comp_PROriginalServiceStartDate"))) {
        tmp = getDateAsString(recCompany("comp_PROriginalServiceStartDate"));
    }
    buffer += addField("Original Service Start Date", tmp);


    buffer += "</tr></table>\n";
    buffer += createAccpacBlockFooter();

    return buffer;
}

function addField(label, value) {

    var buffer = "<td width=\"50%\"><span class=\"VIEWBOXCAPTION\">" + label + ":</span><br/><span class=\"VIEWBOX\">";
    
    if ((value != undefined) &&
        (value != null)) {
        buffer += value;
    }

    buffer += "</span></td>";
    return buffer;
}
%>
