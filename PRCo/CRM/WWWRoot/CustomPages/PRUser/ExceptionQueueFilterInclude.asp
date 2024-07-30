<%
        blkFilter = eWare.GetBlock("ExceptionQueueFilterBox");
        blkFilter.Title = "Filter By";

        // determine the user date setting
        sUserDateFormat = "dd/mm/yyyy"; 
        recUserDateSetting = eWare.FindRecord("UserSettings", "uset_userid=" + user_userid + " AND uset_key='NSet_UserDateFormat'");
        if (!recUserDateSetting.eof)
            sUserDateFormat = recUserDateSetting("uset_value"); 

        // get the form variables that may or may not exist
        sDBStartDate = "NULL";
        sFormStartDate = getFormValue("_startdate");
        if (sFormStartDate == null || isEmpty(sFormStartDate))
        {
            sFormStartDate = "";
        }
        else
        {
            // call the PRCoGeneral.asp function for help getting the db date format
            sDBStartDate = "'" + getDBDate(sFormStartDate, sUserDateFormat) + "'";
        }
    
        sDBEndDate = "NULL";
        sFormEndDate = getFormValue("_enddate");
        if (sFormEndDate == null || isEmpty(sFormEndDate))
        {
            sFormEndDate = "";
        }
        else
        {
            sDBEndDate = "'" + getDBDate(sFormEndDate, sUserDateFormat) + "'";
        }
        
        sDBCompanyId = "NULL";
        preq_companyid = getFormValue("preq_companyid");
        if (!isEmpty(preq_companyid))
        {
            sDBCompanyId = preq_companyid; 
            entryCompany = blkFilter.getEntry("preq_CompanyId");
            entryCompany.DefaultValue = preq_companyid;
        }

        sDBAssignedUserId = user_userid;
        sUserIdToSelect = user_userid;
        preq_assigneduserid = getFormValue("preq_assigneduserid");
        if (preq_assigneduserid == "")
        {
            sDBAssignedUserId = "NULL";
            sUserIdToSelect = "";
        }
        else if (!isEmpty(preq_assigneduserid))
        {
            sDBAssignedUserId = preq_assigneduserid; 
            sUserIdToSelect = preq_assigneduserid;
        }

            
        sDBType = "NULL";
        preq_type = getFormValue("preq_type");
        if (!isEmpty(preq_type))
        {
            sDBType = "'" + preq_type + "'"; 
            // Again, the accpac functions to load do not seem to work for all types;
            // look tot the "FormLoad" routine on the caller
            //entryType = blkFilter.getEntry("preq_type");
            //entryType.DefaultType = 1;
            //entryType.DefaultValue = preq_type;
        }

        sDBStatus = "NULL";
        preq_status = getFormValue("preq_status");
        if (!isEmpty(preq_status))
        {
            sDBStatus = "'" + preq_status + "'"; 
        }
            
        entryStartDate = blkFilter.getEntry("_startdate");
        entryStartDate.Caption = "Start Date:";
        // we know the following line does not work in accpac 5.7 so look for this caller's formload routine
        //     to see how the values for these dates are set
        //entryStartDate.DefaultValue = sFormStartDate;

        entryEndDate = blkFilter.getEntry("_enddate");
        entryEndDate.Caption = "End Date:";
        // see comment above
        //entryEndDate.DefaultValue = sFormEndDate;

        entryType = blkFilter.getEntry("preq_Type");
        //entryType.LookupFamily = 'preq_Type';


        // Add a button to the local block
        sFilterAction = changeKey(sURL, "em", Edit);
        blkFilter.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.action='"+sFilterAction+ "';document.EntryForm.submit();" ));


            
            
%>

