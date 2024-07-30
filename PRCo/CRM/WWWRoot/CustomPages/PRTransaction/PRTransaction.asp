<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
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

    bDebug = false;
    
    var sSecurityGroups = "1,2,3,4,5,6,8,10,11";
    // create a list of the unique keys; append this when redirecting to assist in loading the screen 
    // that the user came from 
    var sUniqueQueryParams = new String("&" + Request.Querystring);
    // remove known keys
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "SID");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "F");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "J");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key0");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key1");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key2");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "comp_companyid");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "pers_personid");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "em");
    DEBUG("<BR>"+sUniqueQueryParams );
    
    var lCompId = null;
    var pers_personid = null;
    var lBusinessEventId = null;
    var lPersonEventId = null;
    
    var bDisplayNewCSButton = true;
    var sDisableExplanation = "";
    
    DEBUG("URL: " + sURL);
    // 99 is our real edit mode indicator; this means Edit was clicked; document.submit can
    // update the Mode to Edit via clicks on grid col headers; ignore those by setting the 
    // Mode back to view.
    if (eWare.Mode == 99)
        eWare.Mode = Edit;
    else if (eWare.Mode == Edit)
        eWare.Mode = View;

    // set the continue action in case of error
    ErrorContinueUrl = eWare.Url(103);

    var sEntityType = "Company";
    var sPrevCustomUrl = Request.QueryString("PrevCustomUrl") ;
    
    var Now=new Date();

    var prtx_transactionid = getIdValue("prtx_TransactionId");
    DEBUG("<br>prtx_transactionid:" + prtx_transactionid);

    // indicate that this is new
    if (prtx_transactionid == -1 )
    {
	    recTrx = eWare.CreateRecord("PRTransaction");
        sTxnStatus = "O";
        if (eWare.Mode < Edit) {
            eWare.Mode = Edit;
        }
    } else {
        if (eWare.Mode != Save && eWare.Mode != 51)
            sType = "vPRTransaction";
        else
            sType = "PRTransaction";
            
        recTrx = eWare.FindRecord(sType, "prtx_TransactionId=" + prtx_transactionid);
        
        sTxnStatus = recTrx.prtx_Status;
        if ( !isEmpty(recTrx("prtx_CompanyId")) )
            lCompId = recTrx("prtx_CompanyId");
        else if ( !isEmpty(recTrx("prtx_PersonId")) )
            pers_personid = recTrx("prtx_PersonId");
        else if ( !isEmpty(recTrx("prtx_BusinessEventId")) )
            lBusinessEventId = recTrx("prtx_BusinessEventId");
        else if ( !isEmpty(recTrx("prtx_PersonEventId")) )
            lPersonEventId = recTrx("prtx_PersonEventId");
    }

    sSummaryAction = eWare.Url("PRTransaction/PRTransaction.asp")+ "&prtx_transactionid="+ prtx_transactionid;

    bValidationError = false;
    if (eWare.Mode == 51)  //custom mode indicating save end transaction
    {
        DEBUG("<br>eWare.Mode == 51");
	    recTrx.prtx_Status = "C";
	    recTrx.prtx_CloseDate = getDBDateTime(Now);
	    recTrx.SaveChanges();
        Response.Redirect(sSummaryAction);

    }

    // Set up the main block, defer adding it to the Content block until
    // we know that there are no existing transactions
    if (eWare.Mode != 50 && eWare.Mode != 51) {
        blkMain=eWare.GetBlock("PRTransactionNewEntry");
        blkMain.Title = "Transaction";
        entry = blkMain.GetEntry("prtx_Status");
        entry.DefaultValue = sTxnStatus;
        entry.ReadOnly = true;
    }

    // Set up which entity is getting the transaction (blkMain is modified in this block, so it needs to exist).
    if (eWare.Mode == Save || eWare.Mode == View || eWare.Mode == Edit || bValidationError)
    {


        if (prtx_transactionid == -1 )
        {
            // use comp_companyid instead
            lCompId = comp_companyid;
            //lCompId = eWare.GetContextInfo("Company", "Comp_CompanyId");
            pers_personid = eWare.GetContextInfo("Person", "pers_PersonId");
            if (isEmpty(pers_personid))
                pers_personid = getIdValue("pers_PersonId");
            lBusinessEventId = getIdValue("prbe_BusinessEventId");
            lPersonEventId = getIdValue("prpe_PersonEventId");
        }

        DEBUG("PersonEventId:" + lPersonEventId);
        DEBUG("BusinessEventId:" + lBusinessEventId);
        DEBUG("PersonId:" + pers_personid);
        DEBUG("CompanyId:" + lCompId);

        sListingAction = "";
        if (!isEmpty(pers_personid) && pers_personid != -1)
        {
            sEntityType = "Person";
            sListingAction = eWare.Url("PRPerson/PRPersonSummary.asp")+ "&pers_personid=" + pers_personid + "&T=Person&Capt=Transactions";

    	    if (prtx_transactionid != -1)
    	    {
                sSummaryAction = eWare.Url("PRTransaction/PRTransaction.asp")+ "&prtx_transactionid="+ recTrx("prtx_TransactionId") + "&T=Person&Capt=Transactions";
            } else {
                sPrevCustomUrl = getIdValue("PrevCustomUrl");
                DEBUG("sPrevCustomUrl:" + sPrevCustomUrl);
                if ((sPrevCustomUrl != "-1") &&
                    (sPrevCustomUrl != "")&&
                    (sPrevCustomUrl != "PRTransaction/PRTransaction.asp")) {



                    if (sPrevCustomUrl.indexOf("?SID=") > -1)
                    {
                        sSummaryAction = sPrevCustomUrl;
                    } else {
                        var customPagesPath = "/"+sInstallName + "/CustomPages";
    
                        if (sPrevCustomUrl.toLowerCase().indexOf(customPagesPath.toLowerCase()) > -1)
                        { 
                            sPrevCustomUrl = sPrevCustomUrl.substring(customPagesPath.length + 1);
                        }
                       sSummaryAction = eWare.URL(sPrevCustomUrl) + sUniqueQueryParams;
                    }
                } else {
                    sSummaryAction = eWare.Url("PRPerson/PRPersonSummary.asp");
                }
                sSummaryAction = changeKey(sSummaryAction, "Key0", "2");
                sSummaryAction = changeKey(sSummaryAction, "Key2", pers_personid);
            }

           
            DEBUG("sSummaryAction:" + sSummaryAction);
            entry = blkMain.AddEntry("prtx_PersonId", 0, true);
            entry.EntryType = 26;
            entry.DefaultType = 26;
            entry.DefaultValue = pers_personid;
            entry.Caption = "Person:";
            entry.ReadOnly = true;

            // Only default the Authorized Info for
            // new transactions
            if ((prtx_transactionid == -1 ) &&
                (eWare.Mode == Edit)) {
                entryAuthorizedById = blkMain.GetEntry("prtx_AuthorizedById");
                entryAuthorizedById.DefaultValue = pers_personid;
            }
        }
        else if (!isEmpty(lCompId) && lCompId != -1)
        {
            sEntityType = "Company";
            sListingAction = eWare.Url("PRCompany/PRCompanyTransaction.asp")+ "&comp_companyid=" + lCompId + "&T=Company&Capt=Transactions";

    	    if (prtx_transactionid != -1)
    	    {
                sSummaryAction = eWare.Url("PRTransaction/PRTransaction.asp")+ "&prtx_transactionid="+ recTrx("prtx_TransactionId") + "&T=Company&Capt=Transactions";
            } else {

                sPrevCustomUrl = getIdValue("PrevCustomUrl");

                DEBUG("sPervCustomUrl:" + sPrevCustomUrl);
                if ((sPrevCustomUrl != "-1") &&
                    (sPrevCustomUrl != "")) {
                    if (sPrevCustomUrl.indexOf("?SID=") > -1)
                    {
                        sSummaryAction = sPrevCustomUrl;
                    } else {
                        var customPagesPath = "/"+sInstallName + "/CustomPages";
                        if (sPrevCustomUrl.toLowerCase().indexOf(customPagesPath.toLowerCase()) > -1)
                        { 
                            sPrevCustomUrl = sPrevCustomUrl.substring(customPagesPath.length + 1);
                        }
                       sSummaryAction = eWare.URL(sPrevCustomUrl) + sUniqueQueryParams;
                    }
                } else {
                    sSummaryAction = eWare.Url("PRCompany/PRCompanySummary.asp");
                }
                sSummaryAction = changeKey(sSummaryAction, "Key0", "1");
                sSummaryAction = changeKey(sSummaryAction, "Key1", lCompId);

                DEBUG("sSummaryAction:" + sSummaryAction);
            }            
            
            
            entry = blkMain.AddEntry("prtx_CompanyId", 0, true);
            entry.EntryType = 56;
            entry.DefaultType = 56;
            entry.DefaultValue = lCompId;
            entry.Caption = "Company:";
            entry.ReadOnly = true;
            entryAuthorizedById = blkMain.GetEntry("prtx_AuthorizedById");
            entryAuthorizedById.Restrictor = "prtx_companyid";
            
        } 
     
        if (eWare.Mode != View) {
            entry = blkMain.GetEntry("prtx_CloseDate")
            entry.Hidden=true;
        }
    }
    

    blkContainer = eWare.GetBlock("container");
    blkContainer.DisplayButton(Button_Default) = false;
        
    if ((eWare.Mode == Edit || bValidationError) && prtx_transactionid == -1) {
        // Check the attempted transaction. If one currently exists, then print a message and get out.
        var sSqlEntity;
        var sql;
        switch (sEntityType) {
            case "Company":
                sSqlEntity = "prtx_CompanyId = " + lCompId;
                break;
            case "Person":
                sSqlEntity = "prtx_PersonId = " + pers_personid;
                break;
            case "PRBusinessEvent":
                sSqlEntity = "prtx_BusinessEventId = " + lBusinessEventId;
                break;
            case "PRPersonEvent":
                sSqlEntity = "prtx_PersonEventId = " + lPersonEventId;
                break;
            default:
                sSqlEntity = "1 = 0"; // dummy in case the switch drops through.
        }
        sql = "SELECT TOP 1 prtx_TransactionId, RTrim(User_FirstName) + ' ' + RTrim(User_LastName) As User_Name FROM PRTransaction WITH (NOLOCK) INNER JOIN Users ON (user_UserID = prtx_CreatedBy) WHERE prtx_Status = 'O' AND prtx_Deleted Is Null AND " + sSqlEntity;
        var qry = eWare.CreateQueryObj(sql);

        qry.SelectSQL();
        if (qry.RecordCount > 0) {
            // If record exists, then a transaction got opened by someone else. print a message and get out.
            var blkOpenTrans = eWare.GetBlock('Content');
            blkOpenTrans.Contents = "<h2 style=\"text-align:center\">A Transaction is already open by " + qry("User_Name") + "</h2>";
            blkContainer.AddBlock(blkOpenTrans);
	        blkContainer.AddButton(eWare.Button("Continue","continue.gif",sListingAction));
	        eWare.AddContent(blkContainer.Execute());
	        Response.Write(eWare.GetPage());
	        Response.End();
	    }
	}
	


    // If we made it here, then no duplicate transactions exists. Add the main block to the container and move on.
    if (eWare.Mode != 50 && eWare.Mode != 51) {
        blkContainer.AddBlock(blkMain);
	    blkContainer.CheckLocks = false;
    }

    if (eWare.Mode == Save)
    {
        if (blkContainer.Validate())
        {

            blkContainer.Execute(recTrx); 

            // If a company, iterate through the person list and see if we need to
            // open any person transactions
            if (sEntityType == "Company") {

                var sSQL = "SELECT pers_PersonID, peli_PersonLinkID, pers_FullName, dbo.ufn_GetCustomCaptionValue('peli_PRStatus', peli_PRStatus, 'en-us') As peli_PRStatus, peli_PRTitle " +
                             "FROM vPRPersonnelListing  " +
                            "WHERE peli_CompanyID=" + lCompId + " " + 
                              "AND peli_PRStatus IN (1,2)  " +
                         "ORDER BY pers_FullName";

                recPersons = eWare.CreateQueryObj(sSQL);
                recPersons.SelectSQL();

                while (!recPersons.eof) {
                    var iPersonID = recPersons("pers_PersonID")
                    
                    if (getFormValue("cbPersonID_" + iPersonID ) == "on") {
 
                        recPersonTrx = eWare.CreateRecord("PRTransaction");
                        recPersonTrx.prtx_PersonID = iPersonID;
                        recPersonTrx.prtx_ParentTransactionID = recTrx.prtx_TransactionId;
                        recPersonTrx.prtx_EffectiveDate = recTrx.prtx_EffectiveDate;
                        recPersonTrx.prtx_AuthorizedInfo = recTrx.prtx_AuthorizedInfo;
                        recPersonTrx.prtx_AuthorizedById = recTrx.prtx_AuthorizedById;
                        recPersonTrx.prtx_NotificationType = recTrx.prtx_NotificationType;
                        recPersonTrx.prtx_NotificationStimulus = recTrx.prtx_NotificationStimulus;
                        recPersonTrx.prtx_RedbookDate = recTrx.prtx_RedbookDate;
	                    recPersonTrx.prtx_Status = recTrx.prtx_Status;
                       
                        szExplanation = GetPersonTrxExplanation(iPersonID);
                        if (getFormValue("cbCopy_" + iPersonID ) == "on") {
                            if (szExplanation.length > 0) {
                                szExplanation+= "  ";
                            }                        
                            szExplanation += recTrx.prtx_Explanation;
                        }
                        recPersonTrx.prtx_Explanation = szExplanation;
 
	                    recPersonTrx.SaveChanges();
                    }

                    recPersons.NextRecord();
                }
            }
            
            
            //Debugging Lines...
            //eWare.AddContent(blkContainer.Execute(recTrx)); 
            //eWare.Mode = View;
            //Response.Write(eWare.GetPage('New'));
    	    if (prtx_transactionid != -1)
    	    {
                sSummaryAction = eWare.Url("PRTransaction/PRTransaction.asp")+ "&prtx_transactionid="+ recTrx("prtx_TransactionId");
            }
            
            Response.Redirect(sSummaryAction);
        }
        else
        {
            bValidationError = true;
            eWare.Mode = Edit;
        }
        
    }


    if (eWare.Mode == Edit || bValidationError)
    {

        // For companies, list all active persons to allow the user to also
        // open transactions on them.
        if ( (sEntityType == "Company") && (eWare.Mode == Edit) ){

            var sOrderByField = "pers_FullName";
            if (isEmpty(Request.QueryString("OrderBy")) == false) {
                sOrderByField = Request.QueryString("OrderBy");
                //Response.Write("<br/>Request.QueryString(\"OrderBy\"):" + Request.QueryString("OrderBy"));
            }

            var sSQL = "SELECT pers_PersonID, peli_PersonLinkID, pers_FullName, dbo.ufn_GetCustomCaptionValue('peli_PRStatus', peli_PRStatus, 'en-us') As peli_PRStatus, peli_PRTitle " +
                         "FROM vPRPersonnelListing  " +
                               "INNER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'pers_TitleCode' and capt_code = peli_PRTitleCode " +
                        "WHERE peli_CompanyID=" + lCompId + " " + 
                          "AND peli_PRStatus IN (1,2)  " +
                     "ORDER BY " + sOrderByField;

            recPersons = eWare.CreateQueryObj(sSQL);
            recPersons.SelectSQL();
            
            // Create a block to hold the custom grid/table
            blkPersons = eWare.GetBlock("Content");
            sContent = "";
            sContent = createAccpacBlockHeader("PersonGrid", "Select Persons");


            sContent = sContent + "\n<span class=\"VIEWBOXCAPTION \">";
            sContent = sContent + "\n<br/>Select persons to also open a transaction for.  When this company transaction is closed, these person transactions will also be closed automatically.";
            sContent = sContent + "\n</span>";

            // Build our Sort URL.  Make sure the mode stays in "View" and remove
            // any previous order by key.
            var sSortUrl = changeKey(removeKey(sURL, "OrderBy"), "em", View) + "&OrderBy=";
            
            if (sOrderByField == "pers_FullName") {
                sURLSortByField = "capt_order";
                sURLSortByLabel = "LRL Order";
            } else {
                sURLSortByField = "pers_FullName";
                sURLSortByLabel = "Name";
            }
            
           

            sContent = sContent + "\n<table id=tbl_PersonGrid width=100% cellpadding=0 cellspacing=0 border=0>";

            sContent = sContent + "\n<tr>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\" align=\"center\" rowspan=\"2\"><input type=checkbox id=cbAll onclick=\"TogglePersons();\" /></td>";

            sContent = sContent + "\n<td class=\"GRIDHEAD\" rowspan=\"2\">Person ";
            sContent = sContent + "\n &nbsp; Sort By: <a class=\"GRIDHEAD\" href=\"javascript:Sort('" + sURLSortByField + "');\">" + sURLSortByLabel + "</a>";
            sContent = sContent + "<input type=\"hidden\" name=\"hidCurrentOrderBy\" id=\"hidCurrentOrderBy\" value=" + sOrderByField + " />";
            sContent = sContent + "<input type=\"hidden\" name=\"hidSortURL\" id=\"hidSortURL\" value=\"" + sSortUrl + "\" />";
            sContent = sContent + "</td>";

            sContent = sContent + "\n<td class=\"GRIDHEAD\" rowspan=\"2\">Status</td>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\" rowspan=\"2\">Published Title</td>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\" colspan=\"5\" align=\"center\">Person Transaction Explanations</td>";
            sContent = sContent + "\n</tr>";
            sContent = sContent + "\n<tr>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\" align=\"center\" title=\"Contact Info\">CI</td>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\" align=\"center\" title=\"No Longer Connected\">NLC</td>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\" align=\"center\" title=\"Title Change\">TC</td>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\" align=\"center\" title=\"Copy from Company\">Copy</td>";
            sContent = sContent + "\n<td class=\"GRIDHEAD\">Other</td>";
            sContent = sContent + "\n</tr>";

            var sClass = "ROW1";
            var szDisabled = "";
            var szChecked = "";
            
            while (!recPersons.eof){
                var iPersonID = recPersons("pers_PersonID")
                sClassTag = " CLASS=\"" + sClass + "\" ";

                
                szChecked = HasChildTransaction(prtx_transactionid, iPersonID);
                szDisabled = ""
                if (szChecked.length > 0) {
                    szDisabled = " disabled ";
                } else {
                    szDisabled = HasOpenTransaction(iPersonID);
                }


                sContent = sContent + "\n<tr " + szDisabled + " >";

                sContent = sContent + "\n<td align=\"center\" style=\"vertical-align:middle\" " + sClassTag + "><input type=checkbox value=\"on\" id=cbPersonID_" + iPersonID + " name=cbPersonID_" + iPersonID + " " + szChecked + " " + szDisabled + " /></td>";
                sContent = sContent + "\n<td style=\"vertical-align:middle\" " + sClassTag + ">" + recPersons("pers_FullName") + "</td> ";
                sContent = sContent + "\n<td style=\"vertical-align:middle\" " + sClassTag + ">" + recPersons("peli_PRStatus") + "</td> ";
                
                sValue = recPersons("peli_PRTitle");
                if ( isEmpty(sValue) )
                    sValue = "&nbsp;";
                sContent = sContent + "\n<td style=\"vertical-align:middle\" " + sClassTag + " >" + sValue + "</td> "; 

                sContent = sContent + "\n<td align=\"center\" style=\"vertical-align:middle\" " + sClassTag + "><input type=\"checkbox\" value=\"on\" name=cbCI_" + iPersonID + " id=cbCI_" + iPersonID + " /></td>";
                sContent = sContent + "\n<td align=\"center\" style=\"vertical-align:middle\" " + sClassTag + "><input type=\"checkbox\" value=\"on\" name=cbNLC_" + iPersonID + " id=cbNLC_" + iPersonID + " /></td>";
                sContent = sContent + "\n<td align=\"center\" style=\"vertical-align:middle\" " + sClassTag + "><input type=\"checkbox\" value=\"on\" name=cbTC_" + iPersonID + " id=cbTC_" + iPersonID + " /></td>";
                sContent = sContent + "\n<td align=\"center\" style=\"vertical-align:middle\" " + sClassTag + "><input type=\"checkbox\" value=\"on\" name=cbCopy_" + iPersonID + " id=cbCopy_" + iPersonID + " /></td>";
                sContent = sContent + "\n<td style=\"vertical-align:middle\" " + sClassTag + "><input type=\"checkbox\" value=\"on\" name=cbOther_" + iPersonID + " id=cbOther_" + iPersonID + " /><input name=txtOther_" + iPersonID + " id=txtOther_" + iPersonID + " type=\"text\" maxlength=\"500\" size=\"30\" /></td>";
                sContent = sContent + "\n</tr>";
                
                if (sClass=="ROW1")
                    sClass = "ROW2";
                else
                    sClass = "ROW1";

                recPersons.NextRecord();
            }
            sContent = sContent + "\n</table>";

            sContent = sContent + createAccpacBlockFooter();
            blkPersons.Contents=sContent;
            blkContainer.AddBlock(blkPersons);
        }            

   
        // this only applies to new Person transactions
        if ( (sEntityType == "Person") && (prtx_transactionid == -1) && (eWare.Mode == Edit) ){
            // place a list of open company transactions on the screen.
            // if the user selects a linked column, replace the values 
            // entered in the company trx into the person trx.
            var sSQL = "Select prcse_FullName = case when prtx_CompanyId is not null then '(C) ' + prcse_FullName else '(P) ' + dbo.ufn_FormatPersonById(prtx_PersonId) end , " +
                    " prtx_AuthorizedById, dbo.ufn_FormatPersonById(prtx_AuthorizedById) AS FormattedAuthorizedBy, " +
                    " prtx_AuthorizedInfo, prtx_Explanation " +
                    " FROM PRTransaction WITH (NOLOCK) " +
                    " LEFT OUTER JOIN PRCompanySearch WITH (NOLOCK) ON prtx_CompanyId = prcse_CompanyId  "+
                    " LEFT OUTER JOIN Person WITH (NOLOCK) ON prtx_PersonId = pers_PersonId " +
                    " WHERE prtx_Status = 'O' " +
                    "   and (prtx_CompanyId is not null or prtx_PersonId is not null) " + 
                    "   and prtx_CreatedBy = " + user_userid + 
                    " order by prcse_FullName ";
            recOpenCompTrx = eWare.CreateQueryObj(sSQL);
            recOpenCompTrx.SelectSQL();
            
            // Create a block to hold the custom grid/table
            blkOpenTrxs = eWare.GetBlock("Content");
            sContent = "";
            sContent = createAccpacBlockHeader("OpenTransactionsGrid", "Company Transactions Available for Copy");

            sContent = sContent + "\n<TABLE ID=tbl_OpenTrxs width=100% cellpadding= cellspacing=1 border=0>";
            var sClass="ROW1";
            var sClassTag = " CLASS=" + sClass + " ";
            sContent = sContent + "\n<TR><TH CLASS=GRIDHEAD>(C)ompany/(P)erson Trx</TH><TH CLASS=GRIDHEAD>Authorized By</TH>" + 
                    "<TH CLASS=GRIDHEAD>Authorized Info</TH><TH CLASS=GRIDHEAD>Explanation</TH><TH CLASS=GRIDHEAD>Action</TH></TR>";
            var rowId = 1
            while (!recOpenCompTrx.eof){
                sClassTag = " CLASS=" + sClass + " ";
                sContent = sContent + "\n<TR>";

                sValue = recOpenCompTrx("prcse_FullName");
                if ( isEmpty(sValue) )
                    sValue = "&nbsp;";
                sContent = sContent + "\n<td " + sClassTag + " >" + sValue + "</td> ";

                sValue = recOpenCompTrx("FormattedAuthorizedBy");
                if ( isEmpty(sValue) )
                    sValue = "&nbsp;";
                sContent = sContent + "\n<td AuthId="+ recOpenCompTrx("prtx_AuthorizedById") + sClassTag + " >" + sValue + "</td> ";

                sValue = recOpenCompTrx("prtx_AuthorizedInfo");
                if ( isEmpty(sValue) )
                    sValue = "&nbsp;";
                sContent = sContent + "\n<td " + sClassTag + " >" + sValue + "</td> ";

                sValue = recOpenCompTrx("prtx_Explanation");
                if ( isEmpty(sValue) )
                    sValue = "&nbsp;";
                sContent = sContent + "\n<td " + sClassTag + " >" + sValue + "</td> ";

                sContent = sContent + "\n<td " + sClassTag + " ><a href=\"javascript:copyTrx("+rowId+");\">Copy</A></td> ";

                sContent = sContent + "\n</TR>";
                
                if (sClass=="ROW1")
                    sClass = "ROW2";
                else
                    sClass = "ROW1";
                rowId++;
                recOpenCompTrx.NextRecord();
            }
            sContent = sContent + "\n</TABLE>";

            sContent = sContent + createAccpacBlockFooter();
            blkOpenTrxs.Contents=sContent;
            blkContainer.AddBlock(blkOpenTrxs);
        }

        
        if (sTxnStatus == "C") {
            sDisableExplanation = "document.EntryForm.prtx_explanation.disabled = true;";
        }
    
        Response.Write("<script type=\"text/javascript\" src=\"PRTransactionInclude.js\"></script>\n");
        Response.Write("<script type=\"text/javascript\" src=\"PRTransactionClose.js\"></script>\n");
        if (prtx_transactionid == -1 ) {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        } else {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        }
        
        
        
        if (isUserInGroup(sSecurityGroups))
        {

            sSaveUrl = changeKey(sURL, "em", Save);
   	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"document.EntryForm.action='" + sSaveUrl + "';save();"));
        }
        
        eWare.AddContent(blkContainer.Execute(recTrx)); 
        Response.Write(eWare.GetPage());
    }

    else if (eWare.Mode == View)
    {
        if (sEntityType == "Company") {
            var sCompareListing = "<table><tr><td valign=top width=300px>";
            
            sCompareListing += createAccpacBlockHeader("PreviousListing", "Previous Listing");
            
            var sSQL = "SELECT ISNULL(prtx_Listing, 'Listing is not available.') As Listing " +
                         "FROM PRTransaction WITH (NOLOCK) " +
                        "WHERE prtx_TransactionID IN (  " +
                            "SELECT MAX(prtx_TransactionID)  " +
                              "FROM PRTransaction WITH (NOLOCK)  " +
                             "WHERE prtx_CompanyID = " + comp_companyid + " " +
                               "AND prtx_TransactionID < " + prtx_transactionid + "); ";
            var objQuery = eWare.CreateQueryObj(sSQL,''); 
            objQuery.SelectSQL(); 

            var sListing = "Listing is not available.";
            if (!objQuery.EOF)
            {
                sListing = objQuery("Listing");
                sListing = sListing.replace(new RegExp( "\\n", "g" ), "<br/>");
                sListing = sListing.replace(new RegExp( " ", "g" ), "&nbsp;");

            }
            sCompareListing += "<span class=\"VIEWBOX\">" + sListing + "</span>"; 
            sCompareListing += createAccpacBlockFooter();

            sCompareListing += "</td><td valign=top width=300px>";
            sCompareListing += createAccpacBlockHeader("NewListing", "New Listing");

            sListing = "Listing is not available.";
            if (sTxnStatus == "O")  {
    	        var objQuery = eWare.CreateQueryObj("SELECT RetValue = dbo.ufn_GetListingFromCompany (" + comp_companyid + ", 0, 0) "); 
                objQuery.SelectSQL(); 
                
                if (!objQuery.EOF) {
                    sListing = objQuery("RetValue");
                }

            } else {
                if (!isEmpty(recTrx("prtx_Listing")))     {
                    sListing = recTrx("prtx_Listing"); 
                    sListing = sListing.replace(new RegExp( "\\n", "g" ), "<br/>");
                    sListing = sListing.replace(new RegExp( " ", "g" ), "&nbsp;");
                }            
            }
            sCompareListing += "<span class=\"VIEWBOX\">" + sListing + "</span>";  
            sCompareListing += createAccpacBlockFooter();

            var sSQL = "SELECT dbo.ufn_GetCSItemCache(prcs_CreditSheetID, 0) As ItemText, prcs_Status, prcs_KilledDate " +
                         "FROM PRCreditSheet WITH (NOLOCK) " +
                        "WHERE prcs_SourceID=" + prtx_transactionid + " AND prcs_SourceType = 'TX'";

   	        var objQuery = eWare.CreateQueryObj(sSQL); 
            objQuery.SelectSQL(); 
            if (!objQuery.EOF) {
                bDisplayNewCSButton = false;
                sCompareListing += "</td><td valign=top width=300px>";
                sCompareListing += createAccpacBlockHeader("CreditSheetItemText", "Credit Sheet Item Text");

                if (objQuery("prcs_Status") == "K") {
                    sCompareListing += "<div style=\"text-align:center;color:red;\">** Killed on " +  getDateAsString(objQuery("prcs_KilledDate"))  + " **</div>";
                }

                sCompareListing += "<span class=\"VIEWBOX\">" + objQuery("ItemText") + "</span>";  
                //sCompareListing += sSQL;
                sCompareListing += createAccpacBlockFooter();
            }
            sCompareListing += "</td></tr></table>";


            blkCompanyListing=eWare.GetBlock("content");
            blkCompanyListing.contents = sCompareListing;
            blkContainer.AddBlock(blkCompanyListing);
        }
    
        Response.Write("<script type=\"text/javascript\" src=\"PRTransactionClose.js\"></script>\n");
        Response.Write("<script type=\"text/javascript\" src=\"PRTransactionInclude.js\"></script>\n");

        recDetails = eWare.FindRecord("PRTransactionDetail", "prtd_TransactionId=" + prtx_transactionid);
        recDetails.OrderBy = 'prtd_ColumnName';
        Detail=eWare.GetBlock("PRTransactionDetailGrid");
        Detail.ArgObj = recDetails
        blkContainer.AddBlock(Detail);
    
	    
	    blkContainer.AddButton(eWare.Button("Continue","continue.gif",sListingAction));

        if (isUserInGroup(sSecurityGroups))
        {
            sEditUrl = changeKey(sURL, "em", "99");

            if (sTxnStatus == "O") {
                if (recTrx("prtx_CreatedBy") == user_userid)
                    blkContainer.AddButton(eWare.Button("Update Txn","edit.gif","javascript:location.href='"+sEditUrl+"';"));
            } else {
    		    blkContainer.AddButton(eWare.Button("Update Txn","edit.gif","javascript:location.href='"+sEditUrl+"';"));
            }

		    if (sTxnStatus == "O") 
		    {
		    
                var sSQL = "SELECT COUNT(1) As Cnt " +
                             "FROM PRTransaction WITH (NOLOCK) " +
                            "WHERE prtx_Status = 'O' " +
                              "AND prtx_ParentTransactionID =  " + prtx_transactionid;

                recChildTrx = eWare.CreateQueryObj(sSQL);
                recChildTrx.SelectSQL()
                var iCount = recChildTrx("Cnt");

                if (iCount == 0) {		    
                    sCloseAction = changeKey(sURL, "em", "51");
			        blkContainer.AddButton(eWare.Button("Close Txn", "close.gif", "#\" onclick=\"return confirmCloseTransaction('" + sCloseAction + "');"));
                } else {
                    var sCloseTranastionAction = eWare.URL("PRTransaction/PRTransactionClose.asp") + "&prtx_TransactionId=" + prtx_transactionid;
                    blkContainer.AddButton(eWare.Button("Close Txn", "close.gif", "javascript:openCloseTranWindow('" + sCloseTranastionAction + "');"));
                }			    
		    } 

		    // for company and person, add a New C/S button
		    if ((sEntityType == "Company" || sEntityType == "Person") && bDisplayNewCSButton)
		    {
    		    var sNewCSUrl = eWare.Url("PRCreditSheet/PRCreditSheet.asp");
		        sNewCSUrl += "&prcs_SourceType=TX&prcs_SourceId=" + prtx_transactionid;
		        //sNewCSUrl += "&prevCustomURL=" + sURL; 
                //sNewCSUrl += "&prevCustomURL=" + Server.URLEncode(sURL); 
                sNewCSUrl = changeKey(sNewCSUrl, "PrevCustomURL", Server.URLEncode(sURL));
                
		        blkContainer.AddButton(eWare.Button("New C/S Item", "new.gif", sNewCSUrl));
            }
        }
        
        eWare.AddContent(blkContainer.Execute(recTrx)); 
        
        
        if (sEntityType == "Company" || sEntityType == "Person")
            Response.Write(eWare.GetPage(sEntityType));
        else
            Response.Write(eWare.GetPage());
    }
 
    if (sEntityType == "Company")
    {
%>
        <!-- #include file="../PRCompany/CompanyFooters.asp" -->
<%    
    } else if (sEntityType == "Person") {
    
        var sTopContentUrl = "PersonTopContent.asp";
   
%>
        <!-- #include file="../RedirectTopContent.asp" -->

<%
    }

    // Sets the default effective date
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n");
    Response.Write("<script type=\"text/javascript\">\n");

    if (prtx_transactionid == -1 ) { 
        Response.Write("    function initBBSI()\n"); 
        Response.Write("    {\n ");
        Response.Write("         document.getElementById(\"prtx_effectivedate\").value = getDateAsString();\n");
        Response.Write("    }\n\n");
        Response.Write("    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }\n");
        Response.Write("    if (window.document.forms['EntryForm'].addEventListener) {\n" ); 
        Response.Write("         window.document.forms['EntryForm'].addEventListener(\"keypress\", handleEnterKey);\n" ); 
        Response.Write("    } else {\n" ); 
        Response.Write("         window.document.forms['EntryForm'].attachEvent(\"onkeypress\", handleEnterKey);\n" ); 
        Response.Write("    }\n\n" ); 

    } else {
        Response.Write(sDisableExplanation + "\n");
    }

    if (eWare.Mode == View)
    {
        if (sEntityType == "Company")
        {
            Response.Write("\tdocument.getElementById(\"_Dataprtx_companyid\").style.width = \"300px\";\n");
        }
        if (sEntityType == "Person")
        {
            Response.Write("\tdocument.getElementById(\"_Dataprtx_personid\").style.width = \"300px\";\n");
        }
        Response.Write("\tdocument.getElementById(\"_Dataprtx_authorizedbyid\").style.width = \"350px\";\n");
    }

    Response.Write("\n</script>");   
    
// Helper method that returns the canned verbiage
// for the specified person if any of the checkboxes
// were selected. 
function GetPersonTrxExplanation(iPersonID) {

    var szExplanation = "";
    
    if (getFormValue("cbCI_" + iPersonID ) == "on") {
        szExplanation += GetCustomVerbiage("CI");
    }

    if (getFormValue("cbNLC_" + iPersonID ) == "on") {
        if (szExplanation.length > 0) {
            szExplanation+= "  ";
        }
        szExplanation += GetCustomVerbiage("NLC") + lCompId + " - " + recCompany("comp_Name");
    }

    if (getFormValue("cbTC_" + iPersonID ) == "on") {
        if (szExplanation.length > 0) {
            szExplanation+= "  ";
        }
        szExplanation += GetCustomVerbiage("TC");
    }

    if (getFormValue("cbOther_" + iPersonID ) == "on") {
        if (szExplanation.length > 0) {
            szExplanation+= "  ";
        }
        szExplanation += getFormValue("txtOther_" + iPersonID );
    }
 
    return szExplanation;
}    

var aPersonTrxExplanation = null; 
function GetCustomVerbiage(szCode) {

    if (aPersonTrxExplanation == null) {
        aPersonTrxExplanation = new Array();
        
        var sSQL = "SELECT RTRIM(capt_code) As capt_code, capt_us " +
                     "FROM custom_captions WITH (NOLOCK) " +
                    "WHERE capt_family = 'PersonTrxExplanation'; ";
        var objQuery = eWare.CreateQueryObj(sSQL,''); 
        objQuery.SelectSQL(); 

        var iIndex = 0
        while (!objQuery.EOF) {
            aPersonTrxExplanation[iIndex] = new Array(2);
            aPersonTrxExplanation[iIndex][0] = objQuery("capt_code");
            aPersonTrxExplanation[iIndex][1] = objQuery("Capt_US");

            iIndex++;        
            objQuery.NextRecord();    
        }
    }

    for (i in aPersonTrxExplanation) {
        if (aPersonTrxExplanation[i][0] == szCode) {
            return aPersonTrxExplanation[i][1]
        }
    }
    
    return "";
}

var aChildTrxIDs = null; 
function HasChildTransaction(iParentTrxID, iPersonID) {

    if (aChildTrxIDs == null) {
        aChildTrxIDs = new Array();
        
        var sSQL = "SELECT prtx_PersonID " +
                     "FROM PRTransaction WITH (NOLOCK) " +
                    "WHERE prtx_ParentTransactionID = " + iParentTrxID + " " +
                      "AND prtx_Status = 'O'";

        var objQuery = eWare.CreateQueryObj(sSQL,''); 
        objQuery.SelectSQL(); 

        var iIndex = 0
        while (!objQuery.EOF) {
            aChildTrxIDs[iIndex] = objQuery("prtx_PersonID");
            iIndex++;        
            objQuery.NextRecord();    
        }
    }

    for (i in aChildTrxIDs) {
        if (aChildTrxIDs[i] == iPersonID) {
            return " checked ";
        }
    }
    
    return "";
}



function HasOpenTransaction(iPersonID) {

        
    var sSQL = "SELECT prtx_PersonID " +
                 "FROM PRTransaction WITH (NOLOCK) " +
                "WHERE prtx_PersonID = " + iPersonID + " " +
                  "AND prtx_Status = 'O'";
                      
    var objQuery = eWare.CreateQueryObj(sSQL,''); 
    objQuery.SelectSQL(); 


    if (objQuery.EOF) {
        return "";
    }

    return " disabled ";
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");

%>