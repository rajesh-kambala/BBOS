<!-- #include file ="..\accpaccrm.js" -->
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
%>

<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->

<%
    var prfs_financialid = getIdValue("prfs_FinancialId");
    recFinancial = Session("recFinancial");
    var bRecLoadedFromSession = false;

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

var bNew = true;
var sSID = Request.Querystring("SID");

function getFinancialBlockContents(sBlockName) {
    var blkMain = eWare.GetBlock(sBlockName);
    var colFields = new Enumerator(blkMain);
	sBlockContent = "\n  <table width=100\% cellpadding=0 border=0 align=left>";
	nBlockTotal = 0;
	while (!colFields.atEnd()) {
		sFieldName = String(colFields.item());

		bTotalField = false;
		sClass = "VIEWBOX";
		sClassCaption = "VIEWBOXCAPTION";
		if ((sFieldName.indexOf("total") > -1) || (sFieldName.indexOf("net") > -1) || (sFieldName.indexOf("working") > -1)) 
		{
			bTotalField = true;
			sClass = "ROW1";
			sClassCaption = "ROW1";
        }
		sTranslation = eWare.GetTrans('ColNames', sFieldName);
		if (bTotalField)
		    sTranslation = "<b>" + sTranslation + "</b>";
        // put the caption on the page
		sBlockContent += "\n<tr><td class=" + sClassCaption + ">" + sTranslation + ": </td>";

		var sFieldValue = null;
		// if we're in view mode we can use the values retrieved from the Financial Statement
		if (eWare.Mode == View || bTotalField)
		{
			sFieldValue = recFinancial(sFieldName);
            // remove any session values that may exist; these will be rebuilt if
            // we go into edit mode.
            Session.Contents.Remove("arr_" + sFieldName);
            Session.Contents.Remove("arrTemp_" + sFieldName);
			if (isEmpty(sFieldValue))
			    sFieldValue = "0";
		    if (bTotalField)
		        sFieldValue = "<b>" + nBlockTotal + "</b>";
		    sBlockContent += "\n    <td colspan=2 class=" + sClass + " width=70>";
		    if (bTotalField)
		    {
			    sBlockContent += "\n        <input name='TOT_" + sFieldName + "' id='TOT_" + sFieldName + "' value=" + nBlockTotal + " type=HIDDEN>";
		    }
		    sBlockContent += "    <span id='"+sFieldName+"' style='height:15px;'>" + formatCommaSeparated(sFieldValue) + "</span>";
		    sBlockContent += "\n    </td>";
            
			sBlockContent += "\n</tr>";
		}
		else if (eWare.Mode == Edit)
		{
		    // if we are in edit mode, calcualted fields will have an "arr_<fieldname>"
		    // entry on the session; if it is not there, check the database to see if 
		    // PRFinancialDetail records exist (note this is the first chance to load them).
		    // If neither is present, assume we can use the Financial Statement value
		    sCalcValue = 0;
            nTotal = 0;
            // determine the default value for the field; if coes from the session,
            // it cannot be changed by FinancialDetail calculations
		        sFieldValue = recFinancial(sFieldName);
		    if (isEmpty(sFieldValue))
		        sFieldValue = 0;

		    // now try to find a calc value (FinancialDetail entries) for the field
		    arrValues = Session("arr_"+sFieldName);
			sBlockContent += "\n    <td class=" + sClass + " width=20>";
	        if (arrValues != null && arrValues.length>0)
		    {
                for (ndx=0; ndx<arrValues.length; ndx++)    
                { 
                    detailValues = arrValues[ndx].split("~");
	                sAmount = detailValues[2];
        	        nAmount = parseInt(sAmount);
	                if ( !isNaN(nAmount))
	                    nTotal = nTotal + nAmount;
                }
                sCalcValue = String(nTotal);
                // we can only change a displayed field value if it was not loaded from
                // the session.  Values loaded from the session may have been altered by 
                // the user prior to going to a FinancialDetail page.
                if (!bRecLoadedFromSession)
                {
                    sFieldValue = sCalcValue;
                }
            }
            else
            {
                if (!isEmpty(prfs_financialid ) && prfs_financialid != -1)
                {
                    // try the database for values
                    arrValues = new Array();
                    // look to the database
                    sSQLSelect = "SELECT prfd_FinancialDetailId, prfd_Description, prfd_Amount";
                    sSQLFrom = " FROM PRFinancialDetail WITH (NOLOCK) ";
                    sSQLWhere = "WHERE prfd_FinancialId = " + recFinancial("prfs_FinancialId") + " AND prfd_FieldName='" + sFieldName + "' AND prfd_Deleted IS NULL";
                    sSQL = sSQLSelect + sSQLFrom + sSQLWhere;
                    recFDs = eWare.CreateQueryObj(sSQL)
                    recFDs.SelectSql();
                    
                    var ndx = 0
                    if (recFDs.RecordCount > 0)
                    {
                        while(!recFDs.eof)
                        {
                            sAmount = recFDs("prfd_Amount");
                            arrValues[ndx] = recFDs("prfd_FinancialDetailId")+ "~" + recFDs("prfd_Description")+ "~" + sAmount
        	                nAmount = parseInt(sAmount);
	                        if ( !isNaN(nAmount))
	                            nTotal = nTotal + nAmount;
                            recFDs.NextRecord();
                            ndx = ndx + 1;
                        }
                        sCalcValue = String(nTotal);
                        Session("arr_" + sFieldName) = arrValues;
                        // see comment in section above for explanation of this check
                        if (!bRecLoadedFromSession)
                        {
                            sFieldValue = sCalcValue;
                        }
                    }
                }
            }
			//sBlockContent += "\n        <input name='HIDDEN_FD_" + sFieldName + "' id='HIDDEN_FD_" + sFieldName + "' value=" + sCalcValue + " type=HIDDEN>";
			sBlockContent += "\n        <input name='HIDDEN_FD_" + sFieldName + "' id='HIDDEN_FD_" + sFieldName + "' value=0 type=HIDDEN>";
			sBlockContent += "\n        <input style='vertical-align:top;' name='"+sFieldName+"' id='"+sFieldName+"' value=\""+ formatCommaSeparated(sFieldValue)+ "\"" +
			                            " type=TEXT size=10 class=VIEWBOX " +
			                            " onkeyup='onFinancialFieldKeyUp();' onkeypress='return onFinancialFieldKeyPress();'"+
                                        " onchange='onFinancialFieldChange();'>";
			sVisibility = "'visibility: visible;'";
            if ((sCalcValue == "0" && sFieldValue != "0") ||
                (sCalcValue != sFieldValue))
                sVisibility = "'visibility: hidden;'";    
			sBlockContent += "\n    </td>";
			sBlockContent += "\n    <td width=5>";
            sBlockContent += "        <div><img ID=img_"+sFieldName+" style="+sVisibility+ " border=0 src=../../img/buttons/smallnew.gif ALT='View/Change " + sTranslation + " Detail' ";
            sBlockContent += "        onclick='viewFinancialDetails(\"" + sFieldName + "\",\"" + sBlockName + "\");'";
            sBlockContent += "        onmouseover='document.body.style.cursor=\"pointer\";' onmouseout='document.body.style.cursor=\"default\";' ></div>";
			sBlockContent += "\n    </td>";
			sBlockContent += "\n    <td class=" + sClassCaption + " width=10 align=left></td>";
			sBlockContent += "\n</tr>";

        }
		// check for fields where we subtract from the total
		if (sFieldValue != null)
		{
		    if ("prfs_accumulateddepreciation".indexOf(sFieldName) > -1)
		        nBlockTotal -= parseInt(sFieldValue); 
		    else
		        nBlockTotal += parseInt(sFieldValue); 
        }
	    colFields.moveNext();
	}

	sBlockContent += "</table>";
	return sBlockContent;
}

function doPage()
{

    sURL = removeKey(sURL, "em");
    //Response.Write("URL" + sURL);
    //Response.Write("<br>Mode:" + eWare.Mode);
    //Response.Write("<br>comp_companyid:" + comp_companyid);

    if (recFinancial != null)
    {
        bRecLoadedFromSession = true;
        bNew = false;
    }
    else
    {
        if (prfs_financialid != -1)
        {
            recFinancial = eWare.FindRecord("PRFinancial", "prfs_FinancialId=" + prfs_financialid);
            bNew = false;
        }
        else
        {
            // A valid PRFinancial record is required; if one is not passed create a new one
            recFinancial = eWare.CreateRecord("PRFinancial");
            recFinancial("prfs_companyid") = comp_companyid;
            if (eWare.Mode == View)
                eWare.Mode = Edit;
        }    
    }

    cntMain = eWare.GetBlock("container");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

    if (eWare.Mode == Edit)  {
	    if (bNew) {
            var blkFlags = eWare.GetBlock("content");
            sSQL = "SELECT TOP 1 prfs_SubordinationAgreements FROM PRFinancial WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON  prfs_CompanyId = comp_CompanyID AND prfs_StatementDate = comp_PRFinancialStatementDate WHERE comp_PRFinancialStatementDate IS NOT NULL AND comp_CompanyID=" + comp_companyid + " ORDER BY prfs_StatementDate DESC, ISNULL(prfs_SubordinationAgreements, 'N') DESC";
            recFlags = eWare.CreateQueryObj(sSQL);
            recFlags.SelectSQL();
            flag = "";

 
           if (!recFlags.eof)
                flag = recFlags("prfs_SubordinationAgreements");

            if (isEmpty(flag))
                flag = "N";    

            if (flag == "Y") {
                var blkBanners = eWare.GetBlock('content');
                var sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
			    sBannerMsg += "<table class=\"MessageContent\" align=\"center>\"\n";
                sBannerMsg += "<tr><td>Previous Financial Statement flagged with Subordination Agreement.  Please review current Financial for Subordination Agreement and set flags accordingly.</td></tr>";
			    sBannerMsg += "</table>\n";
			    sBannerMsg += "</td></tr></table>\n\n";
			    blkBanners.contents = sBannerMsg;
				cntMain.AddBlock(blkBanners);

//            } else {
//
//                var blkBanners = eWare.GetBlock('content');
//                var sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
//			    sBannerMsg += "<table class=\"MessageContent\" align=\"center>\"\n";
//               sBannerMsg += "<tr><td>DEBUG: No Subordination Agreement on previous financial statement found. " + recCompany.comp_PRFinancialStatementDate + "</td></tr>";
//			    sBannerMsg += "</table>\n";
//			    sBannerMsg += "</td></tr></table>\n\n";
//			    blkBanners.contents = sBannerMsg;
//				cntMain.AddBlock(blkBanners);
            }
                
            blkFlags.contents = "<input type=\"hidden\" id=\"hdn_SubordinationAgreement\" value=\""+ flag+"\">";
            cntMain.AddBlock(blkFlags);
	    }
    }

                var blkFlags = eWare.GetBlock("content");
            sSQL = "SELECT TOP 1 prfs_SubordinationAgreements FROM PRFinancial WITH (NOLOCK) INNER JOIN Company WITH (NOLOCK) ON  prfs_CompanyId = comp_CompanyID AND prfs_StatementDate = comp_PRFinancialStatementDate WHERE comp_PRFinancialStatementDate IS NOT NULL AND comp_CompanyID=" + comp_companyid + " ORDER BY prfs_StatementDate DESC, ISNULL(prfs_SubordinationAgreements, 'N') DESC";
            recFlags = eWare.CreateQueryObj(sSQL);
            recFlags.SelectSQL();
            flag = "";

     if (eWare.Mode == View)  {
            if (recCompany.comp_PRConfidentialFS == "2") {
                var blkBanners = eWare.GetBlock('content');
                var sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
			    sBannerMsg += "<table class=\"MessageContent\" align=\"center>\"\n";
                sBannerMsg += "<tr><td>Financial figures for this company have been marked Confidential.</td></tr>";
			    sBannerMsg += "</table>\n";
			    sBannerMsg += "</td></tr></table>\n\n";
			    blkBanners.contents = sBannerMsg;
				cntMain.AddBlock(blkBanners);
            }
        }






    // always show this block
    blkEntry = eWare.GetBlock("PRFinancialHeader");
    blkEntry.Title = "Financial";
    field = blkEntry.GetEntry("prfs_companyid");
    field.DefaultValue = comp_companyid;
    field = blkEntry.GetEntry("prfs_currency");
    if (recFinancial("prfs_currency") != null)
        field.DefaultValue = recFinancial("prfs_currency");
    //    Response.Write("prfs_currency:" +  recFinancial("prfs_currency"));

    field = blkEntry.GetEntry("prfs_statementdate");
    field.OnChangeScript = "onchange_StatementDate()";

    cntMain.AddBlock(blkEntry);
    cntMain.CheckLocks = false;
    cntMain.DisplayButton(1)=false;

    var bRedirect = false;

    if (eWare.Mode == "95")// special mode indicating redirection to a FinancialDetail page
    {
        // get the financial detail values needed from the url; these were added in the viewFinancialDetails()
        // javascript method
        var sField = Request.Querystring("sField");
        var sBlock = Request.Querystring("sBlock");
        
        // before redirecting, we need to take all the current fields and store them
        // on the session; otherwise changed values will be lost.  When we return 
        // from PRFinancialDetail, we can reload from the record instead of the database.
        // When we refresh the page in View mode, the record is removed from the session.
        for (x=1; x<= Request.Form.count(); x++)
        {
            sFieldName = String(Request.Form.Key(x));
            if (sFieldName.substr(0,3) == "TOT_")
                sFieldName = sFieldName.substr(4);
            sFieldValue = String(Request.Form.Item(x));
            if (sFieldValue == "on")
                sFieldValue = "Y";
            // we only need to preserve the editable fields
            if (sFieldName.substr(0,5) == "prfs_")
            {
                if (sFieldName == "prfs_companyidURL" || sFieldName.indexOf("prfs_statementdate_") > -1 )
                {
                    continue;
                }
                recFinancial(sFieldName) = sFieldValue;
            }
        }
        Session("recFinancial") = recFinancial;
        
        // assuming we have all the values we need saved, redirect to the FinancialDetails page
        sRedirectUrl = eWare.URL("PRFinancial/PRFinancialDetail.asp")+"&prfs_FinancialId="+prfs_financialid+
                        "&sField="+sField+"&sBlock="+sBlock + "&T=Company&Capt=Rating";
        Response.Redirect(sRedirectUrl);
        return;
    }
    else if (eWare.Mode == Save)
    {
        sFinancialFields = ""+
            ("prfs_cashequivalents,prfs_artrade,prfs_duefromrelatedparties,prfs_loansnotesreceivable," +
            "prfs_marketablesecurities,prfs_inventory,prfs_groweradvances,prfs_othercurrentassets,prfs_totalcurrentassets," + 
            "prfs_accountspayable,prfs_currentmaturity,prfs_creditline," + 
            "prfs_currentloanpayableshldr,prfs_othercurrentliabilities,prfs_totalcurrentliabilities,prfs_property," +
            "prfs_leaseholdimprovements,prfs_otherfixedassets,prfs_accumulateddepreciation,prfs_netfixedassets" +
	        "prfs_longtermdebt,prfs_loansnotespayableshldr,prfs_otherlongliabilities,prfs_totallongliabilities," +
	        "prfs_otherloansnotesreceivable,prfs_goodwill,prfs_othermiscassets,prfs_totalotherassets," +
	        "prfs_othermiscliabilities,prfs_retainedearnings,prfs_otherequity,prfs_totalequity,"+
	        "prfs_totalliabilityandequity,prfs_totalassets,prfs_workingcapital");


        // create a new PRFinancial object because using the one from the session fails
        prfs_Id = recFinancial("prfs_FinancialId");
        if (isEmpty(prfs_Id) || prfs_Id == null){
            recFinancial = eWare.CreateRecord("PRFinancial");
            recFinancial.prfs_companyid = comp_companyid;
            // default the NetPrfotiLoss (Income Statement field) to 'N/A'
            recFinancial.prfs_NetProfitLoss = "N/A";
        }    
        
        sFDNamesToCheck = "";
        for (x=1; x<= Request.Form.count(); x++)
        {
            sFieldName = String(Request.Form.Key(x));
            if (sFieldName.substr(0,4) == "TOT_")
                sFieldName = sFieldName.substr(4);
            sFieldValue = String(Request.Form.Item(x));
            if (sFieldValue == "on")
                sFieldValue = "Y";
            else if (sFieldValue == "-")
                sFieldValue = "0";

            if (sFieldName.substr(0,5) == "prfs_")
            {
                // exclude these fields
                if (sFieldName == "prfs_companyidURL" 
                    || sFieldName == "prfs_reviewedbyInput" 
                    || sFieldName == "prfs_updatedbyInput" 
                    || sFieldName.indexOf("prfs_statementdate_")
                    > -1  )
                {
                    continue;
                }
                // get the corresponding hidden-calc field for each value field
                sCalcFieldValue = String(Request.Form.Item("HIDDEN_FD_"+sFieldName));
                if (!isEmpty(sCalcFieldValue))
                {
                    // we now know this is a numeric field
                    if (sFieldValue == null || sFieldValue == "")
                        sFieldValue = "0";
                    // if a calc field exists compare the totals; if they are the same
                    // and not 0, we may need to add PRFinancialDetail records
                    // append the name to the sFDNamesToCheck list
                    if (sCalcFieldValue == sFieldValue && sFieldValue != "0")
                    {
                        if (sFDNamesToCheck != "")
                            sFDNamesToCheck += ",";
                        sFDNamesToCheck += sFieldName
                    }
                    else if (sCalcFieldValue != sFieldValue && sCalcFieldValue != "0")
                    {
                        // the user has overridden the financial detail values and they need to be removed.
	                    sSQL = "DELETE FROM PRFinancialDetail WHERE " +
	                              " prfd_FinancialId = " + prfs_financialid + " AND " +
	                              " prfd_FieldName='"+ sFieldName + "'"; 
		                qry = eWare.CreateQueryObj(sSQL);
		                qry.ExecSql();
		                // remove the session array 
                        Session.Contents.Remove("arr_" + sFieldName);
                    }
                }
                // if this is a financial field, remove any commas
                if (sFinancialFields.indexOf(sFieldName) > -1)
                {
                    // remove the commas
                    sFieldValue = sFieldValue.replace(/,/g,"");
                    DEBUG("<br>Value being saved for " + sFieldName + ": '" + sFieldValue + "'");
                    recFinancial(sFieldName) = (isNaN(parseInt(sFieldValue))?"":parseInt(sFieldValue));
                }
                // regardless, the FinancialStatement field should be updated
                else if (sFieldName == "prfs_statementdate")
                {
                    // dates have to be stored using the user's preference setting.
                    sDateFormat = "mm/dd/yyyy";
                    recUserSetting = eWare.FindRecord("UserSettings", "uset_userid=" + user_userid + " AND uset_key='NSet_UserDateFormat'");
                    if (!recUserSetting.eof)
                    {
                        if (!isEmpty(recUserSetting.uset_value) && recUserSetting.uset_value != sDateFormat)
                        {
                            sDateFormat = recUserSetting.uset_value;
                            sDate = sFieldValue;
                            if (sDateFormat == "dd/mm/yyyy")
                            {
                                arrDate = sFieldValue.split("/");
                                sFieldValue = arrDate[1]+"/"+arrDate[0]+"/"+arrDate[2];
                            }
                        }
                    }
                    recFinancial(sFieldName) = sFieldValue;
                }
                else if (sFieldName == "prfs_assignedtouserInput")
                {
                    recFinancial("prfs_assignedtouser") = sFieldValue;
                }
                else
                {
                    recFinancial(sFieldName) = sFieldValue;
                }
            }
        }

        // Now check for our publish flag.  Since it is a checkbox, if it is deselected, the
        // browser will not send it to the server.
        sFieldValue = String(Request.Form.Key("prfs_Publish"));
        if (isEmpty(sFieldValue)) {
            recFinancial.prfs_Publish = "";
        }


        // Now check for our publish flag.  Since it is a checkbox, if it is deselected, the
        // browser will not send it to the server.
        sFieldValue = String(Request.Form.Key("prfs_SubordinationAgreements"));
        if (isEmpty(sFieldValue)) {
            recFinancial.prfs_SubordinationAgreements = "";
        }




        // Load the module to perform and save the calcualted ratio values.

    %>
    <!-- #include file ="RatioCalculationsInclude.asp" -->
    <%

        // Save the financial statement
        recFinancial.SaveChanges();

        prfs_financialid = recFinancial("prfs_FinancialId");
        recFinancial = eWare.FindRecord("PRFinancial", "prfs_FinancialId=" + prfs_financialid);
        // now that we have a financial statement, check any fields that may have financial detail records to save

        arrFDFields = sFDNamesToCheck.split(",");
        // for each of the values in the array, check the session; if an array exists
        // parse and save it as the financial details.
        for (ndx=0; ndx < arrFDFields.length; ndx++)
        {
            sFieldName = arrFDFields[ndx];
            arrValues = Session("arr_"+sFieldName);
            if (arrValues != null && arrValues.length > 0)
            {
                for (ndxValues=0; ndxValues < arrValues.length; ndxValues++)
                {
                    detailValues = arrValues[ndxValues].split("~");
                    // FD values exist in the form <FDId>~<description>~<value>
	                sFinancialDetailId = detailValues[0];
	                sDescription = detailValues[1];
	                sAmount = detailValues[2];
	                // if amount is empty, DELETE; if FinancialDetailId is 0, INSERT; else update
	                if (sAmount == "" && sFinancialDetailId != 0)
	                {
	                    sSQL = "DELETE FROM PRFinancialDetail WHERE prfd_FinancialDetailId = " + sFinancialDetailId;
		                qry = eWare.CreateQueryObj(sSQL);
		                qry.ExecSql();
	                }
	                else if (sFinancialDetailId == 0)
	                {
	                    // never add new if amount is empty
	                    if (!isEmpty(sAmount))
	                    {
	                        recFD = eWare.CreateRecord("PRFinancialDetail");
	                        recFD.prfd_FinancialId = prfs_financialid;    
	                        recFD.prfd_FieldName = sFieldName;    
	                        recFD.prfd_Description = sDescription;    
	                        recFD.prfd_Amount = sAmount;
	                        recFD.SaveChanges();    
                        }
	                }
	                else
	                {
	                    recFD = eWare.FindRecord("PRFinancialDetail", "prfd_FinancialDetailId=" +sFinancialDetailId);
	                    sOrigDesc = recFD.prfd_Description;
	                    sOrigAmt = recFD.prfd_Amount;
	                    if (sOrigDesc != sDescription || sOrigAmt != sAmount)
	                    {
	                        recFD.prfd_Description = sDescription;    
	                        recFD.prfd_Amount = sAmount;
	                        recFD.SaveChanges();    
	                    }
	                }
                }
            }
        }
        
        // after we save, allow the financial statement to be displayed in view mode
        if (!bNew )
            eWare.Mode = View;
        else
        {
            eWare.Mode = Edit;
            bNew = false;
            Session("recFinancial") = recFinancial;
        }
    }


    var szStatementImageFile = ""
    if (eWare.Mode == View)
    {
        // remove the saved values from the session; they can only exist if we are in edit mode
        Session.Contents.Remove("recFinancial");
    }
        
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRFinancial.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRFinancialSummary.js\"></script>");

    Response.Write("<script type=\"text/javascript\">");
    // set up client-side variable for the PRFinancialDetail invocation
    sFDUrl = changeKey(sURL, "em", "95");
    Response.Write("    var sFinancialDetailUrl = \"" + sFDUrl+ "\";");
    Response.Write("</script>");

    // do not allow saving fincial infor until the header is saved
    if (!bNew)
    {
        // **************
        // CURRENT ASSETS
        // **************
        sAssetContents = createAccpacBlockHeader("tblCurrentAssets", "Current Assets");
        sAssetContents += getFinancialBlockContents("PRFinancialCurrentAssets");
        sAssetContents += createAccpacBlockFooter();

        // **************
        // CURRENT LIABILITIES
        // **************
        sLiabilityContents = createAccpacBlockHeader("tblCurrentLiabilities", "Current Liabilities");
        sLiabilityContents += getFinancialBlockContents("PRFinancialCurrentLiabilities");
        sLiabilityContents += createAccpacBlockFooter();

        // **************
        // FIXED ASSETS
        // **************
        sFixedAssetsContents = createAccpacBlockHeader("tblFixedAssets", "Fixed Assets");
        sFixedAssetsContents += getFinancialBlockContents("PRFinancialFixedAssets");
        sFixedAssetsContents += createAccpacBlockFooter();

        // **************
        // LONG-TERM LIABILITIES
        // **************
        sLTLiabilitiesContents = createAccpacBlockHeader("tblLTLiabilities", "Long-Term Liabilities");
        sLTLiabilitiesContents += getFinancialBlockContents("PRFinancialLTLiabilities");
        sLTLiabilitiesContents += createAccpacBlockFooter();

        // **************
        // OTHER ASSETS
        // **************
        sOtherAssetsContents = createAccpacBlockHeader("tblOtherAssets", "Other Assets");
        sOtherAssetsContents += getFinancialBlockContents("PRFinancialOtherAssets");
        sOtherAssetsContents += createAccpacBlockFooter();

        // **************
        // OTHER LIABILITIES
        // **************
        sOtherLiabilitiesContents = createAccpacBlockHeader("tblOtherLiabilities", "Other Liabilities");
        sOtherLiabilitiesContents += getFinancialBlockContents("PRFinancialOtherLiabilities");
        sOtherLiabilitiesContents += createAccpacBlockFooter();

        // **************
        // OTHER EQUITY
        // **************
        sOtherEquityContents = createAccpacBlockHeader("tblOtherEquity", "Total Equity");
        sOtherEquityContents += getFinancialBlockContents("PRFinancialOtherEquity");
        sOtherEquityContents += createAccpacBlockFooter();


        // **************
        // TOTALS
        // **************
        sTotalsContents = createAccpacBlockHeader("tblTotals", "Totals");
        sTotalsContents += getFinancialBlockContents("PRFinancialTotals");
        sTotalsContents += createAccpacBlockFooter();


        sBalanceSheetContents = "\n<table width=95% ID=\"tblBalanceSheet\" CELLPADDING=0>";
        sBalanceSheetContents += "\n<tr>";
        sBalanceSheetContents += "\n<td valign=\"TOP\">";
        
        // create a table with two columns; one for all fields contributing to net income, the other
        // for depreciation and amortization
        sBalanceSheetContents += "\n<table valign=\"TOP\" width=\"100%\" ID='tblBSDetails' CELLPADDING=0>";

        sBalanceSheetContents += "\n<tr>";
        sBalanceSheetContents += "\n<td valign=top width=\"49%\">";
        sBalanceSheetContents += sAssetContents;
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n<td width=5>&nbsp;</td>";
        sBalanceSheetContents += "\n<td valign=top width=\"49%\">";
        sBalanceSheetContents += sLiabilityContents;
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n</tr>";

        sBalanceSheetContents += "\n<tr height=10><td></td></tr>";

        sBalanceSheetContents += "\n<tr>";
        sBalanceSheetContents += "\n<td valign=top>";
        sBalanceSheetContents += sFixedAssetsContents;
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n<td width=5>&nbsp;</td>";
        sBalanceSheetContents += "\n<td valign=top>";
        sBalanceSheetContents += sLTLiabilitiesContents;
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n</tr>";

        sBalanceSheetContents += "\n<tr height=10><td></td></tr>";

        sBalanceSheetContents += "\n<tr>";
        sBalanceSheetContents += "\n<td valign=top>";
        sBalanceSheetContents += sOtherAssetsContents;
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n<td width=5>&nbsp;</td>";
        sBalanceSheetContents += "\n<td valign=top>";
        sBalanceSheetContents += sOtherLiabilitiesContents;
        sBalanceSheetContents += "<br>\n";
        sBalanceSheetContents += sOtherEquityContents;
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n</tr>";

        sBalanceSheetContents += "\n<tr height=10><td></td></tr>";

        sBalanceSheetContents += "\n<tr>";
        sBalanceSheetContents += "\n<td valign=top >";
        sBalanceSheetContents += sTotalsContents;
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n<td width=5>&nbsp;</td>";
        sBalanceSheetContents += "\n<td valign=top>";
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n</tr>";
        sBalanceSheetContents += "\n</table>";
        
        sBalanceSheetContents += "\n</td>";
        sBalanceSheetContents += "\n</tr>";
        sBalanceSheetContents += "\n</table>";

        blkContent = eWare.GetBlock("content");
        blkContent.contents = sBalanceSheetContents;
        cntMain.AddBlock(blkContent);
    }

    sListingAction = eWare.Url("PRCompany/PRCompanyFinancial.asp")+ "&comp_companyid=" + comp_companyid + "&T=Company&Capt=Rating";
    // IF WERE DELETING
    if (eWare.Mode == PreDelete) 
    {
        sql = "DELETE FROM PRFinancial WHERE prfs_FinancialId = " + prfs_financialid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
        Response.Redirect(sListingAction);
    } 
    else 
    {
        cntMain.DisplayButton(Button_Continue) = false;
        if(eWare.Mode == Edit) 
        {
	        if (bNew) {
	            sCancelAction = sListingAction; 
	        } else {
	            sCancelAction = eWare.URL("PRFinancial/PRFinancialSummary.asp") + "&T=Company&Capt=Rating";
                sCancelAction = changeKey(sCancelAction, "prfs_FinancialId", prfs_financialid);
	        }
	        cntMain.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
            sSaveAction = changeKey(sURL, "prfs_FinancialId", prfs_financialid);
	        cntMain.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.action='" + sSaveAction + "';save();"));
        } else {
	        cntMain.AddButton(eWare.Button("Continue", "continue.gif", eWare.URL("PRCompany/PRCompanyFinancial.asp")));
	        cntMain.AddButton(eWare.Button("Income Statement", "calendar.gif", eWare.URL("PRFinancial/PRFinancialIncome.asp")+"&E=PRCompany&T=Company&Capt=Rating&prfs_FinancialId=" + prfs_financialid, 'PRCompany', 'insert'));
	        cntMain.AddButton(eWare.Button("Ratios", "calendar.gif", eWare.URL("PRFinancial/PRFinancialRatio.asp")+"&E=PRCompany&T=Company&Capt=Rating&prfs_FinancialId=" + prfs_financialid, 'PRCompany', 'insert'));
            sChangeAction = changeKey(sURL, "prfs_FinancialId", prfs_financialid);
	        cntMain.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sChangeAction + "';document.EntryForm.submit();", 'PRCompany', 'insert'));

            sDeleteUrl = changeKey(sURL, "em", "3");
            cntMain.AddButton(eWare.Button("Delete", "delete.gif", 
                "javascript:if (confirm('Are you sure you want to permanently delete this financial statement?')) {" + 
                "location.href='"+sDeleteUrl+"';}"));

        }
    }

    eWare.AddContent(cntMain.Execute(recFinancial));
    Response.Write(eWare.GetPage('Company'));
    if (!bNew)
    {
    %>
        <script type="text/javascript" >
            function initBBSI() 
            {
                loadFields();
                updatePrimaryTotals();                
                // Be nice and call the Accpac default onLoad routine
                //LoadComplete('');

<%    if (eWare.Mode == View)   { 
        if (!isEmpty(recFinancial("prfs_StatementImageFile"))) { 
            prfs_statementimagefile = recFinancial("prfs_StatementImageFile").replace(/\\/, '/');
            sFinancialStatementRoot = eWare.GetTrans("FinancialStatementRoot", 1);
%>
            var oCtrl = document.all["_Dataprfs_statementimagefile"];
            if (oCtrl != null){
                var sInner = oCtrl.innerHTML;
                
                sInner = "<a href=\"<%= sFinancialStatementRoot %>/<%= prfs_statementimagefile%>\" class=WEBLINK target=EWAREVISITS> <%= prfs_statementimagefile%></a>";
                oCtrl.innerHTML = sInner;
            }
        
<%      }
    } 
%>

            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
        </script>
<%
    }
}

doPage();

if (eWare.Mode == Edit) { %>
        <script type="text/javascript" >
			window.setTimeout(function ()
			{
				document.getElementById("prfs_statementdate").focus();
			}, 100);
		
        </script>
<% } %>

<!-- #include file="../PRCompany/CompanyFooters.asp" -->