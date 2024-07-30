<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2019

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

<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\PRPerson\PersonIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    function setChangeTracking(blk, field)
    {
        var entry = blk.GetEntry(field);
        if (entry != null)
            entry.OnChangeScript = "onChangeHandler();setCaretTextRange();";
    }

function doPage()
{    
    //bDebug = true;
    DEBUG(sURL);
    DEBUG(comp_companyid)
    
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");


    // this is used in the form load at the bottom of th page; if necessary, this will contain
    // instructions on drawing the CompanySelect dropdown to the page.
    var sCompanySelectDraw = "";

    // sPostBlockData is used to provide messages to the user for th C\S Item block
    var sPostBlockData = null;

    // determine if the user is part of the Listing Specialist group
    var bIsListingSpecialist = false;
    if (isUserInGroup("4,10"))
        bIsListingSpecialist = true;

    var bIsRatingAnalyst = false;
    if (isUserInGroup("1,2,10"))
        bIsRatingAnalyst = true;


    // Determine if this is new or edit
    var sCustomAction = new String(Request.QueryString("customact"));
    var prcs_CreditSheetId = getIdValue("prcs_CreditSheetId");
    var key0 = getIdValue("key0");
    
    var szAuthorNotes = "";
    var bHideNotes = false;
    var sTransactionSelectDraw = "";
    
    var prcs_SourceType = getIdValue("prcs_sourcetype");
    var prcs_SourceId = getIdValue("prcs_sourceid");
    

    // if there is no credit sheet and we are on MyCRM redirect to the listing
    if (prcs_CreditSheetId == "-1" && (key0=="4"||key0=="5"))
    {
        var sRedirectURL = eWare.URL("PRCreditsheet/PRCreditSheetListing.asp") + "&T=Company&Capt=Transactions";
        Response.Redirect(sRedirectURL);
        return;
    }

    // indicate that this is new
    if (prcs_CreditSheetId == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
            
        recCreditSheet=eWare.CreateRecord("PRCreditSheet");
        recCreditSheet.prcs_Status = "N";

        // the channelid (team) for cs items will be 4-Listing Specialist
        recCreditSheet.prcs_ChannelId = "4";

        if (comp_companyid != -1) {
            recCreditSheet.prcs_CompanyId = comp_companyid;
            recCreditSheet.prcs_CityId = recCompany.comp_PRListingCityID;
        } else if (eWare.Mode == Save) {
            // we need the company id in order to save; check the entire form
            comp_id = getIdValue("prcs_companyid");
            if (comp_id != -1)
            {
                comp_companyid  = comp_id;
                recCreditSheet.prcs_CompanyId = comp_companyid;
            }
        }
    }
    else
    {
        recCreditSheet = eWare.FindRecord("PRCreditSheet", "prcs_CreditSheetId=" + prcs_CreditSheetId);
        // all credit sheets should have a company assigned
        comp_companyid = recCreditSheet("prcs_CompanyId");
        prcs_SourceType = recCreditSheet("prcs_SourceType");
        prcs_SourceId = recCreditSheet("prcs_SourceId");
    }
    



    blkPage = eWare.GetBlock('container');
    blkPage.DisplayButton(Button_Default) = false;

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    //blkContainer.CheckLocks = false;
    blkContainer.NewLine = false;

    var bIsCompany = false;

    if (comp_companyid != -1 ) {
        bIsCompany = true;
        
        // Create a listing block
        blkContainerListing = eWare.GetBlock('container');
        blkContainerListing.DisplayButton(Button_Default) = false;
        blkContainerListing.Width = "250";

        blkCompanyListing=eWare.GetBlock("content");
        blkCompanyListing.contents = createAccpacBlockHeader("ViewListing", "Listing");
        var sSQL = "SELECT RetValue = dbo.ufn_GetListingFromCompany (" + comp_companyid + ", 0, 0) ";

        //Response.Write(sSQL);

	    var objQuery = eWare.CreateQueryObj(sSQL,''); 
        objQuery.SelectSQL(); 
        var sListing = "No Listing Available";
        if (!objQuery.EOF)
        {
            sListing = objQuery("RetValue");
        }
        blkCompanyListing.contents += "<span class=\"VIEWBOX\">" + sListing + "</span>";
        blkCompanyListing.contents += createAccpacBlockFooter();

        blkContainerListing.AddBlock(blkCompanyListing);
    }
        
    blkHeader=eWare.GetBlock("PRCreditSheetHeader");
    blkHeader.Title="Credit Sheet Header";
    blkHeader.NewLine = false;

    if (recCompany("comp_PRIndustryType") != "L") {
        blkHeader.GetEntry("prcs_NewListing").ReadOnly = true;
    }



    // add the header right away
    blkContainer.AddBlock(blkHeader);

    blkCSItem=eWare.GetBlock("PRCreditSheetClassic");
    blkCSItem.Title="Credit Sheet Item";




    if (bNew)
    {                
        recCreditSheet.prcs_AuthorId = user_userid;
        entryAuthor = blkHeader.GetEntry("prcs_AuthorId");
        
        // The following lines do not work in Accpac 5.7 so we are just going to 
        // make the author and approver invisible for new items
        //entryAuthor.DefaultType = 1;
        //entryAuthor.DefaultValue = user_userid;
        
        entryAuthor.Hidden = true;

        blkHeader.GetEntry("prcs_ApproverId").Hidden = true;
        blkHeader.GetEntry("prcs_ApprovalDate").Hidden = true;
        
        entryCityID = blkCSItem.GetEntry("prcs_CityID");
        entryCityID.DefaultValue = recCompany.comp_PRListingCityID;
    }    

    var bIsAuthor = recCreditSheet("prcs_AuthorId" ) == user_userid;

    // Determine where we came from 
    var prevCustomURL = String(Request.QueryString("PrevCustomURL"));
    if (isEmpty(prevCustomURL))
        prevCustomURL = "PRCreditSheet/PRCreditSheetListing.asp";
    DEBUG("<br>PrevCustomURL:" + prevCustomURL);
    if ((prevCustomURL.toLowerCase()).indexOf(("/"+sInstallName+ "/custompages/").toLowerCase()) > -1)
    {
        DEBUG("Removing 'crm/custompages'");
        prevCustomURL = prevCustomURL.substring(("/"+sInstallName+ "/CustomPages/").length);
    } 
    DEBUG("<br>PrevCustomURL:" + prevCustomURL);
    sListingAction = eWare.URL(prevCustomURL);
    sSummaryAction = eWare.URL("PRCreditSheet/PRCreditSheet.asp") + "&prcs_CreditSheetId=" + prcs_CreditSheetId
                                                                  + "&prevCustomURL="+prevCustomURL + "&T=Company&Capt=Transactions";


//Response.Write("<p>" + prevCustomURL);

    // Mode 95 means lock the CS item.
    if (eWare.Mode == 95) {
        recCreditSheet.prcs_Locked = "Y";
        recCreditSheet.SaveChanges();
        Response.Redirect(sSummaryAction);
        return;
    }

    if (eWare.Mode == 96) {
        recCreditSheet.prcs_Locked = "Z";  //Special flag for the trigger
        recCreditSheet.SaveChanges();
        Response.Redirect(sSummaryAction);
        return;
    }




    // determine if a publishable CS has been used in Published Products; specifically how many
    var nPublishedProductUseCount = 0;
    if (!isEmpty(recCreditSheet("prcs_ExpressUpdatePubDate")))
        nPublishedProductUseCount++;
    if (!isEmpty(recCreditSheet("prcs_WeeklyCSPubDate")))
        nPublishedProductUseCount++;
    if (!isEmpty(recCreditSheet("prcs_EBBUpdatePubDate")))
        nPublishedProductUseCount++;
    if (!isEmpty(recCreditSheet("prcs_AUSDate")))
        nPublishedProductUseCount++;

    
/*****  HANDLE THE EDIT ACTION   ******/
    if (eWare.Mode == Edit)
    {
        // create a table to hold the C/S Phrases that the use can select to add to various text fields
        sContents = "<table CELLPADDING=0 CELLSPACING=0 BORDER=0 style=\"display:none;\">";
        
        sContents += "<tr id=\"tr_csphraseselection\">";
        sContents += "<td colspan=\"5\" valign=\"top\"><table CELLPADDING=2 CELLSPACING=0 BORDER=1 RULES=NONE>";
        sContents += "<tr><td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Credit Sheet Phrase:</span>";
        sContents += "<br/><select CLASS=\"EDIT\" ID=\"CSPhrase\" >";
        var recPhrases = eWare.FindRecord("PRCSPhrase","");
        recPhrases.OrderBy = "prcsp_Order";
        while (!recPhrases.eof) 
        {
            sContents += "<option value=\""+ recPhrases("prcsp_CSPhraseId") + "\">" + recPhrases("prcsp_Phrase") + "</option>";
            recPhrases.NextRecord();
        }
        sContents += "</select>&nbsp;&nbsp;";
        sContents += "</td><td>";    
        sContents += "<img class=\"ButtonItem\" align=\"left\" border=\"0\" src=\"../../img/Buttons/new.gif\" " + 
                        " onclick=\"javascript:insertTextAtCursor('CSPhrase');\">";
        sContents += "</td><td>";    
        sContents += "<span class=\"ButtonItem\" onclick=\"javascript:insertTextAtCursor('CSPhrase');\">";
        sContents += "Insert<br/>Phrase</span>";    
        sContents += "</td></tr>";
        sContents += "</table></td>";
        sContents += "</tr>";

        sContents += "<tr height=\"5\"><td></td></tr>";
        sContents += "</table>";
        Response.Write(sContents); 
        
        // we're going to disable accpac's default handling of locking and do it manually with the RecordLock call below
        blkContainer.CheckLocks = false;
        if (!bIsListingSpecialist && !bIsRatingAnalyst && !bIsAuthor)
        {
            sLockContent = getErrorHeader("Credit Sheet Items can only be edited by members of the Listing Specialist group.");
            eWare.AddContent(sLockContent + "<br/>");
            eWare.Mode = View;
        } else {
            sLockMsg = "";
            if (!recCreditSheet.eof)
                sLockMsg = recCreditSheet.RecordLock();
            if (sLockMsg != "")
            {
                // determine who has this locked
                sLockUser = sLockMsg.substring("CurrRecordIsbeingEdited ".length)
                sUserName = recUser.user_FirstName + " " + recUser.user_LastName ;
                //Response.Write(" sLockMsg: " + sLockMsg + "<br/>");
                //Response.Write(" Lock User: " + sLockUser + "  Curr User: " + sUserName + "<br/>");
                
                if ((sLockUser != "") &&
                    (sUserName != sLockUser))
                {
                    sLockContent = getErrorHeader("This record is currently Locked by " + sLockUser + ".");
                    eWare.AddContent(sLockContent + "<br/>");
                    eWare.Mode = View;
                }
            }
        }
        
        
       
        // if we are still good to edit...
        if (eWare.Mode == Edit)
        {
            Response.Write("<script type=\"text/javascript\" src=\"../DataChangeInclude.js\"></script>");
            Response.Write("<script type=\"text/javascript\" src=\"CreditSheetInclude.js\"></script>");
            // Any field that can trigger a "data change" must be listed
            setChangeTracking(blkCSItem, "prcs_Tradestyle");
            setChangeTracking(blkCSItem, "prcs_CityID");
            setChangeTracking(blkCSItem, "prcs_Numeral");
            setChangeTracking(blkCSItem, "prcs_Parenthetical");
            setChangeTracking(blkCSItem, "prcs_Change");
            setChangeTracking(blkCSItem, "prcs_RatingLine");
            setChangeTracking(blkCSItem, "prcs_RatingValue");
            setChangeTracking(blkCSItem, "prcs_PreviousRatingValue");
            setChangeTracking(blkCSItem, "prcs_Notes");
        }


        if (bNew)
        {
            //if this is new, let's check what type of entity sent us here 
            // our options are: CompanyTransaction(TX), PersonTransaction(TX), BusinessEvent(BE), PersonEvent(PE)
            var sCompanySelectDisplay = null;
            var recTransaction = null;
            var prtx_PersonId = null;

            var prcs_SourceType = getIdValue("prcs_SourceType");
            var prcs_SourceId = getIdValue("prcs_SourceId");
            if (prcs_SourceType != "-1")
            {
                recCreditSheet.prcs_SourceType = prcs_SourceType;
                recCreditSheet.prcs_SourceId = prcs_SourceId;
                if (prcs_SourceType == "TX")
                {
                    // determine the related transaction
                    recTransaction = eWare.FindRecord("PRTransaction", "prtx_TransactionId="+ prcs_SourceId);
                    prtx_PersonId = recTransaction("prtx_PersonId");
                    if (isEmpty(prtx_PersonId))
                        prtx_PersonId = null;

                    var sSQL = "SELECT 1 FROM PRTRansactionDetail WITH (NOLOCK) " +
                               "WHERE prtd_EntityName = 'Rating' AND prtd_TransactionId="+ prcs_SourceId; 
                    var recRatingChange = eWare.CreateQueryObj(sSQL, "");
                    recRatingChange.SelectSQL();
                    if (!recRatingChange.eof)
                    {
                        entryRatingChangeVerbiage = blkCSItem.GetEntry("prcs_RatingChangeVerbiage");
                        entryRatingChangeVerbiage.DefaultValue = "Current";
                        recCreditSheet.prcs_RatingChangeVerbiage = "Current";

                        // get the previous rating value
                        var sSQL = "select top 1 prra_RatingLine from vPRCompanyRating " +
                                " where prra_Current is null and prra_CompanyId=" + comp_companyid + 
                                " order by prra_Date desc " ;
                        var recPreviousRating = eWare.CreateQueryObj(sSQL, "");
                        recPreviousRating.SelectSQL();
                        if (!recPreviousRating.eof)
                        {
                            entry = blkCSItem.GetEntry("prcs_PreviousRatingValue");
                            entry.DefaultValue = recPreviousRating("prra_RatingLine");
                            recCreditSheet.prcs_PreviousRatingValue = recPreviousRating("prra_RatingLine");
                        }                

                        // get the current rating
                        sSQL = "select prra_RatingLine from vPRCompanyRating where prra_Current='Y' and prra_CompanyId = " + comp_companyid;
                        var recRating = eWare.CreateQueryObj(sSQL, "");
                        recRating.SelectSQL();
                        if (!recRating.eof)
                        {
                            entryRatingValue = blkCSItem.GetEntry("prcs_RatingValue");
                            entryRatingValue.DefaultValue = recRating("prra_RatingLine");
                            recCreditSheet.prcs_RatingValue = recRating("prra_RatingLine");
                        }                
                    }
                }
            } 


            // if this is a PE or a Tranasction for a person, we need to let the user select a company
            if (prcs_SourceType == "PE" || 
                (prcs_SourceType == "TX" && prtx_PersonId != null ))
            {
                // determine if we have created a company history record during this transaction
                var sNewHistoryValue = "";
                var sSQL = "SELECT prtd_NewValue FROM PRTransactionDetail WITH (NOLOCK) " +
                           "WHERE prtd_EntityName = 'History' AND prtd_Action = 'Insert' AND prtd_TransactionId="+ prcs_SourceId; 
                var recTrxDetail = eWare.CreateQueryObj(sSQL, "");
                recTrxDetail.SelectSQL();
                if (!recTrxDetail.eof)
                    sNewHistoryValue = recTrxDetail("prtd_NewValue");
                                    
                // draw the select box based upon the companies this person is linked to
                //<div style={display:none}> 
                sCompanySelectDisplay = "<div style={display:none}> <div ID=\"div_prcs_companyid\" >" + 
                    "<span ID=\"_Captprcs_companyid\" CLASS=VIEWBOXCAPTION>Company:</span><br/>" +
                    "<span><select CLASS=EDIT SIZE=1 NAME=\"prcs_companyid\">" ;
                // get the list of companies
                var sSQL = "SELECT peli_PersonId, comp_companyid, comp_Name, comp_PRListingCityId, comp_PRBookTradestyle " + 
                             "FROM Person_Link WITH (NOLOCK) " + 
                                  "INNER JOIN Company WITH (NOLOCK) ON peli_CompanyId = comp_CompanyId " + 
                            "WHERE peli_PersonId = " + prtx_PersonId;
                var recCompanies = eWare.CreateQueryObj(sSQL);
                recCompanies.SelectSQL();
                var sSelect = "";
                while (!recCompanies.eof) 
                {
                    sSelect = "";
                    sCompanyName = recCompanies("comp_name");
                    if (sNewHistoryValue != "" && sNewHistoryValue.indexOf(sCompanyName) != -1)
                    {
                        sSelect = " SELECTED ";
                        entryTradestyle = blkCSItem.GetEntry("prcs_Tradestyle");
                        entryTradestyle.DefaultValue = recCompanies("comp_PRBookTradestyle");
                        entry = blkCSItem.GetEntry("prcs_CityId");
                        entry.DefaultValue = recCompanies("comp_PRListingCityId");
                    }
                    sCompanySelectDisplay += "<option " + sSelect + "VALUE=\""+ recCompanies("comp_companyid") + "\" >"+ sCompanyName + "</option> ";
                    recCompanies.NextRecord();
                }
                sCompanySelectDisplay += "</select></span><span>&nbsp;&nbsp;</span></div></div>";
                
                Response.Write(sCompanySelectDisplay);
                sCompanySelectDraw = " placeCompanySelect(\"_IDprcs_keyflag\", \"div_prcs_companyid\");";
                sCompanySelectDraw += " AppendCell(\"_CAPTprcs_publishabledate\", \"_td_force_left\");";
            }
            
            // Set the default values as appropriate
            if (comp_companyid != -1) {
                entryTradestyle = blkCSItem.GetEntry("prcs_Tradestyle");
                entryTradestyle.DefaultValue = recCompany("comp_PRBookTradestyle");
                recCreditSheet.prcs_Tradestyle = recCompany("comp_PRBookTradestyle");
            }            
        }






        // Handle associating the CS Item with
        // a Transaction.  We only display this in edit mode.
        if (eWare.Mode == Edit)
        {

            // Determine if the user should be able to select a
            // transaction. 
            var bDisplayTrx = false;
            if (bNew) {
                if ((prcs_SourceType == "TX") ||
                    (prcs_SourceType == "-1")) {
                    bDisplayTrx = true;
                }
            } else {
                if ((recCreditSheet.prcs_SourceType == "TX") ||
                    (recCreditSheet.prcs_SourceType == null)) {
                    bDisplayTrx = true;
                }
            }

            if (bDisplayTrx) {

                var selectedTransactionID = prcs_SourceId;
                if (bNew) {
                    recOpenTransaction = eWare.FindRecord("PRTransaction", "prtx_Status='O' AND prtx_CompanyID = " + comp_companyid);
                    if (!recOpenTransaction.EOF) {
                        selectedTransactionID = recOpenTransaction("prtx_TransactionID");
                    }
                }

                // Now build the Transaction Selection drop down list
                 var sSQL = "SELECT TOP 5 prtx_TransactionID, prtx_CreatedDate, prtx_CloseDate, prtx_Status, User_Logon " +
                              "FROM PRTransaction WITH (NOLOCK) " +
                                   "INNER JOIN Users WITH (NOLOCK) on prtx_CreatedBy = user_userID " +
                                   "LEFT OUTER JOIN PRCreditSheet WITH (NOLOCK) on prtx_TransactionID = prcs_SourceID AND prcs_SourceType = 'TX' " +
                             "WHERE prcs_SourceID IS NULL ";
                 
                 if (prcs_SourceType == "PE" || 
                    (prcs_SourceType == "TX" && prtx_PersonId != null )) {
                        sSQL += "AND prtx_PersonId = " + prtx_PersonId;
                 } else {
                        sSQL += "AND prtx_CompanyId = " + comp_companyid;
                 }
                    
                 sSQL += " ORDER BY prtx_CreatedDate DESC";
                
                sTransactionSelectDisplay = "<table><tr id=\"_tr_sourceid\"><td id=\"_td_sourceid\">" + 
                        "<span ID=\"_Captprcs_sourceid\" CLASS=VIEWBOXCAPTION>Transaction:</span><br/>" +
                        "<span><select class=\"EDIT\" size=\"1\" name=\"prcs_sourceid\">" +
                        "<option VALUE=\"\">-- None --</option>" ;
                        
                        
                var recTransactions = eWare.CreateQueryObj(sSQL);
                recTransactions.SelectSQL();
                var sSelect = "";
                while (!recTransactions.eof) 
                {
                    if (selectedTransactionID == recTransactions("prtx_TransactionID")) {
                        sSelect = " SELECTED ";
                    } else {
                        sSelect = "";
                    }
                    sTransactionSelectDisplay += "<option value=\""+ recTransactions("prtx_TransactionID") + "\" " + sSelect + " >";
                    
                    sTransactionSelectDisplay += getDateAsString(recTransactions("prtx_CreatedDate")); 
                    
                    if ( getDateAsString(recTransactions("prtx_Status")) == "O") {
                        sTransactionSelectDisplay += " - OPEN "; 
                    } else {
                        if ( getDateAsString(recTransactions("prtx_CloseDate")) != "12/30/1899") {
                            sTransactionSelectDisplay += " - " + getDateAsString(recTransactions("prtx_CloseDate")); 
                        }
                    }
                    sTransactionSelectDisplay += " - " + recTransactions("User_Logon"); 
                    sTransactionSelectDisplay += "</option>"; 
                    
                    recTransactions.NextRecord();
                }
                
                
                if ((sSelect == "") &&
                    (prcs_SourceId != "") &&
                    (prcs_SourceId != "-1") &&
                    (prcs_SourceId != null)) {
                    sSQL = "SELECT prtx_TransactionID, prtx_CreatedDate, prtx_CloseDate, prtx_Status, User_Logon FROM PRTransaction WITH (NOLOCK) INNER JOIN Users WITH (NOLOCK) on prtx_CreatedBy = user_userID WHERE prtx_TransactionID = " + prcs_SourceId
                    
                    recTransactions = eWare.CreateQueryObj(sSQL);
                    recTransactions.SelectSQL();
                    if (!recTransactions.eof) 
                    {
                        sTransactionSelectDisplay += "<option value=\""+ recTransactions("prtx_TransactionID") + "\" selected>";
                        sTransactionSelectDisplay += getDateAsString(recTransactions("prtx_CreatedDate")); 
                        
                        if ( getDateAsString(recTransactions("prtx_Status")) == "O") {
                            sTransactionSelectDisplay += " - OPEN "; 
                        } else {
                            if ( getDateAsString(recTransactions("prtx_CloseDate")) != "12/30/1899") {
                                sTransactionSelectDisplay += " - " + getDateAsString(recTransactions("prtx_CloseDate")); 
                            }
                        }
                        sTransactionSelectDisplay += " - " + recTransactions("User_Logon"); 
                        sTransactionSelectDisplay += "</option>"; 
                    }                    
                    
                }
                
                sTransactionSelectDisplay += "</select></span>" ;
                sTransactionSelectDisplay += "<input type=\"hidden\" name=\"prcs_sourcetype\" value=\"TX\"></td></tr></table>";
                    
            } else {
                // If we are not displaying the transaction drop down, then be sure to
                // have hidden field to hold any other specified source type and ID.
                sTransactionSelectDisplay = "<table><tr id=\"_tr_sourceid\"><td id=_td_sourceid>" +                 
                                            "<input type=\"hidden\" name=\"prcs_sourcetype\" value=\"" + prcs_SourceType + "\">" +
                                            "<input type=\"hidden\" name=\"prcs_sourceid\" value=\"" + prcs_SourceId + "\">" +
                                            "</td></tr></table>";
            }

            // Write the custom HTML to the page.  Then create JS that moves
            // this custom HTML to the appropriate position in the page (and DOM).
            Response.Write(sTransactionSelectDisplay);                                            
            sTransactionSelectDraw = " InsertRow(\"_Captprcs_authornotes\", \"_tr_sourceid\");";                                                              
        }


        // only the author can update author notes
        entryAuthorNotes = blkHeader.GetEntry("prcs_AuthorNotes");
        if (bIsAuthor)
        {
            entryAuthorNotes.ReadOnly = false;
            
            // If the user isn't a listing specialist and the status isn't "new"
            // then the key flag is locked.  Note: The "new" status means the
            // CS item hasn't been reviewed yet. 
            if (!bIsListingSpecialist && (recCreditSheet("prcs_Status") != "N"))
            {
                blkHeader.GetEntry("prcs_KeyFlag").ReadOnly = true;
            }        
        }
        else
        {
            entryAuthorNotes.ReadOnly = true;
            
            var szValue = "";
            if (!isEmpty(recCreditSheet("prcs_AuthorNotes"))) {
                szValue = recCreditSheet("prcs_AuthorNotes") 
            }

            bHideNotes = true;
	        szAuthorNotes = "\n<table id=\"tblentryAuthorNotes\">";
            szAuthorNotes += "\n<tr><td id=\"td_tblentryAuthorNotes\">";
            szAuthorNotes += "\n<input type=\"HIDDEN\" NAME=\"prcs_authornotes\" value=\"" + szValue + "\">";
            szAuthorNotes += "\n</td></tr></table>";
            Response.Write(szAuthorNotes);
        }


         blkHeader.GetEntry("prcs_LockedDate").ReadOnly = true;
         blkHeader.GetEntry("prcs_LockedByUser").ReadOnly = true;
         blkHeader.GetEntry("prcs_KilledDate").ReadOnly = true;
         blkHeader.GetEntry("prcs_KilledByUser").ReadOnly = true;


        // Determine which buttons to show
        if (bNew)
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"if (validate()) save();\""));
        
        // only listing specialists get these buttons
        if ((bIsListingSpecialist) && (prcs_CreditSheetId != "-1"))
        {
            if ("P,A".indexOf(recCreditSheet("prcs_Status")) == -1)
                blkContainer.AddButton(eWare.Button("Approve", "save.gif", "#\" onClick=\"if (validate('A')) { save();}"));

            // "Do Not Approve" shows if this hasn't been publishable
            if ("P,D".indexOf(recCreditSheet("prcs_Status")) == -1)
                blkContainer.AddButton(eWare.Button("Hold Approval", "save.gif", "#\" onClick=\"if (validate('D')) save();\""));

    	}

        // Once this has been published in a product,
        // it cannot be killed.
        if (nPublishedProductUseCount == 0) {
            if (bIsListingSpecialist) {
                // Listing Specialist can always kill an item.
                if ("K".indexOf(recCreditSheet("prcs_Status")) == -1)
                    blkContainer.AddButton(eWare.Button("Kill", "save.gif", "#\" onClick=\"if (validate('K')) save();\""));
            } else {
                if ((bIsRatingAnalyst)  && (prcs_CreditSheetId != "-1")) {
                
                    if ("P,K".indexOf(recCreditSheet("prcs_Status")) == -1)
                        blkContainer.AddButton(eWare.Button("Kill", "save.gif", "#\" onClick=\"if (validate('K')) save();\""));
                }
            }
        }

        if (nPublishedProductUseCount > 0) {
            blkHeader.GetEntry("prcs_KeyFlag").ReadOnly = true;
        }


        //determine if the CS Item block should be shown or if the user should get a message
        if (!bNew && !bIsListingSpecialist && !bIsRatingAnalyst) {
            sPostBlockData = getInfoHeader("The Credit Sheet Item data is only editable by a members of the Listing Specialist group.");
        } else if (recCreditSheet("prcs_Status" )=="P" && nPublishedProductUseCount > 0) {
            sPostBlockData = getInfoHeader("The Credit Sheet Item data is not editable because it was used in a published product.");
        } else {
            blkContainer.AddBlock(blkCSItem);
        }

    }
/**** END EDIT HANDLING ****/


    var sNewStatus = "";
    var sPreserveKeyFlag = "";

/*****  HANDLE THE SAVE ACTION   ******/
    if (eWare.Mode == Save )
    {
        // make sure we have a company
        if (recCreditSheet("prcs_companyid") <= 0)
        {
            sErrorContent = getErrorHeader("Cannot determine the company for this Credit Sheet. Save failed." );
            eWare.AddContent(sErrorContent + "<br/>");
            eWare.Mode = View;
        }
        
        
        /* *****************************************************
         * Special Note: ACCPAC won't let us change this status here because it gets overridden by the submitted form value
         * Therefore, this is done on the client side during validation
        *********************************************************/
        sNewStatus = getIdValue("_HIDDENprcs_status");

        if (getFormValue("prcs_sourceid") != "") {
            recCreditSheet.prcs_SourceId = getFormValue("prcs_sourceid");
            recCreditSheet.prcs_SourceType = getFormValue("prcs_sourcetype");
        }
        

        // If the rating analyst edits an existing CS item that is 
        // marked "key", the flag value is lost.  The control is disabled
        // but for some reason Sage does not recognize that and preserve
        // the old value.
        if ((!bIsListingSpecialist) &&
            (getFormValue("_HIDDENprcs_keyflag") == "Y")) {
            sPreserveKeyFlag = "Y";
        }

        // if we still want to save...
        if (eWare.Mode == Save )
            blkContainer.AddBlock(blkCSItem);
    }

/*****  HANDLE THE VIEW ACTION   ******/
    if (eWare.Mode == View)
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        
        // if this is killed, you cannot do anything with it
        if (recCreditSheet("prcs_Status") != "K")
        {
            // Only listing specialist can change this
            if (bIsListingSpecialist || bIsRatingAnalyst ||   bIsAuthor) {

                if (recCreditSheet("prcs_Locked") != "Y") {
                    blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
                }
            }

            if (bIsListingSpecialist) {
                if (recCreditSheet("prcs_Locked") == "Y") {
                    var unLockURL = changeKey(sURL, "em", "96");
                    blkContainer.AddButton(eWare.Button("Unlock", "save.gif", unLockURL));
                } else {
                    var lockURL = changeKey(sURL, "em", "95");
                    blkContainer.AddButton(eWare.Button("Lock", "save.gif", lockURL));
                }
            }
        }

        if (eWare.Mode == View ) {
            blkContainer.AddBlock(blkCSItem);
        }

        // only show this block in view mode
        blkPubStatus=eWare.GetBlock("PRCreditSheetPublishingStatus");
        blkPubStatus.Title="Publishing Status";
        blkContainer.AddBlock(blkPubStatus);

        // Create a  block
        blkCSItemText=eWare.GetBlock("content");
        blkCSItemText.contents = createAccpacBlockHeader("ViewItem", "Credit Sheet Item Text");
        var sSQL = "SELECT RetValue = dbo.ufn_GetCSItemCache(" + prcs_CreditSheetId + ", 0)";

        //<!--Create a Query Object-->
        var objQuery = eWare.CreateQueryObj(sSQL,''); 
        objQuery.SelectSQL(); 
        var sListing = "No Item Text Available";
        if (!objQuery.EOF)
        {
            sListing = objQuery("RetValue");
        }
        blkCSItemText.contents += "<span class=\"VIEWBOX\">" + sListing + "</span>";
        blkCSItemText.contents += createAccpacBlockFooter();
        blkContainer.AddBlock(blkCSItemText);    
    }

    // perform the action
    if (bIsCompany) {
        blkPage.AddBlock(blkContainerListing);
    }

    blkPage.AddBlock(blkContainer);

    eWare.AddContent(blkPage.Execute(recCreditSheet));
    
    // this value may have been set in the Edit handling; it must appear after the .Execute statement above
    if (sPostBlockData != null)
        eWare.AddContent(sPostBlockData);
    

    var sCreditSheetPhraseDisplay = "";
    // determine how to show or where to go
    if (eWare.Mode == Save) 
    {
        if (bNew)
	        Response.Redirect(sListingAction);
	    else   { 

            if (sNewStatus != "") {
                if ((sNewStatus == "A") &&
                    (recCreditSheet.prcs_status != "A")) {
                    recCreditSheet.prcs_ApproverId = user_userid;
                }

                recCreditSheet.prcs_status = sNewStatus;
                recCreditSheet.SaveChanges();
            }
            

            if (sPreserveKeyFlag != "") {
                recCreditSheet.prcs_KeyFlag = sPreserveKeyFlag;
                recCreditSheet.SaveChanges();
            }


           Response.Redirect(sSummaryAction);              
            //DumpFormValues();
            //Response.Write(eWare.GetPage());

        }
        return;
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('New'));
        // we can only show the phrase selection if the CS Item block is going to show
        if (sPostBlockData == null)
            sCreditSheetPhraseDisplay = "\nInsertRow(\"_Captprcs_tradestyle\", \"tr_csphraseselection\");\nRegisterCSPhraseHandlers();";

    }
    else
        Response.Write(eWare.GetPage());

    // this structure creates the table to align the Header fields to the left; set as part of sCompanySelectDraw    
    Response.Write("<table><tr><td id=_td_force_left width=\"100%\">&nbsp;</td></tr></table>"); 
%>
        <script type="text/javascript">
            function initBBSI() 
            {
                // set the current user; the js user_userid is defined in PRGeneral.js
                user_userid = <%= user_userid %>;
                // correct the accpac bug with the caption being the wrong class on Text fields
                document.getElementById("_Captprcs_authornotes").className = "VIEWBOXCAPTION";
                document.getElementById("_Captprcs_listingspecialistnotes").className = "VIEWBOXCAPTION";
                
                <% =sCreditSheetPhraseDisplay %>
                // sCompanySelectDraw will be "" if we don't have to show this; otherwise it
                // will be an InsertRow statement
                <% =sCompanySelectDraw  %>
                
                <% 
                    if (sTransactionSelectDraw != "") {
                        Response.Write(sTransactionSelectDraw);
                    }
                %>
                
                // We do this to make the textareas handle only 34 characters
                // The way to achieve this is to set the font to a fixed-width
                // font and make the textarea 35 characters wide (yes, 35 to
                // display 34).
                if (document.getElementById("prcs_parenthetical") != null) {
                    document.getElementById("prcs_parenthetical").className="CSTAEDIT";
                    document.getElementById("prcs_change").className="CSTAEDIT;";
                    document.getElementById("prcs_ratingchangeverbiage").className="CSTAEDIT;";
                    document.getElementById("prcs_notes").className="CSTAEDIT;";
                }
                
                if (<% =bHideNotes.toString().toLowerCase() %>) {
                    AppendCell("_Dataprcs_authornotes", "td_tblentryAuthorNotes");
                }
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
        </script>
 <%         
}
doPage();    
    var sTopContentUrl = "CompanyTopContent.asp";
    %> <!-- #include file ="../RedirectTopContent.asp" --> 
<%
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>


