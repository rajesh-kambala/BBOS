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
        // USE OF THIS INCLUDE REQUIRES DEFINITION OF THE FOLLOWING FIELDS:
        //    sScreenType - defines the type of screen being displayed; this can be "ARAgingOn" (default),
        //                  "ARAgingBy", "ARAgingByDetail"

        user_userid = eWare.getContextInfo("User", "User_UserId");
        // determine the user date setting
        sUserDateFormat = "dd/mm/yyyy"; 
        recUserDateSetting = eWare.FindRecord("UserSettings", "uset_userid=" + user_userid + " AND uset_key='NSet_UserDateFormat'");
        if (!recUserDateSetting.eof)
            sUserDateFormat = recUserDateSetting("uset_value"); 

        // get the form variables that may or may not exist
        sDBStartDate = "NULL";
        sFormStartDate = String(Request.Form.Item("prtr_date_start"));
        if (sFormStartDate == null || isEmpty(sFormStartDate)) {
            sFormStartDate = "";
        } else {
            // call the PRCoGeneral.asp function for help getting the db date format
            sDBStartDate = "'" + getDBDate(sFormStartDate, sUserDateFormat) + "'";
        }
    
        sDBEndDate = "NULL";
        sFormEndDate = String(Request.Form.Item("prtr_date_end"));
        if (sFormEndDate == null || isEmpty(sFormEndDate)) {
            sFormEndDate = "";
        } else {
            sDBEndDate = "'" + getDBDate(sFormEndDate, sUserDateFormat) + " 23:59:59'";
        }

        
        sDBException = "NULL";
        sFormException = String(Request.Form.Item("_exception"));
        if (sFormException.toLowerCase() == "checked") {
            sDBException = " = 'Y' ";
            jsException = "document.getElementsByName('_exception')[0].checked = true;";
        }            

        if (sFormException.toLowerCase() == "notchecked") {
            sDBException = " = 'N' ";
            jsException = "document.getElementsByName('_exception')[1].checked = true;";
        }            

        if (sFormException.toLowerCase() == "either") {
            sDBException = " IN ('Y', 'N') ";
            jsException = "document.getElementsByName('_exception')[2].checked = true;";
        }            
        
        sResponderID = String(Request.Form.Item("prtr_responderid"));
        if (sResponderID == null || isEmpty(sResponderID))  {
            sResponderID = "";
        }
        
        // finally get the list of business type (classification) values 
        // not sure which one I'll ultimately use, so create a couple and remove the unused later
        sDBClassificationList = "";
        sDBClassListForInClause = "";
        sDBClassListForWhereClause = "";
        if (sScreenType == "ARAgingOn" || sScreenType == "ARAgingByDetail") {


            for (var x = 1; x <= Request.Form.Count; x++) {
                sFieldName = String(Request.Form.Key(x));

                if (sFieldName.substr(0,10) == "chk_class_")
                {
                    sClassAbbr = sFieldName.substr(10);
                    sFieldValue = getFormValue(sFieldName);

                    if (sFieldValue == "on")
                    {
                        if (sDBClassificationList != "")
                            sDBClassificationList += ",";
                        sDBClassificationList += sClassAbbr;
                        if (sDBClassListForInClause != "")
                            sDBClassListForInClause += ",";
                        sDBClassListForInClause += "'"+ sClassAbbr + "'";
                        if (sDBClassListForWhereClause != "")
                            sDBClassListForWhereClause += " OR ";
                        sDBClassListForWhereClause += " CHARINDEX('"+ sClassAbbr + "', Level1ClassificationValues) > 0 ";
                    }    
                }
            }
        }



        if (sDBClassificationList == "")
            sDBClassificationList = "NULL";
        else
            sDBClassificationList = "'" + sDBClassificationList + "'";
        if (sDBClassListForWhereClause != "")
            sDBClassListForWhereClause = " ( " + sDBClassListForWhereClause + ") ";
            
        blkFilter = eWare.GetBlock("TradeActivityFilterBox");
        blkFilter.Title = "Filter By";
        

        entryResponder = blkFilter.getEntry("prtr_responderid");
        entryResponder.Hidden = true;

        if (sScreenType == "ARAgingOn") {
            entryResponder.Hidden = false;
        }

        if (sScreenType == "ARAgingBy" || sScreenType == "TESAbout")
        {
            entryException = blkFilter.getEntry("_exception");
            entryException.Hidden = true;
        }

        if (sScreenType == "ARAgingOn" || sScreenType == "ARAgingByDetail")
        {
            // create an html table to hold the classification options.
            sSQL = "SELECT * FROM PRClassification WHERE prcl_Level = 1"
            
            if (isLumber) {
                sSQL += " AND prcl_BookSection=3";
            } else {
                sSQL += " AND prcl_BookSection<>3";
            }

            recClassification = eWare.CreateQueryObj(sSQL);
            recClassification.SelectSQL();

	        sSearchClassContent = "\n<TABLE ID='tblSearchClassOptions' WIDTH='100%' CELLPADDING=0 BORDER=0 align=left>";
            sSearchClassContent += "\n  <TR><TD COLSPAN=4 CLASS=VIEWBOXCAPTION ALIGN=LEFT >Classifications:</TD></TR>";
            while (!recClassification.eof)
            {
                sName = "chk_class_" + recClassification("prcl_Name") ; 
                sChecked = "";
                if (sDBClassificationList.indexOf(recClassification("prcl_Name")) > -1)
                    sChecked = " CHECKED ";
                sSearchClassContent += "\n  <TR>";
                sSearchClassContent += "\n    <TD WIDTH=20 CLASS=VIEWBOXCAPTION ALIGN=LEFT ><INPUT TYPE=CHECKBOX " + sChecked+ " ID=\""+ sName + "\" NAME=\""+sName+"\"></TD>"
                        +"<TD CLASS=VIEWBOXCAPTION ALIGN=LEFT >" + recClassification("prcl_Name") + "</TD>";
                recClassification.NextRecord();
                if (recClassification.eof)
                {
                    sSearchClassContent += "\n  </TR>";
                    break;
                }
                sName = "chk_class_" + recClassification("prcl_Name") ; 
                sChecked = "";
                if (sDBClassificationList.indexOf(recClassification("prcl_Name")) > -1)
                    sChecked = " CHECKED ";
                sSearchClassContent += "\n    <TD WIDTH=20 CLASS=VIEWBOXCAPTION ALIGN=LEFT ><INPUT TYPE=CHECKBOX " + sChecked+ " ID=\""+ sName + "\" NAME=\""+sName+"\"></TD>"
                        +"<TD CLASS=VIEWBOXCAPTION ALIGN=LEFT >" + recClassification("prcl_Name") + "</TD>";
                sSearchClassContent += "\n  </TR>";
                recClassification.NextRecord();
            }
            sSearchClassContent += "\n</TABLE>";
        }
        // Add a button to the local block
        sFilterAction = changeKey(sURL, "em", Find);
        blkFilter.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.action='"+sFilterAction+ "';document.EntryForm.submit();" ));
%>