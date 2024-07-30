/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
var txt_prfs_sales = null;
var txt_prfs_costgoodssold = null;
var TOT_prfs_grossprofitmargin = null;
var lbl_prfs_grossprofitmargin = null;

var txt_prfs_operatingexpenses = null;
var TOT_prfs_operatingincome = null;
var lbl_prfs_operatingincome = null;

var txt_prfs_interestincome = null;
var txt_prfs_otherincome = null;
var txt_prfs_extraordinarygainloss = null;
var txt_prfs_interestexpense = null;
var txt_prfs_otherexpenses = null;
var txt_prfs_taxprovision = null;
var lbl_prfs_netincome = null;
var TOT_prfs_netincome = null;

var txt_prfs_depreciation = null;
var txt_prfs_amortization = null;

// these fields are used often and it is better to incur the cost of loading them 
// once rather than doing document.all calls for every keypress.
function loadFields()
{
    txt_prfs_sales = document.all("prfs_sales");
    txt_prfs_costgoodssold = document.all("prfs_costgoodssold");
    lbl_prfs_grossprofitmargin = document.all("prfs_grossprofitmargin");
    TOT_prfs_grossprofitmargin = document.all("TOT_prfs_grossprofitmargin");

    txt_prfs_operatingexpenses = document.all("prfs_operatingexpenses");
	lbl_prfs_operatingincome = document.all("prfs_operatingincome");
	TOT_prfs_operatingincome = document.all("TOT_prfs_operatingincome");

	txt_prfs_interestincome = document.all("prfs_interestincome");
	txt_prfs_otherincome = document.all("prfs_otherincome");
	txt_prfs_extraordinarygainloss = document.all("prfs_extraordinarygainloss");
	txt_prfs_interestexpense = document.all("prfs_interestexpense");
	txt_prfs_otherexpenses = document.all("prfs_otherexpenses");
	txt_prfs_taxprovision = document.all("prfs_taxprovision");
    lbl_prfs_netincome = document.all("prfs_netincome");
    TOT_prfs_netincome = document.all("TOT_prfs_netincome");
    hdn_prfs_netprofitloss = document.all("hdn_prfs_netprofitloss");
    lbl_prfs_netprofitloss = document.all("prfs_netprofitloss");
	
	txt_prfs_depreciation = document.all("prfs_depreciation");
	txt_prfs_amortization = document.all("prfs_amortization");
}

function onFinancialFieldKeyUp()
{
    sFieldName = window.event.srcElement.name;
    updateFieldChangeTotals(sFieldName);
}

function updateFieldChangeTotals(sFieldName)
{
	sTemp = txt_prfs_sales.value;
	nSales = (txt_prfs_sales.value==""?0:parseInt(txt_prfs_sales.value.replace(/,/g, "")));
	nCostofGoods = (txt_prfs_costgoodssold.value==""?0:parseInt(txt_prfs_costgoodssold.value.replace(/,/g, "")));
	nGrossProfitMargin = nSales - nCostofGoods;
	
	lbl_prfs_grossprofitmargin.innerHTML = "<b>"+formatCommaSeparated(nGrossProfitMargin)+"</b>";
	TOT_prfs_grossprofitmargin.value = nGrossProfitMargin;

	nOperatingExpenses = (txt_prfs_operatingexpenses.value==""?0:parseInt(txt_prfs_operatingexpenses.value.replace(/,/g, "")));
	nOperatingIncome = nGrossProfitMargin - nOperatingExpenses;
	
	lbl_prfs_operatingincome.innerHTML = "<b>"+formatCommaSeparated(nOperatingIncome)+"</b>";
	TOT_prfs_operatingincome.value = nOperatingIncome;

	nOtherIncome = (txt_prfs_interestincome.value==""?0:parseInt(txt_prfs_interestincome.value.replace(/,/g, "")))  
	               + (txt_prfs_otherincome.value==""?0:parseInt(txt_prfs_otherincome.value.replace(/,/g, ""))) 
	               + (txt_prfs_extraordinarygainloss.value==""?0:parseInt(txt_prfs_extraordinarygainloss.value.replace(/,/g, ""))) 
	               - (txt_prfs_interestexpense.value==""?0:parseInt(txt_prfs_interestexpense.value.replace(/,/g, ""))) 
	               - (txt_prfs_otherexpenses.value==""?0:parseInt(txt_prfs_otherexpenses.value.replace(/,/g, ""))) 
	               - (txt_prfs_taxprovision.value==""?0:parseInt(txt_prfs_taxprovision.value.replace(/,/g, ""))) 
	
	nNetIncome = nOperatingIncome + nOtherIncome;
	
	lbl_prfs_netincome.innerHTML = "<b>"+formatCommaSeparated(nNetIncome)+"</b>";
	TOT_prfs_netincome.value = nNetIncome;
	
	// now set the NetProfitLoss field
    var sProfitLoss = "Breakeven";
    if (nNetIncome > 0)
        sProfitLoss = "Profitable";
    else if (nNetIncome < 0)
        sProfitLoss = "Loss";
    lbl_prfs_netprofitloss.innerHTML = 	sProfitLoss
	hdn_prfs_netprofitloss.value = sProfitLoss;
	
}
