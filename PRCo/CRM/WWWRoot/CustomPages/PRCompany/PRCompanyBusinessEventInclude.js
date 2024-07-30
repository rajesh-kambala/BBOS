function handleBusinessEventTypeChange()
{
    cbo = document.EntryForm.prbe_businesseventtypeid;
    document.getElementById("div_blk_2").style.display='none';
    document.getElementById("div_blk_10").style.display = 'none';
    document.getElementById("div_blk_11").style.display = 'none';
    document.getElementById("div_blk_11A").style.display = 'none';
    //Acquisition
    if (cbo.options[cbo.selectedIndex].value == "1")
    {
        document.getElementById("div_blk_10").style.display = 'inline';
        relcomp2 = document.getElementById("_Dataprbe_relatedcompany2id");
        if (relcomp2 != null)
        {   
            document.getElementById("_captprbe_relatedcompany2id").style.display = 'none';
            relcomp2.style.display='none';
        }
        document.getElementById("div_blk_11").style.display = 'inline';
        handleDetailedTypeChange("acquisition");

        //document.getElementById("SearchSmallAdvprbe_relatedcompany2id").style.display='none';
        //document.getElementById("SearchSmallprbe_relatedcompany2id").style.display='none';
        ///document.getElementById("prbe_relatedcompany2idTEXT").style.display='none';
        //document.getElementById("prbe_relatedcompany2id").style.display='none';
    }
    //Agreement in Principle
    else    
    {
        document.getElementById("div_blk_2").style.display = 'inline';
    }

}

function handleDetailedTypeChange()
{
    cbo = document.getElementById("prbe_DetailedType");
    txtOther = document.getElementById("prbe_OtherDescription");
    captOther = document.getElementById("_Captprbe_OtherDescription");
    if (cbo == null)
        return;
    if (cbo.options[cbo.selectedIndex].innerText == "Other") 
    {
        if (txtOther != null)
        {
            txtOther.style.display='inline';
            captOther.style.display='inline';
        }
    }    
    else
    {
        if (txtOther != null)
        {
            txtOther.style.display='none';
            captOther.style.display='none';
        }
    }    
    
}

function onClickEffectiveDateRadio()
{
    var oRadio = document.getElementsByName("_radioDispEffDate");
    var oCustom = document.getElementById("prbe_DisplayedEffectiveDate");
    var oFormatted = document.getElementById("prbe_displayedeffectivedatestyle");
    
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
            cboDisplayedDate = document.getElementById("prbe_displayedeffectivedatestyle");
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
    txtEffectiveDate = document.getElementById("prbe_effectivedate");
    // if the effective date is entered, reset the DisplayedEffectiveDate dropdown values
    cboDisplayedDate = document.getElementById("prbe_displayedeffectivedatestyle");
    if (cboDisplayedDate != null && txtEffectiveDate != null)
    {
        var nSelectedIndex = cboDisplayedDate.selectedIndex;
        while (cboDisplayedDate.options.length > 0)
            cboDisplayedDate.options.remove(0);
        
        if (txtEffectiveDate.value != "")
        {
            arrDate = txtEffectiveDate.value.split("/");
            dateEffective = new Date(txtEffectiveDate.value);
            // European  Format: sValue = arrDate[1]+"/"+arrDate[0]+"/"+arrDate[2];
            switch (dateEffective.getMonth()+1)
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
    cboDisplayedDate = document.getElementById("prbe_displayedeffectivedatestyle");
    if (cboDisplayedDate != null )
    {
        txtDisplay = document.getElementById("prbe_DisplayedEffectiveDate");
        if (cboDisplayedDate.selectedIndex > -1)
            txtDisplay.value = cboDisplayedDate.options[cboDisplayedDate.selectedIndex].innerText;
    }    
}
function setDisplayedDateStyleIndex(index)
{
    cboDisplayedDate = document.getElementById("prbe_displayedeffectivedatestyle");
    if (cboDisplayedDate != null )
    {
        if (index > -1)
        {
            cboDisplayedDate.selectedIndex = index;
            handleDisplayedDateStyleChange();
        }
    }    
}

function setDefaultPublishUntil()
{
    cbo = document.EntryForm.prbe_businesseventtypeid;
    txtPublishUntil = document.EntryForm.prbe_publishuntildate;
    if (cbo != null && txtPublishUntil != null)
    {
        sTypeValue = cbo.options[cbo.selectedIndex].value;
        dtNow = new Date();
        nMonth = dtNow.getMonth() + 1;
        nDate = dtNow.getDate();
        nYear = dtNow.getFullYear();
        switch (parseInt(sTypeValue))
        {
            case 1:
            case 7:
            case 8:
            case 9:
            case 10:
            case 22:
            case 26:
            case 31:
            case 42:
                {nYear = 2999; break; }
            case 2: 
            case 19: 
            case 23: 
                {nYear += 2; break; }
            case 3: 
            case 4: 
            case 5: 
            case 6: 
            case 11: 
            case 21: 
            case 24: 
            case 32:
            case 33:
            case 39:
            case 40:
            case 41: 
                { nYear += 10; break; }
            case 12: 
            case 13: 
            case 15: 
            case 16: 
            case 17: 
            case 18: 
            case 20: 
            case 25: 
            case 27: 
            case 28: 
            case 29: 
            case 30: 
                {nYear += 7; break;} 
            case 14: 
            case 36: 
                {nYear += 4; break; }
            case 26: 
            case 34: 
            case 35: 
            case 37: 
                {nYear += 5; break;} 
        }

        if (nYear == 2999)
        {
            nMonth = 12;
            nDate = 31;
        }
        txtPublishUntil.value = nMonth + "/" + nDate + "/" + nYear;         
    }
}

function save()
{
    var oFormatted = document.getElementById("prbe_displayedeffectivedatestyle");
    var oCustom = document.getElementById("prbe_DisplayedEffectiveDate");
    if (oFormatted.disabled == true)
        oFormatted.disabled = false;
    if (oCustom.disabled == true)
        oCustom.disabled = false;


    if (oFormatted.selectedIndex == -1 )
    {
        var oOption = document.createElement("OPTION");
        oFormatted.options.add(oOption);
        oOption.value = "-1";
        
        oFormatted.selectedIndex = oFormatted.options.length-1;
    }

    // if this is a business closure, alert the user to change the status to "Do Not Publish"
    var prbe_businesseventtypeid = document.EntryForm._HIDDENprbe_businesseventtypeid;
    if (prbe_businesseventtypeid != null)
    {
        if (prbe_businesseventtypeid.value == 7)
            alert("After saving this business event, please be sure to review this company's \"Do Not Publish\" flag and \"Listing Status\".");
            
        if (prbe_businesseventtypeid.value == 24)
            alert("After saving this business event, please be sure to review this company's \"Listing Status\".");
            
    }

    if (document.EntryForm._HIDDENprbe_businesseventtypeid.value == "5") {
        prepareNumericValue(document.getElementById("prbe_assetamount"));
        prepareNumericValue(document.getElementById("prbe_liabilityamount"));
    }

    
    document.EntryForm.submit();
}

function prepareNumericValue(eControl) {
    eControl.value = eControl.value.replace(/,/g, '');
    eControl.value = eControl.value.replace(/\$/g, '');
}