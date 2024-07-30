<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013-2020

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

/*
    We are using our own tmpMode variable to control the flow from
    one page to the next.  Originally tried to use the eWare.Mode
    for this but ran into issues as eWare doesn't like mode values
    it is not aware of.  
*/


    var modeProduceVendors = 50;
    var modeProduceVendorsSave = 51;
    var modeProduceVendorsTypes = "'09'";
    var modeProduceVendorsIndustry = "'Produce', 'Transportation', 'Supply'";

    var modeProduceCustomers = 52;
    var modeProduceCustomersSave = 53;
    var modeProduceCustomersTypes = "'13'";
    var modeProduceCustomerIndustry = "'Produce', 'Transportation', 'Supply'";

    var modeProduceBrokers = 54;
    var modeProduceBrokersSave = 55;
    var modeProduceBrokersTypes ="'10'";
    var modeProduceBrokersIndustry = "'Produce', 'Transportation', 'Supply'";

    var modeTransportationBrokers = 60;
    var modeTransportationBrokersSave = 61;
    var modeTransportationBrokersTypes = "'10'";
    var modeTransportationBrokersIndustry = "'Transportation'";

    var modeTransportationTruckers = 62;
    var modeTransportationTruckersSave = 63;
    var modeTransportationTruckersTypes = "'11'";
    var modeTransportationTruckersIndustry = "'Transportation'";

    var modeTransportationProduce = 64;
    var modeTransportationProduceSave = 65;
    var modeTransportationProduceTypes ="'11'";
    var modeTransportationProduceIndustry = "'Produce'";


    var modeLumberVendors = 70;
    var modeLumberVendorsSave = 71;
    var modeLumberVendorsTypes = "'09'";
    var modeLumberVendorsIndustry = "'Produce', 'Transportation', 'Supply', 'Lumber'";

    var modeLumberCustomers = 72;
    var modeLumberCustomersSave = 73;
    var modeLumberCustomersTypes = "'13'";
    var modeLumberCustomersIndustry = "'Produce', 'Transportation', 'Supply', 'Lumber'";


    var tmpMode = 0;

    doPage();

function doPage()
{


    var prcl2_ConnectionListID = getIdValue("prcl2_connectionlistid");
    var sSummaryAction = eWare.Url("PRCompany/PRConnectionList.asp")+ "&prcl2_connectionlistid="+ prcl2_ConnectionListID + "&T=Company&Capt=Relationships";


    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;
    
    tmpMode =  getIdValue("tmpMode");

    if (tmpMode == -1) {

        switch (recCompany("comp_PRIndustryType")) {
            case "P":
                tmpMode = modeProduceVendors;
                break;
            case "T":
                tmpMode = modeTransportationBrokers;
                break;
            case "L":
                tmpMode = modeLumberVendors;
                break;
        }
    }

    // Convert to an Int
    tmpMode = new Number(tmpMode).valueOf();

    var sqlRelTypeInClause;
    var sqlIndustryTypeInClause;
    var gridName;
    var gridTitle;
    var bntSaveTitle;

    switch(tmpMode) {
        case modeProduceVendors:
        case modeProduceVendorsSave:
            sqlRelTypeInClause = modeProduceVendorsTypes;
            sqlIndustryTypeInClause = modeProduceVendorsIndustry;
            break;

        case modeProduceCustomers:
        case modeProduceCustomersSave:
            sqlRelTypeInClause = modeProduceCustomersTypes;
            sqlIndustryTypeInClause = modeProduceCustomerIndustry;
            break;

        case modeProduceBrokers:
        case modeProduceBrokersSave:
            sqlRelTypeInClause = modeProduceBrokersTypes;
            sqlIndustryTypeInClause = modeProduceBrokersIndustry;
            break;

        case modeTransportationBrokers:
        case modeTransportationBrokersSave:
            sqlRelTypeInClause = modeTransportationBrokersTypes;
            sqlIndustryTypeInClause = modeTransportationBrokersIndustry;
            break;

        case modeTransportationTruckers:
        case modeTransportationTruckersSave:
            sqlRelTypeInClause = modeTransportationTruckersTypes;
            sqlIndustryTypeInClause = modeTransportationTruckersIndustry;
            break;

        case modeTransportationProduce:
        case modeTransportationProduceSave:
            sqlRelTypeInClause = modeTransportationProduceTypes;
            sqlIndustryTypeInClause = modeTransportationProduceIndustry;
            break;

        case modeLumberVendors:
        case modeLumberVendorsSave:
            sqlRelTypeInClause = modeLumberVendorsTypes;
            sqlIndustryTypeInClause = modeLumberVendorsIndustry;
            break;

        case modeLumberCustomers:
        case modeLumberCustomersSave:
            sqlRelTypeInClause = modeLumberCustomersTypes;
            sqlIndustryTypeInClause = modeLumberCustomersIndustry;
            break;
    }


    if ((tmpMode == modeProduceVendorsSave) ||
        (tmpMode == modeProduceCustomersSave) ||
        (tmpMode == modeProduceBrokersSave) ||
        (tmpMode == modeTransportationBrokersSave) ||
        (tmpMode == modeTransportationTruckersSave) ||
        (tmpMode == modeTransportationProduceSave) ||
        (tmpMode == modeLumberVendorsSave) ||
        (tmpMode == modeLumberCustomersSave)) {

        var recRelatedCompanies = eWare.FindRecord("vPRConnectionListDetailsType", "prcl2_ConnectionListID=" + prcl2_ConnectionListID + " AND prcr_Type IN (" + sqlRelTypeInClause + ") AND IndustryType IN (" + sqlIndustryTypeInClause + ")") ;    
        while (!recRelatedCompanies.eof)
        {
            relatedCompanyID =recRelatedCompanies("CompanyID");

            prtr_IntegrityID = Request.Form.Item("ddlIntegrity" +relatedCompanyID );
            prtr_PayRatingID = Request.Form.Item("ddlPayRating" +relatedCompanyID );
            prtr_HighCredit = Request.Form.Item("ddlHighCredit" +relatedCompanyID );
            prtr_LastDealtDate = Request.Form.Item("ddlLastDealt" +relatedCompanyID );


		    if ((!isEmpty(prtr_IntegrityID)) ||
                (!isEmpty(prtr_PayRatingID)) ||
                (!isEmpty(prtr_HighCredit)) ||
                (!isEmpty(prtr_LastDealtDate))) {

			    recTradeReport = eWare.CreateRecord("PRTradeReport");
                recTradeReport.prtr_ResponseSource = "R";

    		    if (!isEmpty(prtr_IntegrityID))  {
                    recTradeReport.prtr_integrityid = prtr_IntegrityID;
                }

		        if (!isEmpty(prtr_PayRatingID)) {
                    recTradeReport.prtr_PayRatingID = prtr_PayRatingID;
                }

		        if (!isEmpty(prtr_HighCredit)) {
                    recTradeReport.prtr_HighCredit = prtr_HighCredit;
                }

		        if (!isEmpty(prtr_LastDealtDate)) {
                    recTradeReport.prtr_LastDealtDate = prtr_LastDealtDate;
                }

                recTradeReport.prtr_ResponderId = comp_companyid;
                recTradeReport.prtr_SubjectId = relatedCompanyID;
                recTradeReport.prtr_Date = getDateAsString(null);
                recTradeReport.SaveChanges();
            }
                
            txtCurrent = Request.Form.Item("txtCurrent" +relatedCompanyID );
            txt130 = Request.Form.Item("txt130" +relatedCompanyID );
            txt3160 = Request.Form.Item("txt3160" +relatedCompanyID );
            txt6190 = Request.Form.Item("txt6190" +relatedCompanyID );
            txt91Plus = Request.Form.Item("txt91Plus" +relatedCompanyID );

		    if ((!isEmpty(txtCurrent)) ||
                (!isEmpty(txt130)) ||
                (!isEmpty(txt3160)) ||
                (!isEmpty(txt6190)) ||
                (!isEmpty(txt91Plus))) {


                var recConnectionList = eWare.FindRecord("PRConnectionList", "prcl2_connectionlistid=" + prcl2_ConnectionListID) ; 

			    recPRARAging = eWare.CreateRecord("PRARAging");
                recPRARAging.praa_Date = getDateAsString(null);
                recPRARAging.praa_CompanyId = comp_companyid;
                recPRARAging.praa_PersonId = recConnectionList.prcl2_PersonID;
                recPRARAging.praa_Count = 1;

    		    if (!isEmpty(txtCurrent))  {
                    recPRARAging.praa_TotalCurrent = txtCurrent;
                }

    		    if (!isEmpty(txt130))  {
                    recPRARAging.praa_Total1to30 = txt130;
                }

    		    if (!isEmpty(txt3160))  {
                    recPRARAging.praa_Total31to60 = txt3160;
                }

    		    if (!isEmpty(txt6190))  {
                    recPRARAging.praa_Total61to90 = txt6190;
                }

    		    if (!isEmpty(txt91Plus))  {
                    recPRARAging.praa_Total91Plus = txt91Plus;
                }

                recPRARAging.SaveChanges();

                recPRARAgingDetail = eWare.CreateRecord("PRARAgingDetail");
                recPRARAgingDetail.praad_ARAgingId = recPRARAging.praa_ARAgingId;
                recPRARAgingDetail.praad_SubjectCompanyID = relatedCompanyID;

    		    if (!isEmpty(txtCurrent))  {
                    recPRARAgingDetail.praad_AmountCurrent = txtCurrent;
                }

    		    if (!isEmpty(txt130))  {
                    recPRARAgingDetail.praad_Amount1to30 = txt130;
                }

    		    if (!isEmpty(txt3160))  {
                    recPRARAgingDetail.praad_Amount31to60 = txt3160;
                }

    		    if (!isEmpty(txt6190))  {
                    recPRARAgingDetail.praad_Amount61to90 = txt6190;
                }

    		    if (!isEmpty(txt91Plus))  {
                    recPRARAgingDetail.praad_Amount91Plus = txt91Plus;
                }

                recPRARAgingDetail.SaveChanges();
            }                    
            recRelatedCompanies.NextRecord();
        }      
      

        if ((tmpMode == modeProduceBrokersSave) ||
            (tmpMode == modeTransportationProduceSave)||
            (tmpMode == modeLumberCustomersSave)) {
            Response.Redirect(sSummaryAction);
            return;
        } else {
            tmpMode = tmpMode + 1;
        }
    }


//Response.Write("<p>tmpMode:" + tmpMode);
    switch(tmpMode) {
        case modeProduceVendors:
            sqlRelTypeInClause = modeProduceVendorsTypes;
            sqlIndustryTypeInClause = modeProduceVendorsIndustry;
            gridName = modeProduceVendors;
            gridTitle = " Produce Vendors";
            bntSaveTitle = "Save & Next";
            break;

        case modeProduceCustomers:
            sqlRelTypeInClause = modeProduceCustomersTypes;
            sqlIndustryTypeInClause = modeProduceCustomerIndustry;
            gridName = modeProduceCustomers;
            gridTitle = " Produce Customers";
            bntSaveTitle = "Save & Next";
            break;

        case modeProduceBrokers:
            sqlRelTypeInClause = modeProduceBrokersTypes;
            sqlIndustryTypeInClause = modeProduceBrokersIndustry;
            gridName = modeProduceBrokers;
            gridTitle = " Carrier/Truck Brokers";
            bntSaveTitle = "Save";
            break;

        case modeTransportationBrokers:
            sqlRelTypeInClause = modeTransportationBrokersTypes;
            sqlIndustryTypeInClause = modeTransportationBrokersIndustry;
            gridName = modeTransportationBrokers;
            gridTitle = " Truck Brokers";
            bntSaveTitle = "Save & Next";
            break;

        case modeTransportationTruckers:
            sqlRelTypeInClause = modeTransportationTruckersTypes;
            sqlIndustryTypeInClause = modeTransportationTruckersIndustry;
            gridName = modeTransportationTruckers;
            gridTitle = " Truckers";
            bntSaveTitle = "Save & Next";
            break;

        case modeTransportationProduce:
            sqlRelTypeInClause = modeTransportationProduceTypes;
            sqlIndustryTypeInClause = modeTransportationProduceIndustry;
            gridName = modeTransportationProduce;
            gridTitle = " Produce Connections";
            bntSaveTitle = "Save";
            break;

        case modeLumberVendors:
            sqlRelTypeInClause = modeLumberVendorsTypes;
            sqlIndustryTypeInClause = modeLumberVendorsIndustry;
            gridName = modeLumberVendorsTypes;
            gridTitle = " Vendor Connections";
            bntSaveTitle = "Next";
            break;

        case modeLumberCustomers:
            sqlRelTypeInClause = modeLumberCustomersTypes;
            sqlIndustryTypeInClause = modeLumberCustomersIndustry;
            gridName = modeLumberCustomers;
            gridTitle = " Customer Connections";
            bntSaveTitle = "Save";
            break;
    }

    var sql = "prcl2_ConnectionListID=" + prcl2_ConnectionListID + " AND prcr_Type IN (" + sqlRelTypeInClause + ") AND IndustryType IN (" + sqlIndustryTypeInClause + ")";
    //Response.Write("<p>" + sql);
    var recRelatedCompanies = eWare.FindRecord("vPRConnectionListDetailsType", sql) ;    
    var lstRelatedCompanies = eWare.GetBlock("content");
    lstRelatedCompanies.Contents = buildRelationshipGrid(recRelatedCompanies, gridName, gridTitle);
    blkContainer.AddBlock(lstRelatedCompanies);

    // Set our mode to the next step
    tmpMode++;
    blkContainer.AddButton(eWare.Button("Done", "continue.gif", sSummaryAction));
    blkContainer.AddButton(eWare.Button(bntSaveTitle, "save.gif", "#\" onClick=\"save();\""));
   
    eWare.AddContent(blkContainer.Execute()); 
   
    Response.Write(eWare.GetPage("Company"));
}


function buildRelationshipGrid(recCompanyRelationships,
                               sGridName,
                               sGridTitle) {  

    var sWorkContent = "";
    var Content01 = "";
    var Content02 = "";
    var Content03 = "";
    var Content04 = "";
    var Content05 = "";
    var Content06 = "";
    var Content07 = "";
    var Content08 = "";
    var Content09 = "";
    var Content10 = "";
    var Content11 = "";
    var Content12 = "";
    var Content13 = "";
    var Content14 = "";
    var Content15 = "";
    var Content16 = "";
    var Content17 = "";
    var Content18 = "";
    var Content19 = "";
    var Content20 = "";    
    
//Response.Write("<br/>" + sGridName + " Start: " + new Date());
    
   
    var sContent;
    sContent = createAccpacBlockHeader(sGridName, recCompanyRelationships.RecordCount + sGridTitle);

    sContent += "\n\n<table CLASS=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width='100%' >" +
                "\n<THEAD>" +
                "\n<TR>";
    sContent += "<td class=GRIDHEAD align=center>" + getColumnHeader(sGridName, "BB ID", "CompanyID") + "</TD> " +
                "<td class=GRIDHEAD >" + getColumnHeader(sGridName, "Company", "CompanyName") + "</TD> " +
                "<td class=GRIDHEAD >" + getColumnHeader(sGridName, "Location", "CityStateCountryShort") + "</TD> ";

    if ((sGridName == modeProduceVendors)||
        (sGridName == modeProduceCustomers)||
        (sGridName == modeProduceBrokers) ||
        (sGridName == modeTransportationBrokers) ||
        (sGridName == modeTransportationTruckers) ||
        (sGridName == modeTransportationProduce)) {
        sContent += "<td class=GRIDHEAD align=center>Last Dealt</td> ";
        sContent += "<td class=GRIDHEAD align=center>Trade Practices</td> ";
    }

    if ((sGridName == modeProduceCustomers) ||
        (sGridName == modeTransportationTruckers) ||
        (sGridName == modeTransportationProduce)) {
        sContent += "<td class=GRIDHEAD align=center>High Credit</td>";
        sContent += "<td class=GRIDHEAD align=center>Pay</td>";
    }

    if ((sGridName == modeLumberVendors) ||
        (sGridName == modeLumberCustomers)) {
        sContent += "<td class=GRIDHEAD align=center>Current</td>";
        sContent += "<td class=GRIDHEAD align=center>1-30 DDP</td>";
        sContent += "<td class=GRIDHEAD align=center>31-60 DDP</td>";
        sContent += "<td class=GRIDHEAD align=center>61-90 DDP</td>";
        sContent += "<td class=GRIDHEAD align=center>91+ DDP</td>";
    }

    sContent += "\n</tr>";
    sContent += "\n</thead>";

    sClass = "ROW2";
    var iCount = 0;
    while (!recCompanyRelationships.eof)
    {
        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }
    
        sWorkContent += "\n<tr class=" + sClass + ">";
        sWorkContent += "<td class=" + sClass + " align=center>" + getValue(recCompanyRelationships("CompanyID")) + "</td>";
        sWorkContent += "<td class=" + sClass + ">" + recCompanyRelationships("CompanyName") + "</td>";
        sWorkContent += "<td class=" + sClass + ">" + getValue(recCompanyRelationships("CityStateCountryShort")) + "</td>";

        if ((sGridName == modeProduceVendors)||
            (sGridName == modeProduceCustomers)||
            (sGridName == modeProduceBrokers) ||
            (sGridName == modeTransportationBrokers) ||
            (sGridName == modeTransportationTruckers) ||
            (sGridName == modeTransportationProduce)) {

            sWorkContent += "<td class=" + sClass + " align=\"center\"><select name=\"ddlLastDealt" + getValue(recCompanyRelationships("CompanyID")) + "\"><option value=\"\"></option><option value=\"A\">1-6 Months</option><option value=\"B\">7-12 Months</option><option value=\"C\">Over 1 Year</option></select></TD> ";
            sWorkContent += "<td class=" + sClass + " align=\"center\"><select name=\"ddlIntegrity" + getValue(recCompanyRelationships("CompanyID")) + "\"><option value=\"\"></option><option value=\"6\">XXXX</option><option value=\"5\">XXX</option><option value=\"2\">XX</option><option value=\"1\">X</option</select></TD> ";
        }        
  
        if ((sGridName == modeProduceCustomers) ||
            (sGridName == modeTransportationTruckers) ||
            (sGridName == modeTransportationProduce)) {
              sWorkContent += "<td class=" + sClass + " align=\"center\"><select name=\"ddlHighCredit" + getValue(recCompanyRelationships("CompanyID")) + "\"><option value=\"\"></option><option value=\"A\">10M</option><option value=\"B\">50M</option><option value=\"C\">75M</option><option value=\"D\">100M</option><option value=\"E\">250M</option><option value=\"G\">500M</option><option value=\"H\">1000M</option><option value=\"I\">>1 million</option></select></TD> ";
              sWorkContent += "<td class=" + sClass + " align=\"center\"><select name=\"ddlPayRating" + getValue(recCompanyRelationships("CompanyID")) + "\"><option value=\"\"></option><option value=\"9\">14</option><option value=\"8\">21</option><option value=\"6\">28</option><option value=\"5\">35</option><option value=\"4\">45</option><option value=\"3\">60</option><option value=\"2\">60+</option></select></TD> ";
        }

        if ((sGridName == modeLumberVendors) ||
            (sGridName == modeLumberCustomers)) {
            sWorkContent += "<td class=" + sClass + " align=\"center\"><input type=\"text\" size=\"10\" maxlength=\"10\" style=\"text-align:right;\" name=\"txtCurrent" + getValue(recCompanyRelationships("CompanyID")) + "\"></td>";
            sWorkContent += "<td class=" + sClass + " align=\"center\"><input type=\"text\" size=\"10\" maxlength=\"10\" style=\"text-align:right;\" name=\"txt130" + getValue(recCompanyRelationships("CompanyID")) + "\"></td>";
            sWorkContent += "<td class=" + sClass + " align=\"center\"><input type=\"text\" size=\"10\" maxlength=\"10\" style=\"text-align:right;\" name=\"txt3160" + getValue(recCompanyRelationships("CompanyID")) + "\"></td>";
            sWorkContent += "<td class=" + sClass + " align=\"center\"><input type=\"text\" size=\"10\" maxlength=\"10\" style=\"text-align:right;\" name=\"txt6190" + getValue(recCompanyRelationships("CompanyID")) + "\"></td>";
            sWorkContent += "<td class=" + sClass + " align=\"center\"><input type=\"text\" size=\"10\" maxlength=\"10\" style=\"text-align:right;\" name=\"txt91Plus" + getValue(recCompanyRelationships("CompanyID")) + "\"></td>";
        }

        sWorkContent += "</tr>";
        
        iCount++;
        
        // This is to deal with large numbers of records.  We keep appending to the same string, but since
        // string are immutable, we are allocating memory at an exponential pace, thus the last 500 records
        // can take 10 times as long to process as the first 500 records.  This is purposely not in an array.
        switch(iCount) {
            case 50: 
                Content01 = sWorkContent;
                sWorkContent = "";
                break;
            case 100: 
                Content02 = sWorkContent;
                sWorkContent = "";
                break;
            case 150: 
                Content03 = sWorkContent;
                sWorkContent = "";
                break;
            case 200: 
                Content04 = sWorkContent;
                sWorkContent = "";
                break;
            case 250: 
                Content05 = sWorkContent;
                sWorkContent = "";
                break;
            case 300: 
                Content06 = sWorkContent;
                sWorkContent = "";
                break;
            case 350: 
                Content07 = sWorkContent;
                sWorkContent = "";
                break;
            case 400: 
                Content08 = sWorkContent;
                sWorkContent = "";
                break;
            case 450: 
                Content09 = sWorkContent;
                sWorkContent = "";
                break;
            case 500: 
                Content10 = sWorkContent;
                sWorkContent = "";
                break;
            case 550: 
                Content11 = sWorkContent;
                sWorkContent = "";
                break;
            case 600: 
                Content12 = sWorkContent;
                sWorkContent = "";
                break;
            case 650: 
                Content13 = sWorkContent;
                sWorkContent = "";
                break;
            case 700: 
                Content14 = sWorkContent;
                sWorkContent = "";
                break;
            case 750: 
                Content15 = sWorkContent;
                sWorkContent = "";
                break;
            case 800: 
                Content16 = sWorkContent;
                sWorkContent = "";
                break;
        }        
        recCompanyRelationships.NextRecord();
    }      
    
    sContent += Content01 + Content02 + Content03 + Content04 + Content05 + Content06 + Content07 + Content08 + Content09 + Content10 + 
                Content11 +  Content12 +  Content13 +  Content14 +  Content15 +  Content16 + sWorkContent;
    
    sContent += "\n</table>";
    sContent += createAccpacBlockFooter();
    
//Response.Write("<br/>" + sGridName + " End: " + new Date());    
    return sContent;
}

%>
       <script type="text/javascript">
           function save() {
               var input = document.createElement('input');
               input.type = 'hidden';
               input.name = "tmpMode";
               input.value = "<% =tmpMode %>";
               document.EntryForm.appendChild(input);

                document.EntryForm.submit();
            }
        </script>

<!-- #include file ="../PRCompany/CompanyFooters.asp" -->