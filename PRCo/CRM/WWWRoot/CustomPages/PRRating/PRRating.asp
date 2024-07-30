<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="..\PRCompany\CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
function doPage()
{
    //bDebug = true;
    DEBUG(sURL);
    var sSecurityGroups = "1,2,10";

    blkContainer.CheckLocks = false;
    sContinueUrl = eWare.URL("PRCompany/PRCompanyRatingListing.asp") + "&comp_companyid="+ comp_companyid;
    
    prra_ratingid = getIdValue("prra_ratingid");
    if (prra_ratingid != "-1")
    {
        recRating = eWare.FindRecord("PRRating", "prra_ratingid=" + prra_ratingid);
        sSummaryUrl = eWare.URL("PRRating/PRRating.asp") + "&prra_ratingid=" + prra_ratingid;

    }    
    recCurrent = eWare.FindRecord("PRRating","prra_Current='Y' AND prra_CompanyId=" + comp_companyid);
    recNumerals = null;
    if (eWare.Mode == Save || eWare.Mode == Edit || (eWare.Mode == View && prra_ratingid == -1))
    {
        // We'll need rating numberals for each of these actions
        
        // Query for all of the rating numerals now, but build a list of what the user can actualy modify
        // for use later.
        sSecurityRNString = "";
        
        sRNString = "";
        sSQL = "SELECT prrn_RatingNumeralId, prrn_Name, prrn_Type, capt_us as prrn_Desc " +
                 "FROM PRRatingNumeral WITH (NOLOCK) " +
                      "INNER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'prrn_Name' AND prrn_Name = capt_code ";


        if (!isUserInGroup(sSecurityGroups)) {
            if (isUserInGroup("4,5,6"))    
                sSecurityRNString = ",30,31,32,35,40,45,87,89,";
            else if (isUserInGroup("8"))
                sSecurityRNString = ",54,55,56,57,58,";
        }

        if (!isUserInGroup("4,5,6,8")) {
            if (recCompany.comp_PRType == "B")
                sRNString = "not in (60,82,84,86)";
            else
                sRNString = "not in (80)";
        }                                
        
        sSQL = sSQL + " WHERE prrn_IndustryType LIKE '%," + recCompany.comp_PRIndustryType + ",%' ";
        if (sRNString != "") {
            sSQL = sSQL + " AND prrn_RatingNumeralId " + sRNString;
        }
        sSQL = sSQL + " ORDER BY prrn_RatingNumeralId ";

        recNumerals = eWare.CreateQueryObj(sSQL);
        recNumerals.SelectSQL();
    }

    var bRedirect = false;

    if (eWare.Mode == PreDelete )  {
        bRedirect = true;

        CreateTransactionDetail(prra_ratingid, "Delete");
        
        //Perform a physical delete of the Rating Record
        sql = "DELETE FROM PRRating WHERE prra_RatingID="+ prra_ratingid;
        
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
        Response.Redirect(sContinueUrl);
    }

    if (eWare.Mode == Save)
    {
        bRedirect = true;
        var bError = false;
        // As of Build 2.1, we are allowing the edit of fields from PRRating instead of alwyas creating new
        if (prra_ratingid != "-1")
        {   
	        prra_publishedanalysis = new String (Request.Form.Item("prra_publishedanalysis"));
	        if (prra_publishedanalysis != null)
	            recRating.prra_publishedanalysis = prra_publishedanalysis;

	        prra_internalanalysis = new String (Request.Form.Item("prra_internalanalysis"));
	        if (prra_internalanalysis != null)
	            recRating.prra_internalanalysis = prra_internalanalysis;

	        prra_upgradedowngrade = new String (Request.Form.Item("prra_upgradedowngrade"));
	        if (prra_upgradedowngrade != null)
	            recRating.prra_upgradedowngrade = prra_upgradedowngrade;

	        prra_current = new String (Request.Form.Item("prra_current"));
	        if (prra_current == "Y")
	            recRating.prra_Current = "Y";  

	        recRating.SaveChanges();
	        Response.Redirect(sSummaryUrl);
	        return;
        }
        else
        {    
            // DumpFormValues();
            if (!recCurrent.eof)
            {    
                recCurrent.prra_Current = '';
                recCurrent.SaveChanges();
            }

            recNewRating=eWare.CreateRecord("PRRating");
            
	        // just before submitting this form, values are move from the combo boxes to 
	        // hidden input fields; this is because if the combo is disabled, its valus is 
	        // not submitted.
	        prra_creditworthid = new String (Request.Form.Item("_HIDDENprra_creditworthid"));
	        if (prra_creditworthid != null && !isEmpty(prra_creditworthid) && prra_creditworthid != "")
	            recNewRating.prra_creditworthid = prra_creditworthid;
	        prra_integrityid = new String (Request.Form.Item("_HIDDENprra_integrityid"));
	        if (prra_integrityid != null && !isEmpty(prra_integrityid) && prra_integrityid != "")
	            recNewRating.prra_integrityid = prra_integrityid;
	        prra_payratingid = new String (Request.Form.Item("_HIDDENprra_payratingid"));
	        if (prra_payratingid != null && !isEmpty(prra_payratingid) && prra_payratingid != "")
	            recNewRating.prra_payratingid = prra_payratingid;

            EntryGroup=eWare.GetBlock("PRRatingNewEntry");
            EntryGroup.Title="New Rating";
            //blkContainer.AddBlock(EntryGroup);

            if (EntryGroup.Validate())
            {
                EntryGroup.Execute(recNewRating);
                recNewRating.prra_Current = "Y";           
                recNewRating.SaveChanges();     
            }
            else
            {
                return;
            } 

            // now go through the possible list of Rating Numerals and save any that were selected
            while (!recNumerals.eof) 
            {
                prrn_ratingnumeralid = recNumerals("prrn_RatingNumeralId");
                prrn_name = recNumerals("prrn_name");
                
                // for each RN get the form's Select checkbox value
                chkSelect = Request.Form.Item("_chkNumeralSelect_"+prrn_name);
                if (chkSelect == "on")
                {
                    // we only do inserts on this type because there are no edits
                    recRNAssigned = eWare.CreateRecord("PRRatingNumeralAssigned");
                    recRNAssigned.pran_RatingId = recNewRating("prra_ratingid");
                    recRNAssigned.pran_RatingNumeralId = prrn_ratingnumeralid;
                    recRNAssigned.SaveChanges();


                    // if RN == 88, 89, 113, or 114, the comp_PRListingStatus gets updated
                    if ("(89)".indexOf(prrn_name) > -1)
                    {
                        recCompany.comp_PRListingStatus = "N3";
                        recCompany.SaveChanges();
                    }
                    else if ("(88)(113)(114)".indexOf(prrn_name) > -1)
                    {

                        // Only set this field if it's not already set
                        if ((recCompany.comp_PRListingStatus != "N4") &&
                            (recCompany.comp_PRListingStatus != "N5") &&
                            (recCompany.comp_PRListingStatus != "N6")) {

                            recCompany.comp_PRListingStatus = "N5";
                            recCompany.SaveChanges();
                        }
                    }
                    else if ("(27)(74)(76)(78)(85)(108)(124)(132)".indexOf(prrn_name) > -1)
                    {
                        recCompany.comp_PRListingStatus = "H";
                        recCompany.SaveChanges();
                    }
                }
                recNumerals.NextRecord();
            }
            CreateTransactionDetail(recNewRating.prra_RatingID, "Insert");
            
            Response.Redirect(sContinueUrl);
            return;
        }
    }

    // determine if we are in edit of view based upon whether the prra_ratingid was passed
    if (prra_ratingid == -1)
    {
        eWare.Mode = Edit;    

        sInvalidCWR = "";

        // determine if branches exist with the described Pay Ratings; this will apply for branches or
        // HQs and is necessary for determining rule violations upon save
        sSQL = "SELECT 1 " +
                 "FROM vPRCompanyRating " +
                "WHERE prra_Current = 'Y' " +
                  "AND prin_Name in ('X','XX','XX147','XXX148') " +
                  "AND prra_CompanyId in (SELECT comp_companyid FROM company WITH (NOLOCK) WHERE comp_PRHQId=";
        if (recCompany.comp_PRType == "B")
            sSQL = sSQL + recCompany.comp_PRHQId + ")";
        else
            sSQL = sSQL + recCompany.comp_CompanyId + ")";
        recLowPayRating = eWare.CreateQueryObj(sSQL,"");
        recLowPayRating.SelectSQL();
        sHQContent = "<INPUT TYPE=HIDDEN ID=\"branch_lowpayrating\" VALUE=\""; 
        if (!recLowPayRating.eof)
            sHQContent = sHQContent + "Y\">";    
        else
            sHQContent = sHQContent + "N\">";    

        // determine if any branch has a Rating nUmeral of 80; this will 
        // be necessary for determining rule violations upon save
        sSQL = "SELECT 1 " +
                 "FROM vPRCompanyRating " +
                "WHERE prra_Current = 'Y' " + 
                  "AND prra_AssignedRatingNumerals Like '%(80)%' " +
                  "AND prra_CompanyId in (SELECT comp_companyid FROM company WITH (NOLOCK) WHERE comp_PRHQId=";
        if (recCompany.comp_PRType == "B")
            sSQL = sSQL + recCompany.comp_PRHQId + ")";
        else
            sSQL = sSQL + recCompany.comp_CompanyId + ")";
        recBranchWith80 = eWare.CreateQueryObj(sSQL,"");
        recBranchWith80.SelectSQL();
        sHQContent = "<INPUT TYPE=HIDDEN ID=\"branch_with80\" VALUE=\""; 
        if (!recBranchWith80.eof)
            sHQContent = sHQContent + "Y\">";    
        else
            sHQContent = sHQContent + "N\">";    

        sSQL = "SELECT 1 " +
                 "FROM PRRating WITH (NOLOCK) " +
                      "INNER JOIN PRCompanyRelationship ON prcr_RightCompanyId="+recCompany.comp_companyid + " " +
                                                    "AND prcr_LeftCompanyId = prra_companyid " + 
                                                    "AND prcr_Type in ('27','28') " + 
               "WHERE prra_Current = 'Y' " +
                 "AND prra_creditworthid IS NOT NULL ";
        recAllow150 = eWare.CreateQueryObj(sSQL,"");
        recAllow150.SelectSQL();
        sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"allow150\" VALUE=\""; 
        if (!recAllow150.eof)
        {
            sHQContent = sHQContent + "Y\">";    
        }
        else
        {
            sInvalidCWR = sInvalidCWR + "'(150)'";
            sHQContent = sHQContent + "N\">";    
        }
        
        recHQ = null;
        recHQRating = null;
        if (recCompany.comp_PRType == "B")
        {
            
            recHQ = eWare.FindRecord("Company","comp_companyid="+recCompany.comp_PRHQId);
            sSQL = "SELECT * FROM vPRCompanyRating " +
                    "WHERE prra_Current = 'Y' AND prra_CompanyId=" + recCompany.comp_PRHQId;
            recHQRating = eWare.CreateQueryObj(sSQL,"");
            recHQRating.SelectSQL();

            hqprra_AssignedRatingNumerals = "";
            hqprcw_Name = "";
            hqprra_CreditWorthId = "";
            hqprin_Name = "";
            hqprra_IntegrityId = "";
            hqprpy_Name = "";
            hqprra_PayRatingId = "";
            if (!recHQRating.eof)
            {
                hqprra_AssignedRatingNumerals = recHQRating("prra_AssignedRatingNumerals");
                if (!isEmpty(recHQRating("prcw_Name")))
                    hqprcw_Name = recHQRating("prcw_Name");
                if (!isEmpty(recHQRating("prin_Name")))
                    hqprin_Name = recHQRating("prin_Name");
                if (!isEmpty(recHQRating("prra_IntegrityId")))
                    hqprra_IntegrityId = recHQRating("prra_IntegrityId");
                if (!isEmpty(recHQRating("prpy_Name")))
                    hqprpy_Name = recHQRating("prpy_Name");
                if (!isEmpty(recHQRating("prra_PayRatingId")))
                    hqprra_PayRatingId = recHQRating("prra_PayRatingId");
            }
                
            
            sHQContent = createAccpacBlockHeader("HQInfo","Headquarter's Rating Info");
            sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"hq_prra_assignedratingnumerals\" VALUE=\"" + hqprra_AssignedRatingNumerals + "\">";
            sHQContent = sHQContent + "<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0>";
            sCaption = eWare.GetTrans("ColNames","comp_PRHQId");
            sHQContent = sHQContent + "<TR><TD VALIGN=TOP >&nbsp;</TD><TD VALIGN=TOP COLSPAN=2><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>" +
                                            "<SPAN CLASS=VIEWBOX>" + recHQ.comp_Name + "</SPAN></TD><TD VALIGN=TOP >&nbsp;</TD></TR>";

            sCaption = eWare.GetTrans("ColNames","prra_CreditWorthId");
            sHQContent = sHQContent + "<TR><TD>&nbsp;</TD>"; 
            sHQContent = sHQContent + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>" ;
            if (!recHQRating.eof)
                sHQContent = sHQContent + "<SPAN CLASS=VIEWBOX>" + hqprcw_Name + "</SPAN>";
            sHQContent = sHQContent + "</TD>";
            sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"hq_prcw_name\" VALUE=\"" + hqprcw_Name + "\">";
            sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"hq_prra_creditworthid\" VALUE=\"" + hqprra_CreditWorthId + "\">";

            sCaption = eWare.GetTrans("ColNames","prra_IntegrityId");
            sHQContent = sHQContent + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>"; 
            if (!recHQRating.eof)
                sHQContent = sHQContent + "<SPAN CLASS=VIEWBOX>" + hqprin_Name + "</SPAN>";
            sHQContent = sHQContent + "</TD>";
            sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"hq_prin_name\" VALUE=\"" + hqprin_Name + "\">";
            sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"hq_prra_integrityid\" VALUE=\"" + hqprra_IntegrityId + "\">";

            sCaption = eWare.GetTrans("ColNames","prra_PayRatingId");
            sHQContent = sHQContent + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>"; 
            if (!recHQRating.eof)
                sHQContent = sHQContent + "<SPAN CLASS=VIEWBOX>" + hqprpy_Name + "</SPAN>";
            sHQContent = sHQContent + "</TD>";
            sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"hq_prpy_name\" VALUE=\"" + hqprpy_Name + "\">";
            sHQContent = sHQContent + "<INPUT TYPE=HIDDEN ID=\"hq_prra_payratingid\" VALUE=\"" + hqprra_PayRatingId + "\">";

            sHQContent = sHQContent + "<TD>&nbsp;</TD></TR>"; 
            sHQContent = sHQContent + "</TABLE>"; 

            sHQContent = sHQContent + createAccpacBlockFooter();
        }
            
        blkContent = eWare.GetBlock("content");
        blkContent.Contents = sHQContent;
        blkContainer.AddBlock(blkContent);
        
        recRating = eWare.FindRecord("PRRating", "prra_Current='Y' and prra_companyid=" + comp_companyid);
        viewRating = null;
        if (recRating.eof)
            recRating=eWare.CreateRecord("PRRating");
        else
        {
            sSQL = "SELECT * FROM vPRCompanyRating " +
                    "WHERE prra_Current = 'Y' AND prra_CompanyId=" + comp_companyid;
            viewRating = eWare.CreateQueryObj(sSQL,"");
            viewRating.SelectSQL();
        }
        EntryGroup=eWare.GetBlock("PRRatingNewEntry");
        EntryGroup.Title="New Rating";

        entry = EntryGroup.GetEntry("prra_current");
        entry.Hidden = true;
        entry.DefaultValue = "Y";

        entry = EntryGroup.GetEntry("prra_Rated");
        entry.Hidden = true;

        entry = EntryGroup.GetEntry("prra_Date");
        entry.DefaultValue = new Date();
        blkContainer.AddBlock(EntryGroup);
        
    %>
        <!-- #include file ="RatingDropdowns.asp" -->
        <!-- #include file ="PRRatingNumeralsInclude.asp" -->
    <%

        sRatingNumeralContents = "<table><TR><TD ROWSPAN=20 ALIGN=LEFT ID=\"_td_tblRatingNumeralSection\">" + sRatingNumeralContents + "</TD></tr></table>";
        Entry = EntryGroup.GetEntry("prra_CompanyId");
        Entry.DefaultValue = comp_companyid;
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sContinueUrl));
        if (isUserInGroup("1,2,4,5,6,8,10"))
            blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

            eWare.AddContent(blkContainer.Execute(recRating));

            RefreshTabs=Request.QueryString("RefreshTabs");
            if( RefreshTabs = 'Y' )
                sResponse = eWare.GetPage('Company');
            else
                sResponse = eWare.GetPage();

            Response.Write(sResponse);
            
            Response.Write(sNewLine );
            Response.Write(sRatingNumeralContents );
            //sRatingNumeralContents = sRatingNumeralContents.replace(/\"/g,'\\\"');

            Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n");
            if (prra_ratingid == -1)
            {
                Response.Write("<script type=\"text/javascript\" src=\"PRRatingInclude.js\"></script>\n");
            }
            Response.Write("<script type=\"text/javascript\" src=\"../jquery.tablescroll.js\"></script>\n");

            Response.Write("\n<script type=\"text/javascript\">");
            if (isUserInGroup("1,2,10") )
            {
                Response.Write("\n        bAlwaysDisable_CreditWorth = false; ");
                Response.Write("\n        bAlwaysDisable_Integrity = false; ");
                Response.Write("\n        bAlwaysDisable_Pay = false; ");
            }
            Response.Write("\n        entry = document.getElementById(\"prra_date\");");
            Response.Write("\n        if (entry != null) ");
            dtNow = new Date();
            Response.Write("\n            entry.value=\""+ (dtNow.getMonth()+1) +"/"+dtNow.getDate()+"/"+dtNow.getYear()+"\" ");
            
            Response.Write("\n        AppendRow(\"_Captprra_date\", \"_tr_RatingValues\");");
            Response.Write("\n        AppendCell(\"_Captprra_companyid\", \"_td_tblRatingNumeralSection\");");
            Response.Write("\n        processRatingNumeralRules();");
            Response.Write("\n        var comp_PRIndustryType=\"" + recCompany.comp_PRIndustryType + "\";");

            Response.Write("\n       $(document).ready(function($) { $('#_NumeralsListing').tableScroll({height:270}); }); ");

            // New ratings should not default the upgrade/downgrade field 
            // to the previous value.  It should default to none.
            if (prra_ratingid == -1) {
                Response.Write("\n        entry = document.getElementById(\"prra_upgradedowngrade\").value = \"\";");
            }


        
            Response.Write("\n</script>");
    }
    else
    {
        // can now be edit of view
        //eWare.Mode = View;
        EntryGroup=eWare.GetBlock("PRRatingNewEntry");
        EntryGroup.Title="Rating Summary";

        // cannot edit certain fields.
        entry  = EntryGroup.GetEntry("prra_Date");
        entry.ReadOnly = true;
        entry  = EntryGroup.GetEntry("prra_Current");
        entry.ReadOnly = true;
        blkContainer.AddBlock(EntryGroup);
    
        if (eWare.Mode == View){
            blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
            
            if (iTrxStatus == TRX_STATUS_EDIT) {
                if (isUserInGroup(sSecurityGroups)) {
                    sDeleteUrl = changeKey(sURL, "em", "3");
                    blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
                    blkContainer.AddButton(eWare.Button("Change","edit.gif",
                        "javascript:document.EntryForm.action='" + sSummaryUrl + "';document.EntryForm.submit();"));
                }
            }
        } else {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryUrl));
    	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }            
        
        eWare.AddContent(blkContainer.Execute(recRating));
        sResponse = eWare.GetPage();

        sSQL = "SELECT * FROM vPRCompanyRating " +
                "WHERE prra_RatingId=" + prra_ratingid;
        vPRCompanyRating = eWare.CreateQueryObj(sSQL,"");
        vPRCompanyRating.SelectSQL();
        if (!vPRCompanyRating.eof)
        {
            prcw_name = vPRCompanyRating("prcw_Name");
            if (isEmpty(prcw_name))
                prcw_name = "&nbsp;";
            prin_name = vPRCompanyRating("prin_Name");
            if (isEmpty(prin_name))
                prin_name = "&nbsp;";
            prpy_name = vPRCompanyRating("prpy_Name");
            if (isEmpty(prpy_name))
                prpy_name = "&nbsp;";
            prra_assignedratingnumerals = vPRCompanyRating("prra_AssignedRatingNumerals");
            if (isEmpty(prra_assignedratingnumerals))
                prra_assignedratingnumerals = "&nbsp;";
        }
        
        sCaption = eWare.GetTrans("ColNames","prra_CreditWorthId");
        sRatingRow = "<TABLE><TR ID=\"_tr_RatingRow\">"; 
        sRatingRow = sRatingRow + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>" ;
        sRatingRow = sRatingRow + "<SPAN CLASS=VIEWBOX>" + prcw_name + "</SPAN>";
        sRatingRow = sRatingRow + "</TD>";

        if (recCompany.comp_PRIndustryType != "L") {
            sCaption = eWare.GetTrans("ColNames","prra_IntegrityId");
            sRatingRow = sRatingRow + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>"; 
            sRatingRow = sRatingRow + "<SPAN CLASS=VIEWBOX>" + prin_name + "</SPAN>";
            sRatingRow = sRatingRow + "</TD>";

            sCaption = eWare.GetTrans("ColNames","prra_PayRatingId");
            sRatingRow = sRatingRow + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>"; 
            sRatingRow = sRatingRow + "<SPAN CLASS=VIEWBOX>" + prpy_name + "</SPAN>";
            sRatingRow = sRatingRow + "</TD>";
        }

        sRatingRow = sRatingRow + "</TR>"; 

        // now add the rating numerals row
        sRatingRow = sRatingRow + "<TR ID=\"_tr_NumeralsRow\">"; 
        //sCaption = eWare.GetTrans("ColNames","prra_AssignedRatingNumerals");
        sCaption = "Assigned Rating Numerals";
        sRatingRow = sRatingRow + "<TD VALIGN=TOP><SPAN CLASS=VIEWBOXCAPTION>"+sCaption+":</SPAN><br>"; 
        sRatingRow = sRatingRow + "<SPAN CLASS=VIEWBOX>" + prra_assignedratingnumerals + "</SPAN>";
        sRatingRow = sRatingRow + "</TD>";
        sRatingRow = sRatingRow + "</TR>"; 
        sRatingRow = sRatingRow + "</TABLE>"; 

        Response.Write(sResponse);
        Response.Write(sRatingRow);
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n");
        Response.Write("\n<script type=\"text/javascript\" >");
        Response.Write("\n        AppendRow(\"_Captprra_date\", \"_tr_NumeralsRow\");");
        Response.Write("\n        AppendRow(\"_Captprra_date\", \"_tr_RatingRow\");");

        Response.Write("\n</script>");
    }
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
doPage();

function CreateTransactionDetail(iRatingID, sAction) {

    // Manually build the transaction detail record    
    var sValue = "";    
    var sOldValue = "";    
    var sNewValue = "";    
    var recRatingView = eWare.FindRecord("vPRCompanyRating", "prra_ratingid=" + iRatingID);
    var dtDate = new Date(recRatingView.prra_Date);
   
    sValue = (dtDate.getMonth()+1).toString() + "/" + dtDate.getDate().toString()  + "/" + dtDate.getYear().toString()
    sValue += ", " + recRatingView.prra_RatingLine
    
    if (sAction == "Delete") {
        sOldValue = sValue;
    } else {
        sNewValue = sValue;
    }
    
    qryTransDetail = eWare.CreateQueryObj("usp_CreateTransactionDetail " + recTrx.prtx_TransactionId + ", 'Rating', '" + sAction + "', 'Effective Date, Rating Line', '" + sOldValue + "', '" + sNewValue + "'");
    qryTransDetail.ExecSql();
}


%>
<!-- #include file="../PRCompany/CompanyFooters.asp" -->