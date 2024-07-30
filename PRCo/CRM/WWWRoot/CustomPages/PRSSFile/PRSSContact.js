var eCurrentCompanyId, eCurrentPersonId
var xmlHttp 
var sFileId
var sCompanyId
var sSSContactId
var sCompanyInfoUrl
var sPersonInfoUrl

function prssc_companyid_change()  {  
	eCurrentCompanyId = document.EntryForm.prssc_companyid;
	eCurrentPersonId = document.EntryForm.prssc_personid;
	sCompanyId = eCurrentCompanyId.options[eCurrentCompanyId.selectedIndex].value;
	if (sCompanyId > 0)
    {
	    xmlHttp = GetXmlHttpObject();
        xmlHttp.onreadystatechange=setCompanyInfoFromResponse
	    xmlHttp.open("GET",sCompanyInfoUrl + "&CompanyId=" + sCompanyId + "&SSFileId=" + sFileId,true);
        xmlHttp.send(null);		
    }
}	

function prssc_personid_change()  {  
	var ePersonId = document.EntryForm.prssc_personid;
	obj_prssc_contactattn = document.EntryForm.prssc_contactattn;
	if (ePersonId.selectedIndex == 0)
	    obj_prssc_contactattn.value = "";
	else {
	    obj_prssc_contactattn.value = ePersonId.options[ePersonId.selectedIndex].text;

	    xmlHttp = GetXmlHttpObject();
	    xmlHttp.onreadystatechange = setPersonInfoFromResponse
	    xmlHttp.open("GET", sPersonInfoUrl + "&CompanyId=" + sCompanyId + "&PersonID=" + ePersonId.value, true);
	    xmlHttp.send(null);		
	}
}	


function setCompanyInfoFromResponse() {
    // readyState of 4 = Complete
    if(xmlHttp.readyState==4) {
        // if "OK"
        if (xmlHttp.status==200)
        {
            // set the adress fields and the companyid options
            eCurrentPersonId = document.forms[0].prssc_personid;
            eval(xmlHttp.responseText);
            prssc_personid_change();
        }
        else 
            location.href = sCompanyInfoUrl + "&CompanyID=" + sCompanyId + "&SSFileId=" + sFileId;
    }
}



function setPersonInfoFromResponse() {
    // readyState of 4 = Complete
    if (xmlHttp.readyState == 4) {
        // if "OK"
        if (xmlHttp.status == 200) {
            eval(xmlHttp.responseText);
        }
        else {
            alert("Error");
        }
    }
}


function save()
{
    if (validate()){
        // enable before submit or the value will not be passed
        document.EntryForm.prssc_isprimary.disabled = false;
    
        document.EntryForm.submit();
    }
}

function initialize()
{
    // set the available fields based upon status
    status_Change();
}

function validate()
{
	var sAlertString = "";
	
/*    var cboStatus = document.EntryForm.prss_status;
    var cboClosedReason = document.EntryForm.prss_closedreason;
    if (cboStatus.options[cboStatus.selectedIndex].value == "C")
    {
        if (cboClosedReason.options[cboClosedReason.selectedIndex].value == "")
        {
		    if (sAlertString != "")	sAlertString += "\n";
	        sAlertString += "Closed Reason is required when Status is set to Closed.";
        }
    }
*/
    var oEmailAddress = document.EntryForm.prssc_email;
    if (oEmailAddress != null) {
        if (oEmailAddress.value.indexOf(",") !== -1)
            sAlertString += " - Email Address cannot contain a comma.\n";
    }

	if (sAlertString != "")
	{
		alert ("To save this record, the following changes are required:\n\n" + sAlertString);
		return false;
	}
	return true;		

}

