var WarnOnStreetLength = 40; 
var bUsingAddrLine2 = false;
function selectRow(oSrc)
{
    // get the selected row
    var oParent = oSrc.parentElement; 
    // get the values from the selected row
    var aTDs = oParent.getElementsByTagName("td");
    var sStreet = new String(aTDs[0].childNodes[0].nodeValue);
    var sCity = aTDs[1].childNodes[0].nodeValue;
    var sState = aTDs[2].childNodes[0].nodeValue;
    var sZip = aTDs[3].childNodes[0].nodeValue;
    var sCounty = aTDs[4].childNodes[0].nodeValue;

    /*
    alert("Length: "
      + aTDs.length
      + "\nStreet: " + sStreet
      + "\nCity: " + sCity
      + "\nState: " + sState
      + "\nZip: " + sZip
      + "\nCounty: " + sCounty
      
    );
    
    */
    var bContinue = true;
    if (sStreet.length > WarnOnStreetLength)
    {
        bContinue = confirm('The street address exceeds '+ WarnOnStreetLength + ' characters. Do you still want to use this address?');
    }
    if (bContinue) {

        var oForm = window.parent.document.EntryForm;
        if (bUsingAddrLine2)
            oForm.addr_address2.value = sStreet;
        else
            oForm.addr_address1.value = sStreet;
        
        // extra work to set the city    
        CustomSetaddr_prcityid(sCity + ', ' + sState);
        oForm.addr_postcode.value = sZip;
        oForm.addr_prcounty.value = sCounty;
        parent.populateFromPerfectAddress();
    }
}

function CustomSetaddr_prcityid(Text)
{
    var oDoc = window.parent.document;
    var oForm = oDoc.EntryForm;

    var oSearchSmallAdvaddr_prcityid = oDoc.all("SearchSmallAdvaddr_prcityid");

    // clear the existing value without a prompt
    oForm.addr_prcityidTEXT.style.textDecoration="none";
    oForm._HIDDENaddr_prcityidTEXT.value="";
    oForm.addr_prcityid.value="";
    oForm.addr_prcityidTEXT.title="";

    // display the text for the city appropriately
    oForm.addr_prcityidTEXT.value=Text;

    // use the native accpac function to set the correct id value
    oSearchSmallAdvaddr_prcityid.onclick();
}

var autoSelectFirstRow = false;
function AutoSelectFirstRow() {
    if (autoSelectFirstRow) {
        var firstRow = document.getElementById("tblResults").rows[1];
        selectRow(firstRow);
    }
}