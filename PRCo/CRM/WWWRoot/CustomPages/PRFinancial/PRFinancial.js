function onFinancialFieldChange()
{
    src = window.event.srcElement;
    src.value = formatCommaSeparated(src.value.replace(/,/g,""));
}


function formatCommaSeparated(sValue)
{
    sValue = String(sValue);
    var objRegExp  = new RegExp('(-?[0-9]+)([0-9]{3})');

    //check for match to search criteria
    while(objRegExp.test(sValue)) {
       //replace original string with first group match,
       //a comma, then second group match
       sValue = sValue.replace(objRegExp, '$1,$2');
    }
  return sValue;
}


function onFinancialFieldKeyPress()
{
    var key = window.event.keyCode;
    if((key < 48 || key > 57) 
        && key != 45 // -
        //&& key != 46 // .
        && key != 44 // ,
        )
    {
        return false;
    }
   
    sText = window.event.srcElement.value;
    if (key == 45) 
    {
        if (sText.charAt(0) == "-") 
            return false;
        else if (sText.length > 0)
        {
            window.event.srcElement.value = "-" + sText;
            return false;
        }
    }
    return true;
    
}

/* 
    this function ensures that we are dealing with a numeric value (0 if NAN)
*/
function makeNumeric(field)
{
    var nReturn = 0;
    sValue = new String(field.value)
    sValue = sValue.replace(/,/g,"");
                
    nReturn = (sValue==""?0:parseInt(sValue));
    if (isNaN(nReturn))
        nReturn = 0;
        
    return nReturn

}