<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2016

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    var sSecurityGroups = "1,2,3,5,6,10";

    origMode = eWare.Mode;
    // sets an accpac block field based upon the submitted value
    function setDefaultValue(blk, sFieldName)
    {
        fld = blkCore.GetEntry(sFieldName);
        sValue = String(Request.Form.Item(sFieldName));
        if (!isEmpty(sValue))
            fld.DefaultValue = sValue;
    }


    sURL = removeKey(sURL, "em");

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyBusinessEventInclude.js\"></script>");

    var sDefaultPublishUntilLine = "";
    // Determine if this is new or edit
    var sCustomAction = new String(Request.QueryString("customact"));
    var prbe_BusinessEventId = getIdValue("prbe_BusinessEventId");

    var bNew = false;
    // indicate that this is new
    if (prbe_BusinessEventId == "-1")
    {
        prbe_publishuntildate  = Request.Form.Item("prbe_publishuntildate");
        if (isEmpty(prbe_publishuntildate))
            sDefaultPublishUntilLine = "setDefaultPublishUntil();";
        bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }

//Response.Write("<br>OrigMode: " + origMode);
//Response.Write("<br>Mode: " + eWare.Mode);
//Response.Write("<br>CompanyId: " + comp_companyid);
//Response.Write("<br>BusEventId: " + prbe_BusinessEventId);

    sListingAction = eWare.Url("PRCompany/PRCompanyBusinessEventListing.asp")+ "&prbe_CompanyId=" + comp_companyid + "&T=Company&Capt=Bus.+Events";
    sSummaryAction = eWare.Url("PRCompany/PRCompanyBusinessEvent.asp")+ "&prbe_BusinessEventId="+ prbe_BusinessEventId + "&T=Company&Capt=Bus.+Events";

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkCore=eWare.GetBlock("PRBusinessEvent_Core");
    blkCore.Title = "Business Event";

    if (bNew)
    {
        recBusinessEvent = eWare.CreateRecord("PRBusinessEvent");
        prbe_BusinessEventTypeId = getIdValue("prbe_BusinessEventTypeId");
        prbe_DisplayedEffectiveDateStyle = getIdValue("prbe_DisplayedEffectiveDateStyle");
        // store the submitted business event type id
        if (prbe_BusinessEventTypeId != "-1")
            recBusinessEvent.prbe_BusinessEventTypeId = prbe_BusinessEventTypeId;
         
    } 
    else
    {
        recBusinessEvent = eWare.FindRecord("PRBusinessEvent", "prbe_BusinessEventId=" + prbe_BusinessEventId);
        prbe_BusinessEventTypeId = recBusinessEvent("prbe_BusinessEventTypeId");
        prbe_DisplayedEffectiveDateStyle = recBusinessEvent("prbe_DisplayedEffectiveDateStyle");
    }    

  
    fldBusinessEventType = blkCore.GetEntry("prbe_BusinessEventTypeId");
    fldBusinessEventType.AllowBlank = false;
    fldBusinessEventType.OnChangeScript = "setDefaultPublishUntil();";
    fldEffDate = blkCore.GetEntry("prbe_EffectiveDate");
    fldEffDate.OnChangeScript = "handleEffectiveDateChange();";

    var blk2=null;
    if (origMode == 95)
    {
        setDefaultValue(blkCore, "prbe_effectivedate");
        setDefaultValue(blkCore, "prbe_CreditSheetNote");
        setDefaultValue(blkCore, "prbe_InternalAnalysis");
        setDefaultValue(blkCore, "prbe_PublishedAnalysis");
        setDefaultValue(blkCore, "prbe_PublishUntilDate");
    }
    if (!bNew || origMode == 95 || eWare.Mode == Save)
    {
        // Load Type-Specific Screens
        switch (prbe_BusinessEventTypeId) {
            case "1": 
                blk2=eWare.GetBlock("PRBusinessEvent_Acquisition");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_AcquisitionType";
                fldDetailedType.Caption = "Acquisition Type:";
                fldDetailedType.AllowBlank = false;
                fldDetailedType.OnChangeScript = "handleDetailedTypeChange();";
                break;
            case "2": 
            case "19":             
                blk2=eWare.GetBlock("PRBusinessEvent_Agreement");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_AcquisitionType";
                fldDetailedType.AllowBlank = false;
                fldDetailedType.OnChangeScript = "handleDetailedTypeChange();";
                fld = blk2.GetEntry("prbe_AgreementCategory");
                fld.AllowBlank = false;
                break;
            case "3": 
                blk2=eWare.GetBlock("PRBusinessEvent_Assignment");
                break;
            case "5": 
                blk2=eWare.GetBlock("PRBusinessEvent_USBankrupcy");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_USBankruptcyType";
                fldDetailedType.AllowBlank = false;
                fld = blk2.GetEntry("prbe_USBankruptcyEntity");
                fld.AllowBlank = false;
                fld = blk2.GetEntry("prbe_USBankruptcyCourt");
                fld.AllowBlank = false;
                fld = blk2.GetEntry("prbe_SpecifiedCSNumeral");
                fld.AllowBlank = false;
                fld = blk2.GetEntry("prbe_AssigneeTrusteeName");
                fld.Caption = "Trustee Name:";
                fld = blk2.GetEntry("prbe_AssigneeTrusteePhone");
                fld.Caption = "Trustee Phone:";
                break;
            case "6": 
                blk2=eWare.GetBlock("PRBusinessEvent_CanBankrupcy");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_CanBankruptcyType";
                fldDetailedType.AllowBlank = false;
                break;
            case "7": 
                blk2=eWare.GetBlock("PRBusinessEvent_BusinessClosed");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_BusinessClosureType";
                fldDetailedType.AllowBlank = false;
                break;
            case "8": 
                blk2=eWare.GetBlock("PRBusinessEvent_BusinessChange");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_NewEntityType";
                fldDetailedType.AllowBlank = false;
                break;
            case "9": 
                blk2=eWare.GetBlock("PRBusinessEvent_BusinessStarted");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_NewEntityType";
                fldDetailedType.AllowBlank = false;
                break;
            case "10": 
                blk2=eWare.GetBlock("PRBusinessEvent_OwnershipSale");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_SaleType";
                fldDetailedType.AllowBlank = false;
                break;
            case "11": 
                blk2=eWare.GetBlock("PRBusinessEvent_BusinessSale");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_AcquisitionType";
                fldDetailedType.AllowBlank = false;
                fldDetailedType.OnChangeScript = "handleDetailedTypeChange();";
                break;
            case "12": 
                blk2=eWare.GetBlock("PRBusinessEvent_DRCIssue");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_DRCType";
                fldDetailedType.AllowBlank = false;
                break;
            case "13": 
                blk2=eWare.GetBlock("PRBusinessEvent_Extension");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_ExtensionType";
                fldDetailedType.AllowBlank = false;
                break;
            case "17": 
                blk2=eWare.GetBlock("PRBusinessEvent_Injunction");
                break;
            case "18": 
            case "20": 
            case "30": 
                blk2=eWare.GetBlock("PRBusinessEvent_Judgement");
                break;
            case "23": 
                blk2=eWare.GetBlock("PRBusinessEvent_Disaster");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_DisasterType";
                fldDetailedType.AllowBlank = false;
                fldDetailedType.OnChangeScript = "handleDetailedTypeChange();";
                fld = blk2.GetEntry("prbe_DisasterImpact");
                fld.AllowBlank = false;
                break;
            case "27": 
                blk2=eWare.GetBlock("PRBusinessEvent_PACAEvent");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_OtherPACAType";
                fldDetailedType.AllowBlank = false;
                break;
            case "28": 
                blk2=eWare.GetBlock("PRBusinessEvent_PACASuspended");
                fldDetailedType = blk2.GetEntry("prbe_DetailedType");
                fldDetailedType.LookupFamily = "prbe_PACASuspensionType";
                fldDetailedType.AllowBlank = false;
                break;
            case "32": 
            case "33": 
                blk2=eWare.GetBlock("PRBusinessEvent_Receivership");
                fld = blk2.GetEntry("prbe_RelatedCompany1Id");
                fld.Caption = "Receiver Company:";
                fld = blk2.GetEntry("prbe_RelatedCompany2Id");
                fld.Caption = "Party Company:";
                break;
            case "36": 
                blk2=eWare.GetBlock("PRBusinessEvent_TreasuryStock");
                fld = blk2.GetEntry("prbe_Amount");
                fld.Caption = "Valued Amount:";
                break;
            case "37": 
                blk2=eWare.GetBlock("PRBusinessEvent_TRO");
                fld = blk2.GetEntry("prbe_RelatedCompany1Id");
                fld.Caption = "Plaintiff Company:";
        }

        if (blk2 != null)
            blk2.Title = "Additional Info";

        fldBusinessEventType.DefaultValue = prbe_BusinessEventTypeId;
        fldBusinessEventType.ReadOnly = true;
        if (origMode == 95)
        {
            if (blk2 == null)
                eWare.Mode = Save;
            else    
                eWare.Mode = Edit;
        }        
    }
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        //DumpFormValues();
        
        if (bNew)
        {
            if (!isEmpty(comp_companyid)) 
            {
                recBusinessEvent.prbe_CompanyId = comp_companyid;
            }
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
	    }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }
	    
        if (isUserInGroup(sSecurityGroups))
        {
            if (bNew && origMode != 95)
            {
                sAddInfoUrl = changeKey(sURL, "em", "95");
                blkContainer.AddButton(eWare.Button("Next","save.gif","javascript:document.EntryForm.action='" + sAddInfoUrl + "';save();"));
            }
            else
            {
                sURL = changeKey(sURL, "prbe_BusinessEventTypeId", prbe_BusinessEventTypeId);
                blkContainer.AddButton(eWare.Button("Save","save.gif","javascript:document.EntryForm.action='" + sURL + "';save();"));
            }    
        }
	}
    else if (eWare.Mode == PreDelete )
    {
        var sText = "";
        sql = "SELECT text = dbo.ufn_GetBusinessEventText(" + prbe_BusinessEventId + ", 1)";
        qryText = eWare.CreateQueryObj(sql);
        qryText.SelectSql();
        if (!qryText.eof)  {
            sText = qryText("text");
        }
        var qryTransDetail = eWare.CreateQueryObj("usp_CreateTransactionDetail " + recTrx.prtx_TransactionId + ", 'Business Event', 'Delete', 'Published Text', '" + padQuotes(sText) + "', null");
        qryTransDetail.ExecSql();
    
        //Perform a physical delete of the record
        sql = "DELETE FROM PRBusinessEvent WHERE prbe_BusinessEventId="+ prbe_BusinessEventId;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        
        
    
        if (iTrxStatus == TRX_STATUS_EDIT)
        {        
            if (isUserInGroup(sSecurityGroups))
            {
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
            }
            
            if (isUserInGroup("1,2,10"))
            {
                sDeleteUrl = changeKey(sURL, "em", "3");
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:if(confirm('Are you sure you want to delete this business event?')) {location.href='"+sDeleteUrl+"'};"));
            }
        }
        
        
        if (isUserInGroup(sSecurityGroups))
        {
    	    // Add a New C/S button for the business event
    	    var sNewCSUrl = eWare.Url("PRCreditSheet/PRCreditSheet.asp");
		    sNewCSUrl += "&prcs_SourceType=BE&prcs_SourceId=" + prbe_BusinessEventId;
		    sNewCSUrl += "&prevCustomURL=" + sURL; 
		    blkContainer.AddButton(eWare.Button("New C/S Item", "new.gif", sNewCSUrl));
        }
    }

    // update blkCore to only show the Displayed Date dropdown or text value, not both
    fldDisplayedEffDate = blkCore.GetEntry("prbe_DisplayedEffectiveDate");
    fldDisplayedEffDateStyle = blkCore.GetEntry("prbe_DisplayedEffectiveDateStyle");

    fldUpdatedBy = blkCore.GetEntry("prbe_UpdatedBy");
    fldUpdatedBy.ReadOnly = true;
    
    fldUpdatedDate = blkCore.GetEntry("prbe_UpdatedDate");
    fldUpdatedDate.ReadOnly = true;

    if (eWare.Mode == Edit)
    {
        fldDisplayedEffDate.Hidden = true;
        fldDisplayedEffDateStyle.Hidden = true;

        //fldDisplayedEffDateStyle.OnChangeScript = "handleDisplayedDateStyleChange();";

        blkContent = eWare.GetBlock("Content");
        blkContent.contents  = "\n<div id=\"div_DispEffDate\">\n";
        blkContent.contents += "<span class=\"VIEWBOXCAPTION\">Displayed Effective Date:</span><br/>\n";
        blkContent.contents += "<table cellpadding=0 cellspacing=0 border=0>\n";
        var sRadio0Checked = "";
        var sRadio1Checked = "";
        if (bNew)
        {
            // check the form values for the style
            _radioDispEffDate = getIdValue("_radioDispEffDate");

            if ( _radioDispEffDate != "-1")
                sRadio0Checked = "CHECKED";
            else
                sRadio1Checked = "CHECKED";
            prbe_displayedeffectivedatestyle = getIdValue("prbe_displayedeffectivedatestyle");
            prbe_displayedeffectivedate = new String(Request.Form.Item("prbe_displayedeffectivedate"));
            if ( !Defined(prbe_displayedeffectivedate))
                prbe_displayedeffectivedate = "";
        }
        else
        {
            prbe_displayedeffectivedatestyle = recBusinessEvent("prbe_displayedeffectivedatestyle");
            prbe_displayedeffectivedate = recBusinessEvent("prbe_displayedeffectivedate");
            if (prbe_displayedeffectivedatestyle > -1)
                sRadio0Checked = "CHECKED";
            else
                sRadio1Checked = "CHECKED";
        }
        blkContent.contents += "<tr>\n";
        blkContent.contents += "<td style=\"width:100px;\"><input type=\"radio\" id=\"_radioDispEffDate\" name=\"_radioDispEffDate\" onclick=\"onClickEffectiveDateRadio();\" " + sRadio0Checked + " >";
        blkContent.contents += "<span class=\"VIEWBOXCAPTION\">Formatted:&nbsp;</span>\n</td>\n";
        blkContent.contents += "<td>\t<select class=\"EDIT\" size=\"1\" id=\"prbe_displayedeffectivedatestyle\" name=\"prbe_displayedeffectivedatestyle\" onchange=\"handleDisplayedDateStyleChange();\"\n>";
        blkContent.contents += "<option value=\"\" SELECTED>--None--</option></select></td>\n";
        blkContent.contents += "</tr>\n";
        blkContent.contents += "<tr>\n";
        blkContent.contents += "<td style=\"width:100px;\" ><input type=\"radio\" id=\"_radioDispEffDate\" name=\"_radioDispEffDate\" onclick=\"onClickEffectiveDateRadio();\"" + sRadio1Checked + " >";
        blkContent.contents += "<span class=\"VIEWBOXCAPTION\">Custom:&nbsp;</span></td>\n";
        blkContent.contents += "<td><input class=\"EDIT\" type=\"text\" name=\"prbe_DisplayedEffectiveDate\" id=\"prbe_DisplayedEffectiveDate\" value=\"" + prbe_displayedeffectivedate + "\"></td>\n";
        blkContent.contents += "</tr>\n";
        blkContent.contents += "</table></div>\n\n";
        blkContainer.AddBlock(blkContent);
    }
    else
    {
        fldDisplayedEffDateStyle.Hidden = true;
    }

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkCore);
    if (blk2 != null)
        blkContainer.AddBlock(blk2);
    if (eWare.Mode == View)
    {
        var sText = ""
        sql = "SELECT text = dbo.ufn_GetBusinessEventText(" + prbe_BusinessEventId + ", 1)";
        qryText = eWare.CreateQueryObj(sql);
        qryText.SelectSql();
        if (!qryText.eof)  {
            sText = qryText("text");
        }

        //var sText = "Formatted Business Event text is temporarily unavailable.";
        
        blkBEText = eWare.GetBlock("Content");
        blkBEText.contents = createAccpacBlockHeader("BEText", "Business Event Text");
        blkBEText.contents += "<table class=CONTENT width=100% ><tr><td  VALIGN=TOP >";
        blkBEText.contents += "<span class=VIEWBOX >" + sText + "&nbsp;</span></td></tr></table>";
        blkBEText.contents += createAccpacBlockFooter();
        blkContainer.AddBlock(blkBEText);    
        eWare.AddContent(blkContainer.Execute(recBusinessEvent));
    }
    else if (eWare.Mode == Save && bNew)
    {
        // when saving a new record, accpac will save core fields then execute an update statement
        // on any blk2 fields; this will fail because a transaction is not open.  Therefore, we have
        // to move the blk2 fields to the record prior to the blkCore record save.
        for (x = 1; x <= Request.Form.count(); x++) {
            sFieldName = Request.Form.Key(x);
            if (sFieldName.substring(0,5) == "prbe_")
            {
                if ( (sFieldName.indexOf("_HOUR") == -1) &&
                     (sFieldName.indexOf("_MINUTE") == -1) &&
                     (sFieldName.indexOf("_AMPM") == -1) &&
                     (sFieldName.indexOf("idURL") == -1) &&
                     (sFieldName.indexOf("idTEXT") == -1) 
                   )
                {   
                    sFieldValue = Request.Form.Item(x);
                    if (sFieldName == "prbe_creditsheetpublish" ||
                        sFieldName == "prbe_usbankruptcyvoluntary")
                    {
                        if (sFieldValue == "on")
                            sFieldValue = "Y";
                    }
                    
                    recBusinessEvent(sFieldName) = sFieldValue;
                }
            }
            else if (sFieldName == "_HIDDENprbe_businesseventtypeid")
            {
                sFieldValue = Request.Form.Item(x);
                // handle types that only have one screen
                if (!isEmpty(sFieldValue))
                    recBusinessEvent("prbe_businesseventtypeid") = sFieldValue;
            }
        }
        recBusinessEvent.SaveChanges();
        
        //If the CS Publish checkbox is checked, create a credit sheet item with the appropriate defaults
        var prbe_creditsheetpublish = Request.Form.Item("prbe_creditsheetpublish");
        
        // Now create some Credit Sheet items for select
        // lumber company events.
        if ((bNew) && 
            (prbe_creditsheetpublish == "on") &&
            (recCompany.comp_PRIndustryType ==  "L") &&
                (recCompany.comp_PRListingStatus == "L" || 
                 recCompany.comp_PRListingStatus == "H" || 
                 recCompany.comp_PRListingStatus == "LUV" || 
                 recCompany.comp_PRListingStatus == "N3" || 
                 recCompany.comp_PRListingStatus == "N5" || 
                 recCompany.comp_PRListingStatus == "N6")
            ) {        

            var iDaysThreshold = 120;
            recDaysThreshold = eWare.CreateQueryObj("SELECT dbo.ufn_GetCustomCaptionValue('LumberBizEventCSThreshold', 'Days', DEFAULT) As LumberBizEventCSThreshold;");
            recDaysThreshold.SelectSQL();
            if (!recDaysThreshold.eof)  {
                iDaysThreshold = recDaysThreshold("LumberBizEventCSThreshold");
            }

            var today=new Date();
            var one_day=1000*60*60*24;
            
            var dtEffectiveDate = new Date(recBusinessEvent("prbe_EffectiveDate"));
            
            // Only events within a certain number of days in the past are included.
            if ((dtEffectiveDate.getTime() >  Math.ceil((today.getTime() - (iDaysThreshold * one_day)))) &&
                (dtEffectiveDate.getTime() < today.getTime())) {

                // Custom captions controls which business events get translated
                // into Credit Sheet items.
                var szCreditSheetText = null;
                recCreditSheetText = eWare.CreateQueryObj("SELECT dbo.ufn_GetCustomCaptionValue('CreditSheetBusinessEventText', '" + prbe_BusinessEventTypeId + "', DEFAULT) As CreditSheetText;");
                recCreditSheetText.SelectSQL();
                if (!recCreditSheetText.eof)  {
                    szCreditSheetText = recCreditSheetText("CreditSheetText");
                }
      
                if (szCreditSheetText != null) {
                    recCS = eWare.CreateRecord("PRCreditSheet");
                    recCS.prcs_CompanyId = comp_companyid;
                    recCS.prcs_Tradestyle = recCompany("comp_PRBookTradestyle");
                    recCS.prcs_CityID = recCompany("comp_PRListingCityID");
                    recCS.prcs_Status = "P";
                    recCS.prcs_SourceId = recBusinessEvent("prbe_BusinessEventId");
                    recCS.prcs_SourceType = "BE";
                    recCS.prcs_AuthorId = recBusinessEvent("prbe_CreatedBy");
                    recCS.prcs_KeyFlag = "Y";
                    recCS.prcs_PublishableDate = getDBDateTime(today);
                    recCS.prcs_Change = szCreditSheetText;
                    recCS.SaveChanges();
                }            
            }     
        }
    }
    else
        eWare.AddContent(blkContainer.Execute(recBusinessEvent));

    if (eWare.Mode == Save) 
    {
	    if (bNew)
	        Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction);
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n        handleDetailedTypeChange(); " );
        Response.Write("\n        onClickEffectiveDateRadio(); " );
        Response.Write("\n        setDisplayedDateStyleIndex(" + prbe_DisplayedEffectiveDateStyle + "); ");
        Response.Write("\n        " + sDefaultPublishUntilLine );
        Response.Write("\n        AppendCell(\"_Captprbe_effectivedate\", \"div_DispEffDate\");" );

    
        recExcludeBETypes = eWare.CreateQueryObj("SELECT prbt_BusinessEventTypeid FROM PRBusinessEventType WITH (NOLOCK) WHERE prbt_IndustryTypeCode NOT LIKE '%," + recCompany.comp_PRIndustryType + ",%';");
        recExcludeBETypes.SelectSQL();
        while (!recExcludeBETypes.eof)  {
        	Response.Write("\n    RemoveDropdownItemByValue('prbe_businesseventtypeid', '" + recExcludeBETypes("prbt_BusinessEventTypeid") + "');")
	        recExcludeBETypes.NextRecord();
        }

        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");

    }
    else
    {
        Response.Write(eWare.GetPage());
    }

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

%>
<!-- #include file="CompanyFooters.asp" -->
