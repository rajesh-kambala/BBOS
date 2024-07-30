//***********************************************************************
//***********************************************************************
// Copyright Produce Reporter Co. 2007
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
// Filename:		bbos.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>



function CheckEmailAddress(e) {
	if (e.checked) {
		var txtEmail = document.getElementById('txt' + e.value);
		
		if (txtEmail.value == '') {
			displayErrorMessage("The person must have an email address before they can be selected.");
			e.checked = false;
		}
		
		var szPersonID = e.getAttribute('PersonID')
	}
	
	var colTRs = document.getElementsByTagName('TR');
	for (i = 0; i < colTRs.length; i++) {

		if (colTRs[i].getAttribute('ID') == e.getAttribute('PersonID')) {

			if (colTRs[i].getAttribute('person_linkID') != e.value) {
				
				if (e.checked) {
					//colTRs[i].disabled = true;
					
					colTRs[i].cells[0].disabled = true;
					colTRs[i].cells[1].disabled = true;
					colTRs[i].cells[2].disabled = true;
					colTRs[i].cells[3].disabled = true;
					colTRs[i].cells[4].disabled = true;
					
				} else {
					//colTRs[i].disabled = false;				

					colTRs[i].cells[0].disabled = false;
					colTRs[i].cells[1].disabled = false;
					colTRs[i].cells[2].disabled = false;
					colTRs[i].cells[3].disabled = false;
					colTRs[i].cells[4].disabled = false;

				}
			}
		}
	}	
	
}

function CheckCheckbox(e) {
	if (e.value == '') {
		var checkbox = document.getElementById('cb' + e.getAttribute('person_linkID'));
		checkbox.checked = false;
		CheckEmailAddress(checkbox)
	}
}



var szClass = "";
function highlightRow(obj, newClass) {
    if (obj.className != "colHeader") {
	    szClass = obj.className;
	    obj.className = newClass;
	}
}

function restoreRow(obj) {
    if (obj.className != "colHeader") {
	    obj.className = szClass;
	}
}

function EnableRowHighlight(objTable) {

    if (objTable == undefined) {
        return;
    }

	var rows = objTable.getElementsByTagName('tr');
    for (iRowIndex = 0; iRowIndex < rows.length; iRowIndex++) {

        rows[iRowIndex].onmouseover = 	function() {
            highlightRow(this, 'highlightrow');
        }

        rows[iRowIndex].onmouseout = function() {
			restoreRow(this, '');		
		}
    }
}


function CheckEmailOnLoad(e) {
	var colTRs = document.getElementsByTagName('TR');
	for (i = 0; i < colTRs.length; i++) {
		if (colTRs[i].getAttribute('ID') == e.getAttribute('PersonID')) {
			if (colTRs[i].getAttribute('person_linkID') != e.value) {
				if (e.checked) {
					//colTRs[i].disabled = true;
					
					colTRs[i].cells[0].disabled = true;
					colTRs[i].cells[1].disabled = true;
					colTRs[i].cells[2].disabled = true;
					colTRs[i].cells[3].disabled = true;
					colTRs[i].cells[4].disabled = true;
					
				} else {
					//colTRs[i].disabled = false;				

					colTRs[i].cells[0].disabled = false;
					colTRs[i].cells[1].disabled = false;
					colTRs[i].cells[2].disabled = false;
					colTRs[i].cells[3].disabled = false;
					colTRs[i].cells[4].disabled = false;

				}
			}
		}
	}	
}

function OnLoad() {

	var oCheckboxes = document.body.getElementsByTagName("INPUT");
	 
	for(var i = 0; i < oCheckboxes.length; i++) {
		if (oCheckboxes[i].type == "checkbox") {
		    oCheckbox = oCheckboxes[i];
            
            if (oCheckbox.checked) {
                CheckEmailOnLoad(oCheckbox);
            }
		}
	}
}