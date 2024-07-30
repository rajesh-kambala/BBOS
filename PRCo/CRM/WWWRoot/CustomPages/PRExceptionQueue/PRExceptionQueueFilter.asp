<%
    //DumpFormValues();
	var blkFilter = eWare.GetBlock("ExceptionQueueFilterBox");
	blkFilter.Title = "Filter By";

	var entryExceptionType = blkFilter.getEntry("preq_Type");
	entryExceptionType.Caption = "Exception Type:";
	entryExceptionType.LookupFamily = "preq_Type_SearchOption";

	var entryCompanyType = blkFilter.getEntry("comp_PRType");
	entryCompanyType.Caption = "Company Type:";

	// set the default values for all the fields that get 
	// passed to the query
	var sDBStartDate = "NULL";
	var sDBEndDate = "NULL";
	var sDBAssignedUserId = "NULL";
	var sDBExceptionType = "NULL";
	var sDBCompanyType = "NULL";
	var sDBIndustryType = "NULL";
	var sDBStatus = "NULL";
    var sDBTMFM = "";
    var tmfmAward = "";

	// if the search button has been pressed, determine 
	// what search values have been entered and pass them 
	// on to the query
	if (eWare.Mode == Find) {
    	sFormStartDate = getFormValue("preq_date_start");
    	if (!isEmpty(sFormStartDate))
    		sDBStartDate = "'" + getDBDate(sFormStartDate) + "'";
    	sFormEndDate = getFormValue("preq_date_end");
    	if (!isEmpty(sFormEndDate))
    		sDBEndDate = "'" + getDBDate(sFormEndDate) + " 23:59:59'";

	    preq_type = getFormValue("preq_type");
	    if (!isEmpty(preq_type))
	    {
	        sDBExceptionType = "'" + preq_type + "'"; 
        }

	    preq_status = getFormValue("preq_status");
	    if (!isEmpty(preq_status))
	    {
		    sDBStatus = "'" + preq_status + "'"; 
	    }

	    comp_prtype = getFormValue("comp_prtype");
	    DEBUG(comp_prtype );
	    if (!isEmpty(comp_prtype))
	    {
		    sDBCompanyType = "'" + comp_prtype + "'"; 
	    }
	    comp_prindustrytype = getFormValue("comp_prindustrytype");
	    if (!isEmpty(comp_prindustrytype))
	    {
		    sDBIndustryType = "'" + comp_prindustrytype + "'"; 
	    }


        tmfmAward = getFormValue("tmfmFilter");
	    if (!isEmpty(tmfmAward))
	    {
            if (tmfmAward == "O") {
    		    sDBTMFM = "comp_PRTMFMAward = 'Y'"; 
            }

            if (tmfmAward == "E") {
    		    sDBTMFM = "comp_PRTMFMAward IS NULL"; 
            }
	    }
        

	} else {
	    sDBStatus = "'O'"; 
	    sDBExceptionType = "'TESAR'"; 
	}

    // Always apply the user ID filter
    if (key0 == 4){
        sDBAssignedUserId = user_userid;
    } else {
        preq_assigneduserid = getFormValue("preq_assigneduserid");
        if (!isEmpty(preq_assigneduserid)) {
        
            if (preq_assigneduserid == "#USER#") {
                sDBAssignedUserId = user_userid;
            } else {
                sDBAssignedUserId = preq_assigneduserid;
            }
        }
    }


    var tmfmFilter = "<table style=\"{display:none}\"><tr id=\"tr_tmfmFilter\"><td id=\"td_tmfmFilter\" class=\"VIEWBOXCAPTION\">";
    tmfmFilter += "<span class=VIEWBOXCAPTION>TM/FM Award:&nbsp;</SPAN>";
    tmfmFilter += "<select id='tmfmFilter' name='tmfmFilter' class=EDIT>";

    var selected = "";
    if (tmfmAward == "") {
        selected = " selected='true' ";
    }
    tmfmFilter += "<option value='' " + selected + ">--All--</option>";

    selected = "";
    if (tmfmAward == "O") {
        selected = " selected='true' ";
    }
    tmfmFilter += "<option value='O' " + selected + ">TM/FM Only</option>";

    selected = "";
    if (tmfmAward == "E") {
        selected = " selected='true' ";
    }
    tmfmFilter += "<option value='E' " + selected + ">Exclude TM/FM</option>";
    tmfmFilter += "</select>";
    tmfmFilter += "</td></tr></table>" ;

    //Response.Write(tmfmFilter);

    var blkStatusDisplay = eWare.GetBlock('content');
    blkStatusDisplay.contents = tmfmFilter;
    
    var sCustomFieldsDraw = " AppendCell(\"CAPTcomp_prindustrytype\", \"td_tmfmFilter\");\n";

	// build the where cluase based upon the current user, the user's security, and the filter criteria

	var sGridFilterWhereClause = "";
	var sGridFilterInnerWhereClause = "";
	if (sDBAssignedUserId != "NULL")
		sGridFilterWhereClause = "preq_AssignedUserId =" + sDBAssignedUserId;
	if (sDBStartDate != "NULL")
		sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "preq_Date >= " + sDBStartDate;
	if (sDBEndDate != "NULL")
		sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "preq_Date <= " + sDBEndDate;
	if (sDBStatus != "NULL")
		sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "preq_status = " + sDBStatus;
	if (sDBExceptionType != "NULL") {
		sGridFilterInnerWhereClause = "WHERE preq_Type In (" + (sDBExceptionType == "'TESAR'" ? "'TES', 'AR'" : sDBExceptionType) + ")";
	    if (sDBExceptionType == "'TESAR'")
		    sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "preq_Type in ('TES', 'AR') " ;
	    else
		    sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "preq_Type = " + sDBExceptionType;
	}
	if (sDBCompanyType != "NULL")
		sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "comp_PRType = " + sDBCompanyType;
	if (sDBIndustryType != "NULL")
		sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "comp_PRIndustryType = " + sDBIndustryType;

    if (sDBTMFM != "") {
        sGridFilterInnerWhereClause += (sGridFilterInnerWhereClause == ""?"":" AND ") + sDBTMFM;
        
    }

	// now create the formload section to reload all the values with the submitted values
	sFormLoadCommands = "";
	sFormLoadCommands += "RemoveDropdownItemByName('preq_type', '--None--');\n";
	sFormLoadCommands += "RemoveDropdownItemByName('comp_prtype', '--None--');\n";
	sFormLoadCommands += "RemoveDropdownItemByName('comp_prindustrytype', '--None--');\n";
	sFormLoadCommands += "RemoveDropdownItemByName('comp_prindustrytype', 'Supply and Service');\n";
	sFormLoadCommands += "RemoveDropdownItemByName('preq_assigneduserid', '--None--');\n";
	sFormLoadCommands += "RemoveDropdownItemByName('preq_status', '--None--');\n";
    sFormLoadCommands += "AppendCell(\"_Datacomp_prindustrytype\", \"td_tmfmFilter\");\n";

	// if there isn't a value, set the default
	if (eWare.Mode == 0)
	{  
		sFormLoadCommands += "if (document.EntryForm._HIDDENpreq_type.value == '') SelectDropdownItemByValue('preq_type', 'TESAR');\n";
		sFormLoadCommands += "if (document.EntryForm._HIDDENpreq_status.value == '') SelectDropdownItemByValue('preq_status', 'O');\n";
	}        

%>

