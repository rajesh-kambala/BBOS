 function Service() {

    var _ServiceCode;
    var _WebAccessLevel;
    var _WebAccessDescription;
    var _MaxUserCount;
    var _AssignedUserCount;
    var _RemainingUserCount;
    var _IsTrial = false;

    this.init = function (ServiceCode, WebAccessLevel, WebAccessDescription, MaxUserCount, AssignedUserCount, IsTrial) {
        _ServiceCode = ServiceCode;
        _WebAccessLevel = WebAccessLevel;
        _WebAccessDescription = WebAccessDescription;
        _MaxUserCount = MaxUserCount;
        _AssignedUserCount = AssignedUserCount;
        _RemainingUserCount = _MaxUserCount - _AssignedUserCount;
        _IsTrial = IsTrial;
    }

    this.UseLicense = function () {
        if (_MaxUserCount < 9999) {
            _AssignedUserCount = _AssignedUserCount + 1;
            _RemainingUserCount = _RemainingUserCount - 1;
        }

    }

    this.AddLicense = function () {
        if (_MaxUserCount < 9999) {
            _AssignedUserCount = _AssignedUserCount - 1;
            _RemainingUserCount = _RemainingUserCount + 1;
        }
    }

    this.GetServiceCode = function () { return _ServiceCode; }   
    this.GetWebAccessLevel = function() { return _WebAccessLevel;}    
    
    
    this.GetWebAccessDescription = function() { return _WebAccessDescription;}    


    this.GetUserCount = function() { return _UserCount;}
    this.GetRemainingUserCount = function () { return _RemainingUserCount; }
    this.IsTrial = function () { return _IsTrial; }
}

var bDataChanged = false;


function initialize(){
    setAvailableServicesDropdown();
    document.EntryForm.cbo_AvailableServices.selectedIndex = 0
    AvailableServices_Click();
}


function AvailableServices_Click(){
    setAvailableAccessDropdown();
}

function setAvailableServicesDropdown(){
    cbo = document.EntryForm.cbo_AvailableServices;
    cbo.options.length = 0;

    for (i = 0; i < arrServices.length; i++){
        if (arrServices[i].GetRemainingUserCount() > 0) {

            var sRemainingCountText = "";
            if (arrServices[i].GetRemainingUserCount() < 9999) {
                sRemainingCountText = " (" + arrServices[i].GetRemainingUserCount() + ") ";
            }

            addOption(cbo, arrServices[i].GetServiceCode(), arrServices[i].GetWebAccessDescription() + sRemainingCountText);
        }       
    }
}


function addOption(cbo, sValue, sCaption){
    oOption = document.createElement("OPTION");
    cbo.options.add(oOption);
    oOption.innerText = sCaption;
    oOption.value = sValue;
}


function getAccessLevelDescription(sValue) {
    for (i = 0; i < arrServices.length; i++){
        if ((arrServices[i].GetWebAccessLevel() == parseInt(sValue)) &&
            (arrServices[i].IsTrial() == false)) {
            return arrServices[i].GetWebAccessDescription()
        }       
    }
    return "";
}

function setAvailableAccessDropdown(){
    cboService = document.EntryForm.cbo_AvailableServices;
    sServiceCode = cboService.options[cboService.selectedIndex].value;

    sMaxAccessLevel = 0;
    var oService = null;
    for (i = 0; i < arrServices.length; i++) {

        if (arrServices[i].GetServiceCode() == sServiceCode) {
            oService = arrServices[i];
            sMaxAccessLevel = arrServices[i].GetWebAccessLevel();
            break;
        }       
    }

    cbo = document.EntryForm.cbo_AvailableAccessLevels;
    cbo.options.length = 0;

    var hdnIndustryType = document.getElementById("hdnIndustryType");

    if (hdnIndustryType != null && hdnIndustryType.value == "L") {
        //Lumber only
        if (oService.GetWebAccessLevel() >= 500)
            addOption(cbo, "500", getAccessLevelDescription("500"));
        if (oService.GetWebAccessLevel() >= 400)
            addOption(cbo, "400", getAccessLevelDescription("400"));
        if (oService.GetWebAccessLevel() >= 350)
            addOption(cbo, "350", getAccessLevelDescription("350"));
        if (oService.GetWebAccessLevel() >= 300)
            addOption(cbo, "300", getAccessLevelDescription("300"));
    }
    else {
        //Non-lumber
        if (oService.GetWebAccessLevel() >= 700)
            addOption(cbo, "700", getAccessLevelDescription("700"));
        if (oService.GetWebAccessLevel() >= 400)
            addOption(cbo, "400", getAccessLevelDescription("400"));
        if (oService.GetWebAccessLevel() >= 300)
            addOption(cbo, "300", getAccessLevelDescription("300"));
    }

    if ((sServiceCode == "None") ||
        (sServiceCode == "None2") ||
        (sServiceCode == "ITALIC")) {
        addOption(cbo, oService.GetWebAccessLevel(), getAccessLevelDescription(oService.GetWebAccessLevel()));
    }
}

function setWebSiteUserAcccess_Click()
{
    cboService = document.EntryForm.cbo_AvailableServices;
    cboAccessLevel = document.EntryForm.cbo_AvailableAccessLevels;
    
    // get an array of all the selected web users
    tbl = document.getElementById("tblWebSiteUsers");
    arrSelected = new Array;
    AllInput = tbl.getElementsByTagName("INPUT");
    for (x = 0; x < AllInput.length; x++) {

        if ((AllInput[x].type == "checkbox")  &&
		    (AllInput[x].name.indexOf("chk_") == 0)) {
            // create an array of selected checkboxes
            if (AllInput[x].checked == true)
                arrSelected[arrSelected.length] = AllInput[x];
        }
    }

    // if none selected, message and exit.
    if (arrSelected.length <= 0 ){
        alert("No BBOS users have been selected.  Select the users that will be assigned the specified access level.");
        return;
    }
    
    // get the selected Access Level and verify there are enough licenses left
    var oService;
    sSelectedServiceValue = cboService.options[cboService.selectedIndex].value;

    sSelectedAccessLevelValue = "0";
    if (cboAccessLevel.options.length > 0)
        sSelectedAccessLevelValue = cboAccessLevel.options[cboAccessLevel.selectedIndex].value;

    if (sSelectedServiceValue != "" && sSelectedServiceValue != "0"){
        // go find the service info
        for (x = 0; x < arrServices.length; x++){
            if (arrServices[x].GetServiceCode() == sSelectedServiceValue) {
                oService = arrServices[x];
                break;
            }       
        }
        if (!oService){
            alert("Error determining service.");
            return;
        }
        nAvailable = oService.GetRemainingUserCount();
        if (arrSelected.length > nAvailable){
            alert("Only " + nAvailable + " " + oService.GetWebAccessDescription() + " license(s) are available, but " + arrSelected.length + " users have been selected. Please deselect some users before continuing.");
            return;
        }
    }

    bDataChanged = true;
    for (y = 0; y < arrSelected.length; y++) {

        sPersonLinkID = (arrSelected[y].id).substring(4);

        sName = "txt_peli_" + sPersonLinkID;
        txtAccessLevel = document.getElementById(sName);

        sServiceName = "txt_prse_" + sPersonLinkID;
        txtServiceCode = document.getElementById(sServiceName);

        // if there is currently a value, give it back to the original service
        if (txtServiceCode && txtServiceCode.value != "" && txtServiceCode.value != "0") {

            var oOldService;
            for (z = 0; z < arrServices.length; z++){
                if (arrServices[z].GetServiceCode() == txtServiceCode.value) {
                    oOldService = arrServices[z];
                    break;
                }       
            }
            if (!oOldService) {
                alert("Warning: Could not return license for modified web access.");
                //continue;
            } else {
                oOldService.AddLicense()
            }
        }


        sServiceCodeDesc = "";
        sTrialDesc = "";
        if (sSelectedServiceValue == "" ) {
            txtAccessLevel.value = sNoServiceDefaultAccess;     // reset to registered user
            txtServiceCode.value = "";
        } else {
            txtAccessLevel.value = sSelectedAccessLevelValue;
            txtServiceCode.value = oService.GetServiceCode();
            oService.UseLicense();
            sServiceCodeDesc = oService.GetWebAccessDescription();

            if (oService.IsTrial()) {
                sTrialDesc = "Y";
            }
        }

        td = document.getElementById("td_Access_Level_" + sPersonLinkID);
        td.innerText = getAccessLevelDescription(txtAccessLevel.value);

        td = document.getElementById("td_Trial_" + sPersonLinkID);
        td.innerText = sTrialDesc;
 
        arrSelected[y].checked = false;
    }
    setAvailableServicesDropdown();
    //AvailableServices_Click();

    return false;
}


window.onbeforeunload = confirmExit;
function confirmExit()
{
    if (bDataChanged == true)
        return "Data has changed. Leaving this page will cause changes to be lost.  Are you sure you want to leave this page?";
    return;
}


function sendEmail(sURL) {

    var selected = false;
    var inputControls = document.getElementsByTagName("INPUT");
    for (i = 0; i < inputControls.length; i++) {
        if (inputControls[i].type == "checkbox") {
            if (inputControls[i].checked == true) {
                selected = true;
                break;
            }
        }
    }

    if (!selected) {
        alert("No BBOS users have been selected.  Select the users that will have their passwords sent to them.");
        return;
    }

    if (confirm("Are you sure you want to send the selected users their passwords?")) {
        document.EntryForm.action = sURL;
        document.EntryForm.submit();
    }
}


function save() {
    bDataChanged = false;
    document.EntryForm.submit();
}

function CheckAll(bChecked) {

    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    for (var i = 0; i < oCheckboxes.length; i++) {
        if ((oCheckboxes[i].type == "checkbox") &&
		    (oCheckboxes[i].name.indexOf("chk_") == 0) ) {
            if (oCheckboxes[i].disabled == false) {
                oCheckboxes[i].checked = bChecked;
            }
        }
    }
}


function openEnterpriseUsersReport() {
    var sReportURL = document.getElementById("hidSSRSURL").value;
    sReportURL += "/BBOSUsageReports/BBOSEnterpriseUsers";
    sReportURL += "&HQID=" + document.getElementById("hidHQID").value;
    sReportURL += "&rc:Parameters=false";
    //sReportURL += "&rs:ClearSession=true&rs:format=PDF"8
    
    window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=800,height=600", true);

}