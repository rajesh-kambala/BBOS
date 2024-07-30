<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

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

        blkFilter = eWare.GetBlock("PRCreditSheetSearchBox");
        blkFilter.Title = "Filter By";

        // now create the formload section to reload all the values with the submitted values
        sFormLoadCommands = "";

        var sFormStatusNew = "";
        var sFormStatusModified = "";
        var sFormStatusApproved = "";
        var sFormStatusHoldApproval = "";
        var sFormStatusPublishable = "";
        var sFormStatusKilled = "";
        

        var sGridFilterWhereClause = "";
        if (eWare.Mode != 6)
        {  
            sDBKeyFlag = "NULL";
            sFormKeyFlag = getFormValue("_KeyFlagSelect");
            if (!isEmpty(sFormKeyFlag))
            {
                sDBKeyFlag = sFormKeyFlag ; 
            }

            sDBStatus = "";
            sFormStatusNew = getFormValue("prcs_Status_New");
            if (isEmpty(sFormStatusNew))
                sFormStatusNew = "";
            sFormStatusModified = getFormValue("prcs_Status_Modified");
            if (isEmpty(sFormStatusModified))
                sFormStatusModified = "";
            sFormStatusApproved = getFormValue("prcs_Status_Approved");
            if (isEmpty(sFormStatusApproved))
                sFormStatusApproved = "";
            sFormStatusHoldApproval = getFormValue("prcs_Status_HoldApproval");
            if (isEmpty(sFormStatusHoldApproval))
                sFormStatusHoldApproval = "";
            sFormStatusPublishable = getFormValue("prcs_Status_Publishable");
            if (isEmpty(sFormStatusPublishable))
                sFormStatusPublishable = "";
            sFormStatusKilled = getFormValue("prcs_Status_Killed");
            if (isEmpty(sFormStatusKilled))
                sFormStatusKilled = "";
            // determine which flags should be on
            if (sFormStatusNew.toLowerCase() == "on")
                sDBStatus += "'N'";
            if (sFormStatusModified.toLowerCase() == "on")
                sDBStatus += (sDBStatus==""?"":",") + "'M'";
            if (sFormStatusApproved.toLowerCase() == "on")
                sDBStatus += (sDBStatus==""?"":",") + "'A'";
            if (sFormStatusHoldApproval.toLowerCase() == "on")
                sDBStatus += (sDBStatus==""?"":",") + "'D'";
            if (sFormStatusPublishable.toLowerCase() == "on")
                sDBStatus += (sDBStatus==""?"":",") + "'P'";
            if (sFormStatusKilled.toLowerCase() == "on")
                sDBStatus += (sDBStatus==""?"":",") + "'K'";
            // force a default
            if (sDBStatus == "")
            {
                sFormStatusNew = "on";
                sFormStatusModified = "on";
                sFormStatusApproved = "on";
                sDBStatus = "'N','M','A'";                
            }
            
            if (sDBKeyFlag != "NULL")
            {
                if (sDBKeyFlag == "Y")
                    sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prcs_KeyFlag = '" + sDBKeyFlag + "'";
                else
                    sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prcs_KeyFlag is NULL ";
            }        
            // this implementation is structured to only filter if one of the statuses is selected.
            // Otherwise, we get them all
            if (sDBStatus != "")
            {
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prcs_Status in (" + sDBStatus + ")";
            }        
        }
        sFormLoadCommands += "AppendRow(\"prcs_createddate_end\", \"div_prcs_keyflag\");";
        sFormLoadCommands += "AppendCell(\"_Captprcs_createddate\", \"td_prcs_Status\");";
        
        // create the option for the _KeyFlagSelect field
        sCaption = eWare.GetTrans("ColNames","prcs_KeyFlag");
        // outer <div> tag just hides some "flashing" during refresh
        sKeyFlagDisplay = "<div style={display:none}><div  ID=\"div_prcs_keyflag\" VALIGN=TOP >" + 
                "<SPAN ID=\"_Captprcs_keyflag\" CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br><SPAN>" +
                "<SELECT CLASS=EDIT SIZE=1 NAME=\"_KeyFlagSelect\">" + 
                "<OPTION VALUE=\"Y\" >Yes</OPTION> " +
                "<OPTION VALUE=\"N\" >No</OPTION> " +
                "<OPTION SELECTED VALUE=\"\" >All</OPTION> " +
                "</SELECT></SPAN></div></div>";
        //Response.Write(sKeyFlagDisplay);

        sCaption = eWare.GetTrans("ColNames","prcs_Status");
        sStatusDisplay = "<Table Style={display:none} ><TR><TD ROWSPAN=3 WIDTH=\"70%\" CLASS=VIEWBOXCAPTION ID=\"td_prcs_Status\" VALIGN=TOP>" + 
                "<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><TR><TD>"+
                "<SPAN ID=\"_Captprcs_Status\" CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN></TD>" +
                "<TR>"+
                "<TD CLASS=VIEWBOXCAPTION ><INPUT " +(sFormStatusNew!=""?"CHECKED ":"") + "TYPE=CHECKBOX CLASS=VIEWBOX NAME=\"prcs_Status_New\">New</TD>" + 
                "<TD CLASS=VIEWBOXCAPTION ><INPUT " +(sFormStatusModified!=""?"CHECKED ":"") + "TYPE=CHECKBOX CLASS=VIEWBOX NAME=\"prcs_Status_Modified\">Modified</TD>" + 
                "<TD CLASS=VIEWBOXCAPTION ><INPUT " +(sFormStatusApproved!=""?"CHECKED ":"") + "TYPE=CHECKBOX CLASS=VIEWBOX NAME=\"prcs_Status_Approved\">Approved</TD>" + 
                "<TR>"+
                "<TD CLASS=VIEWBOXCAPTION ><INPUT " +(sFormStatusHoldApproval!=""?"CHECKED ":"") + "TYPE=CHECKBOX CLASS=VIEWBOX NAME=\"prcs_Status_HoldApproval\">Do Not Approve</TD>" + 
                "<TD CLASS=VIEWBOXCAPTION ><INPUT " +(sFormStatusPublishable!=""?"CHECKED ":"") + "TYPE=CHECKBOX CLASS=VIEWBOX NAME=\"prcs_Status_Publishable\">Publishable</TD>" + 
                "<TD CLASS=VIEWBOXCAPTION ><INPUT " +(sFormStatusKilled!=""?"CHECKED ":"") + "TYPE=CHECKBOX CLASS=VIEWBOX NAME=\"prcs_Status_Killed\">Killed</TD>" + 
                "</TR></TABLE>"+
                "</TD></TR></TABLE>";
        //Response.Write(sStatusDisplay);

        var blkStatusDisplay = eWare.GetBlock('content');

        blkStatusDisplay.contents = sKeyFlagDisplay;
        blkStatusDisplay.contents += sStatusDisplay;
%>

