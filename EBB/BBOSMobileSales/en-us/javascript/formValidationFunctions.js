//***********************************************************************
//***********************************************************************
// Copyright Travant Solutions, Inc. 2000-2006
//
// The use, disclosure, reproduction, modification, transfer, or  
// transmittal of  this work for any purpose in any form or by any 
// means without the written  permission of Travant Solutions is 
// strictly prohibited.
//
// Confidential, Unpublished Property of Travant Solutions, Inc.
// Use and distribution limited solely to authorized personnel.
//
// All Rights Reserved.
//
// Notice:  This file was created by Travant Solutions, Inc.  Contact
// by e-mail at info@travant.com
//
// Filename:		formValidationFunctions.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>

//  getAttribute('tsiRequired')  (true/false)
//  getAttribute('tsiDisplayName') (string) The name to use in the validation message
//  getAttribute('tsiInteger') (true/false)
//  getAttribute('tsiNumeric') (true/false)
//  getAttribute('tsiMin') (numeric)
//  getAttribute('tsiMax') (numeric)
//  getAttribute('tsiCurrency') (true/false)
//  getAttribute('tsiDate') (true/false)
//  getAttribute('tsiDate')Time (true/false)
//  getAttribute('tsi4DigitYear')(true/false)
//  getAttribute('tsiEmail') (true/false)
//  getAttribute('tsiPhone') (true/false)
//  getAttribute('tsiZip') (true/false)
//  getAttribute('tsiEquals') (value the control must be equal to)
//  getAttribute('tsiMaxLength') (for textarea controls)
//
// Available Functions
// displayErrorMessage(szMsg) 
// getDaysInMonth(eDate) 
// isBlank(szText)
// isFutureDate(szDate)
// isLeapYear(eDate) 
// IsValidCurrency(szText)
// IsValidDate(szText, b4DigitYear) 
// IsValidDateRange(eFromDate, eToDate) 
// isValidEMail(szEmail) 
// IsValidInteger(szText)
// IsValidNumber(szText) 
// IsValidNumericRange(eFrom, eTo) 
// isValidPhone(szPhone) 
// isValidZip(szZip) 
// make4DigitYear(szText) 
// Trim(szString) 

var bUnknownAcceptable = false;
var bEnableRequireCheck = true;
var bEnableValidation = true;
var aDisabled = new Array();


// Determine if the tsiRequired
// tags should be enforced.
function DisableRequired() {
	bEnableRequireCheck = false;
}

// Disable all tsi* validation
// tags.
function DisableValidation() {
	DisableRequired();
	bEnableValidation = false;
}

// Override this in local
// script to execute pre-validation
// code.
function preStdValidation(form) {
	return true;
}

// Override this in local
// script to execute post-validation
// code.
function postStdValidation(form) {
	return true;
}

function disableControls(form) {
	var iIndex=0;
	
    for (var i=0; i<form.length; i++) {
	    e = form.elements[i];
		if ((e.getAttribute('tsiDisable')) &&
			(e.disabled == false)) {
			 e.disabled = true;
			 aDisabled[iIndex] = e;
			 iIndex++;
		}
	}


    for (var i=0; i<document.anchors.length; i++) {
	    e = document.anchors[i];
	    
		if ((e.getAttribute('tsiDisable')) &&
			(e.disabled == false)) {
			 e.disabled = true;
			 aDisabled[iIndex] = e;
			 iIndex++;
		}
	}
}

function resetControls() {
	for(var i=0; i<aDisabled.length; i++) {
		aDisabled[i].disabled = false;
	}
}

/* Executes when a form is submitted.  Executes the 
* preStdValidation (user defined), then the system
* validations, then finally postStdValidation (user 
* defined).  If any valdiation fails, the method will
* return false which will cancel the form submission */
function formOnSubmit(form)
{
	if (bEnableValidation == false) {
		return true;
	}
	
	disableControls(form);

	var bReturn = false;
    if (preStdValidation(form))
    	if (validateForm(form))
        	if (postStdValidation(form))
            	bReturn= true;


	resetControls();
	return bReturn;
  }

function validateForm(form)
{
	var e;
    var eToFocus;
    var eHid;
    var nValue;

    var szRequiredErrors = "";
    var szNumericErrors = "";
    var szDateErrors = "";
    var szErrorMessage = "";
	var szGeneralErrors = "";
    var szDateFormat = "";
    var szTrimmedString = "";
	
    var bSearchForm;
    var bIsValid;



    //  First we need to see if we have
    //  any specified date formats.
    szDateFormat = "mm/dd/yy";

    // Loop through the elements of the form, looking for all
    // all text and textarea elements that have the "required"
    // property defined, and are empty. Display an error message
    // identifying the fields that have errors.
    for (var i=0; i<form.length; i++) {

		e = form.elements[i];

        if (e.disabled) {
			continue;
        }
        
        if (e.name == "__VIEWSTATE") {
            continue;
        }

        if (e.type == "text") {
             // if the field is not empty, trim string
            if ((e.value != null) && (e.value != "") && !isBlank(e.value)) {
                szTrimmedString = Trim(e.value);
                e.value = szTrimmedString;
            }
        } // End If (e.type == "text")

        if ((e.type == "select-one") || (e.type == "select-multiple"))  {
            if ((bEnableRequireCheck) &&
				(e.getAttribute('tsiRequired'))) {
				
				if (e.length > 0) {
					szValue = e.options[e.selectedIndex].value;
					if ((szValue == null) || (szValue == "") || (isBlank(szValue)) || (szValue=="None") || (szValue=="0")) {
						szRequiredErrors += "\n          " + e.getAttribute('tsiDisplayName');
						continue;
					}
				}
			}
		
		} else if ((e.type == "text") || (e.type == "textarea") || (e.type == "password") || (e.type == "hidden") || (e.type == "file")) {

            if ((bEnableRequireCheck) &&
				(e.getAttribute('tsiRequired'))) {
                // first check if the field is empty
                if ((e.value == null) || (e.value == "") || isBlank(e.value)) {
                    if (!szRequiredErrors && !szNumericErrors)
                        eToFocus = e;

                    szRequiredErrors += "\n          " + e.getAttribute('tsiDisplayName');
                    continue;
                }
            } // End if (e.getAttribute('tsiRequired'))

			// Validate numeric fields if they are not blank and not an asterisk.
			//alert(e.getAttribute('tsiDisplayName') + ":" + e.getAttribute('tsiInteger'));
            if ((e.value.length > 0) && ((e.getAttribute('tsiInteger') != null) || (e.getAttribute('tsiNumeric') != null) || (e.getAttribute('tsiMin') != null) || (e.getAttribute('tsiMax') != null))) {
            	if (e.getAttribute('tsiInteger'))
                	bIsValid = IsValidInteger(e.value);
                else
                    bIsValid = IsValidNumber(e.value);

                if (!bIsValid) {
                	if (!szRequiredErrors && !szNumericErrors && !szDateErrors)
                        eToFocus = e;


	                szNumericErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a number"
                    szNumericErrors += ".\n";
                } else {
                    nValue = parseFloat(e.value);
                    if (isNaN(nValue) ||
                        ((e.getAttribute('tsiMin') != null) && (nValue < e.getAttribute('tsiMin'))) ||
                        ((e.getAttribute('tsiMax') != null) && (nValue > e.getAttribute('tsiMax'))))
                    {
                        if (!szRequiredErrors && !szNumericErrors && !szDateErrors)
                            eToFocus = e;

                        szNumericErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a number";

                        if (e.getAttribute('tsiMin') != null)
                            szNumericErrors += " that is greater than or equal to " + e.getAttribute('tsiMin');

                        if ((e.getAttribute('tsiMax') != null) && (e.getAttribute('tsiMin') != null))
                            szNumericErrors += " and less than or equal to " + e.getAttribute('tsiMax');
                        else if (e.getAttribute('tsiMax') != null)
                            szNumericErrors += " that is less than or equal to " + e.getAttribute('tsiMax');

                        szNumericErrors += ".\n";
                    }
                } // End Else (!bIsValid)

                if ((e.getAttribute('tsiEquals') != null) && (nValue != e.getAttribute('tsiEquals'))) {
                  	if (!szRequiredErrors && !szNumericErrors && !szDateErrors)
						eToFocus = e;
							
				    szNumericErrors += " - The field " + e.getAttribute('tsiDisplayName');
				    if (e.getAttribute('tsiEquals') != null)
						szNumericErrors += " must equal to " + e.getAttribute('tsiEquals');

				    szNumericErrors += ".\n";
			    } // End If ((e.getAttribute('tsiEquals') != null) && (nValue != e.getAttribute('tsiEquals')))
            } // End If (e.value.length > 0) && (e.getAttribute('tsiInteger') || e.getAttribute('tsiNumeric') || (e.getAttribute('tsiMin') != null) || (e.getAttribute('tsiMax') != null) || (e.parsequals != null)))

		
            if ((e.value.length > 0) && e.getAttribute('tsiCurrency')) {
                bIsValid = IsValidCurrency(e.value);

                if (!bIsValid) {
                    if (!szRequiredErrors && !szNumericErrors && !szDateErrors)
                        eToFocus = e;
                    szNumericErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a valid currency amount.\n";
                }
            }  // End If e.getAttribute('tsiCurrency')

            if ((e.value.length > 0) && e.getAttribute('tsiDate')) {
            	if (e.getAttribute('tsi4DigitYear')) {
                    b4DigitYear = true;
                    szDateFormat = "mm/dd/yyyy";
                } else {
                    b4DigitYear = false;
                    szDateFormat = "mm/dd/yy";
                }

				
				bContinue = true;
				
				// Look to see if this is a special value
				if (e.getAttribute('tsiDateUnknown')) {
					szValue = e.value.toLowerCase();
					if ((szValue == "unknown") || (szValue == "n/a") || (szValue == "na")) {
						bContinue = false;
					}
				}
				
				if (bContinue) {
	                if (!IsValidDate(e.value, b4DigitYear)) {
	                    if (!szRequiredErrors && !szNumericErrors && !szDateErrors)
	                        eToFocus = e;
	
	                    if (e.getAttribute('tsiDisplayName') == null)
	                        szDateErrors += " - The Date field must be a valid date in the format " + szDateFormat + ".\n";
	                    else
	                        szDateErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a valid date in the format " + szDateFormat + ".\n";
	                } // End if (!IsValidDate(e.value, b4DigitYear))
	
	                e.value = make4DigitYear(e.value);
				}
      		} // End If e.getAttribute('tsiDate')



            if ((e.value.length > 0) && e.getAttribute('tsiDateTime')) {
            	if (e.getAttribute('tsi4DigitYear')) {
                    b4DigitYear = true;
                    szDateFormat = "mm/dd/yyyy";
                } else {
                    b4DigitYear = false;
                    szDateFormat = "mm/dd/yy";
                }

				
				bContinue = true;
				
				// Look to see if this is a special value
				if (e.getAttribute('tsiDateUnknown')) {
					szValue = e.value.toLowerCase();
					if ((szValue == "unknown") || (szValue == "n/a") || (szValue == "na")) {
						bContinue = false;
					}
				}
				
				if (bContinue) {
	                if (!IsValidDateTime(e.value)) {
	                    if (!szRequiredErrors && !szNumericErrors && !szDateErrors)
	                        eToFocus = e;
	
	                    if (e.getAttribute('tsiDisplayName') == null)
	                        szDateErrors += " - The Date/Time field must be a valid date in the format " + szDateFormat + ".\n";
	                    else
	                        szDateErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a valid date/time in the format " + szDateFormat + " hh:mm am.\n";
	                } // End if (!IsValidDate(e.value, b4DigitYear))
	
	                //e.value = make4DigitYear(e.value);
				}
      		} // End If e.getAttribute('tsiDate')
				
            if ((e.value.length > 0) && e.getAttribute('tsiEmail')) {
				if (!isValidEMail(e.value)) {
					szGeneralErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a valid Internet e-mail address.\n";				
				}
			} // End If e.getAttribute('tsiEmail')				


            if ((e.value.length > 0) && e.getAttribute('tsiPhone')) {
				if (!isValidPhone(e.value)) {
					szGeneralErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a valid phone number.\n";				
				}
			} // End If e.getAttribute('tsiPhone')				

            if ((e.value.length > 0) && e.getAttribute('tsiZip')) {
				if (!isValidZip(e.value)) {
					szGeneralErrors += " - The field " + e.getAttribute('tsiDisplayName') + " must be a valid U.S. or Canadian postal code.\n";				
				}
			} // End If e.getAttribute('tsiZip')				
			
			
			if ((e.value.length > 0) && e.getAttribute('tsiMaxLength')) {
				if (e.value.length > e.getAttribute('tsiMaxLength')) {
					szGeneralErrors += " - The value for the field " + e.getAttribute('tsiDisplayName') + " exceeds the maximum allowable length of " + e.getAttribute('tsiMaxLength') + " characters.\n";								
				}
			}
			
        } // End if ((e.type == "text") || (e.type == "textarea") || (e.type == "password") || (e.type == "hidden"))
		else {
	//		alert(e.type);
		}
    } // End for (var i=0; i<form.length; i++)
	
	
    // If there were any errors, display a message,
    // and return false, to prevent the form from
    // being submitted. Ohterwise return true.
    if (szRequiredErrors || szNumericErrors || szDateErrors || szGeneralErrors) {

		szErrorMessage = "";
        if (szRequiredErrors) {
			szErrorMessage += " - The following required field(s) are empty:\n";

			if (bUnknownAcceptable) {			
				szErrorMessage += "   (Some fields accept 'N/A' or 'Unknown')\n";
    		}        
			szErrorMessage += szRequiredErrors + "\n";
            
			if ((szNumericErrors) ||
                (szDateErrors))
                szErrorMessage += "\n";
        }

        if (szNumericErrors){
			szErrorMessage += szNumericErrors;
            if (szDateErrors || szGeneralErrors)
                szErrorMessage += "\n";
        }

        if (szDateErrors) {
            szErrorMessage += szDateErrors;
            if (szGeneralErrors)
                szErrorMessage += "\n";
		}
		
		if (szGeneralErrors) {
            szErrorMessage += szGeneralErrors;
		}
			
        //alert(szErrorMessage);
        displayErrorMessage(szErrorMessage);

         if ((eToFocus != null) &&
             (eToFocus.type != "hidden"))
         {
         	eToFocus.focus();
            eToFocus.select();
         }
            
		return false;
 	} else {
        return true;
    } // if (szRequiredErrors || szNumericErrors || szDateErrors)
} // End function validateForm(form)

	
// 
// This function returns true if a string 
// contains only whitespace characters.
//
function isBlank(szText) {
	var ch;
	
    for(var i=0; i<szText.length; i++) {
		ch = szText.charAt(i);
        if ((ch != ' ') && (ch != '\n') && (ch != '\t'))
        	return false;
    }
    
	return true;
} // End function isBlank(szText)

//
// This function validates both two digit
// and four digit years.  It also checks
// for leap year
//
function IsValidDate(szText, b4DigitYear) {

    // This is an assumption, but due to some AJAX
    // controls, we have little choice.
    if (szText == "mm/dd/yyyy") {
        return true;
    }


    var szDate, aDateElements, szDay, szMonth, szYear, aDaysInMonth
    szDate = new String(szText);

	// If we don't find a date separator
	// then it is an invalid date.
    iSlash1 = szDate.indexOf("/");
    if (iSlash1 == -1) {
        return false;
    }

    if (iSlash1 == szDate.length) {
        return false;
    }

	// If we don't find a second date 
	// separator then it is an invalid date.
    iSlash2 = szDate.indexOf("/", iSlash1 + 1);
    if (iSlash2 == -1)  {
        return false;
    }

    szMonth = szDate.substring(0, iSlash1);
    szDay = szDate.substring(iSlash1+1,iSlash2);
    szYear = szDate.substring(iSlash2+1);

	// Validate the day of month
    iDay = parseFloat(szDay);
    if (isNaN(szDay) || isNaN(iDay)) {
        return false;
    }

	// Validate the month of year
    iMonth = parseFloat(szMonth);
    if (isNaN(szMonth)|| isNaN(iMonth)) {
        return false;
    }

    if ((iMonth < 1) || (iMonth > 12)) {
        return false;
    }
	
	// Validate the year
    iYear = parseFloat(szYear);
	if (isNaN(szYear) || isNaN(iYear)) {
        return false;
    }

	if (b4DigitYear) {
 		if (szYear.length < 4) {
		  	return false;
  		}
	}

	// Now make sure the year fits
	// into our "window" of valid years
	today = new Date();
	minYear = today.getFullYear() - 150;
 	maxYear = today.getFullYear() + 20;

	inputDate = new Date(szText);	
 	if ((inputDate.getFullYear() < minYear) ||
    	(inputDate.getFullYear() > maxYear)) {
    	return false;
 	}

	if (szYear.length == 3 ) {
 		return false;
	}

   	if (iYear < 0) {
        return false;
    }

	   
    if (Math.round(iYear/4) == iYear/4) {
      	//it's leap year....
      	aDaysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];            
    }else{
    	//non leap year...
      	aDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    }                      
   
    
    if ((iDay < 1) ||
        (iDay > aDaysInMonth[iMonth-1])) {
        return false;
    }

	// If we made it this far, all is well
    return true;
	
} // function IsValidDate(szText, b4DigitYear)

function IsValidDateTime(szText) {

	var szDateTime, szDate, szTime, szHour, szMinute, szAM;
	var iSpace, iColon, iHour, iMinute;
	
    szDateTime = new String(szText);

	// We should find a blank character between
	// the date and time..
    iSpace = szDateTime.indexOf(" ");
    if (iSpace == -1) {
        return false;
    }

	szDate = szDateTime.substring(0, iSpace);
	
	// First validate the Date
	if (!IsValidDate(szDate, false)) {
		return false;
	}
	
	szTime = szDateTime.substring(iSpace+1, szDateTime.length);
	// If we don't find a time separator
	// then it is an invalid date.
    iColon1 = szTime.indexOf(":");
    if (iColon1 == -1) {
        return false;
    }

    if (iColon1 == szTime.length) {
        return false;
    }

	// If we don't find a second time 
	// separator then it is an invalid time.
    iSpace = szTime.indexOf(" ", iColon1 + 1);
    if (iSpace == -1)  {
        return false;
    }

    szHour	= szTime.substring(0, iColon1);
    szMinute= szTime.substring(iColon1+1,iSpace);
    szAM	= szTime.substring(iSpace+1);

	// Validate the Hour
    iHour = parseFloat(szHour);
    if (isNaN(szHour)|| isNaN(iHour)) {
        return false;
    }

    if ((iHour < 1) || (iHour > 12)) {
        return false;
    }

	// Validate the Minute
    iMinute = parseFloat(szMinute);
    if (isNaN(szMinute)|| isNaN(iMinute)) {
        return false;
    }

    if ((iMinute < 0) || (iMinute > 59)) {
        return false;
    }
	
	szAM = szAM.toLowerCase();
	if ((szAM != "am") &&
		(szAM != "a") &&
		(szAM != "pm") &&
		(szAM != "p")) {
		return false;
	}
	
	return true;
}

    
// 
// Determines if the value is a valid
// number.  This includes commas, negative
// sign, and decimal point.
//
function IsValidNumber(szText) {
    var iIndex;
    var szValues = "0123456789,.-";
    var bValid = true;
	var iDecimalCount = 0;

	// Iterate through each character
	// in the value.
    for(iIndex=0; (iIndex <= szText.length-1) && (bValid); iIndex++) {
        
		// If we don't find our character in our 
		// valid characters values, it is invalid.
		if (szValues.indexOf(szText.charAt(iIndex)) == -1) {
            bValid = false;

		// Is the current char a decimal?
        } else if ( szText.charAt(iIndex) == '.' ) {
            iDecimalCount = iDecimalCount + 1;

            // Number must have only one decimal
            if (iDecimalCount > 1) {
                bValid = false;
            }
			
		// Is the current char a negative sign?	
        } else if ( szText.charAt(iIndex) == '-' ) {
            // Number must have only one dash and when present it
            // must be first character
            if (iIndex > 0)
                bValid = false;
        }
	} // End For

    return bValid;
}

// 
// Determines if the value is a valid
// currency.  This includes commas, negative
// sign, and decimal point.
//
function IsValidCurrency(szText)
{
    var iIndex;
    var szValues = "0123456789,.";
    var bValid = true;
    var bFoundDecimal = false;
    var iDecimalCount = 0;
    var iAfterDecimalCount = 0;
    var iDollarSignCount = 0;
    var iPosofRightMostDollarSign = 0;

    for(iIndex=0; (iIndex <= szText.length-1) && (bValid); iIndex++) {

		if ( szText.charAt(iIndex) == '$' ) {
        	iDollarSignCount = iDollarSignCount + 1;
            iPosofRightMostDollarSign = iIndex;

        // Number must have only one dash and when present it
        //  must be first character (or the second if the first
        //  is the dollar sign)
        } else if ( szText.charAt(iIndex) == '-' ) {
			if (iIndex > 0) {
                if ( (iIndex != 1) || (szText.charAt(0) != '$'))
                        bValid = false;
            }
        }

        if ( bFoundDecimal == true ) {
            iAfterDecimalCount = iAfterDecimalCount + 1;
        }

        if ( szText.charAt(iIndex) == '.' ) {
            iDecimalCount = iDecimalCount + 1;
            bFoundDecimal = true;
        }

        if (szValues.indexOf(szText.charAt(iIndex)) == -1) {
            bValid = false;
        }
    } // end-for


    // Only one decimal makes sense
    if (iDecimalCount > 1) {
        bValid = false;
    }

    // Only one dollarsign makes sense
    if (iDollarSignCount > 1) {
        bValid = false;
    }

    // Dollar sign must be in position 0
    if (iPosofRightMostDollarSign > 0) {
        bValid = false;
    }

	// If we don't have two places after
	// the decimal, then this is invalid
	// We allow 0 decimal points for backwards
	// compatibility.
	if (iAfterDecimalCount > 2) {
		bValid = false;
	}
	
	return bValid;
}

//
// Determine if the value is a valid
// integer - no decimals
//
function IsValidInteger(szText) {

    // If it is a valid number and it contains no decimal point,
    //  then it is a valid integer
    if ( (IsValidNumber(szText)) && (szText.indexOf(".") == -1) && (szText.indexOf(",") == -1) )
        return true;
    else
        return false;
}

// 
// Remove all whitespaces from before
// and after the value.
//
function Trim(szString) {

    var szTrimCharacter = ' ';
    var szNewString = "";

    // Make a copy of the string to work with
    szNewString = szString;

    // Remove the leading characters
    while (szNewString.charAt(0) == szTrimCharacter) {
        szNewString = szNewString.substring(1,szNewString.length);
    }

    // Remove the trailing characters
    while (szNewString.charAt(szNewString.length - 1) == szTrimCharacter) {
        szNewString = szNewString.substring(0,szNewString.length - 1);
    }

    return szNewString;
}


// 
// Displays an error message
//
function displayErrorMessage(szMsg) {
    bootbox.alert({ title: "Please correct the following error(s)", message: szMsg });
}

// 
// Take a date value and if it has
// a two-digit year, return a 
// four-digit year.
//
function make4DigitYear(szText) {

 	var szDate, aDateElements, szDay, szMonth, szYear,
    szDate = new String(szText);

    iSlash1 = szDate.indexOf("/");
    iSlash2 = szDate.indexOf("/", iSlash1 + 1);

    szMonth = szDate.substring(0, iSlash1);
    szDay = szDate.substring(iSlash1+1,iSlash2);
    szYear = szDate.substring(iSlash2+1);

    if (szYear.length == 2) {
		iYear = parseFloat(szYear);
      	if (iYear > 90) {
       		iYear = iYear + 1900;
       	} else {
       		iYear = iYear + 2000;
       	}
       	szYear = iYear;
    }

    return szMonth + "/" + szDay + "/" + szYear;
}


//
// Determine if a date range is valid.  The
// from date must be before or equal to the
// end date
//
function IsValidDateRange(eFromDate, eToDate) {

	fromValue = Trim(eFromDate.value);
	toValue = Trim(eToDate.value);

	if ((fromValue.length > 0) &&
	    (toValue.length > 0)) {

		var dtFromDate = new Date(make4DigitYear(fromValue));
		var dtToDate = new Date(make4DigitYear(toValue));

		if (dtFromDate > dtToDate) {
			return "An invalid date range has been specified for the " + eFromDate.getAttribute('tsiDisplayName') + " and " + eToDate.getAttribute('tsiDisplayName') + " fields.\n";
		}
	}

	return "";
}


function IsValidDateRange2(eFromDate, eToDate) {

	fromValue = Trim(eFromDate.value);
	toValue = Trim(eToDate.value);

	if ((fromValue.length > 0) &&
		(toValue.length == 0)) {
		return "When a value is specified for the " + eFromDate.getAttribute('tsiDisplayName') + " field, a value is required for the " + eToDate.getAttribute('tsiDisplayName') + " field.";
	}

	if ((toValue.length > 0) &&
		(fromValue.length == 0)) {
		return "When a value is specified for the " + eToDate.getAttribute('tsiDisplayName') + " field, a value is required for the " + eFromDate.getAttribute('tsiDisplayName') + " field.";
	}
	
	if ((fromValue.length > 0) &&
	    (toValue.length > 0)) {

		var dtFromDate = new Date(make4DigitYear(fromValue));
		var dtToDate = new Date(make4DigitYear(toValue));

		if (dtFromDate > dtToDate) {
			return "An invalid date range has been specified for the " + eFromDate.getAttribute('tsiDisplayName') + " and " + eToDate.getAttribute('tsiDisplayName') + " fields.\n";
		}
	}

	return "";
}


function IsValidDateRangeMsg2(eFromDate, eToDate) {
	
	fromValue = Trim(eFromDate.value);
	toValue = Trim(eToDate.value);

	if ((fromValue.length > 0) &&
	    (toValue.length > 0)) {

		var dtFromDate = new Date(make4DigitYear(fromValue));
		var dtToDate = new Date(make4DigitYear(toValue));

		if (dtFromDate > dtToDate) {
			return "- The field " + eFromDate.getAttribute('tsiDisplayName') + " must be earlier than the field " + eToDate.getAttribute('tsiDisplayName') + ".\n";
		}
	}

	return "";
}	


//
// Determine if a numeric range is valid.
// The from number must be less than or
// equal to the to value.
//
function IsValidNumericRange(eFrom, eTo) {

	var fromValue = 0.0;
	var toValue = 0.0;
	
	fromValue = parseFloat(eFrom.value);
	toValue = parseFloat(eTo.value);
	
	if (fromValue > toValue) {
		return "An invalid range has been specified for the " + eFrom.getAttribute('tsiDisplayName') + " and " + eTo.getAttribute('tsiDisplayName') + " fields.\n";
	}

	return "";
}

// 
// Return the number of days in
// month of the specified date.
//
function getDaysInMonth(eDate) {

    var aDaysInMonth = new Array(12);
    aDaysInMonth[0] = 31;
    aDaysInMonth[1] = 28;
    aDaysInMonth[2] = 31;
    aDaysInMonth[3] = 30;
    aDaysInMonth[4] = 31;
    aDaysInMonth[5] = 30;
    aDaysInMonth[6] = 31;
    aDaysInMonth[7] = 31;
    aDaysInMonth[8] = 30;
    aDaysInMonth[9] = 31;
    aDaysInMonth[10] = 30;
    aDaysInMonth[11] = 31;

    var myDate = new Date(eDate.value);
    var month = myDate.getMonth();


    // If this is February
    if ((month == 1) &&
        isLeapYear(eDate))
        daysInMonth = 29;
    else 
        daysInMonth = aDaysInMonth[month];

    return daysInMonth;
}

//
// Determine if the specified
// date is in a leap year.
//
function isLeapYear(eDate) {

    date = new Date(eDate.value);
    year = date.getYear();

    if (year % 100 == 0) {
        if (year % 400 == 0) { 
            return true;    
        }
    } else {
        if ((year % 4) == 0) { 
            return true; 
        }
    }
    
    return false;
}

//
// Compares today's date with the entered date.
// Returns true if the entered date is greater than today's date.
// The passed date should be a valid date in the format ("mm/dd/yyyy")
//
function isFutureDate(szDate)
{
    var current_date = new Date;    
        
	// If we don't find a date separator
	// then it is an invalid date.
    iSlash1 = szDate.indexOf("/");
    if (iSlash1 == -1) {
        return false;
    }

    if (iSlash1 == szDate.length) {
        return false;
    }

	// If we don't find a second date 
	// separator then it is an invalid date.
    iSlash2 = szDate.indexOf("/", iSlash1 + 1);
    if (iSlash2 == -1)  {
        return false;
    }

    szMonth = szDate.substring(0, iSlash1);
    szDay = szDate.substring(iSlash1+1,iSlash2);
    szYear = szDate.substring(iSlash2+1);
        
    var passedDate = new Date(szYear,
                              szMonth-1,
                              szDay);

    if (passedDate > current_date)
    	return true;
    else
    	return false;
    
}

//
// Compares today's date with the entered date.
// Returns true if the entered date is less than today's date.
// The passed date should be a valid date in the format ("mm/dd/yyyy")
//
function isPastDate(szDate)
{
    var current_date = new Date;    
        
    var passedDate = new Date(szDate.substring(6,10),
                              szDate.substring(0,2)-1,
                              szDate.substring(3,5));
                                           
    if (passedDate < current_date)
    	return true;
    else
    	return false;
    
}

//
// Determines if the value is a
// valid Internet e-mail address.
//
function isValidEMail(szEmail) {

	iAtSignCount = 0;
	iPosofAtSign=0;
	iPosofRightMostDot=0;
  	bSpaceFound = false;
  
  	szEmail = Trim(szEmail);
	for(iIndex=0; iIndex <= szEmail.length-1; iIndex++)
	{
		if (szEmail.charAt(iIndex) == '@' )
		{
			iAtSignCount = iAtSignCount + 1;
			iPosofAtSign = iIndex;
		}

		if (szEmail.charAt(iIndex) == '.' )
		{
			iPosofRightMostDot = iIndex;
		}
		
		if (szEmail.charAt(iIndex) == ' ')
		{
		    bSpaceFound = true;
		}
	} // End For

	// If we don''t have a single '@' character or if
	// the "." is not to the right of the '@' then this is
	// not a valid SMTP e-mail address.
	if ((iAtSignCount != 1) ||
	    (iPosofAtSign > iPosofRightMostDot) ||
		(bSpaceFound)) {
		return false;
	}

	return true;
}


//
// Determines if the specified
// phone number is valid.  Do not
// pass in an area code.
function isValidPhone(szPhone) {

	if (szPhone.length == 0) {
		return true;
	}

	if (szPhone.length == 8) {
		szDelimiter = szPhone.charAt(3);
		if ((szDelimiter != "-") &&
			(szDelimiter != ".")) {
			return false;
		}
	
		szExchange = szPhone.substring(0,3);
		szNumber = szPhone.substring(4,8);
	} else if (szPhone.length == 7) {

		szExchange = szPhone.substring(0,3);
		szNumber = szPhone.substring(3,7);

	} else {
		return false;
	}

	
	if (IsValidInteger(szExchange) == false) {
		return false;
	}

	if (IsValidInteger(szNumber) == false) {
		return false;
	}

	if (szExchange == "555") {
		return false;
	}
	
	return true;
}

//
// Checks for both 5 and 9 digit
// zip codes.
//
function isValidZip(szZip) {

	if (szZip.length == 5) {
	
		if (!IsValidInteger(szZip)) {
			return false;
		}
		
	} else if (szZip.length == 10) {
		if (szZip.charAt(5) != "-") {
			return false;
		}

		if (!IsValidInteger(szZip.substring(0,4))) {
			return false;
		}

		if (!IsValidInteger(szZip.substring(6,10))) {
			return false;
		}
	
	} else if (szZip.length == 7) {
		if (szZip.charAt(3) != " ") {
			return false;
		}
		
		if ((!IsValidAlphabetic(szZip.substring(0,1))) ||
			(!IsValidInteger(szZip.substring(1,2)))    ||
		    (!IsValidAlphabetic(szZip.substring(2,3))) || 
		    (!IsValidInteger(szZip.substring(4,5)))    ||
		    (!IsValidAlphabetic(szZip.substring(5,6))) ||
		    (!IsValidInteger(szZip.substring(6,7)))) {
			return false;
		}
	} else {
		return false;
	}
	
	// If we made it this far, then
	// everything is fine.
	return true;
}


// 
// Determines if the value is a valid
// number.  This includes commas, negative
// sign, and decimal point.
//
function IsValidAlphabetic(szText) {
    var iIndex;
    var szValues = "abcdefghijklmnopqrstuvwxyz";
    var bValid = true;

	szLowerText = szText.toLowerCase();
	
	// Iterate through each character
	// in the value.
    for(iIndex=0; (iIndex <= szLowerText.length-1) && (bValid); iIndex++) {
        
		// If we don't find our character in our 
		// valid characters values, it is invalid.
		if (szValues.indexOf(szLowerText.charAt(iIndex)) == -1) {
            bValid = false;
		}
	} // End For

    return bValid;
}

// 
// Determines if the length of the text entered into 
// the text area control has been exceeded.  If so, no longer 
// allow the user to enter characters.  
// NOTE: The maxlength property of multi-line text box controls
// is not applied.
//
function ValidateTextAreaLength(oControl, iMaxLength)
{
    var szValue = oControl.value;
    if(iMaxLength && szValue.length > iMaxLength-1)
    {
          event.returnValue = false;
          iMaxLength = parseInt(iMaxLength);
    }
}


