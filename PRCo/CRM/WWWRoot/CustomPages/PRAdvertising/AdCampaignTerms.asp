<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyHeaders.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2019

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Reporter Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.

***********************************************************************
***********************************************************************/
doPage();

function doPage()
{
    var sSystemAdminSecurityGroups = "10";
    
    bDebug=false;
    var blueprintsCount = 0;

    eWare.AddContent("<script type=\"text/javascript\" src=\"AdCampaignTerms.js\"></script>")

    doPage();

    function doPage() {
        Response.Write("<script type='text/javascript' src='AdCampaignAd.js'></script>")

        var AdCampaignID = getIdValue("pradc_AdCampaignID");
        DEBUG("AdCampaignID = " + AdCampaignID);
    
        var F = new String(Request.QueryString("F"));
        sCancelAction = changeKey(eWare.Url(F), "pradc_AdCampaignID", AdCampaignID);

        if (eWare.Mode == Save)
        {
            DEBUG("Save");
            var qryBillingDetails = eWare.CreateQueryObj("SELECT pract_AdCampaignTermsID, ISNULL(pract_BillingDate,'') pract_BillingDate, pract_TermsAmount, ISNULL(pract_InvoiceDate,'') pract_InvoiceDate, ISNULL(pract_OrderNumber,'') pract_OrderNumber, pract_InvoiceDescription FROM PRAdCampaignTerms WHERE pract_AdCampaignID = " + AdCampaignID + " ORDER BY pract_BillingDate ASC");
            qryBillingDetails.SelectSQL();

            //Update or delete existing
            while (!qryBillingDetails.eof) {
                var pract_AdCampaignTermsID = qryBillingDetails("pract_AdCampaignTermsID");
                var billingDate = getFormValue("BillingDate" + pract_AdCampaignTermsID);
                var termsAmt = parseFloat(getFormValue("TermsAmt" + pract_AdCampaignTermsID).replace(/,/g, "").replace(/[$]/g, ""));
                var invoiceDescription = getFormValue("InvoiceDescription" + pract_AdCampaignTermsID);
                var recPRAdCampaignTerms = eWare.FindRecord("PRAdCampaignTerms", "pract_AdCampaignTermsID = " + pract_AdCampaignTermsID);

                if (termsAmt == 0 || billingDate=="") {
                    var sql = "DELETE FROM PRAdCampaignTerms WHERE pract_AdCampaignTermsID = " + pract_AdCampaignTermsID;
                    var qryDelete = eWare.CreateQueryObj(sql);
                    qryDelete.ExecSql();
                } else {
                    if (recPRAdCampaignTerms.eof) {
                        recPRAdCampaignTerms = eWare.CreateRecord("PRAdCampaignTerms");
                        recPRAdCampaignTerms.pract_AdCampaignID = AdCampaignID;
                    }

                    recPRAdCampaignTerms.pract_BillingDate = billingDate;
                    recPRAdCampaignTerms.pract_TermsAmount_CID = 1;
                    recPRAdCampaignTerms.pract_TermsAmount = termsAmt;
                    recPRAdCampaignTerms.pract_InvoiceDescription = invoiceDescription;

                    var resetProcessed = getFormValue("ResetProcessed" + pract_AdCampaignTermsID);
                    if(resetProcessed == 'on')
                    {
                        recPRAdCampaignTerms.pract_Processed = ""; //reset pract_Processed to NULL in db

                        var newDate = new Date();
                        newDate.setDate(newDate.getDate() + 2); //add 2 days
	                    var dtMonth = newDate.getMonth() + 1; //0-based
                        var dtDay = newDate.getDate();
	                    var dtYear = newDate.getFullYear();

	                    var szNewDate = dtMonth + "/" + dtDay + "/" + dtYear;
                        recPRAdCampaignTerms.pract_BillingDate = szNewDate; //reset Billing Date to 2 days in future
                    }
                
                    recPRAdCampaignTerms.SaveChanges();

                }
                qryBillingDetails.NextRecord();
            }

            //Loop through new extra rows
            var cnt = Request.Form("TermsAmt").Count;
            for(var i = 1; i <= cnt; i++) {
                var bd = Request.Form("BillingDate")(i);
                var ta = Request.Form("TermsAmt")(i);
                var id = Request.Form("InvoiceDescription")(i);
                DEBUG("bd="+bd);
                DEBUG("ta="+ta);
                DEBUG("id="+id);
        
                if(bd != null && bd != "" && ta != null && ta != "")
                {
                    recPRAdCampaignTerms = eWare.CreateRecord("PRAdCampaignTerms");
                    recPRAdCampaignTerms.pract_AdCampaignID = AdCampaignID;
                    recPRAdCampaignTerms.pract_BillingDate = getDateAsString(bd);
                    recPRAdCampaignTerms.pract_TermsAmount_CID = 1;
                    recPRAdCampaignTerms.pract_TermsAmount = ta;
                    recPRAdCampaignTerms.pract_InvoiceDescription = id;
                    
                    recPRAdCampaignTerms.SaveChanges();
                }
            }
        
            Response.Redirect(sCancelAction);
            return;
        }

        if (eWare.Mode == View)
        {
            DEBUG("View");

            recPRAdCampaign = eWare.FindRecord("PRAdCampaign", "pradc_AdCampaignID=" + AdCampaignID);

            //Ad Campaign Section
            if(F == "PRAdvertising/AdCampaignAdDigital.asp")
            {
                blkAdCampaignAd=eWare.GetBlock("AdCampaignAdDigital");
                blkAdCampaignAd.Title="Ad Campaign Digital Ad";
            }
            else if(F == "PRAdvertising/AdCampaignAdBP.asp")
            {
                blkAdCampaignAd=eWare.GetBlock("AdCampaignAdBP");
                blkAdCampaignAd.Title="Ad Campaign Blueprint Ad";
            }
            else if(F == "PRAdvertising/AdCampaignAdKYC.asp")
            {
                blkAdCampaignAd=eWare.GetBlock("AdCampaignAdKYC");
                blkAdCampaignAd.Title="Ad Campaign Know Your Commodity Ad";
            }
            else if(F == "PRAdvertising/AdCampaignAdTT.asp")
            {
                blkAdCampaignAd=eWare.GetBlock("AdCampaignAdTT");
                blkAdCampaignAd.Title="Ad Campaign Trading & Transportation Guide Ad";
            }
        
            blkAdCampaignAd.ArgObj = recPRAdCampaign;
            blkContainer.AddBlock(blkAdCampaignAd);

            entry = blkAdCampaignAd.GetEntry("pradc_CompanyID");
            entry.ReadOnly = true;
            entry.Hidden = true;
    
            entry = blkAdCampaignAd.GetEntry("pradc_AdCampaignHeaderID");
            entry.ReadOnly = true; 
            entry.Hidden = true; 

            entry = blkAdCampaignAd.GetEntry("pradc_AdCampaignType");
            entry.ReadOnly = true; 
            entry.Hidden = true; 

            entry = blkAdCampaignAd.GetEntry("pradc_Discount");
            entry.ReadOnly = true; 
            entry.Hidden = true; 



            //Billing Terms
            var blkTitle = eWare.GetBlock('Content');
            blkTitle.Contents = "<div class='PANEREPEAT' style='padding-left:15px' nowrap='true'>Billing Terms</div>";
            blkContainer.AddBlock(blkTitle);

            var sSaveUrl = changeKey(sURL, "em", Save);
        
            blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.action='" + sSaveUrl + "';save();"));
            blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", sCancelAction));

            var blkBillingTerms = eWare.GetBlock("content");

            blkBillingTerms.contents = "<table id=\"tblDetails\"><tr><td>\n";
            blkBillingTerms.contents += getBillingDetails(AdCampaignID);
            blkBillingTerms.contents += "</td><td style=\"font-family: Tahoma,Arial; font-size: 12px;\">\n";
            blkBillingTerms.contents += "</td></tr></table>\n\n";
    
            blkContainer.AddBlock(blkBillingTerms);

            // blkContent is a catchall for the various page sections which will be dynamically built and moved to other sections of the page
            blkContent = eWare.GetBlock("Content");
            blkContainer.AddBlock(blkContent);

            eWare.AddContent(blkContainer.Execute()); 
            Response.Write(eWare.GetPage());

    %>
            <script type="text/javascript">
            </script>
    <%
        } 

        var sSQL = "select TOP 1 pradch_Name FROM vPRAdCampaign WHERE pradc_adcampaignid = " + AdCampaignID ;
        recHeaderRow = eWare.CreateQueryObj(sSQL);
        recHeaderRow.SelectSQL();
        
        var pradch_Name = "";
        if (!recHeaderRow.eof)
        {
            pradch_Name = recHeaderRow("pradch_Name");
        }

        sSQL = "SELECT prkycc_PostName FROM PRAdCampaign INNER JOIN PRKYCCommodity ON prkycc_KYCCommodityID = pradc_KYCCommodityID WHERE pradc_AdCampaignID = " + AdCampaignID;
        recHeaderRowKYCC = eWare.CreateQueryObj(sSQL);
        recHeaderRowKYCC.SelectSQL();
        
        var prkycc_PostName = "";
        if (!recHeaderRowKYCC.eof)
        {
            prkycc_PostName = recHeaderRowKYCC("prkycc_PostName");
        }
        
        //************************
        //Script Section BEGIN
        //************************
        Response.Write("\n<script type='text/javascript'>");
	    Response.Write("\nfunction initBBSI()"); 
	    Response.Write("\n{ ");

        if(F == "PRAdvertising/AdCampaignAdKYC.asp" || F == "PRAdvertising/AdCampaignAdTT.asp" )
        {
            Response.Write("\n   document.getElementById('_Datapradc_name').innerText = \"" + pradch_Name +"\";");
        }

        if(F == "PRAdvertising/AdCampaignAdKYC.asp" )
        {
            Response.Write("\n   document.getElementById('_Datapradc_name').innerText = \"" + pradch_Name +"\";");
            Response.Write("\n   document.getElementById('_Datapradc_kyccommodityid').innerText = \"" + prkycc_PostName +"\";");
            Response.Write("\n   document.getElementById('_Captpradc_kyccommodityid').innerText = 'KYC Commodity Article:';");
        }

        Response.Write("\n} ");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
	    Response.Write("\n</script>");
        //************************
        //Script Section END
        //************************
    }
    
    function getBillingDetails(adCampaignID) {
        var rowCount = 0;
        var sClass = "ROW2";

        var buffer = "<div style=\"padding-left:15px\"><table class=\"CONTENT\" style=\"displayz:none;margin-top:10px;margin-bottom:5px;width:800px;\">\n<tr><th class=\"GRIDHEAD\" align=center>Billing Date</th><th class=\"GRIDHEAD\" align=center>Amount</th><th class=\"GRIDHEAD\" align=center>Processed&nbsp;</th><th class=\"GRIDHEAD\" align=left>Invoice Description</th>";
        
        if (isUserInGroup(sSystemAdminSecurityGroups))
        {
            //System admins get a reset processed flag checkbox
            buffer += "<th class=\"GRIDHEAD\" align=center>Reset Processed&nbsp;</th>";
        }

        buffer += "</tr>\n";

        var qryBillingDetails = eWare.CreateQueryObj("SELECT pract_AdCampaignTermsID, ISNULL(pract_BillingDate,'') pract_BillingDate, pract_TermsAmount, ISNULL(pract_InvoiceDate,'') pract_InvoiceDate, ISNULL(pract_OrderNumber,'') pract_OrderNumber, ISNULL(pract_Processed,'N') pract_Processed, pract_InvoiceDescription FROM PRAdCampaignTerms WHERE pract_AdCampaignID = " + adCampaignID + " ORDER BY pract_BillingDate ASC");
        qryBillingDetails.SelectSQL();

        var blueprintsArray = "";
        var szLastInvoiceDescription = "";

        while (!qryBillingDetails.eof) {
            if (sClass == "ROW2") {
                sClass = "ROW1";
            } else {
                sClass = "ROW2";
            }

            buffer += "<tr>";
                buffer += AddRow(sClass,
                                 qryBillingDetails("pract_AdCampaignTermsID"),
                                 qryBillingDetails("pract_BillingDate"),
                                 qryBillingDetails("pract_TermsAmount"),
                                 qryBillingDetails("pract_InvoiceDate"),
                                 qryBillingDetails("pract_OrderNumber"),
                                 qryBillingDetails("pract_Processed"),
                                 qryBillingDetails("pract_InvoiceDescription"),
                                 false
                                );
            buffer += "</tr>\n";

            szLastInvoiceDescription = qryBillingDetails("pract_InvoiceDescription");
            rowCount = rowCount + 1;

            qryBillingDetails.NextRecord();
        }

        var bFirstBlank = true;
        //Add blank rows
        while(rowCount < 12)
        {
            if (sClass == "ROW2") {
                sClass = "ROW1";
            } else {
                sClass = "ROW2";
            }
        
            if(bFirstBlank)
            {
                buffer += "<tr id='BR'>";
                bFirstBlank = false;
            }
            else
                buffer += "<tr id='BR' style='display:none'>";

            buffer += AddRow(sClass,
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                szLastInvoiceDescription,
                                true
                           );
            buffer += "</tr>\n";

            rowCount = rowCount + 1;
        }
    
        buffer += "</table></div>\n";

        buffer += "<div style='margin-left:15px;'><input type='button' id='btnAddRow' value='Add Row' onClick='AddRow();'></div>";

        return buffer;
    }

    function AddRow(sClass,
                    pract_AdCampaignTermsID,
                    pract_BillingDate,
                    pract_TermsAmount,
                    pract_InvoiceDate,
                    pract_OrderNumber,
                    pract_Processed,
                    pract_InvoiceDescription,
                    bNewRow)
    {
        var buffer = "";
        var MIN_DATE = '01/01/1900';

        var sBillingDate = getDateAsString(pract_BillingDate);
        if(pract_BillingDate == "" || sBillingDate == MIN_DATE)
            sBillingDate = "";

        var sInvoiceDate = getDateAsString(pract_InvoiceDate);
        if(pract_InvoiceDate == "" || sInvoiceDate == MIN_DATE)
            sInvoiceDate = "";

        var sOrderNum = (pract_OrderNumber?pract_OrderNumber:"");

        var readonly = "";
        if(pract_Processed == "Y")
        {
            readonly = "readonly='readonly' style='background-color: lightgray'";
        }

        var sInvoiceDescription = getString(pract_InvoiceDescription);

        buffer += "<td class='" + sClass + "' width='125px'><input type='Text' " + readonly + "  size='10' maxlength='10' class='BillingDate' name='BillingDate" + pract_AdCampaignTermsID + "' id='BillingDate" + pract_AdCampaignTermsID + "' value='" + sBillingDate + "' onchange='normalizeDate(this);'/></td>";
        buffer += "<td class='" + sClass + "' width='125px'>$<input type='Text' " + readonly + " size='10' maxlength='10' class='TermsAmt' name='TermsAmt" + pract_AdCampaignTermsID + "' id='TermsAmt" + pract_AdCampaignTermsID + "' value='" + formatDollar(pract_TermsAmount) + "' onchange='stripDollarComma(this);'/></td>";
        buffer += "<td class='" + sClass + "' width='125px' style='text-align:center;'>" + pract_Processed + "</td>";
        buffer += "<td class='" + sClass + "' width='275px'><input type='Text' size='35' maxlength='30' class='InvoiceDescription' name='InvoiceDescription" + pract_AdCampaignTermsID + "' id='InvoiceDescription" + pract_AdCampaignTermsID + "' value='" + sInvoiceDescription + "'/></td>";

        if (isUserInGroup(sSystemAdminSecurityGroups))
        {
            if(!bNewRow && pract_Processed=="Y")
                buffer += "<td class='" + sClass + "' width='125px' style='text-align:center;'><input type='checkbox' name='ResetProcessed" + pract_AdCampaignTermsID + "' id='ResetProcessed" + pract_AdCampaignTermsID + "' /></td>";
            else
                buffer += "<td class='" + sClass + "' width='125px'></td>";
        }

        return buffer;
    }
}

%>

<script type="text/javascript">
    function AddRow() {
        $('#BR').first().removeAttr('id');
        $('#BR').first().removeAttr('style');

        var numOfVisibleRows = $('#tblDetails tr:visible').length - 2;
        if (numOfVisibleRows >= 12)
            $('#btnAddRow').hide();

    }
</script>
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->