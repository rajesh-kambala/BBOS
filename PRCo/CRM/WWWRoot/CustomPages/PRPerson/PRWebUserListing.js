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

function initPersonAdvancedSearch()
{
	oUnconfirmed = document.EntryForm.pers_prunconfirmed;
	var oParentTable = null;
	var oParentRow = null;
	if (oUnconfirmed){
		oParentRow = oUnconfirmed.parentElement;
		while (oParentRow != null && oParentRow.tagName != "TR")
			oParentRow = oParentRow.parentElement;
		if (oParentRow != null) {
            oParentTable = oParentRow.parentElement;
            while (oParentTable.rows.length > 0)
                oParentTable.removeChild(oParentTable.rows[0]);
                
            var newTR = document.createElement("TR");
            var newTD = document.createElement("TD");
            newTD.className = "VIEWBOXCAPTION";
            newTD.innerHTML = "Unconfirmed:&nbsp;";
            newTR.insertBefore(newTD)
            oParentTable.insertBefore(newTR);
            
            newTD = document.createElement("TD");
            newTD.className = "VIEWBOXCAPTION";
            newTD.innerHTML = "<SELECT class=EDIT size=1 id=\"pers_prunconfirmed\" name=\"pers_prunconfirmed\"><OPTION Value=\"Y\">Yes</OPTION><OPTION Value=\"N\">No</OPTION><OPTION Value=\"\">--ALL--</OPTION></SELECT>";
            newTR.insertBefore(newTD)
            oParentTable.insertBefore(newTR);
            SelectDropdownItemByValue("pers_prunconfirmed", szUnconfirmed);
		}
	}
}