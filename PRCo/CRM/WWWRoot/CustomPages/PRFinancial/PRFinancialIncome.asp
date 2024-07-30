<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2016

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

<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<%
var prfs_financialid = getIdValue("prfs_financialid");


/* this function will look for values for recFinancial  */
function getIncomeBlockContents(sBlockName) 
{
    var blkMain = eWare.GetBlock(sBlockName);
    var colFields = new Enumerator(blkMain);
    sBlockContent = "\n  <TABLE WIDTH=100\% CELLPADDING=0 BORDER=0 align=left>";
    nBlockTotal = 0;
    while (!colFields.atEnd()) {
        sFieldName = String(colFields.item());
        sTranslation = eWare.GetTrans('ColNames', sFieldName);

        bTotalField = false;
        sClass = "VIEWBOX";
        sClassCaption = "VIEWBOXCAPTION";
        sRowSpacing = "";
        if ("prfs_grossprofitmargin,prfs_operatingincome,prfs_netincome".indexOf(sFieldName) > -1)
        {
            bTotalField = true;
            sClass = "ROW1";
            sClassCaption = "ROW1";
            sTranslation = "<b>" + sTranslation + "</b>";
            sRowSpacing = "\n<tr height=10><td></td></tr>";
        }
        if ("prfs_extraordinarygainloss,prfs_taxprovision".indexOf(sFieldName) > -1)
        {
            sRowSpacing = "\n<tr height=5><td></td></tr>";
        }
        // put the caption on the page
        sBlockContent += "\n<tr><td width='60%' class=" + sClassCaption + ">" + sTranslation + ": </td>";

        // determine the value for the field
        sFieldValue = recFinancial(sFieldName);
        if (isEmpty(sFieldValue))
            sFieldValue = 0;

        // if we're in view mode we can use the values retrieved from the Financial Statement
        if (eWare.Mode == View || bTotalField || sFieldName == "prfs_netprofitloss")
        {
            sBlockContent += "\n    <td class=" + sClass + " width=150>";
            // if it's a total field we need the value submitted with the form
            if (bTotalField)
            {
                sBlockContent += "\n        <input name='TOT_" + sFieldName + "' value=" + sFieldValue + " type=HIDDEN>";
            } else if (sFieldName == "prfs_netprofitloss") {
                sBlockContent += "\n        <input name='hdn_" + sFieldName + "' value=" + sFieldValue + " type=HIDDEN>";
            }
            sFieldValue = formatCommaSeparated(sFieldValue);
            sBlockContent += "    <span id='"+sFieldName+"' style='height:15px;'>" + (bTotalField?"<b>"+sFieldValue+"</b>":sFieldValue) + "</span>";
            sBlockContent += "\n    </td>";
            sBlockContent += "\n</tr>";
            if (sRowSpacing!="")
                sBlockContent += sRowSpacing;
        }
        else if (eWare.Mode == Edit)
        {
            sBlockContent += "\n    <td class=" + sClass + " width=30>";
            sBlockContent += "\n        <input name='"+sFieldName+"' value="+formatCommaSeparated(sFieldValue)+
                                        " type=TEXT size=10 class=VIEWBOX " +
                                        " onkeyup='onFinancialFieldKeyUp();' onkeypress='return onFinancialFieldKeyPress();'" + 
                                        " onchange='onFinancialFieldChange();'>";
            sBlockContent += "\n    </td>";
            sBlockContent += "\n    <td class=" + sClassCaption + " width=10 align=left></td>";
            sBlockContent += "\n</tr>";
            if (sRowSpacing!="")
                sBlockContent += sRowSpacing;
        }
        colFields.moveNext();
    }

    sBlockContent += "</table>";
    return sBlockContent;
}

function doPage()
{
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    if (prfs_financialid != -1)
    {
        recFinancial = eWare.FindRecord("PRFinancial", "prfs_FinancialId=" + prfs_financialid);
    }
    else
    {
        // for income statements, we should always have a financial statement
        var sErrorContent = getErrorHeader("Unexpected navigation has been encountered. The necessary information is not available to create a valid record.  Click Continue to proceed.");
        if (comp_companyid != -1)
            sContinueAction = eWare.URL("PRCompany/PRCompanyFinancial.asp");
        else
            sContinueAction = eWare.URL(130);
        blkContent = eWare.GetBlock("content");
        blkContent.Contents = sErrorContent;
        blkContainer.AddBlock(blkContent);
        eWare.Mode = View;
        blkContainer.AddButton(eWare.Button("continue", "continue.gif", sContinueAction));
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage());
        return;    
    }


    if (eWare.Mode == Save)
    {
        sFinancialFields = "prfs_sales,prfs_costgoodssold,prfs_grossprofitmargin," +
                            "prfs_operatingexpenses,prfs_operatingincome," + 
                            "prfs_interestincome,prfs_otherincome,prfs_extraordinarygainloss," +
                            "prfs_interestexpense,prfs_otherexpenses,prfs_taxprovision," + 
                            "prfs_netincome,prfs_depreciation,prfs_amortization,prfs_marketingadvertisingexpense";

        for (x=1; x <= Request.Form.count(); x++) {
            sFieldName = String(Request.Form.Key(x));
            if (sFieldName.substr(0,4) == "TOT_" || sFieldName.substr(0,4) == "hdn_")
                sFieldName = sFieldName.substr(4);
            if (sFieldName.substr(0,5) == "prfs_")
            {
                // exclude these fields
                if (sFieldName == "prfs_companyidURL" || sFieldName.indexOf("prfs_statementdate_") > -1  || sFieldName == "prfs_assignedtouserInput"  || sFieldName == "prfs_updatedbyInput")
                    continue;

                sFieldValue = String(Request.Form.Item(x));
                if (sFieldValue == "on")
                    sFieldValue = "Y";
                else if (sFieldValue == "-")
                    sFieldValue = "0";

                // if this is a financial field, remove any commas
                if (sFinancialFields.indexOf(sFieldName) > -1)
                {
                    // remove the commas
                    sFieldValue = sFieldValue.replace(/,/g,"");
                    Response.Write("<br>Value being saved for " + sFieldName + ": '" + sFieldValue + "'");
                    recFinancial(sFieldName) = (isNaN(parseInt(sFieldValue))?"":parseInt(sFieldValue));
                }
                else
                {

                    if (sFieldName == "prfs_statementdate") // update the FinancialStatement field 
                    {
                        // dates have to be stored using the user's preference setting.
                        sDateFormat = "mm/dd/yyyy";
                        recUserSetting = eWare.FindRecord("UserSettings", "uset_userid=" + user_userid + " AND uset_key='NSet_UserDateFormat'");
                        if (!recUserSetting.eof)
                        {
                            if (!isEmpty(recUserSetting.uset_value) && recUserSetting.uset_value != sDateFormat)
                            {
                                sDateFormat = recUserSetting.uset_value;
                                sDate = sFieldValue;
                                if (sDateFormat == "dd/mm/yyyy")
                                {
                                    arrDate = sFieldValue.split("/");
                                    sFieldValue = arrDate[1]+"/"+arrDate[0]+"/"+arrDate[2];
                                }
                            }
                        }
                    }
                    recFinancial(sFieldName) = sFieldValue;
                }
            }
        }
%>
<!-- #include file ="RatioCalculationsInclude.asp" -->
<%
        // Save the financial statement
        recFinancial.SaveChanges();
        prfs_financialid = recFinancial("prfs_FinancialId");
        
        // * DEBUGGING LINES
        // reset this to a retireved mode so that we can just continue processing
        //recFinancial = eWare.FindRecord("PRFinancial", "prfs_FinancialId=" + prfs_financialid);
        //eWare.Mode = View;
        // * END DEBUGGING LINES
        
        Response.Redirect(eWare.Url("PRFinancial/PRFinancialIncome.asp")+"&prfs_FinancialId="+prfs_financialid);
        return;
    }
    
    Response.Write("\n<script type=\"text/javascript\" src=\"PRFinancial.js\"></script>\n");
    Response.Write("<script type=\"text/javascript\" src=\"PRFinancialIncome.js\"></script>\n");

    // set a width for all the blocks
    nBlockWidth = 350;

    cntMain = eWare.GetBlock("container");

    blkFinancial = eWare.GetBlock("PRFinancialHeader");
    blkFinancial.Title="Financial";
    cntMain.AddBlock(blkFinancial);

    // Create the container for the income statement contents
    sIncomeStatementContents = createAccpacBlockHeader("tblIncomeStatement", "Income Statement");
    
    // create a table with two columns; one for all fields contributing to net income, the other
    // for depreciation and amortization
    sIncomeStatementContents += "\n<table ID='tblIncomeStatementDetails' CELLPADDING=0>";
    sIncomeStatementContents += "\n<tr>";

    sIncomeStatementContents += "\n<td>";
    sIncomeStatementContents += getIncomeBlockContents("PRFinancialIncomeStatementLeft");
    sIncomeStatementContents += "\n</td>";

    sIncomeStatementContents += "\n<td width=50>&nbsp;</td>";

    sIncomeStatementContents += "\n<td valign=top>";
    sIncomeStatementContents += getIncomeBlockContents("PRFinancialDepreciation");
    sIncomeStatementContents += "\n</td>";
    sIncomeStatementContents += "\n</tr>";
    sIncomeStatementContents += "\n</table>";
    
    sIncomeStatementContents += createAccpacBlockFooter();

    blkContent = eWare.GetBlock("content");
    blkContent.contents = sIncomeStatementContents;
    cntMain.AddBlock(blkContent);
    

    cntMain.CheckLocks = false;
    cntMain.DisplayButton(1)=false;



    cntMain.DisplayButton(Button_Default) = false;
    if(eWare.Mode == Edit) {
        cntMain.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRFinancial/PRFinancialIncome.asp") + "&prfs_Financialid=" + prfs_financialid));
        sDeleteAction = changeKey(sURL, "em", "3");
        cntMain.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+ sDeleteAction + "';"));
        cntMain.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
    } else {
        cntMain.AddButton(eWare.Button("Continue", "continue.gif", eWare.URL("PRCompany/PRCompanyFinancial.asp")));
        cntMain.AddButton(eWare.Button("Balance Sheet", "calendar.gif", eWare.URL("PRFinancial/PRFinancialSummary.asp")+"&E=PRCompany&prfs_Financialid=" + prfs_financialid));
        cntMain.AddButton(eWare.Button("Ratios", "calendar.gif", eWare.URL("PRFinancial/PRFinancialRatio.asp")+"&E=PRCompany&prfs_Financialid=" + prfs_financialid));
        cntMain.AddButton(eWare.Button("Change","edit.gif", "javascript:document.EntryForm.submit();"));
    //    cntMain.AddButton(eWare.Button("Change","edit.gif","javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='prfs_Financialid=" + prfs_financialid + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRFinancial", "EDIT"));
    }

    eWare.AddContent(cntMain.Execute(recFinancial));
    Response.Write(eWare.GetPage('Company'));
%>
    <script type="text/javascript">
        function initBBSI()
        {
            loadFields();
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
    </script>
<%
}
doPage();
%>
<!-- #include file="../PRCompany/CompanyFooters.asp" -->
