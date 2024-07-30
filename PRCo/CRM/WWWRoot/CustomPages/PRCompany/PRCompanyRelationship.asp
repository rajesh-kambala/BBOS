<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->

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
    doPage();

function doPage()
{
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
	//DumpFormValues();
	//Response.Write(eWare.Mode);

  
	
	// first execute code used by all modes
	
	var prcr_companyrelationshipid = getIdValue("prcr_CompanyRelationshipId");
    var prcl2_ConnectionListID = getIdValue("prcl2_connectionlistid");
	
	if (Session("RelationshipReturnURL") == null) {
        sListingAction = eWare.Url("PRCompany/PRCompanyRelationshipListing.asp") + "&T=Company&Capt=Relationships";
    } else {
        sListingAction = Session("RelationshipReturnURL");    
    }        
    sSummaryAction = eWare.Url("PRCompany/PRCompanyRelationship.asp")+ "&prcr_CompanyRelationshipId="+ prcr_companyrelationshipid + "&T=Company&Capt=Relationships";

	// determine if this is a new record
	var bNew = false;
	if (prcr_companyrelationshipid == "-1") {
    
	    bNew = true;
        //Defect 7038
        var rightCompanyId = new String(Request.Form.Item("prcr_RightCompanyId"));
        var relationshipType = new String(Request.Form.Item("prcr_Type"));
        var szIndustryCheck = doIndustryCheck(comp_companyid, rightCompanyId, relationshipType);
        if(szIndustryCheck != "")
        {
            Session("sUserMsg") = szIndustryCheck;
            eWare.Mode = Edit;
        }
	}

    Response.Write("\n<script type=\"text/javascript\" >"); 
    Response.Write("\n        var bNew = " + bNew + ";"); 
    Response.Write("\n</script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyRelationship.js\"></script>");            
            
	// New record requires immediate escalation to Edit mode 
    if ((bNew) && (eWare.Mode == View))
		eWare.Mode = Edit;
		
    blkRelationshipEntry=eWare.GetBlock("PRCompanyRelationshipNewEntry");
	blkRelationshipEntry.Title = "Assign Company Relationship";

    blkTradeReportEntry=eWare.GetBlock("PRTradeReportNewEntry");
    blkTradeReportEntry.Title = "Add Trade Report on Related Company";

    if (bNew)	{
        var bFound = false;
        
        // If we're saving a new relationship record, check to see if one already
        // exists between these two companies for the specified type.  If so, just
        // update the found record.
        if ((eWare.Mode == Save) || (eWare.Mode == 99)) {
        
           var szLeftCompanyID = Request.Form.Item("prcr_LeftCompanyId");
            if (szLeftCompanyID == "") {
                szLeftCompanyID = comp_companyid;
            }

            var szSQL = "prcr_LeftCompanyId=" + szLeftCompanyID
		        + " and prcr_RightCompanyId=" + new String(Request.Form.Item("prcr_RightCompanyId"))
		        + " and prcr_Type=" + new String(Request.Form.Item("prcr_Type"));
	    
			recRelationship = eWare.FindRecord("PRCompanyRelationship", szSQL);
			if (recRelationship.eof) {
			    bFound = false;
			} else {
			    bFound = true;	
			}

            var szLastEntryType = Request.Form("prcr_Type").Item;
            if (!isEmpty(szLastEntryType))
            {                
                Session("LastEntryType") = szLastEntryType;
            }
        }
        
        // new
        if (!bFound) {
            recRelationship = eWare.CreateRecord("PRCompanyRelationship");
		    recRelationship.prcr_LeftCompanyId = comp_companyid;
		}
    
	} else {
		// change
	    recRelationship = eWare.FindRecord("PRCompanyRelationship", "prcr_CompanyRelationshipId=" + prcr_companyrelationshipid);
    }

    // Mode 95 means to deactive all (actually most) relationshps between
    // these two companies
    if (eWare.Mode == 95) {

        var sqlDeactivate = "UPDATE PRCompanyRelationship SET prcr_Active = NULL, prcr_UpdatedBy=" + user_userid + ", prcr_UpdatedDate=GETDATE(), prcr_Timestamp=GETDATE() WHERE prcr_Type IN ('01','04','09','10','11','12','13','14','15','16','23','25') AND prcr_Active='Y' AND prcr_LeftCompanyID=" + recRelationship.prcr_LeftCompanyId + " AND prcr_RightCompanyID = " + recRelationship.prcr_RightCompanyId;
        var qryDeactivate = eWare.CreateQueryObj(sqlDeactivate);
        qryDeactivate.ExecSql();    
        
        sqlDeactivate = "UPDATE PRCompanyRelationship SET prcr_Active = NULL, prcr_UpdatedBy=" + user_userid + ", prcr_UpdatedDate=GETDATE(), prcr_Timestamp=GETDATE() WHERE prcr_Type IN ('01','04','09','10','11','12','13','14','15','16','23','25') AND prcr_Active='Y' AND prcr_RightCompanyID=" + recRelationship.prcr_LeftCompanyId + " AND prcr_LeftCompanyID = " + recRelationship.prcr_RightCompanyId;
        qryDeactivate = eWare.CreateQueryObj(sqlDeactivate);
        qryDeactivate.ExecSql();    
    
        Response.Redirect(sSummaryAction);
    }

    blkRelationshipEntry.ArgObj = recRelationship;
    blkContainer.CheckLocks = false;	// Richard - which cases is this line needed for?
    blkContainer.AddBlock(blkRelationshipEntry);

	// this is a post-release change to allow updates to the Connection List Date
	// putting this in its own block tied to recCompany is the quickest implementation but
	// the users may someday want this to appear differently on the interface.

    // If we are adding a new RL relationship, then we need to default the
    // company's RL date appropriately.  If the specied RL date is more recent
    // than what is on the company, then use the RL date.
    var connectionListDate = recCompany("comp_PRConnectionListDate");
    if (prcl2_ConnectionListID != -1) {
        var recConnectionList = eWare.FindRecord("PRConnectionList", "prcl2_ConnectionListID=" + prcl2_ConnectionListID);
        if (recConnectionList("prcl2_ConnectionListDate") > recCompany("comp_PRConnectionListDate")) {
            connectionListDate = recConnectionList("prcl2_ConnectionListDate");
        }
    }

	blkCompany = eWare.GetBlock("EntryGroup");
	blkCompany.Title = "Company";
	blkCompany.ArgObj = recCompany;
	entryLastConnectionListDate = blkCompany.AddEntry("comp_PRConnectionListDate", -1, false);
    entryLastConnectionListDate.DefaultValue = recCompany("comp_PRConnectionListDate");
    blkContainer.AddBlock(blkCompany);

    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyOwnershipCheck.js\"></script>");
	
	// handle each mode separately (View, Edit, Save, PreDelete)
    //=======================================================================

	if ((eWare.Mode == Save) || (eWare.Mode == 99))
	{
		// mode 99 handles a "Save and Next"
		if (eWare.Mode == 99) {
			bSaveAndNext = true;
			eWare.Mode = Save;
		} else {
			bSaveAndNext = false;
		}
        
		var txtUseTradeReport = getFormValue("_usetradereport");
	    if (bNew)	
	    {
            if (txtUseTradeReport == "true")
			{
		        recTradeReport = eWare.CreateRecord("PRTradeReport");
		        recTradeReport.prtr_ResponseSource = 'R';
                // save the integrity and rating values separately
                prtr_integrityid = Request.Form.Item("prtr_integrityid");
		        if (!isEmpty(prtr_integrityid) )
			        recTradeReport.prtr_integrityid = prtr_integrityid;
                prtr_payratingid = Request.Form.Item("prtr_payratingid");
		        if (!isEmpty(prtr_payratingid) )
			        recTradeReport.prtr_payratingid = prtr_payratingid;

    			// only add this block if we are saving the trade report
    			blkContainer.AddBlock(blkTradeReportEntry);
			    blkTradeReportEntry.ArgObj = recTradeReport;
			}
		}
		
	    blkContainer.Execute(); // generates HTML content that gets seen

        // If we have a connection list ID, then add this
        // company to the specified connection list.
        if (prcl2_ConnectionListID != -1) {

            var sql = "INSERT INTO PRConnectionListCompany (prclc_ConnectionListID, prclc_RelatedCompanyID, prclc_CreatedBy, prclc_CreatedDate, prclc_UpdatedBy, prclc_UpdatedDate, prclc_Timestamp) " +
	                  "VALUES (" + prcl2_ConnectionListID + ", " + recRelationship.prcr_RightCompanyId + ", " + user_userid + ", GETDATE(), " + user_userid + ", GETDATE(), GETDATE())"
    
            var qry = eWare.CreateQueryObj(sql);
            qry.ExecSQL();
        }

	    if (bNew)
	    {
            var recLeftCompany = eWare.FindRecord("company","comp_companyid=" + recRelationship.prcr_LeftCompanyID);
            var recRightCompany = eWare.FindRecord("company","comp_companyid=" + recRelationship.prcr_RightCompanyID);

            if ((recLeftCompany("comp_PRIndustryType") != "L") &&
                (recRightCompany("comp_PRIndustryType") != "L")) {

                if ((recRelationship.prcr_Type == "09") ||
                    (recRelationship.prcr_Type == "10") ||
                    (recRelationship.prcr_Type == "11") ||
                    (recRelationship.prcr_Type == "12") ||
                    (recRelationship.prcr_Type == "13") ||
                    (recRelationship.prcr_Type == "14") ||
                    (recRelationship.prcr_Type == "15") ||
                    (recRelationship.prcr_Type == "16") ||
                    (recRelationship.prcr_Type == "32")) {

                    var qry = "EXEC usp_CreateTES " + recRelationship.prcr_RightCompanyID + ", " + recRelationship.prcr_LeftCompanyID + ", NULL, 'NC', "  + user_userid;
                    var qry = eWare.CreateQueryObj(qry);
                    qry.ExecSQL();
                }
            }

            // If adding a branch to a reference list, instead change
            // it to be the HQ.
            var relType = new String(Request.Form.Item("prcr_Type"));
            if  ((recRightCompany("comp_PRType") == "B") &&
                 ( (relType == "09") || (relType == "10") || (relType == "11") || (relType == "12") || (relType == "13") || (relType == "14") || (relType == "15"))) {

                recRelationship.prcr_RightCompanyID = recRightCompany("comp_PRHQID");
                recRelationship.SaveChanges();
            }
        }

        // mode could have been changed by the execute!
	    if (bSaveAndNext)  {
            sEntryUrl = changeKey(sURL, "em", "1");
		    Response.Redirect(sEntryUrl);
	    }
	    else
	    {
		    if (bNew) {
			    Response.Redirect(sListingAction);
		    } else {
			    Response.Redirect(sSummaryAction);
			}
	    }
 	}

    //=======================================================================
    if (eWare.Mode == PreDelete) {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRCompanyRelationship WHERE prcr_CompanyRelationshipId="+ prcr_companyrelationshipid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
	}
    //=======================================================================
    if (eWare.Mode == View) {

	    if (recRelationship.prcr_LeftCompanyId == comp_companyid) {
    		Entry = blkRelationshipEntry.GetEntry("prcr_LeftCompanyId");
    		sCompanyIDControl = "_HIDDENprcr_RightCompanyId";
	    } else {
    		Entry = blkRelationshipEntry.GetEntry("prcr_RightCompanyId");
    		sCompanyIDControl = "_HIDDENprcr_LeftCompanyId";
	    }
    	Entry.Hidden = true;
	
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (isUserInGroup("2,3,4,10"))
        {
            var canDelete = true;
            if ((recRelationship.prcr_Type == "27") ||
                (recRelationship.prcr_Type == "28")) {

                if (iTrxStatus != TRX_STATUS_EDIT)
                {
                    canDelete = false;
                }
            } 
            
            if (canDelete) {
                sDeleteUrl = changeKey(sURL, "em", "3");
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
            
                sDeactivateUrl = changeKey(sURL, "em", "95");
                blkContainer.AddButton(eWare.Button("Deactivate All", "delete.gif", "javascript:deactivateAll('"+sDeactivateUrl+"');"));
            }
        }
                
        var canEdit = true;
        if ((recRelationship.prcr_Type == "27") ||
            (recRelationship.prcr_Type == "28")) {

            if (iTrxStatus != TRX_STATUS_EDIT)
            {
                canEdit = false;
            }
        } 

        if (canEdit) {
            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
        }

		eWare.AddContent(blkContainer.Execute()); // generates HTML content that gets seen

 		Response.Write(eWare.GetPage());
  		
	    Response.Write("\n<script type=\"text/javascript\" >"); 
        Response.Write("\n  function initBBSI() {");

        Response.Write("\n GetCompanyOwnership('_HIDDENprcr_rightcompanyid');");
        
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
	}

    //=======================================================================
    if (eWare.Mode == Edit)
	{
		// for edit, we need to know what the company's trx state is.
        var TRX_STATUS_NONE = 0;
        var TRX_STATUS_LOCKED = 1;
        var TRX_STATUS_EDIT = 2;
        var iTrxStatus = TRX_STATUS_NONE;
        recTrx = eWare.FindRecord('PRTransaction','prtx_status=\'O\' AND prtx_companyid=' + comp_companyid);
        var sTxnStatus = recTrx.prtx_TransactionId;
        if (!isEmpty(sTxnStatus))
        {
            recTrxUser = eWare.FindRecord('User', 'User_UserId='+recTrx.prtx_CreatedBy);
            if (recTrx.prtx_CreatedBy == user_userid)
                iTrxStatus = TRX_STATUS_EDIT;
            else
                iTrxStatus = TRX_STATUS_LOCKED;
        }
		
		// create some hidden fields for determining if we should use trade reports 
		var txtUseTradeReport = getFormValue("_usetradereport");
		
		// This flag is only used to control the "Toggle State" of
		// the Trade Report block.  It is still included for new relationships,
		// just "toggled off".  The user can "toggle it on" if they wish.  If it is
		// toggled on, then a trade report record and additional type 01 relationship
		// record is created.
		//
		// Trade report data cannot be submitted when editing an existing relationship,
		// but this variable has no control over that.  It is handled elsewhere in the
		// code.
		//
		// CHW 10/5/06   Note: This code should be refactored.
		var sUseTradeReport = "false";
		
		if (!isEmpty(txtUseTradeReport)) {
		    sUseTradeReport = txtUseTradeReport;
        } 
        
		var sFields = "<INPUT ID=\"_usetradereport\" NAME=\"_usetradereport\" type=\"HIDDEN\" value=\"" + sUseTradeReport + "\" ";
		var blkCustom = eWare.GetBlock("Content");		
		blkCustom.Contents = sFields;
		blkContainer.AddBlock(blkCustom);
		
		// The list of relationship types available depends on our
	    // scenario. 
		var entryType = blkRelationshipEntry.GetEntry("prcr_Type"); 
		if (bNew) {
            if (iTrxStatus == TRX_STATUS_EDIT) {
                // New Relationship in a transaction uses this list
                entryType.LookupFamily = "prcr_TypeOpenTrans";
                
                // Branches cannot be owners
                if (recCompany("comp_PRType") == "B") {
                    entryType.RemoveLookup("27");
                    entryType.RemoveLookup("28");
                }
            } else {
                // New Relationship not in a transaction uses this list
                entryType.LookupFamily = "prcr_TypeNoTrans";
            }
        } else {
            // if we're editing, use all of the types because
            // the cannot be changed.
            entryType.LookupFamily = "prcr_TypeFilter";
        }
        entryType.AllowBlank = false;

        if (eWare.Mode == Edit) {
            switch(recCompany("comp_PRIndustryType")) {
                case "P":
                    entryType.RemoveLookup("11");
                    break;
                case "T":  
                    entryType.RemoveLookup("09");
                    entryType.RemoveLookup("12");
                    entryType.RemoveLookup("13");
                    break;

                case "L":
                    entryType.RemoveLookup("10");
                    entryType.RemoveLookup("11");
                    entryType.RemoveLookup("12");
                    break;
            }
        }

        entryTimes = blkRelationshipEntry.GetEntry("prcr_TimesReported");
        entryTimes.ReadOnly = true;
                        		
        if (!bNew) {
	        if (recRelationship.prcr_LeftCompanyId == comp_companyid) {
    		    Entry = blkRelationshipEntry.GetEntry("prcr_LeftCompanyId");
    		    RelatedEntry = blkRelationshipEntry.GetEntry("prcr_RightCompanyId");
	        } else {
    		    Entry = blkRelationshipEntry.GetEntry("prcr_RightCompanyId");
    		    RelatedEntry = blkRelationshipEntry.GetEntry("prcr_LeftCompanyId");
	        }
	        Entry.Hidden = true;
	    }
	
		if (bNew) {
			// set defaults for a new entry
            if (!isEmpty(Session("LastEntryType"))) 
                entryType.DefaultValue = Session("LastEntryType");
            else
			    entryType.DefaultValue = "12";

			entry = blkRelationshipEntry.GetEntry("prcr_Source"); 
			entry.DefaultValue = "C";
            entry.AllowBlank = false;
			entry = blkRelationshipEntry.GetEntry("prcr_Active"); 
			entry.DefaultValue = "Y";
            
            entry = blkRelationshipEntry.GetEntry("prcr_lastreporteddate"); 
            entry.DefaultValue = getDateAsString(connectionListDate);

            entry = blkTradeReportEntry.GetEntry("prtr_Date"); 
            entry.DefaultValue = getDateAsString(connectionListDate);

            entry = blkTradeReportEntry.GetEntry("prtr_responsesource");
            entry.DefaultValue = "R";
		}
		else
		{
			entry = blkRelationshipEntry.GetEntry("prcr_Type"); 
			entry.ReadOnly = true;
		}

		if (!bNew)
		{
			blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }
	    else
	    {		
	            
			Entry = blkRelationshipEntry.GetEntry("prcr_LeftCompanyId");
			Entry.DefaultValue = comp_companyid;
			Entry.Hidden = true;
	            	
			blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
		}
        
        sEntryUrl = removeKey(sURL, "em");
        if (prcl2_ConnectionListID != -1) {
            sEntryUrl = sEntryUrl + "&prcl2_connectionlistid=" + prcl2_ConnectionListID;
        }

	    var sBranchOwnershipUrl = "checkForBranchOwnership()";
	    
	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"if (" + sBranchOwnershipUrl + ") {document.EntryForm.action='" + sEntryUrl + "'; save();}"));
    	
		if (bNew) {
	        sEntryUrl = changeKey(sURL, "em", "99");
	        blkContainer.AddButton(eWare.Button("Save and Next", "save.gif", "#\" onclick=\"if (" + sBranchOwnershipUrl + ") {document.EntryForm.action='" + sEntryUrl + "'; save();}"));
            blkContainer.AddButton(eWare.Button("Include Trade Report", "recurr.gif", "javascript:toggleTradeReportUse();"));

            var blkRelated = eWare.GetBlock("content");
            sSQL = "SELECT relatedcompanylist = dbo.ufn_GetRelatedCompaniesList(" + comp_companyid + ") " ;

            var recRelated = eWare.CreateQueryObj(sSQL);
            recRelated.SelectSQL();
            var sRelated = "";
            if (!recRelated.eof)
                sRelated = recRelated("relatedcompanylist");

            if (isEmpty(sRelated))
                sRelated = "";    

            blkRelated.contents = "<input type=hidden id=hdn_relatedcompanylist value="+ sRelated+">";
            blkContainer.AddBlock(blkRelated);
		}
	
		// allow entry of trade report when new relationship is entered
		if (bNew) {
			// the value for Subject Id will be set in the validate() javascript method.
			// this allows the field to be set on the edit screen via the relationship's Related Company 
			// field (entered once) but still appears as a submitted value so that accpac .Execute
			// method can actually save it
			blkContainer.AddBlock(blkTradeReportEntry);
			entryTradeLeftCompany = blkTradeReportEntry.GetEntry("prtr_SubjectId");
			entryTradeLeftCompany.Hidden = true;
            
            // it is very important to set the Responder Company here or the save of the
            // trade report will fail; accpac will never set a value for the field upon .Execute calls
			entryTradeRightCompany = blkTradeReportEntry.GetEntry("prtr_ResponderId");
			entryTradeRightCompany.DefaultValue = comp_companyid;
			entryTradeRightCompany.Hidden = true;
		}

		eWare.AddContent(blkContainer.Execute()); // generates HTML content that gets seen
	    
		Response.Write(eWare.GetPage('Company'));
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyRelationship.js\"></script>");

        if (!bNew) {
            var sSQL = "SELECT COUNT(1) as CLCount FROM PRCompanyRelationship WHERE prcr_LeftCompanyID = " + recRelationship.prcr_LeftCompanyID + " AND prcr_Active = 'Y' AND prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16');";
            var qry = eWare.CreateQueryObj(sSQL);
            qry.SelectSQL();
            var cnt = qry("CLCount");

     	    // Write out JS that updates the type description so that it makes
	        // sense - remove "Company X" and "Company "Y"
            Response.Write("\n<script type=\"text/javascript\" >"); 
            Response.Write("\n         var clCount=" + cnt);
            Response.Write("\n GetCompanyOwnership('_HIDDENprcr_rightcompanyid');");
        }		        
        Response.Write("\n</script>");

		if (bNew) {
		    recTradeReport = eWare.CreateRecord("PRTradeReport");
%>
<!-- #include file="TradeReportRatingsInclude.asp" -->
<%
		    Response.Write("\n<script type=\"text/javascript\" >"); 
            Response.Write("\n    function initBBSI() {");
			// defaulting date requires special handling 
			if (sUseTradeReport == "true")
			    Response.Write("\n        setTradeReportBlockDisplay(\"inline\");");
			else
			    Response.Write("\n        setTradeReportBlockDisplay(\"none\");");
			
			Response.Write("\n        var sDate = getDateAsString();"); 
			//Response.Write("\n        var entry = document.all(\"prcr_lastreporteddate\");"); 
			//Response.Write("\n        if (entry != null) "); 
			//Response.Write("\n            entry.value= sDate;"); 

			//Response.Write("\n        entry = document.getElementById(\"prtr_date\");"); 
			//Response.Write("\n        if (entry != null) "); 
			//Response.Write("\n            entry.value= sDate;"); 

			Response.Write("\n        entry = document.getElementById(\"comp_prconnectionlistdate\");"); 
			Response.Write("\n        if (entry != null) "); 
			Response.Write("\n            entry.value= '" + getDateAsString(connectionListDate) + "';"); 

            Response.Write("\n        entry = document.getElementById(\"prcr_leftcompanyid\");"); 
            Response.Write("\n        entry.value= '" + comp_companyid + "';"); 

            Response.Write("\n        entry = document.getElementById(\"prtr_responderid\");"); 
            Response.Write("\n        entry.value= '" + comp_companyid + "';"); 

            Response.Write("\n        AppendCell(\"_Captprtr_highcredit\", \"td_prtr_integrityid\");");
            Response.Write("\n        AppendCell(\"_Captprtr_integrityid\", \"td_prtr_payratingid\");");
            //Response.Write("\n        document.getElementById(\"prcr_rightcompanyidTEXT\").addEventListener(\"blur\", SetCompanyListener);");
            Response.Write("\n    }");
            Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
            Response.Write("\n    if (window.addEventListener) { document.getElementById(\"prcr_rightcompanyidTEXT\").addEventListener(\"blur\", SetCompanyListener); } else {document.getElementById(\"prcr_rightcompanyidTEXT\").attachEvent(\"onblur\", SetCompanyListener); }");

            Response.Write("\n</script>");
  		}
   	}

    displayUserMsg();
}

function doIndustryCheck (left, right, relationshipType)
{
    if ((eWare.Mode == Save) || (eWare.Mode == 99))
    {
        // If the relationship type is NOT 27, 28, 29 or 36, implement the industry check.
        // If one is “L” and the other is not “L”, display a user message “Unable to save this company relationship due to industry type mismatch.”.  Then exit the function.
        if((relationshipType != "27") &&
            (relationshipType != "28") &&
            (relationshipType != "29") &&
            (relationshipType != "36"))
        {
            var recLeftCompany = eWare.FindRecord("company","comp_companyid=" + left);
            var recRightCompany = eWare.FindRecord("company","comp_companyid=" + right);

            if ( (recLeftCompany("comp_PRIndustryType") == "L" && recRightCompany("comp_PRIndustryType") != "L") ||
                 (recLeftCompany("comp_PRIndustryType") != "L" && recRightCompany("comp_PRIndustryType") == "L")       )
            {
                var errorMsg = "Unable to save this company relationship due to industry type mismatch.";
                return errorMsg;
            }
        }
    }
    
    return "";
}
%>
<!-- #include file="CompanyFooters.asp" -->