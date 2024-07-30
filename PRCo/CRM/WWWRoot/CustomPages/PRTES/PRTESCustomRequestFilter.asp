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

        user_userid = eWare.getContextInfo("User", "User_UserId");

        // determine the user date setting
        //sUserDateFormat = "dd/mm/yyyy"; 
        sUserDateFormat = "mm/dd/yyyy"; // CHW - Changed default.
        recUserDateSetting = eWare.FindRecord("UserSettings", "uset_userid=" + user_userid + " AND uset_key='NSet_UserDateFormat'");
        if (!recUserDateSetting.eof)
            sUserDateFormat = recUserDateSetting("uset_value"); 

        // get the form variables that may or may not exist
        sDBStartDate = "NULL";
        sFormStartDate = String(Request.Form.Item("_startdate"));
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
        sFormEndDate = String(Request.Form.Item("_enddate"));
        if (sFormEndDate == null || isEmpty(sFormEndDate))
        {
            sFormEndDate = "";
        }
        else
        {
            sDBEndDate = "'" + getDBDate(sFormEndDate, sUserDateFormat) + "'";
        }
        
        sDBListingStatus = "NULL";
        comp_prlistingstatus = String(Request.Form.Item("comp_prlistingstatus"));
        if (!isEmpty(comp_prlistingstatus))
            sDBListingStatus = "'" + comp_prlistingstatus + "'"; 
            
        sDBType = "NULL";
        prcr_type = String(Request.Form.Item("prcr_type"));
        if (!isEmpty(prcr_type))
            sDBType = "'" + prcr_type + "'"; 

        blkFilter = eWare.GetBlock("CustomTESOption5FilterBox");
        blkFilter.Title = "Filter By";

        entryStartDate = blkFilter.getEntry("_startdate");
        entryStartDate.Caption = "Start Date (Last Updated):";
        // we know the following line does not work in accpac 5.7 so look for this caller's formload routine
        //     to see how the values for these dates are set
        //entryStartDate.DefaultValue = sFormStartDate;

        entryEndDate = blkFilter.getEntry("_enddate");
        entryEndDate.Caption = "End Date (Last Updated):";
        // see comment above
        //entryEndDate.DefaultValue = sFormEndDate;

        entryType = blkFilter.getEntry("prcr_Type");
        entryType.LookupFamily = 'prcr_TypeFilter';

        // limit to only valid listing status types
        entryLS = blkFilter.getEntry("comp_prlistingstatus");
        if (!isEmpty(entryLS))
        {
            entryLS.RemoveLookup("N3");
            entryLS.RemoveLookup("N4");
            entryLS.RemoveLookup("N5");
            entryLS.RemoveLookup("N6");
            entryLS.RemoveLookup("D");
        }    
        // Add a button to the local block
        sFilterAction = changeKey(sURL, "em", Edit);
        blkFilter.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.action='"+sFilterAction+ "';document.EntryForm.submit();" ));


            
            
%>

