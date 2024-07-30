<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<!-- #include file ="..\PRTES\PRTESCustomRequestFunctions.asp" -->

<%
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>")
    Response.Write("<script type=\"text/javascript\" src=\"PRTESCustomRequest.js\"></script>")
    var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
    sURL = removeKey(sURL, "em");

    DEBUG("URL: " + sURL); 
    DEBUG("<br>Mode: " + eWare.Mode); 
        
    var lId = new String(Request.Querystring("prtesr_TESRequestId"));
    var szFollowupDate = String(Request.Form.Item("_followupdate"));
    if (szFollowupDate == 'undefined') {
        szFollowupDate = getDateAsString(new Date().setDate(new Date().getDate() + 15));
    }
    
    var iSkipCount = 0;
    var prte_customtesrequest = new String(Request.Querystring("prte_customtesrequest"));
    if (isEmpty(prte_customtesrequest))
    {
        prte_customtesrequest = String(Request.Form.Item("prte_customtesrequest"));
        if (isEmpty(prte_customtesrequest))
        {
            prte_customtesrequest = "";
        }
    }

    // ****  This block handles the selection of the type of custom request to use
    if (eWare.Mode == 0 ) // View
    {

        sTypes = createAccpacBlockHeader("CustomRequestMethods", "Create a Custom TES Request");

        // Set up the Types dropdown
        sSQL = "SELECT capt_code, capt_us FROM custom_captions WHERE capt_familytype = 'Choices' AND capt_family = 'prte_CustomTESRequest' ORDER BY Capt_Order";
        recTypes = eWare.CreateQueryObj(sSQL,"");
        recTypes.SelectSQL();

        var selected = "";

        if (prte_customtesrequest == "") {
            selected = " SELECTED ";
        }

        sTypes += "<table>\n<tr ID=\"tr_customerequesttype\"><td valign=\"top\" ><span class=\"VIEWBOXCAPTION\">Select a Custom TES Request method:</span><br/><span>" +
                  "<select class=\"EDIT\" size=\"1\" name=\"prte_customtesrequest\" id=\"prte_customtesrequest\" onchange=\"onChangeType(this);\" >" +
                        "<option value=\"\" " + selected + ">--None--</option> ";

        while (!recTypes.eof)
        {
            selected = "";
            if (prte_customtesrequest == recTypes("capt_code")) {
                selected = " SELECTED ";
            }
            sTypes += "<option value=\""+ recTypes("capt_code") + "\"" + selected + ">" + recTypes("capt_us") + "</option> ";
            recTypes.NextRecord();
        }
        sTypes += "</select></span></td></tr>\n"

        sTypes += "<tr ID=\"tr_followupdate\"><td><span class=VIEWBOXCAPTION>Task Follow-up Date:</SPAN><br>"
                    + "<input name=\"_followupdate\" value=\"" +szFollowupDate + "\" type=\"TEXT\" class=\"EDIT\" size=\"10\">" 
                    + "</td></tr>\n";

        // This edit box will only show for options 2 and 3
        sTypes += "<tr style=\"visibility:hidden;\" ID=\"tr_requestcount\"><td><span CLASS=VIEWBOXCAPTION>Number of requests to send:</span><br/>"
                    + "<input disabled=\"true\" name=\"_requestcount\" id=\"_requestcount\" value=\"1\" type=\"TEXT\" class=\"EDIT\" size=\"2\">" 
                    + "</td></tr>\n";

        sTypes += "</table>";
        sTypes += createAccpacBlockFooter();
        
        blkTypes = eWare.GetBlock("content");
        blkTypes.Contents = sTypes;

        blkContainer.AddBlock(blkTypes);
    	blkContainer.AddButton(eWare.Button("Process Request", "continue.gif", "javascript:save();"));

    	sCancelUrl = eWare.URL("PRCompany/PRCompanyTESAboutListing.asp") + "&T=Company&Capt=Trade+Activity";
    	blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelUrl));

        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage());
    }
    // ****  This block handles the retrieval and display/storage of the records to be processed
    else if (eWare.Mode == 1) // By default this is edit; we use it for the "Confirmation" screen
    {
        //DumpFormValues();
        recTESToSend = null;
        
        _requestcount = String(Request.Form.Item("_requestcount"));
        if (isEmpty(_requestcount))
        {
            _requestcount = 1;
        }
        
        prte_customtesrequest = String(Request.Form.Item("prte_customtesrequest"));
        
        if (prte_customtesrequest == "1") 
        {
            sSQL = "SELECT * FROM dbo.ufn_GetCustomTESOption1(" + comp_companyid + ");"
        }
        else if (prte_customtesrequest == "2")
        {
            sSQL = "SELECT TOP " + _requestcount + " *, NEWID() As UID " + 
                   "  FROM dbo.ufn_GetCustomTESOption2(" + comp_companyid + ") " +
                   "ORDER BY prcr_Tier, UID;"
        }
        else if (prte_customtesrequest == "3")
        {
            sSQL = "SELECT TOP " + _requestcount + " *, NEWID() As UID " + 
                   "  FROM ufn_GetCustomTESOption3(" + comp_companyid + ") " +
                   "ORDER BY prcr_Tier, UID;"
        }
        else if (prte_customtesrequest == "4")
        {
            sSQL = "SELECT * " + 
                   "  FROM dbo.ufn_GetCustomTESOption4(" + comp_companyid + ");"
        }
        else if (prte_customtesrequest == "5")
        {
            // Custom TES Option 5 uses a filter panel to restict the results
            // add the filter and determine if any fields were entered 
%>
<!-- #include file ="PRTESCustomRequestFilter.asp" --> 
<%
            blkContainer.AddBlock(blkFilter);
            
            // sDBStartDate, sDBEndDate, sDBListingStatus are defined in PRTESCustomRequestFilter 
            // Get a list of companies with a relationship and let the user decide which ones get TES requests
	        sSQL = "SELECT * FROM dbo.ufn_GetCustomTESOption5 (" + comp_companyid + ", " 
	                                                             + sDBStartDate + ", " 
	                                                             + sDBEndDate + ", " 
	                                                             + sDBType + ", " 
	                                                             + sDBListingStatus + ")";
        }
        else if (prte_customtesrequest == "6")
        {
            // Custom TES Option 6 uses a filter panel to restict the results
            // add the filter and determine if any fields were entered 
%>
<!-- #include file ="PRTESCustomRequest6Filter.asp" --> 
<%
            blkContainer.AddBlock(blkFilter);
            
            // sDBStartDate, sDBEndDate, sDBListingStatus are defined in PRTESCustomRequestFilter 
            // Get a list of companies with a relationship and let the user decide which ones get TES requests
	        sSQL = "SELECT * FROM dbo.ufn_GetCustomTESOption6 (" + comp_companyid + ", " 
	                                                             + sDBStartDate + ", " 
	                                                             + sDBEndDate + ", " 
	                                                             + sDBType + ", " 
	                                                             + sDBListingStatus + ", "
                                                                 + sDBConnectionListOnly + ")";

            //Response.Write("<p>" + sSQL);
        }
        recTESToSend = eWare.CreateQueryObj(sSQL);
        recTESToSend.SelectSQL();
        
        if (prte_customtesrequest == null || isEmpty(prte_customtesrequest))
        {
            //Response.Write("<br/>Redirecting back to listing because prte_customtesrequest is empty.");
           // Response.Redirect(eWare.URL("PRCompany/PRCompanyTESAboutListing.asp") + "&T=Company&Capt=Trade+Activity");
        }
        else         
        {
            sCompanyIds = "";
            nRecordCount = 0;
            
            if (recTESToSend != null && recTESToSend.RecordCount != 0)
            {
                nRecordCount = recTESToSend.RecordCount;
                while (!recTESToSend.eof)
                {
                    if (sCompanyIds != "")
                        sCompanyIds += ",";
                    sCompanyIds += recTESToSend("prtesr_respondercompanyid");

                    recTESToSend.Next();
                }

                // reset the query back to the first record in the collection
                while (!recTESToSend.bof)
                {
                    recTESToSend.Previous();
                }
                recTESToSend.Next();
                
            }
            
            
            blkListing = eWare.GetBlock("content");
            sContent = "\n<input type=\"HIDDEN\" name=\"_HIDDENcompanyids\" id=\"_HIDDENcompanyids\" value=\"" + sCompanyIds + "\">";
            sContent += "\n<input type=\"HIDDEN\" name=\"_follupdate\" id=\"_follupdate\" value=\"" + szFollowupDate + "\">\n";
          
            szTabLabel = nRecordCount + " Companies to Receive Surveys";
            
            sContent += createAccpacBlockHeader("TESToCreate", szTabLabel);

            // we need to repeat the customtesrequest value in case Apply Filter is pressed
            if ((prte_customtesrequest == "5") ||
                (prte_customtesrequest == "6")) 
            {
                sContent += "<input type=HIDDEN name=\"prte_customtesrequest\" value=\"" + prte_customtesrequest + "\">";
            }

            if (nRecordCount > 0)
            {
                // this option allows custom selection of the companies to send a TES Request
                if ((prte_customtesrequest == "5") ||
                    (prte_customtesrequest == "6")) 
                {
                    sContent += "\n\n<table WIDTH=\"100%\" ID=\"_tbl_TESCustomSelection\" border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff >";
                    sContent += "\n<thead";
                    sContent += "\n<tr>";
                    sContent += "\n<td class=\"GRIDHEAD\" align=\"center\">Select<br/><input type=\checkbox\ id=\"cbAll\" onclick=\"CheckAll('_chk_', this.checked);\"></td> ";
                    sContent += "<td class=\"GRIDHEAD\" align=\"center\">BBID</td> ";
                    sContent += "<td class=\"GRIDHEAD\">Company Name</td> ";
                    sContent += "<td class=\"GRIDHEAD\">Location</td> ";
                    sContent += "<td class=\"GRIDHEAD\">Relationship<br/>Types</td> ";
                    sContent += "<td class=\"GRIDHEAD\">Listing<br/>Status</td> ";

                    if (prte_customtesrequest == "5") {
                        sContent += "<td class=\"GRIDHEAD\" align=\"center\">Last<br/>TES Sent</td> ";
                    }

                    if (prte_customtesrequest == "6") {
                        sContent += "<td class=\"GRIDHEAD\" align=\"center\">Last TES Sent<br/>to Subject</td> ";
                    }

                    sContent += "<td class=\"GRIDHEAD\" align=\"center\">Last<br/>Updated</td> ";
                    
                    sContent += "<td class=\"GRIDHEAD\">Delivery<br/>Address</td>" 
                    
                    sContent += "\n</tr>";
                    sContent += "\n</thead>";
                    sClass = "ROW1";
                    while (!recTESToSend.eof)
                    {
                        if (sClass == "ROW2") {
                            sClass = "ROW1";
                        } else {
                            sClass = "ROW2";
                        }


                        sID = recTESToSend("prtesr_ResponderCompanyId");
                        sName = recTESToSend("comp_Name");
                        sCityStateCountryShort = recTESToSend("CityStateCountryShort");
                        if (isEmpty(sCityStateCountryShort))
                            sCityStateCountryShort = "&nbsp;";
                        sListingStatus = recTESToSend("comp_prlistingstatus");
                        if (isEmpty(sListingStatus))
                            sListingStatus = "&nbsp;";
                        sTypes = recTESToSend("prcr_Types");
                        if (isEmpty(sTypes))
                            sTypes = "&nbsp;";
                        
                        
                        sLastTES = "";
                        if (prte_customtesrequest == "5") {
                            sWork = new String(recTESToSend("prtesr_SentDateTimeMAX"));
                            if (isEmpty(sLastTES))
                                sWork = "&nbsp;";
                            else
                                sWork = getDateAsString(sLastTES);

                            sLastTES = "<td class=" + sClass + " align=\"center\">" + sWork + "</td>";
                        }

                        sLastUpdate = new String(recTESToSend("prcr_LastUpdatedMAX"));
                        if (isEmpty(sLastUpdate))
                            sLastUpdate = "&nbsp;";
                        else
                            sLastUpdate = getDateAsString(sLastUpdate);


                        sLastTESSentToSubject = "";
                        if (prte_customtesrequest == "6") {
                            sWork = new String(recTESToSend("prtesr_SentDateTimeSubject"));
                            if (isEmpty(sLastUpdate))
                                sWork = "&nbsp;";
                            else
                                sWork = getDateAsString(sWork);

                           sLastTESSentToSubject = "<td class=" + sClass + " align=\"center\">" + sWork + "</td>";
                        }

                        sCheckbox = "<input type=\"checkbox\" ID=\"_chk_" + sID + "\" name=\"_chk_" + sID + "\">";
                        sDeliveryAddress = recTESToSend("DeliveryAddress")
                        if (sDeliveryAddress == null) {
                            sDeliveryAddress = "&nbsp;";
                            sCheckbox = "";
                        }
                        
                        sContent += "\n<tr>"
                                + "<td class=" + sClass + " valign=top align=\"center\" id=\"_tdchk_"+ sID + "\" >" + sCheckbox + "</td>"
                                + "<td class=" + sClass + " align=\"center\">" + sID + "</td>" 
                                + "<td class=" + sClass + ">" + sName + "</td>" 
                                + "<td class=" + sClass + ">" + sCityStateCountryShort + "</td>" 
                                + "<td class=" + sClass + ">" + sTypes + "</td>" 
                                + "<td class=" + sClass + ">" + sListingStatus + "</td>" 
                                + sLastTES
                                + sLastTESSentToSubject
                                + "<td class=" + sClass + " align=\"center\">" + sLastUpdate + "</td>"
                                + "<td class=" + sClass + " >" + sDeliveryAddress + "</td>" ;
                                
                        sContent += "</tr>";
                        recTESToSend.NextRecord();
                    }
                    sContent += "\n</table>" 
                }
                else
                {
                    sContent = sContent + createAccpacListBody("TESCustomRequestGrid", null, recTESToSend, null, null );
                }
            }
            else
            {
                sContent += "\n<table WIDTH=\"100%\"  >";
                sContent += "\n<tr><td align=\"center\" class=\"ROW2\">" +
                                "No Companies match the selected criteria." + "</td></tr>";
                sContent += "\n</table>"
            }
            
            sContent = sContent + createAccpacBlockFooter();
            blkListing.Contents=sContent;
            blkContainer.AddBlock(blkListing);

            if ((nRecordCount > 0) && (iSkipCount != nRecordCount))
            {
                sConfirmLink = eWare.URL("PRTES/PRTESCustomRequest.asp")+"&mode=2" + "&T=Company&Capt=Trade+Activity";
        	    blkContainer.AddButton(eWare.Button("Confirm", "continue.gif", "javascript:document.EntryForm.action='"+sConfirmLink+"';save();"));
            }
    	    sCancelUrl = eWare.URL("PRTES/PRTESCustomRequest.asp") + "&T=Company&Capt=Trade+Activity";
    	    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelUrl));
        }
        
        eWare.AddContent(blkContainer.Execute());

        Response.Write(eWare.GetPage());
        
        if (prte_customtesrequest == "5")
        {
            Response.Write("\n<script type=\"text/javascript\">");
            Response.Write("\n    document.body.onload=function()"); 
            Response.Write("\n    {");
            Response.Write("\n        removeInvalidDropdowns();");
            Response.Write("\n        document.all(\"_startdate\").value = \"" + sFormStartDate + "\";");
            Response.Write("\n        document.all(\"_enddate\").value = \"" + sFormEndDate  + "\";");
            Response.Write("\n        setDropdownValue(\"prcr_type\", \"" + prcr_type + "\");");
            Response.Write("\n        setDropdownValue(\"comp_prlistingstatus\", \"" + comp_prlistingstatus + "\");");
            // Be nice and call the Accpac default onLoad routine
            //Response.Write("\n        LoadComplete('');");
            Response.Write("\n    }");
            Response.Write("\n</script>");
        }   
        
        if (prte_customtesrequest == "6")
        {
            Response.Write("\n\n<script type=\"text/javascript\">");
            Response.Write("\n    document.body.onload=function()"); 
            Response.Write("\n    {");
            Response.Write("\n        removeInvalidDropdowns();");
            Response.Write("\n        document.all(\"prtesr_sentdatetime_start\").value = \"" + sFormStartDate + "\";");
            Response.Write("\n        document.all(\"prtesr_sentdatetime_end\").value = \"" + sFormEndDate  + "\";");
            Response.Write("\n        setDropdownValue(\"prcr_type\", \"" + prcr_type + "\");");
            Response.Write("\n        setDropdownValue(\"comp_prlistingstatus\", \"" + comp_prlistingstatus + "\");");
            // Be nice and call the Accpac default onLoad routine
            //Response.Write("\n        LoadComplete('');");
            Response.Write("\n    }");
            Response.Write("\n</script>");
        }             
    }
    else if (eWare.Mode == 2) // saving the records
    {
        var szCompanyIDs = Request.Form.Item("_HIDDENcompanyids");
        var szMessage = null;
        
        //Response.Write("<p>prte_customtesrequest:" + prte_customtesrequest);

        if (prte_customtesrequest == "6")
        {
            szMessage = createTES2(comp_companyid, szCompanyIDs, null, szFollowupDate, user_userid, "Y");
        } else {
            szMessage = createTES(comp_companyid, szCompanyIDs, null, szFollowupDate, user_userid);
        }

        Response.Redirect(eWare.URL("PRCompany/PRCompanyTESAboutListing.asp"));
    }



%>
<!-- #include file ="..\PRCompany\CompanyFooters.asp" -->
