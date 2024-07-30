<!-- #include file ="..\accpaccrm.js" -->
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
%>

<!-- #include file ="PersonHeaders.asp" -->
<!--#include file ="..\AccpacScreenObjects.asp"-->

<%
/////////////////////////////////////////////////////////
//Filename: PRPersonSummary.asp
//////////////////////////////////////////////////////
function doPage()
{
	// Working Storage
	var sSQL = "";

    //bDebug = true;
    var Key0 = new String(Request.QueryString("Key0"));
    var Key1 = new String(Request.QueryString("Key1"));
    var Key2 = new String(Request.QueryString("Key2"));
    
    DEBUG("<BR>Key0: " + Key0);
    DEBUG("<BR>Key1: " + Key1);
    DEBUG("<BR>Key2: " + Key2);
    var sRedirectUrl = "";
    if (""+Key1 != "undefined" )
    {
        // remove the company key as it can cause some confusion
        sRedirectUrl = eWare.URL("PRPerson/PRPersonSummary.asp");
        sRedirectUrl = removeKey(sRedirectUrl, "Key1");
    }
    // if pers_personid exists but Key2 does not, redirect to add Key2 to the query string
    if (pers_personid != "-1")
    {
        // Accpac will not pass along the pers_personid querystring param but it will pass 
        // Key2 to other native calls
        if (""+Key2 == "undefined" || Key2.valueOf() != pers_personid.valueOf() )
        {
            if (sRedirectUrl == "" )
                sRedirectUrl = eWare.URL("PRPerson/PRPersonSummary.asp");
        
            // depending upon where this link came from the url can be a mess
            // simply it and resend
            sRedirectUrl = changeKey(sRedirectUrl, "Key0", "2");
            sRedirectUrl = changeKey(sRedirectUrl, "Key2", pers_personid);
            sRedirectUrl = changeKey(sRedirectUrl, "pers_personid", pers_personid);
            sPrevVal = new String(Request.QueryString("PrevCustomURL"));
            if (sPrevVal != "undefined")
            {
                reg = new RegExp("&","gi");
                var sFValue = sPrevVal.replace(reg, "%26");
                sRedirectUrl = changeKey(sRedirectUrl, "F", sFValue);
            }
        } 
    }
    if (sRedirectUrl != "")
    {
        //DEBUG("<BR>Redirect: " + sRedirectUrl + "<br><br>");
        Response.Redirect(sRedirectUrl );
        return;
    }       

    DEBUG("<br>PRPersonSummary.asp sURL: " + sURL);
    DEBUG("<br>PRPersonSummary.asp Mode: " + eWare.Mode);
    var sSecurityGroups = sDefaultPersonSecurity;

    sListingAction = eWare.Url(131);
    sSummaryAction = eWare.Url("PRPerson/PRPersonSummary.asp")+ "&pers_personid="+ pers_personid;

    var blkPerson = eWare.GetBlock("PRPersonEntry");
    blkContainer.AddBlock(blkPerson);
    blkContainer.CheckLocks = false;
    
    var bRedirect = false;

    var bNew = false;
    if (pers_personid == -1) {
        bNew = true;
        // Unconfirmed should not show for new persons
        entryUnconfirmed = blkPerson.GetEntry("pers_PRUnconfirmed");
        entryUnconfirmed.Hidden = true;
    }

    if (eWare.Mode == Save)
    {
        bRedirect = true;
        if (bNew) {
            recPerson = eWare.CreateRecord("Person");
        }
        
        blkPerson.ArgObj = recPerson;
        
        if (!blkContainer.Validate()) {
            bRedirect = false;
        } 

        if (bNew) {
            // At this point the Company Should exist.
            recTrx = eWare.CreateRecord("PRTransaction");
            blkTrx=eWare.GetBlock("PRTransactionNewEntry");
            blkTrx.ArgObj = recTrx;
        
            if (!blkTrx.Validate()) {
                bRedirect = false;
            }
        }
                
        if (bRedirect) {
            blkContainer.Execute()
            pers_personid = recPerson("pers_personid");
            
            if (bNew) {
                // set the value to the newly created company
                recTrx.prtx_PersonId = recPerson.pers_personid;
                blkTrx.Execute()

                // Now the Person and transaction will exist. Add a detail record
                sSQL = "EXECUTE usp_CreateTransactionDetail " + 
                            "@prtx_TransactionId = " + recTrx.prtx_TransactionId + ", " +
                            "@Entity = 'Person', " +
                            "@Action = 'Insert', " +
                            "@NewValue = '" + recPerson.pers_FirstName.replace(/'/g, "''") + " " + recPerson.pers_LastName.replace(/'/g, "''") + " Created', " +
                            "@UserId = " + user_userid;
                recQuery = eWare.CreateQueryObj(sSQL);
                recQuery.ExecSql()
            }
            
                
            // Update the Web User record to match the Person Record
            /*
				1. Get the matching record from the web user
				2. if the names don't match, then update the web user to match our name here
				3. but only if this one is not blank
            */

            sSQL = "Select prwu_WebUserID, prwu_FirstName, prwu_LastName From PRWebUser Inner Join Person_Link On (peli_PersonLinkID = prwu_PersonLinkID) Inner Join Person On (pers_PersonID = peli_PersonID) Where pers_PersonId = " + pers_personid;
            var qryWebUser = eWare.CreateQueryObj(sSQL);
            qryWebUser.SelectSQL();
            if (qryWebUser.RecordCount > 0) {
				var PersFirstName = (Request.Form("pers_FirstName").Count > 0 ? String(Request.Form("pers_FirstName")) : "");
				var PersLastName = (Request.Form("pers_LastName").Count > 0 ? String(Request.Form("pers_LastName")) : "");
				var WebUserID = qryWebUser("prwu_WebUserID");
				
				var QueryUpdates = [];
				if (PersFirstName.length > 0) {
					// update the webuser record first name
					QueryUpdates.push("prwu_FirstName = '" + PersFirstName.replace(/'/g, "''") + "'");
				}
				
				if (PersLastName.length > 0) {
					// update the webuser record last name
					QueryUpdates.push("prwu_LastName = '" + PersLastName.replace(/'/g, "''") + "'");
				}
				
				if (QueryUpdates.length > 0) {
					sSQL = "Update PRWebUser Set " + QueryUpdates.join(", ") + " Where prwu_WebUserID = " + WebUserID;
					qryWebUser.SQL = sSQL;
					qryWebUser.ExecSQL();
				}
            }

            sSummaryAction = eWare.Url("PRPerson/PRPersonSummary.asp")+ "&pers_personid="+ pers_personid;
            Response.Redirect(sSummaryAction);
        }
    }
    
    if (bRedirect == false)
    {
        if (bNew) {
            blkPerson.Title = "New Person";
            eWare.Mode = Edit;
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
            // shouldn't be here but protect the action anyway
	        if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
            
	        // Set up the transaction information
            blkTrx=eWare.GetBlock("PRTransactionNewEntry");
            blkTrx.Title = "Transaction";
            entry = blkTrx.GetEntry("prtx_Status");
            entry.ReadOnly = true;
            entry.DefaultValue = "O";        
            blkTrx.GetEntry("prtx_CloseDate").hidden = true;
            
            blkContainer.AddBlock(blkTrx);
            eWare.AddContent(blkContainer.Execute());
            
            Response.Write("<script language=javascript src=\"../PRCoGeneral.js\"></script>");
            Response.Write(eWare.GetPage("New"));
            
            sCloseTrxDisplay = "<table style={display:none}><tr ID=\"tr_closetrx\"><td ID=td_closetrx CLASS=VIEWBOXCAPTION>" + 
                "<INPUT TYPE=CHECKBOX CLASS=EDIT " +
                "onclick=\"if (this.checked==true) document.EntryForm._HIDDENprtx_status.value='C'; else document.EntryForm._HIDDENprtx_status.value='O'; \" " + 
                ">Close Transaction Upon Save</td></tr></table>" ;
            Response.Write(sCloseTrxDisplay);
            sCloseTrxDraw = " AppendCell(\"_Captprtx_status\", \"td_closetrx\");";
            
        }    
        else if (eWare.Mode == Edit)
        {
            blkPerson.Title = "Edit Person";
            blkPerson.ArgObj = recPerson;
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
            if (iTrxStatus == TRX_STATUS_EDIT)
            {
	            if (isUserInGroup(sSecurityGroups))
	                blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
            }
            eWare.AddContent(blkContainer.Execute());
            Response.Write(eWare.GetPage("Person"));
        }
        else
        {
            blkPerson.Title = "Person";
            blkPerson.ArgObj = recPerson;

            // Add correct buttons based on transaction status
            if (iTrxStatus == TRX_STATUS_EDIT)
            {
	            if (isUserInGroup(sSecurityGroups))
                    blkContainer.DisplayButton(Button_Default) = true;
            } 
            else 
            {
                blkContainer.DisplayButton(Button_Default) = false;
            }
            eWare.AddContent(blkContainer.Execute());
            Response.Write(eWare.GetPage("Person"));
        }
    }

    if (eWare.Mode == Edit)
    {
%>
        <script type="text/javascript" >
            var bSaveFlag = false;
            function save() {
    
                if (bSaveFlag == true) {
                    return;
                }
                bSaveFlag = true;

                document.EntryForm.submit();
            }
        </script>
<%
    }
    
   if ((bNew) && (eWare.Mode != Save))
    {
%>
        <script type="text/javascript">
            function initBBSI() 
            {
                <% Response.Write(sCloseTrxDraw ) %>
                document.getElementById("prtx_effectivedate").value = getDateAsString();
                document.getElementById("pers_lastname").focus();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
        </script>
<%
    }    
}
doPage();
Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
%>
<!-- #include file ="../RedirectTopContent.asp" -->
