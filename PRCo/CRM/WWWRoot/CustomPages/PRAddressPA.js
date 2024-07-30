

function refreshPerfectAddress() {

    GetCountryID(document.getElementById("addr_prcityid").value)

    var oAddressLine1 = document.getElementById("addr_address1");
    var oAddressLine2 = document.getElementById("addr_address2");
    var oCityState = document.getElementById("addr_prcityidTEXT");
    var oZip = document.getElementById("addr_postcode");

    var oPA = document.getElementById("embed_PerfectAddress");
    oPA.src = "/CRM/CustomPages/PerfectAddress.aspx?Address1=" + oAddressLine1.value +
                "&Address2=" + oAddressLine2.value +
                "&CityStateZip=" + oCityState.value + " " + oZip.value;

    /*
    alert ("Address 1:" + oAddressLine1.value);
    alert ("City, State:" + oCityState.value);
    alert ("Zip:" + oZip.value);
    */
}


var enableAutoRefreshPerfectAddress = true;
function autoRefreshPerfectAddress() {
    if (enableAutoRefreshPerfectAddress) {
        refreshPerfectAddress();
    }
}

function refreshPerfectAddressAfterPause() {
    if (autoRefreshPerfectAddress) {
        // Pause to give the search function time to
        // set the value of our City/State field
        setTimeout("refreshPerfectAddress()", 750);
    }
}

function initPerfectAddressAutoRefresh() {
    document.getElementById("addr_address1").onblur = autoRefreshPerfectAddress;
    document.getElementById("addr_address2").onblur = autoRefreshPerfectAddress;
    document.getElementById("addr_postcode").onblur = autoRefreshPerfectAddress;
    document.getElementById("addr_prcityidTEXT").onblur = autoRefreshPerfectAddress;

    var eCitySearch = document.getElementById("SearchSmallAdvaddr_prcityid");
    if (eCitySearch.addEventListener) {
        eCitySearch.addEventListener('click', refreshPerfectAddressAfterPause, false);
    } else if (eCitySearch.attachEvent) {
        eCitySearch.attachEvent('onclick', refreshPerfectAddressAfterPause);
    }
}

function populateFromPerfectAddress() {
    enableAutoRefreshPerfectAddress = false;
}

function GetCountryID(cityID) {
    //xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = SetCountryID;
    xmlHttp.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetCountryID?cityID=" + cityID, true);
    xmlHttp.send(null);
}

var countryID = 0;
function SetCountryID() {
    if (xmlHttp.readyState == 4) {
        countryID = xmlHttp.responseXML.text;
    }
}