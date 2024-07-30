var xmlHttpCheckDupLicenseRequest = null;
function checkDupLicense(redirectUrl) {
    // For some reason this hidden field appears twice on this page, thus treat it as an array                
    var sLicenseNumber = new String (document.all("_HIDDENpril_licensenumber")[0].value);

    xmlHttpCheckDupLicenseRequest = new XMLHttpRequest();
    xmlHttpCheckDupLicenseRequest.onreadystatechange = HandleDupLicense;
    xmlHttpCheckDupLicenseRequest.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/PRImportPACADupCheck?LicenseNumber=" + sLicenseNumber + "&redirectUrl=" + encodeURIComponent(redirectUrl), true);
    xmlHttpCheckDupLicenseRequest.send();

    return false;
}

function HandleDupLicense() {
    if (xmlHttpCheckDupLicenseRequest.readyState == 4) {
        if (xmlHttpCheckDupLicenseRequest.responseXML != null) {
            var result = $(xmlHttpCheckDupLicenseRequest.responseText)[2].innerText;

            var obj = jQuery.parseJSON(result);
            if (obj.DuplicateExists) {
                alert("License Number " + obj.LicenseNumber + " has already been associated with \""
                    + obj.CompanyName + "\". However, this is not the company's most current license. "
                    + "Please review the PACA licenses associated with BBID " + obj.CompanyId + ". "
                    + "To override the license for this company, use the \"Existing PACA License\" button.");
                return false;
            }
            else {
                location.href = obj.RedirectUrl;
            }

            return true;
        }
    }
}

var xmlHttpCheckActiveLicenseRequest = null;    
function checkActiveLicense(redirectUrl, saveLink) {                                  
    var sCompanyID = new String ($("#prpa_companyid").val());

    xmlHttpCheckActiveLicenseRequest = new XMLHttpRequest();
    xmlHttpCheckActiveLicenseRequest.onreadystatechange = HandleActiveLicense;
    xmlHttpCheckActiveLicenseRequest.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/PRImportPACAActiveCheck?CompanyID=" + sCompanyID + "&redirectUrl=" + encodeURIComponent(redirectUrl) + "&saveLink=" + encodeURIComponent(saveLink), true);
    xmlHttpCheckActiveLicenseRequest.send();

    return false;
}

function HandleActiveLicense() {
    if (xmlHttpCheckActiveLicenseRequest.readyState == 4) {
        if (xmlHttpCheckActiveLicenseRequest.responseXML != null) {
            var result = $(xmlHttpCheckActiveLicenseRequest.responseText)[2].innerText;

            var obj = jQuery.parseJSON(result);
            if (obj.IsCurrent) {
                bReturnValue = confirm("The specified company already has an active PACA license number.  Do you want to save this record anyway?");
                if (bReturnValue) {
                    document.EntryForm.action = obj.SaveLink;
                    document.EntryForm.submit();
                }
            }
            else {
                document.EntryForm.action = obj.SaveLink;
                document.EntryForm.submit();
            }

            return true;
        }
    }
}

function validateAssignCompany()
{
    var sErrors = "";

    if (document.EntryForm.prpa_companyid.value =='') {
        sErrors += "Assigned company must be entered.\n";
    }

    if (sErrors != "")  {
        alert(sErrors);
        return false;
    }

    return true;
}
