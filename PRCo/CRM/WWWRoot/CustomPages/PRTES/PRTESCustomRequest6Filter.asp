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

        sUserDateFormat = "mm/dd/yyyy"; // CHW - Changed default.
        recUserDateSetting = eWare.FindRecord("UserSettings", "uset_userid=" + user_userid + " AND uset_key='NSet_UserDateFormat'");
        if (!recUserDateSetting.eof)
            sUserDateFormat = recUserDateSetting("uset_value"); 

        // get the form variables that may or may not exist
        var sDBStartDate = "NULL";
        var sFormStartDate = String(Request.Form.Item("prtesr_sentdatetime_start"));
        if (isEmpty(sFormStartDate)) {
            var tmpStartDate = new Date();
            tmpStartDate.setDate(tmpStartDate.getDate()-90);
            sFormStartDate = getDBDate2(tmpStartDate);
            sDBStartDate = "'" + getDBDate(sFormStartDate, sUserDateFormat) + "'";
        } else {
            sDBStartDate = "'" + getDBDate(sFormStartDate, sUserDateFormat) + "'";
        }
    
        var sDBEndDate = "NULL";
        var sFormEndDate = String(Request.Form.Item("prtesr_sentdatetime_end"));
        if (isEmpty(sFormEndDate)) {
            var tmpEndDate = new Date();
            tmpEndDate.setDate(tmpEndDate.getDate()-30);
            sFormEndDate = getDBDate2(tmpEndDate);
            sDBEndDate = "'" + getDBDate(sFormEndDate, sUserDateFormat) + "'";
        } else {
            sDBEndDate = "'" + getDBDate(sFormEndDate, sUserDateFormat) + "'";
        }
    
        sDBListingStatus = "NULL";
        comp_prlistingstatus = String(Request.Form.Item("comp_prlistingstatus"));
        if (isEmpty(comp_prlistingstatus)) {
            comp_prlistingstatus = "";
        } else {
            sDBListingStatus = "'" + comp_prlistingstatus + "'"; 
        }
            
        sDBType = "NULL";
        prcr_type = String(Request.Form.Item("prcr_type"));
        if (isEmpty(prcr_type)) {
            prcr_type = "";
        } else {
            sDBType = "'" + prcr_type + "'"; 
        }

        var sDBConnectionListOnly = "NULL";
        connectionListOnly = String(Request.Form.Item("_ConnectionListOnly"));
        if (connectionListOnly == "Checked") {
            sDBConnectionListOnly = "'Y'"; 
        }
        if (connectionListOnly == "NotChecked") {
            sDBConnectionListOnly = "'N'"; 
        }

        var blkFilter = eWare.GetBlock("CustomTESOption6FilterBox");
        blkFilter.Title = "Filter By";

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

