/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
function isEmpty(sValue)
{
	if (sValue == null || sValue.toString() == "undefined" || sValue == "" )
	  return true;
	return false;
}
function PrintWindow()
{
	window.print();
}

function onPhoneTypeChange()
{
    handleOnPhoneTypeChange(window.event.srcElement);
}
function handleOnPhoneTypeChange(selType)
{
    txtDescription = document.all("phon_prdescription");
    if (selType != null)
    {
        if (selType.selectedIndex < 0)
            txtDescription.value = "";
        else 
        {
            sTypeCode = selType.options[selType.selectedIndex].value;
            sType = selType.options[selType.selectedIndex].innerText;
            //initial load; do not change what was there previously
            if (window.event.srcElement != null)
            {
                if ( sTypeCode == "P" )
                    txtDescription.value = "Phone";
                else if ( sTypeCode == "F" )
                    txtDescription.value = "FAX";
                else if ( sTypeCode == "PF" )
                    txtDescription.value = "Phone or FAX";
                else if ( sTypeCode == "TF" )
                    txtDescription.value = "Toll Free";
                else if ( sTypeCode == "S" )
                    txtDescription.value = "Sales";
                else if ( sTypeCode == "SF" )
                    txtDescription.value = "Sales FAX";
                else if ( sTypeCode == "TP" )
                    txtDescription.value = "Trucker";
                else if ( sTypeCode == "C" )
                    txtDescription.value = "Cell";
                else if ( sTypeCode == "PA" )
                    txtDescription.value = "Pager";
                else 
                    txtDescription.value = "";
            }        
            // get the labels
            arrLabels = document.body.getElementsByTagName("LABEL");
            for (n=0; n<arrLabels.length; n++)
            {
                if (arrLabels[n].htmlFor == "_IDphon_default")
                {
                    if ((sTypeCode == "F")||
                        (sTypeCode == "SF"))
                        arrLabels[n].innerText = "Default FAX";
                    else if (sTypeCode == "PF")
                        arrLabels[n].innerText = "Default Phone or FAX";
                    else    
                        arrLabels[n].innerText = "Default Phone";
                    break;                
                }
            }
                
        }
    }

} 
function RedirectCompany()
{
	var sUrl= String( location.href );

	iEWare = sUrl.indexOf("eware.dll");
	var sApp = String (sUrl.substring(0, iEWare));

	iQMark = sUrl.indexOf("?");
	var sQuery = String (sUrl.slice(iQMark, sUrl.length));

	var sAction = String(""); 
	ndx = sQuery.indexOf("&Act=");
	if (ndx >= 0 )
	{
		ndxNext = sQuery.indexOf("&", ndx+5);

		sAction = sQuery.substring(ndx+5, ndxNext);
		if (sAction == "140" || sAction == "166" || sAction == "1200")
		{
			sQuery = removeKey(sQuery,"Act");
			sQuery = removeKey(sQuery,"Key0");
			sQuery = removeKey(sQuery,"Key1");
			sQuery = removeKey(sQuery,"comp_companyid");
			//sQuery = sQuery.substring(0,ndx) + sQuery.substring(ndxNext,sQuery.length);
			location.href = sApp + "CustomPages/PRCompany/PRCompanyNew.asp"+sQuery;	    
		}
		else if (sAction == "160" || sAction == "200" || sAction == "520")
		{
		    sQuery = removeKey(sQuery, "Act");
		    sQuery = removeKey(sQuery, "Key0");
		    sQuery = removeKey(sQuery, "Key1");
		    sQuery = removeKey(sQuery, "T");
		    sQuery = removeKey(sQuery, "comp_companyid");
		    sQuery = removeKey(sQuery, "Comp_Companyid");
		    sQuery = removeKey(sQuery, "Comp_CompanyId");
		    sQuery = removeKey(sQuery, "comp_CompanyId");
		    sQuery = removeKey(sQuery, "Comp_companyId");
		    
			location.href = sApp + "CustomPages/PRCompany/PRCompanySummary.asp"+sQuery+"&T=Company"+GetKeys()+"&J=PRCompany/PRCompanySummary.asp";	    
		}
	}
	return;
}

