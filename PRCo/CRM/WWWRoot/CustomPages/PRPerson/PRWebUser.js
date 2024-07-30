/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Produce Reporter Company, Inc.
 
***********************************************************************
***********************************************************************/
/*
	Author: Tad M. Eness
*/
(function() {
    // ACCPAC CRM mode constants
    var View = 0, Edit = 1, Save = 2, PreDelete = 3, PostDelete = 4, Clear = 6;
    var Find = 2;

    var initBBSI = function () {
        var mode = document.getElementById('prwu_bbid') ? Edit : View; // look for edit field, if found then we are editing.
        var email_sent = document.getElementById('hdnEmailSent');

        switch (mode) {
            case View:

                if (document.all("_Captprwu_disabled") != null) {
                    InsertDivider("User Summary", "_Captprwu_disabled");
                } else {
                    InsertDivider("User Summary", "_Captprwu_lastname");
                }

                InsertDivider("Usage Summary", "_Captprwu_accesslevel");
                if (email_sent && Number(email_sent.value)) {
                    alert('Password has been emailed to user.');
                }
                break;

            case Edit:
                // There's a dropdown on the page with the person's connected
                // to the current company.
                AppendCell("_Captprwu_personlinkid", "_ddlPersonLink", true);
                var personlinkid = document.getElementById("prwu_personlinkid");

                var ddl = document.getElementById("_ddlPersonLink");
                if (ddl) {
                    ddl.style.display = "inline";
                }

                var ddlpersonlink = document.getElementById("ddlPersonLink");
                if (ddlpersonlink) {
                    ddlpersonlink.onchange = ddlPersonLink_Changed;
                }

                // Hide the original PersonLinkID field.
                // We'll use the dropdown created for this
                // Climb up to the td tag to hide it
                if (personlinkid) {
                    var tr = personlinkid.parentElement;
                    while ((tr != null) && (tr.tagName != "TD")) {
                        tr = tr.parentElement;
                    }
                    if (tr.tagName == "TD") {
                        tr.style.display = "none";
                    }
                }

                BBID_Changed(); 	// Initial list

                break;
        }
    }

    if (window.addEventListener) {
        window.addEventListener("load", initBBSI); // Firefox, etc
    } else {
        window.attachEvent("onload", initBBSI); 	// ie
    }
})();

function ddlPersonLink_Changed(evt) {
	evt = (evt) ? evt : ((event) ? event : null);
	var ddl = evt.srcElement;
	var prwu_personlinkid = document.getElementById("prwu_personlinkid");
	
	if (prwu_personlinkid && ddl.selectedIndex > -1) {
		prwu_personlinkid.value = ddl.options[ddl.selectedIndex].value;
	}
}

function BBID_Changed () {
	var prwu_bbid = document.getElementById("prwu_bbid");
	var url = document.getElementById("hdnWebUserDataURL").value + "&Action=PersonList&CompanyID=" + prwu_bbid.value;
	
	// First, clear the person link drop down
	var ddlpersonlink = document.getElementById("ddlPersonLink");
	ddlpersonlink.options.length = 0;

	// Next, send a request for persons
	window.WebUserXMLHTTP = GetXmlHttpObject();
	var h = window.WebUserXMLHTTP;
	h.onreadystatechange = WebUserDataResponse;
	var r = h.open("GET", url, true);
	h.send(null);
}

function WebUserDataResponse() {
	var ddlpersonlink = document.getElementById("ddlPersonLink");
	
	var h = window.WebUserXMLHTTP;
	if (h.readyState == 4) {
		if (h.status == 200) {
			// Repopulate the person list with the response
			// make sure that the response starts and ends with brackets
			// Expecting a newline delimited list of items, each subitem is tab delimited
			// massage this a little.
			var r = h.responseText;
			if (r) {
				r = r.replace(/^\s*/, '').replace(/\s*$/, '').replace(/\n*/, '');
			}

			ddlpersonlink.options.length = 0;
			var opt = document.createElement("OPTION");
			opt.text = "-- None --";
			opt.value = "0";
			ddlpersonlink.options.add(opt);
			if (r.length > 0) {
				var person_list = r.split("\n");
				while (person_list.length > 0) {
					var person = person_list.shift().split("\t");
					// Selected is 0th element
					// Person_LinkID is 1st element
					// Name is 2nd element
					var opt = document.createElement("OPTION");
					ddlpersonlink.options.add(opt);
					opt.text = person[2];
					opt.value = person[1];
					opt.selected = (person[0] == 1);
				}
			}
		}
	}
}
