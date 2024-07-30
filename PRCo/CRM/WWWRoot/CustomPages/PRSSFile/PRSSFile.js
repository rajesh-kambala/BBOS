var Mode=0;
var userlogon = null;
var prss_PRCoAssistanceFeeType = "";
var prss_PRCoAssistanceFeePct = "";
var prss_PRCoAssistanceFee = 0;

function save()
{
    // make sure this is not in readonly mode
    var cboStatus = document.EntryForm.prss_status;
    if (cboStatus){
        if (validate()) {

            recalcAmounts();

            var cboClosedReason = document.EntryForm.prss_closedreason;
            cboStatus.disabled = false;
            cboClosedReason.disabled = false;
            var objFee = document.getElementById("prss_prcoassistancefee");
            objFee.disabled = false;
            document.EntryForm.submit();
        }
    }
}

function initializePage()
{
    InsertDivider("Summary Info", "_Captprss_ssfileid");
    InsertDivider("Party Info", "_Captprss_claimantcompanyid");
    InsertDivider("File Info", "_Captprss_initialamountowed");
    //InsertDivider("Timeline Info", "_Captprss_claimauthsentdate");
    InsertDivider("<a name=WA></a>Working Assessment", "_Captprss_workingassessment");
    InsertDivider("Claims Activity Table", "_Captprss_meritorious");
    InsertDivider("<a name=RoA></a>Record of Activity", "_Captprss_recordofactivity");

//    removeBRInTD("_Captprss_InitialAmountOwed");
//    removeBRInTD("_Captprss_OldestInvoiceDate");
//    removeBRInTD("_Captprss_AmountPRCoCollected");
//    removeBRInTD("_Captprss_NumberOfInvoices");
//    removeBRInTD("_Captprss_AmountPRCoInvoiced");
//    removeBRInTD("_Captprss_partialinvoice");
//    removeBRInTD("_Captprss_AmountStillOwing");
//    removeBRInTD("_Captprss_pacadeadlinedate");
//    removeBRInTD("_Captprss_ClaimAuthSentDate");
//    removeBRInTD("_Captprss_PLANRefAuthSentDate");
//    removeBRInTD("_Captprss_ClaimAuthRcvdDate");
//    removeBRInTD("_Captprss_PLANRefAuthRcvdDate");
//    removeBRInTD("_Captprss_A1LetterSentDate");
//    removeBRInTD("_Captprss_FileSentToPLANDate");
//    removeBRInTD("_Captprss_D1LetterSentDate");
//    removeBRInTD("_Captprss_PLANPartner");
//    removeBRInTD("_Captprss_WarningLetterSentDate");
//    removeBRInTD("_Captprss_PLANFileNumber");
//    removeBRInTD("_Captprss_ReportLetterSentDate");
//    removeBRInTD("_Captprss_PLANFileResult");
//    removeBRInTD("_Captprss_NumeralReportDate");
//    removeBRInTD("_Captprss_ReportReinstateSentDate");
//    removeBRInTD("_Captprss_NumeralReinstateSentDate");
//    removeBRInTD("_Captprss_FinalNoticeLetterSentDate");
//    removeBRInTD("_Captprss_FinalNoticeLetterSentDate");    
    
    var obj = document.EntryForm.prss_recordofactivity;
    if (obj)
    {
        Mode=1;
        sContents = "<span>";    
        sContents += "<img class=ButtonItem align=left border=0 src=\"../../img/Buttons/new.gif\" " + 
                        " onclick=\"javascript:timestampRecordOfActivity();\">";
        sContents += "<span class=ButtonItem onclick=\"javascript:timestampRecordOfActivity();\">";
        sContents += "Add Timestamp</span>";
        sContents += "</span>";
        AppendCell("_Captprss_recordofactivity", sContents );
    }
    
    initAssistanceFields();
    // set the available fields based upon status
    status_Change();
    initializeTabIndexes();
    initializeKeypressFunctions();
    typeCheck();
    //forceTableCellsToLeftAlign("_Captprss_ssfileid", "10%");
}

function initAssistanceFields()
{
    newTR = document.createElement("TR");

    var newTD = document.createElement("TD");
    newTD.className = "VIEWBOXCAPTION";
    newTD.align = "right";
    newTD.vAlign = "top";
    sContent = "<span ID=_SPANprcoassistancefee>BBSI Assistance Fee: </span>";
    newTD.innerHTML = String(sContent);
    newTR.insertBefore(newTD, null);
    
    newTD = document.createElement("TD");
    newTD.vAlign = "top";
//    if (Mode==0)
//        newTD.className = "VIEWBOXCAPTION";
//    else
        newTD.className = "VIEWBOX";
    
    sContent = "<INPUT onclick=\"typeCheck()\" " + (prss_PRCoAssistanceFeeType == 0 ? "CHECKED" : "") + " CLASS=VIEWBOX TYPE=\"radio\" ID=\"prss_prcoassistancefeetype\" NAME=\"prss_prcoassistancefeetype\" Value=\"0\">"
    sContent += "<SPAN CLASS=VIEWBOXCAPTION>Fee %:&nbsp;&nbsp;&nbsp;&nbsp;</SPAN>";
    if (Mode == 1)
        sContent += "<INPUT CLASS=EDIT TYPE=\"TEXT\" ID=\"prss_prcoassistancefeepct\" NAME=\"prss_prcoassistancefeepct\" SIZE=5 Value=\"" + prss_PRCoAssistanceFeePct + "\"> ";
    else
        sContent += "<SPAN CLASS=VIEWBOX ID=_Dataprss_prcoassistancefeepct>" + prss_PRCoAssistanceFeePct + "</SPAN>";
    sContent += "<BR />";
    sContent += "<INPUT onclick=\"typeCheck()\" " + (prss_PRCoAssistanceFeeType != 0 ? "CHECKED" : "") + " CLASS=VIEWBOX TYPE=\"radio\" NAME=\"prss_prcoassistancefeetype\" Value=\"1\">";
    sContent += "<SPAN CLASS=VIEWBOXCAPTION>Flat Fee:&nbsp;</SPAN>";
    if (isNaN(prss_PRCoAssistanceFee))
        prss_PRCoAssistanceFee = 0;
    if (Mode == 1)
        sContent += "$<INPUT CLASS=EDIT TYPE=\"TEXT\" ID=\"prss_prcoassistancefee\" NAME=\"prss_prcoassistancefee\" SIZE=10 Value=\"" + prss_PRCoAssistanceFee.format(2) + "\"> ";
    else
        sContent += "$<SPAN CLASS=VIEWBOX ID=_Dataprss_prcoassistancefee>" + prss_PRCoAssistanceFee.format(2) + "</SPAN>";
    
    newTD.innerHTML = String(sContent);
    newTR.insertBefore(newTD, null);

    //    var findField = document.getElementById(sFieldName);
//    if (findField == null)
    AppendRow("_Captprss_amountprcoinvoiced", newTR, true);

}

function typeCheck()
{
    var objType = document.getElementsByName("prss_prcoassistancefeetype");
    var objPct = document.getElementById("prss_prcoassistancefeepct");
    var objFee = document.getElementById("prss_prcoassistancefee");
    
    if (objType == null) {
        return;
    }

    if (Mode == 1)
    {
        if (objType[0].checked)
        {
            objPct.disabled = false;
            objFee.disabled = true;
        }else{
            objPct.disabled = true;
            objFee.disabled = false;
        
        }
    } else {
        objType[0].disabled = true;
        objType[1].disabled = true;
    }
}

function timestampRecordOfActivity()
{
    var obj = document.EntryForm.prss_recordofactivity;
    sValue = "";
    if (obj)
    {

        sValue = new String(getDatetimeAsString() + ' - ' + String(userlogon).toUpperCase() + ': ');
        CKEDITOR.instances['prss_recordofactivity'].setData(sValue + "\n" + CKEDITOR.instances['prss_recordofactivity'].getData());
        //obj.value = sValue + '\n' + obj.value;
    }
    //obj.focus();
    //if (obj.createTextRange) {
        //var r = obj.createTextRange();
        //r.move('character', sValue.length);
        //r.select();
    //}
}

function status_Change()
{
    var cboStatus = document.EntryForm.prss_status;
    // if cboStatus is not present, we're not in edit mode
    if (cboStatus == null)
    {
        //alert("Cannot find status value");
        return;
    }
    var cboClosedReason = document.EntryForm.prss_closedreason;
    if (cboStatus.options[cboStatus.selectedIndex].value == "C")
    {
        cboClosedReason.disabled =false;
    } else {
        cboClosedReason.disabled =true;
    }
            
}

function validate()
{
	var sAlertString = "";
	
	var claimantID = document.getElementById("prss_claimantcompanyid").value;
	var claimantName = document.getElementById("prss_claimantcompanyidTEXT").value;

	if ((claimantID == "") ||
        (claimantName == "")) {
	    if (sAlertString != "") sAlertString += "\n";
	    sAlertString += " - A claimant company is required.";
	}


    var cboStatus = document.EntryForm.prss_status;
    var cboClosedReason = document.EntryForm.prss_closedreason;
    if (cboStatus){
        if (cboStatus.options[cboStatus.selectedIndex].value == "C")
        {
            if (cboClosedReason.options[cboClosedReason.selectedIndex].value == "")
            {
                if (sAlertString != "")	sAlertString += "\n";
	            sAlertString += " - Closed Reason is required when Status is set to Closed.";
            }
        }
    }
	if (sAlertString != "")
	{
		alert ("To save this record, the following changes are required:\n\n" + sAlertString);
		return false;
	}
	return true;		
}

// keypress handling functions
function initializeTabIndexes()
{
    var ndx = 1;
    function setTab(field)
    {
        if (field != null)
        {
            field.tabIndex = ndx;
            ndx++;
        }
    }

    setTab(document.EntryForm.prss_type);
    setTab(document.EntryForm.prss_status);
    setTab(document.EntryForm.prss_classificationtype);
    setTab(document.EntryForm.prss_assigneduserid);
    setTab(document.EntryForm.prss_closedreason);
    setTab(document.EntryForm.prss_topic);
    setTab(document.EntryForm.prss_adviceactivity);
    setTab(document.EntryForm.prss_meritorious);
    setTab(document.EntryForm.prss_levelofeffort);
    setTab(document.EntryForm.prss_claimantcompanyidTEXT);
    setTab(document.EntryForm.prss_respondentcompanyidTEXT);
    setTab(document.EntryForm.prss_3rdpartycompanyidTEXT);
    setTab(document.EntryForm.prss_issuedescription);

    setTab(document.EntryForm.prss_initialamountowed);
    setTab(document.EntryForm.prss_amountprcocollected);
    setTab(document.EntryForm.prss_amountstillowing);
    setTab(document.EntryForm.prss_prcoassistancefeetype);
    setTab(document.EntryForm.prss_prcoassistancefeepct);
    setTab(document.EntryForm.prss_prcoassistancefee);
    setTab(document.EntryForm.prss_amountprcoinvoiced);
    setTab(document.EntryForm.prss_oldestinvoicedate);
    setTab(document.EntryForm.prss_numberofinvoices);
    setTab(document.EntryForm.prss_pacadeadlinedate);

    setTab(document.EntryForm.prss_workingAssessment);

    //setTab(document.EntryForm.prss_claimauthsentdate);
    //setTab(document.EntryForm.prss_claimauthrcvddate);
    //setTab(document.EntryForm.prss_a1lettersentdate);
    //setTab(document.EntryForm.prss_d1lettersentdate);
    //setTab(document.EntryForm.prss_warninglettersentdate);
    //setTab(document.EntryForm.prss_reportlettersentdate);
    //setTab(document.EntryForm.prss_numeralreportdate);
    //setTab(document.EntryForm.prss_reportreinstatesentdate);
    //setTab(document.EntryForm.prss_numeralreinstatesentdate);
    //setTab(document.EntryForm.prss_finalnoticelettersentdate);

    //setTab(document.EntryForm.prss_planrefauthsentdate);
    //setTab(document.EntryForm.prss_planrefauthrcvddate);
    //setTab(document.EntryForm.prss_filesenttoplandate);
    setTab(document.EntryForm.prss_planpartner);
    setTab(document.EntryForm.prss_planfilenumber);
    //setTab(document.EntryForm.prss_planfileresult);

}

// keypress handling functions
function initializeKeypressFunctions()
{
    fld = document.EntryForm.prss_prcoassistancefeepct;
    if (fld != null)
    {
        fld.onkeyup=recalcAmounts;
        fld.onchange=recalcAmounts;
    }
    fld = document.EntryForm.prss_amountprcocollected;
    if (fld != null)
    {
        fld.onkeyup=recalcAmounts;
        fld.onchange=recalcAmounts;
    }

    fld = document.EntryForm.prss_oldestinvoicedate;
    if (fld != null)
    {
        fld.onkeyup=recalcPACADeadlineDate;
        fld.onchange=recalcPACADeadlineDate;
    }

}

function recalcAmounts()
{
    initial = document.EntryForm.prss_initialamountowed;
    nInitial = parseFloat(initial.value);
    if (isNaN(nInitial))
        nInitial = 0.00;

    received = document.EntryForm.prss_amountprcocollected;
    nReceived = parseFloat(received.value);
    if (isNaN(nReceived))
        nReceived = 0.00;

    assistancefee = document.EntryForm.prss_prcoassistancefee;
    nAssistanceFee = parseFloat(assistancefee.value);
    if (isNaN(nAssistanceFee))
        nAssistanceFee = 0.00;

    assistancefeepct = document.EntryForm.prss_prcoassistancefeepct;
    nFeePct = parseInt(assistancefeepct.value);
    if (isNaN(nFeePct))
        nFeePct = 0;

    var nFee = 200;
    if (nAssistanceFee > 200)
        nFee = nAssistanceFee;

    var objType = document.getElementsByName("prss_prcoassistancefeetype");
    if (objType[0].checked) {

        if (nReceived > 0) {
            nFee = (nReceived * (nFeePct / 100)).format(2);
        }
    }

    if (nFee < 200)
        nFee = 200.00;
    if (!isNaN(nFee))
        assistancefee.value = nFee;    

    sValue = (nInitial - nReceived).format(2);
    HIDDENstillowed = document.EntryForm._HIDDENprss_amountstillowing;
    HIDDENstillowed.value = sValue;
    DATAstillowed = document.getElementById("_Dataprss_amountstillowing");
    var sTemp = new String(DATAstillowed.innerHTML);
    var ndx = sTemp.indexOf('<');
    var sInnerHTML = "";
    if (ndx > -1)
        sInnerHTML = sTemp.substring(ndx);
    DATAstillowed.innerHTML = "$&nbsp;"+sValue+sInnerHTML;

}

function recalcPACADeadlineDate()
{
    var oldest = document.EntryForm.prss_oldestinvoicedate;
    HIDDENPaca = document.EntryForm._HIDDENprss_pacadeadlinedate;
    DATApaca = document.getElementById("_Dataprss_pacadeadlinedate");
        //Paca = document.EntryForm.prss_pacadeadlinedate;

    if (isValidDate(oldest.value) )
    {
        dtOldest = getValidDate(oldest.value);
        var dtDue = new Date(dtOldest);
        dtDue.setMonth(dtDue.getMonth() + 9);
        //Paca.value = getDateAsString(dtDue);
        HIDDENPaca.value = getDateAsString(dtDue);
        DATApaca.innerText = getDateAsString(dtDue);

    } else {
        HIDDENPaca.value = "";
        DATApaca.innerText = "";
    }
}

function onFileSentToPLANDateChange()
{
    //var txtFileSentToPLANDate = document.EntryForm.prss_filesenttoplandate;
    var cboStatus = document.EntryForm.prss_status;
    var cboClosedReason = document.EntryForm.prss_closedreason;
    var hdnStatus = document.EntryForm._HIDDENprss_status;

    //DATApaca = document.getElementById("_Dataprss_pacadeadlinedate");
        //Paca = document.EntryForm.prss_pacadeadlinedate;

    //if (isValidDate(txtFileSentToPLANDate.value) )
    //{
        //SelectDropdownItemByValue("prss_status", "C");
        //SelectDropdownItemByValue("prss_closedreason", "PLAN");
        
        //cboStatus.disabled = true;
        //cboClosedReason.disabled = true;

    //} else {
        //cboStatus.disabled = false;
        //cboClosedReason.disabled = false;
    //}
}

// Use this function to set the colSpan property of an Accpac cell
// this is currently not a native attribute for each field especially
// if you use the .CaptionPos property to manipulate the layout of fields 
// on a screen
function setColAlignment(sFieldName, alignment) {
    var field = document.getElementById(sFieldName);
    if (field != null && field != "undefined") {

        while ((field != null) && (field.tagName != "TD"))
            field = field.parentElement;

        if (field != null)
            field.align = alignment;
    }
}

function confirmTES(responderType) {

    var responder = "";
    if (responderType == "R") {
        responder = "respondent";
    } else {
        responder = "claimant";
    }


    if (confirm("Are you sure you want to send a TES to the " + responder + "?")) {
        document.getElementById("_hiddenCreateTES").value = responderType;
        document.EntryForm.submit();
    }
}

function openClaimsFiledReport(companyID, sReportURL) {
    //var sReportURL = "<% =SSRSURL %>";
    sReportURL += "/Special Services/Claims Filed";

    sReportURL += "&rc:Parameters=false";
    sReportURL += "&rs:Format=HTML5";
    sReportURL += "&CompanyID=" + companyID;

    window.open(sReportURL,
        "Reports",
        "location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=1200,height=600", true);
}

function printPage() {
    var printWin = window.open('', '', 'left=0,top=0,width=0,height=0,toolbar=0,scrollbars=0,status=0');

    printWin.document.write("<head>");
    printWin.document.write("<link rel='stylesheet' href='../../eware.css'>");
    printWin.document.write("<style>");
    printWin.document.write("   td.FavIcon img { width: 20px; height: 20px; padding - top: 10px;}");
    printWin.document.write("   .TOPCAPTION,.TOPBC,.SEARCHBODY,.SENDOPT {color: #4d4f53; font: 700 13px Arial, Helvetica, sans - serif; }");
    printWin.document.write("   .TOPHEADING {color: #4d4f53; text - decoration: none; font: none 11px Tahoma, Arial; font-weight:400; vertical - align: top; }");
    printWin.document.write("</style>");
    printWin.document.write("</head>");

    printWin.document.write($("#FavEntityId")[0].parentElement.parentElement.parentElement.outerHTML);
    printWin.document.write($("#_HIDDENprss_ssfileid")[0].parentElement.parentElement.parentElement.parentElement.parentElement.outerHTML);
    printWin.document.getElementById("trChange2").style = "display:none";

    printWin.document.getElementsByClassName("copyLink")[0].style = "display:none";

    var aElems = document.getElementsByTagName("a");
    for (var i = 0; i < aElems.length; i++) {
        if (aElems[i].innerText == "View Listing" ||
            aElems[i].innerText == "Send Listing" ||
            aElems[i].innerText == "Send LRL" ||
            aElems[i].innerText == "Open Transaction")
            aElems[i].style = "display:none";
    }
    
    printWin.document.close();
    printWin.print();
    setTimeout(function () { printWin.close(); }, 200);
}
