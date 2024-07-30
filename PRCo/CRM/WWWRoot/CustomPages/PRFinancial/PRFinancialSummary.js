/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2010

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/
var txt_prfs_cashequivalents = null;
var txt_prfs_artrade = null;
var txt_prfs_duefromrelatedparties = null;
var txt_prfs_loansnotesreceivable = null;
var txt_prfs_marketablesecurities = null;
var txt_prfs_inventory = null;
var txt_prfs_groweradvances = null;
var txt_prfs_othercurrentassets = null;
var TOT_prfs_totalcurrentassets = null;
var lbl_prfs_totalcurrentassets = null;

var txt_prfs_accountspayable = null;
var txt_prfs_currentmaturity = null;
var txt_prfs_creditline = null;
var txt_prfs_currentloanpayableshldr = null;
var txt_prfs_othercurrentliabilities = null;
var lbl_prfs_totalcurrentliabilities = null;
var TOT_prfs_totalcurrentliabilities = null;

var txt_prfs_property = null;
var txt_prfs_leaseholdimprovements = null;
var txt_prfs_otherfixedassets = null;
var txt_prfs_accumulateddepreciation = null;
var lbl_prfs_netfixedassets = null;
var TOT_prfs_netfixedassets = null;
		
var txt_prfs_longtermdebt = null;
var txt_prfs_loansnotespayableshldr = null;
var txt_prfs_otherlongliabilities = null;
var lbl_prfs_totallongliabilities = null;
var TOT_prfs_totallongliabilities = null;

var txt_prfs_otherloansnotesreceivable = null;
var txt_prfs_goodwill = null;
var txt_prfs_othermiscassets = null;
var lbl_prfs_totalotherassets = null;
var TOT_prfs_totalotherassets = null;

var txt_prfs_othermiscliabilities = null;

var txt_prfs_otherequity = null;

var txt_prfs_retainedearnings = null;
var lbl_prfs_totalequity  = null;
var TOT_prfs_totalequity = null;
var lbl_prfs_totalliabilityandequity  = null;
var TOT_prfs_totalliabilityandequity = null;
var lbl_prfs_totalassets = null;
var TOT_prfs_totalassets = null;
var lbl_prfs_workingcapital = null;
var TOT_prfs_workingcapital = null;


function validate()
{
    var sSaveErrors = "";
    var oStatementDate = document.EntryForm.prfs_statementdate;
    if (oStatementDate)
    {
        var sStatementDate = String(oStatementDate.value);
        if (sStatementDate == "")
        {
            sSaveErrors += " - Statement Date is required.\n";
        }
    }

    var oStatementType = document.EntryForm.prfs_type;
    if (oStatementType) {
        var sStatementType = String(oStatementType.value);
        if (sStatementType == "") {
            sSaveErrors += " - Statement Type is required.\n";
        }

        if (sStatementType == "I") {
            var oInterimMonth = document.EntryForm.prfs_interimmonth;
            if (oInterimMonth) {
                var sInterimMonth = String(oInterimMonth.value);
                if (sInterimMonth == "") {
                    sSaveErrors += " - When Statement Type = 'Interim', then an Interim Month is required.\n";
                }
            }
        }
    }
    
    
    if (sSaveErrors != "")
    {
        alert("To save this Financial Statement, the following changes are required:\n\n" 
            + sSaveErrors + "\n\nPlease correct these issues before continuing.");
    
        return false;
    }
	return true;
}

function save()
{
    if (validate()) {

        if (document.getElementById("_IDprfs_subordinationagreements").checked == false) { 

            if ((document.getElementById("hdn_SubordinationAgreement")) &&
                (document.getElementById("hdn_SubordinationAgreement").value == "Y")) {
                if (!confirm("Previous Financial Statement flagged with Subordination Agreement.  Please review current Financial for Subordination Agreement and set flags accordingly.  Click OK to continue.")) {
                    return;
                }
            }
        }     


        document.EntryForm.submit();

    }
}


// these fields are used often and it is better to incur the cost of loading them 
// once rather than doing document.getElementById calls for every keypress.
function loadFields()
{
    txt_prfs_cashequivalents = document.getElementById("prfs_cashequivalents");
    txt_prfs_artrade = document.getElementById("prfs_artrade");
    txt_prfs_duefromrelatedparties = document.getElementById("prfs_duefromrelatedparties");
    txt_prfs_loansnotesreceivable = document.getElementById("prfs_loansnotesreceivable");
    txt_prfs_marketablesecurities = document.getElementById("prfs_marketablesecurities");
    txt_prfs_inventory = document.getElementById("prfs_inventory");
    txt_prfs_groweradvances = document.getElementById("prfs_groweradvances");
    txt_prfs_othercurrentassets = document.getElementById("prfs_othercurrentassets");
    lbl_prfs_totalcurrentassets = document.getElementById("prfs_totalcurrentassets");
    TOT_prfs_totalcurrentassets = document.getElementById("TOT_prfs_totalcurrentassets");

    txt_prfs_accountspayable = document.getElementById("prfs_accountspayable");
    txt_prfs_currentmaturity = document.getElementById("prfs_currentmaturity");
	txt_prfs_creditline = document.getElementById("prfs_creditline");
	txt_prfs_currentloanpayableshldr = document.getElementById("prfs_currentloanpayableshldr");
	txt_prfs_othercurrentliabilities = document.getElementById("prfs_othercurrentliabilities");
	lbl_prfs_totalcurrentliabilities = document.getElementById("prfs_totalcurrentliabilities");
	TOT_prfs_totalcurrentliabilities = document.getElementById("TOT_prfs_totalcurrentliabilities");

	txt_prfs_property = document.getElementById("prfs_property");
	txt_prfs_leaseholdimprovements = document.getElementById("prfs_leaseholdimprovements");
	txt_prfs_otherfixedassets = document.getElementById("prfs_otherfixedassets");
	txt_prfs_accumulateddepreciation = document.getElementById("prfs_accumulateddepreciation");
    lbl_prfs_netfixedassets = document.getElementById("prfs_netfixedassets");
    TOT_prfs_netfixedassets = document.getElementById("TOT_prfs_netfixedassets");
	
	txt_prfs_longtermdebt = document.getElementById("prfs_longtermdebt");
	txt_prfs_loansnotespayableshldr = document.getElementById("prfs_loansnotespayableshldr");
	txt_prfs_otherlongliabilities = document.getElementById("prfs_otherlongliabilities");
	lbl_prfs_totallongliabilities = document.getElementById("prfs_totallongliabilities");
	TOT_prfs_totallongliabilities = document.getElementById("TOT_prfs_totallongliabilities");

	txt_prfs_otherloansnotesreceivable = document.getElementById("prfs_otherloansnotesreceivable");
	txt_prfs_goodwill = document.getElementById("prfs_goodwill");
	txt_prfs_othermiscassets = document.getElementById("prfs_othermiscassets");
	lbl_prfs_totalotherassets = document.getElementById("prfs_totalotherassets");
	TOT_prfs_totalotherassets = document.getElementById("TOT_prfs_totalotherassets");

	txt_prfs_othermiscliabilities = document.getElementById("prfs_othermiscliabilities");

	txt_prfs_retainedearnings = document.getElementById("prfs_retainedearnings");
	txt_prfs_otherequity = document.getElementById("prfs_otherequity");
	lbl_prfs_totalequity = document.getElementById("prfs_totalequity");
	TOT_prfs_totalequity = document.getElementById("TOT_prfs_totalequity");
	TOT_prfs_totalliabilityandequity = document.getElementById("TOT_prfs_totalliabilityandequity");
	lbl_prfs_totalliabilityandequity = document.getElementById("prfs_totalliabilityandequity");
	lbl_prfs_totalassets = document.getElementById("prfs_totalassets");
	TOT_prfs_totalassets = document.getElementById("TOT_prfs_totalassets");
	lbl_prfs_workingcapital = document.getElementById("prfs_workingcapital");
	TOT_prfs_workingcapital = document.getElementById("TOT_prfs_workingcapital");
}

function viewFinancialDetails(sFieldName, sBlockName)
{
    // resubmit this form with the predefined sFinancialDetailUrl adding the field and block values;
    // this submission goes to PRFinancialSummary.asp with an em value of "95" which is handled by
    // redirecting to the PRFinancialDetailPage after performing some key actions
    document.EntryForm.action = sFinancialDetailUrl + "&sField=" + sFieldName + "&sBlock=" + sBlockName;;
    document.EntryForm.submit();    
}

function onFinancialFieldKeyUp()
{
    sFieldName = window.event.srcElement.name;
    
    recalcTotalsForFieldChange(sFieldName);
    sFieldValue = document.getElementById(sFieldName).value;
    sCalcValue = document.getElementById("HIDDEN_FD_"+sFieldName).value;
    imgField = document.getElementById("img_"+sFieldName);
    if (sFieldValue == "" || sFieldValue == 0 || (sCalcValue != "0" && sCalcValue == sFieldValue))
        imgField.style.visibility = "visible";
    else
        imgField.style.visibility = "hidden";
    
        
}



function recalcTotalsForFieldChange(sFieldName)
{
	sList = "prfs_cashequivalents,prfs_artrade,prfs_duefromrelatedparties,prfs_loansnotesreceivable,prfs_marketablesecurities,prfs_inventory,prfs_groweradvances,prfs_othercurrentassets";
	if (sList.indexOf(sFieldName) != -1)
	{
		nTotalValue = 0;
		nTotalValue += makeNumeric(txt_prfs_cashequivalents);
		nTotalValue += makeNumeric(txt_prfs_artrade);
		nTotalValue += makeNumeric(txt_prfs_duefromrelatedparties);
		nTotalValue += makeNumeric(txt_prfs_loansnotesreceivable);
		nTotalValue += makeNumeric(txt_prfs_marketablesecurities);
		nTotalValue += makeNumeric(txt_prfs_inventory);
		nTotalValue += makeNumeric(txt_prfs_groweradvances);
		nTotalValue += makeNumeric(txt_prfs_othercurrentassets);

		lbl_prfs_totalcurrentassets.innerHTML = "<b>"+formatCommaSeparated(nTotalValue)+"</b>";
		TOT_prfs_totalcurrentassets.value = nTotalValue;
	}

	sList = "prfs_accountspayable,prfs_currentmaturity,prfs_creditline,prfs_currentloanpayableshldr,prfs_othercurrentliabilities";
	if (sList.indexOf(sFieldName) != -1)
	{
		nTotalValue = 0;
		nTotalValue += makeNumeric(txt_prfs_accountspayable);
		nTotalValue += makeNumeric(txt_prfs_currentmaturity);
		nTotalValue += makeNumeric(txt_prfs_creditline);
		nTotalValue += makeNumeric(txt_prfs_currentloanpayableshldr);
		nTotalValue += makeNumeric(txt_prfs_othercurrentliabilities);

		lbl_prfs_totalcurrentliabilities.innerHTML = "<b>"+formatCommaSeparated(nTotalValue)+"</b>";
		TOT_prfs_totalcurrentliabilities.value = nTotalValue;
	}

	sList = "prfs_property,prfs_leaseholdimprovements,prfs_otherfixedassets,prfs_accumulateddepreciation";
	if (sList.indexOf(sFieldName) != -1)
	{
		nTotalValue = 0;
		nTotalValue += makeNumeric(txt_prfs_property);
		nTotalValue += makeNumeric(txt_prfs_leaseholdimprovements);
		nTotalValue += makeNumeric(txt_prfs_otherfixedassets);
		nTotalValue -= makeNumeric(txt_prfs_accumulateddepreciation);

		lbl_prfs_netfixedassets.innerHTML = "<b>"+formatCommaSeparated(nTotalValue)+"</b>";
		TOT_prfs_netfixedassets.value = nTotalValue;
	}

	sList = "prfs_longtermdebt,prfs_loansnotespayableshldr,prfs_otherlongliabilities";
	if (sList.indexOf(sFieldName) != -1)
	{
		nTotalValue = 0;
		nTotalValue += makeNumeric(txt_prfs_longtermdebt);
		nTotalValue += makeNumeric(txt_prfs_loansnotespayableshldr);
		nTotalValue += makeNumeric(txt_prfs_otherlongliabilities);

		lbl_prfs_totallongliabilities.innerHTML = "<b>"+formatCommaSeparated(nTotalValue)+"</b>";
		TOT_prfs_totallongliabilities.value = nTotalValue;
	}

	sList = "prfs_otherloansnotesreceivable,prfs_goodwill,prfs_othermiscassets";
	if (sList.indexOf(sFieldName) != -1)
	{
		nTotalValue = 0;
		nTotalValue += makeNumeric(txt_prfs_otherloansnotesreceivable);
		nTotalValue += makeNumeric(txt_prfs_goodwill);
		nTotalValue += makeNumeric(txt_prfs_othermiscassets);

		lbl_prfs_totalotherassets.innerHTML = "<b>"+formatCommaSeparated(nTotalValue)+"</b>";
		TOT_prfs_totalotherassets.value = nTotalValue;
	}

	sList = "prfs_otherequity,prfs_retainedearnings";
	if (sList.indexOf(sFieldName) != -1)
	{
		nTotalValue = 0;
		nTotalValue += makeNumeric(txt_prfs_otherequity);
		nTotalValue += makeNumeric(txt_prfs_retainedearnings);

		lbl_prfs_totalequity.innerHTML = "<b>"+formatCommaSeparated(nTotalValue)+"</b>";
		TOT_prfs_totalequity.value = nTotalValue;
	}

	updatePrimaryTotals();
}

function updatePrimaryTotals() {
	// Current assets calculation
	nTotalAssets = (parseInt(lbl_prfs_totalcurrentassets.innerText.replace(/,/g,"")) + 
	                parseInt(lbl_prfs_netfixedassets.innerText.replace(/,/g,"")) + 
	                parseInt(lbl_prfs_totalotherassets.innerText.replace(/,/g,"")));
	lbl_prfs_totalassets.innerHTML = "<b>"+formatCommaSeparated(nTotalAssets)+"</b>";
	TOT_prfs_totalassets.value = nTotalAssets;

	// Total Liabilities calculation
	if (txt_prfs_othermiscliabilities == null || txt_prfs_othermiscliabilities == "undefined")
	    sValue = document.getElementById("prfs_othermiscliabilities").innerText.replace(/,/g,"");
    else
    	sValue = makeNumeric(txt_prfs_othermiscliabilities); 

	nTotalLiabilities = (parseInt(lbl_prfs_totalcurrentliabilities.innerText.replace(/,/g,"")) + 
	                     parseInt(lbl_prfs_totallongliabilities.innerText.replace(/,/g,"")) + 
	                     (sValue==""?0:parseInt(sValue)));



	if (isNaN(nTotalLiabilities))
	     nTotalLiabilities = 0;
    // Total Liabilities and Equity calculation
	nTotalEquity = parseInt(lbl_prfs_totalequity.innerText.replace(/,/g,"")); 
	if (isNaN(nTotalEquity))
	     nTotalEquity = 0;
	
	nTotalLiabilityAndEquity = nTotalLiabilities + nTotalEquity;
	if (isNaN(nTotalLiabilityAndEquity))
	     nTotalLiabilityAndEquity = 0;
	lbl_prfs_totalliabilityandequity.innerHTML = "<b>" + formatCommaSeparated(nTotalLiabilityAndEquity )+ "</b>";
	TOT_prfs_totalliabilityandequity.value = nTotalLiabilityAndEquity;


	// Working Capital calculation
	nWorkingCapital = (parseInt(lbl_prfs_totalcurrentassets.innerText.replace(/,/g,"")) - 
	                  parseInt(lbl_prfs_totalcurrentliabilities.innerText.replace(/,/g,"")));
	if (isNaN(nWorkingCapital))
	     nWorkingCapital = 0;
	    
	lbl_prfs_workingcapital.innerHTML = "<b>" + formatCommaSeparated(nWorkingCapital) + "</b>";
	TOT_prfs_workingcapital.value = nWorkingCapital;
}

function onchange_StatementDate()
{
    var statementdate = document.EntryForm.prfs_statementdate;
    var statementimage = document.EntryForm.prfs_statementimagefile;
    var compid = document.EntryForm._HIDDENprfs_companyid;

    var objRegExp  = new RegExp('([0-9]{2})/([0-9]{2})/[1,2][0-9]([0-9]{2})');

    //check for match to search criteria
    var sValue = statementdate.value;
    while(objRegExp.test(sValue)) {
       sValue = sValue.replace(objRegExp, '$3$1$2');
    }

    if (statementimage) {
        var bUpdate = true;
        var sFileName = compid.value + '_' + sValue + '.pdf';
        if (statementimage.value != "") {
            bUpdate = confirm("The statement date has changed. Would you like to change the Statement Image File value to '" + sFileName + "'?  This won't rename the actual file.  Any changes to the Statement Image File value will have to be manually made to the file on disk in order for the file link to work correctly.");
        }

        if (bUpdate) {
            statementimage.value = sFileName;
        }
    }        
}