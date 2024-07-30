// create placeholders for 10 different types (currently there are only 7);
// the appended numberal represents the type value
var nDefaultPublishYears1 = 0;
var nDefaultPublishYears2 = 0;
var nDefaultPublishYears3 = 0;
var nDefaultPublishYears4 = 0;
var nDefaultPublishYears5 = 0;
var nDefaultPublishYears6 = 0;
var nDefaultPublishYears7 = 0;
var nDefaultPublishYears8 = 0;
var nDefaultPublishYears9 = 0;
var nDefaultPublishYears10 = 0;

function initialize()
{
    txtDate = document.EntryForm.prpe_date;
    if (txtDate.value == "") {
        dtNow = new Date();
        nMonth = dtNow.getMonth() + 1;
        nDate = dtNow.getDate();
        nYear = dtNow.getFullYear();
        txtDate.value = nMonth + "/" + nDate + "/" + nYear;
    }

    handlePersonEventTypeChange();
    handleEffectiveDateChange();
}

function handlePersonEventTypeChange()
{
    var cbo = document.EntryForm.prpe_personeventtypeid;
    var sType = "";
    if (cbo != null && cbo.selectedIndex > -1)
        sType = cbo.options[cbo.selectedIndex].value;
    // educational degree earned
    sStyle = 'none';
    if (sType == "3")
        sStyle = 'inline';

    hideRowField = document.EntryForm.prpe_educationalinstitution;
    var parent = hideRowField.parentElement;
    while ((parent != null) && (parent.tagName != "TR"))
        parent = parent.parentElement;
    if (parent.tagName == "TR")
        parent.style.display=sStyle;
    hideRowField = document.EntryForm.prpe_educationaldegree;
    var parent = hideRowField.parentElement;
    while ((parent != null) && (parent.tagName != "TR"))
        parent = parent.parentElement;
    if (parent.tagName == "TR")
        parent.style.display=sStyle;

    // bankrupcy
    sStyle = 'none';
    if (sType == "4")
        sStyle = 'inline';

    hideRowField = document.getElementById("prpe_bankruptcytype");
    var parent = hideRowField.parentElement;
    while ((parent != null) && (parent.tagName != "TR"))
        parent = parent.parentElement;
    if (parent.tagName == "TR")
        parent.style.display=sStyle;
    hideRowField = document.EntryForm.prpe_usbankruptcycourt;
    var parent = hideRowField.parentElement;
    while ((parent != null) && (parent.tagName != "TR"))
        parent = parent.parentElement;
    if (parent.tagName == "TR")
        parent.style.display=sStyle;

    // bankrupcy dismissed
    sStyle = 'none';
    if (sType == "5")
        sStyle = 'inline';
    
    hideRowField = document.getElementById("prpe_casenumber");
    var parent = hideRowField.parentElement;
    while ((parent != null) && (parent.tagName != "TR"))
        parent = parent.parentElement;
    if (parent.tagName == "TR")
        parent.style.display=sStyle;

    setPublishUntilDate(sType);
}

function setPublishUntilDate(sType)
{
    txtPublishUntil = document.EntryForm.prpe_publishuntildate;
    if (txtPublishUntil != null)
    {
        dtNow = new Date();
        nMonth = dtNow.getMonth() + 1;
        nDate = dtNow.getDate();
        nYear = dtNow.getFullYear();
        var nYearsValue = 0;
        switch (parseInt(sType))
        {
            case 1: nYearsValue = nDefaultPublishYears1; break;
            case 2: nYearsValue = nDefaultPublishYears2; break;
            case 3: nYearsValue = nDefaultPublishYears3; break;
            case 4: nYearsValue = nDefaultPublishYears4; break;
            case 5: nYearsValue = nDefaultPublishYears5; break;
            case 6: nYearsValue = nDefaultPublishYears6; break;
            case 7: nYearsValue = nDefaultPublishYears7; break;
            case 8: nYearsValue = nDefaultPublishYears8; break;
            case 9: nYearsValue = nDefaultPublishYears9; break;
            case 10: nYearsValue = nDefaultPublishYears10; break;
        }
        nYear += nYearsValue;
        txtPublishUntil.value = nMonth + "/" + nDate + "/" + nYear;         
    }

}


function onClickEffectiveDateRadio()
{
    var oRadio = document.getElementsByName("_radioDispEffDate");
    var oCustom = document.getElementById("prpe_DisplayedEffectiveDate");
    var oFormatted = document.getElementById("prpe_displayedeffectivedatestyle");
    
    if (oRadio != null)
    {
        if (oRadio[0].checked)
        {
            oFormatted.disabled = false;
            oCustom.disabled = true;
            oFormatted.selectedIndex = 0;
            handleEffectiveDateChange();
        }
        else
        {
            cboDisplayedDate = document.getElementById("prpe_displayedeffectivedatestyle");
            while (cboDisplayedDate.options.length > 0)
                cboDisplayedDate.options.remove(0);
            oFormatted.selectedIndex = -1;
            oFormatted.disabled = true;
            oCustom.disabled = false;
        }
    }
    
}

function handleEffectiveDateChange()
{
    txtEffectiveDate = document.getElementById("prpe_date");
    // if the effective date is entered, reset the DisplayedEffectiveDate dropdown values
    cboDisplayedDate = document.getElementById("prpe_displayedeffectivedatestyle");
    if (cboDisplayedDate != null && txtEffectiveDate != null)
    {
        var nSelectedIndex = cboDisplayedDate.selectedIndex;
        while (cboDisplayedDate.options.length > 0)
            cboDisplayedDate.options.remove(0);
        
        if (txtEffectiveDate.value != "")
        {
            dateEffective = new Date(txtEffectiveDate.value);
            switch (dateEffective.getMonth() + 1)
            {
                case 1: {sMonthDesc="January";break;}
                case 2: {sMonthDesc="February";break;}
                case 3: {sMonthDesc="March";break;}
                case 4: {sMonthDesc="April";break;}
                case 5: {sMonthDesc="May";break;}
                case 6: {sMonthDesc="June";break;}
                case 7: {sMonthDesc="July";break;}
                case 8: {sMonthDesc="August";break;}
                case 9: {sMonthDesc="September";break;}
                case 10: {sMonthDesc="October";break;}
                case 11: {sMonthDesc="November";break;}
                case 12: {sMonthDesc="December";break;}
                default: sMonthDesc="";
            }
 
            var oOption = document.createElement("OPTION");
            cboDisplayedDate.options.add(oOption);
            oOption.innerText = sMonthDesc + " " + dateEffective.getDate() + ", " + dateEffective.getFullYear() ;
            oOption.value = "0";

            oOption = document.createElement("OPTION");
            cboDisplayedDate.options.add(oOption);
            oOption.innerText = sMonthDesc + " " + dateEffective.getFullYear() ;
            oOption.value = "1";

            oOption = document.createElement("OPTION");
            cboDisplayedDate.options.add(oOption);
            oOption.innerText = dateEffective.getFullYear() ;
            oOption.value = "2";

            oOption = document.createElement("OPTION");
            cboDisplayedDate.options.add(oOption);
            oOption.innerText = new String(dateEffective.getFullYear()).substring(0,3) + "0's" ;
            oOption.value = "3";
            
            if (nSelectedIndex >= 0)
                cboDisplayedDate.selectedIndex = nSelectedIndex;
            handleDisplayedDateStyleChange();    
        }        
    }
}
function handleDisplayedDateStyleChange()
{
    cboDisplayedDate = document.getElementById("prpe_displayedeffectivedatestyle");
    if (cboDisplayedDate != null )
    {
        txtDisplay = document.getElementById("prpe_DisplayedEffectiveDate");
        if (cboDisplayedDate.selectedIndex > -1)
            txtDisplay.value = cboDisplayedDate.options[cboDisplayedDate.selectedIndex].innerText;
    }    
}
function setDisplayedDateStyleIndex(index)
{
    cboDisplayedDate = document.getElementById("prpe_displayedeffectivedatestyle");
    if (cboDisplayedDate != null )
    {
        if (index > -1)
        {
            cboDisplayedDate.selectedIndex = index;
            handleDisplayedDateStyleChange();
        }
    }    
}


function save()
{
    var oFormatted = document.getElementById("prpe_displayedeffectivedatestyle");
    if (oFormatted.disabled == true)
        oFormatted.disabled = false;

    var oCustom = document.getElementById("prpe_DisplayedEffectiveDate");
    if (oCustom.disabled == true)
        oCustom.disabled = false;

    if (oFormatted.selectedIndex == -1 )
    {
        var oOption = document.createElement("OPTION");
        oFormatted.options.add(oOption);
        oOption.value = "-1";
        
        oFormatted.selectedIndex = oFormatted.options.length-1;
    }

    document.EntryForm.submit();
}

