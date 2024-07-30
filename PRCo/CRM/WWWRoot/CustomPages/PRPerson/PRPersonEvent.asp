    <!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<%
    var sSecurityGroups = sDefaultPersonSecurity;

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRPersonEventInclude.js\"></script>");

	var sEntityName = "PRPersonEvent";
    var sListingPage = "PRPerson/PRPersonEventListing.asp";
    var sSummaryPage = "PRPerson/PRPersonEvent.asp";
    var sEntityIdName = "prpe_PersonEventId";
    var sNewEntryBlockName = "PRPersonEventNewEntry";

    blkContainer = eWare.GetBlock("container");
    blkContainer.DisplayButton(Button_Default) = false;

    blkEntry=eWare.GetBlock(sNewEntryBlockName);
    blkEntry.Title="Person Event";

    entry = blkEntry.GetEntry("prpe_USBankruptcyCourt");
    entry.LookupFamily = "prpe_USBankruptcyCourt";

    blkContainer.CheckLocks = false; 
    blkContainer.AddBlock(blkEntry);
    
    DEBUG("PersonID: " + pers_personid);
    var Id = getIdValue(sEntityIdName);
    // indicate that this is new
    if (Id == -1 )
    {
	    rec = eWare.CreateRecord(sEntityName);
		rec.item("prpe_PersonId") = pers_personid;
        prpe_DisplayedEffectiveDateStyle = getIdValue("prpe_displayedeffectivedatestyle");

        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    else
    {
        rec = eWare.FindRecord(sEntityName, sEntityIdName + "=" + Id);
        prpe_DisplayedEffectiveDateStyle = rec("prpe_DisplayedEffectiveDateStyle");
    }

    sListingAction = eWare.Url(sListingPage)+ "&prpe_PersonId=" + pers_personid + "&T=Person&Capt=Events";
    sSummaryAction = eWare.Url(sSummaryPage)+ "&" + sEntityIdName + "="+ Id + "&T=Person&Capt=Events";

    bValidationError = false;
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Save)
    {
        if (blkContainer.Validate())
        {
            prpe_personeventtypeid = new String(Request.Form.Item("prpe_personeventtypeid"));
            rec.prpe_PersonEventTypeId = prpe_personeventtypeid;
            blkContainer.Execute(rec); 

            //Debugging Lines...
            //eWare.AddContent(blkContainer.Execute(rec)); 
            //eWare.Mode = View;
            //Response.Write(eWare.GetPage('New'));
  	    
	        if (Id == -1 )
	            Response.Redirect(sListingAction);
	        else
	            Response.Redirect(sSummaryAction);
        }
        else
        {
            bValidationError = true;
        }
        
    }
    
    var sTypeField = "";
    var sTypePublishTimeList = "";
    
    fldDisplayedEffDate = blkEntry.GetEntry("prpe_DisplayedEffectiveDate");
    fldDisplayedEffDateStyle = blkEntry.GetEntry("prpe_DisplayedEffectiveDateStyle");
    if (eWare.Mode == Edit || bValidationError)
    {

        var fldEffDate = blkEntry.GetEntry("prpe_Date");
        fldEffDate.OnChangeScript = "handleEffectiveDateChange();";

        // Set up the Person Event Type dropdown
        sCaption = eWare.GetTrans("ColNames","prpe_personeventtypeid");
        sTypeField = "<DIV style={display:none;}><DIV ID=\"div_prpe_personeventtypeid\" >" + 
                     "<SPAN ID=\"_Captprpe_personeventtypeid\" CLASS=VIEWBOXCAPTION>" + sCaption + ":</SPAN><br><SPAN CLASS=VIEWBOXCAPTION>" +
                     "<INPUT TYPE=HIDDEN NAME=\"_HIDDENprpe_personeventtypeid\">"; 
        
        sTypeField += "<SELECT CLASS=EDIT SIZE=1 NAME=\"prpe_personeventtypeid\" onchange=\"handlePersonEventTypeChange()\">" ;

        sSQL = "SELECT prpt_personeventtypeid, prpt_Name, prpt_PublishDefaultTime FROM PRPersonEventType "; 
        recTypes = eWare.CreateQueryObj(sSQL,"");
        recTypes.SelectSQL();
        bFoundSelected = false;
        while (!recTypes.eof)
        {
            sSelected = "";
            if (Defined(rec) && !rec.eof && !bFoundSelected )
            {
                if (rec("prpe_PersonEventTypeId") == recTypes("prpt_personeventtypeid"))
                {
                    bFoundSelected = true;
                    sSelected = "SELECTED ";
                }
            }
            sTypeField += "<OPTION " + sSelected + "VALUE=\""+ recTypes("prpt_PersonEventTypeId") + "\" >" + recTypes("prpt_Name") + "</OPTION> ";
            sTypePublishTimeList += "\nnDefaultPublishYears"+recTypes("prpt_PersonEventTypeId") + " = " + recTypes("prpt_PublishDefaultTime") + ";";
            
            recTypes.NextRecord();
        }
        sSelected = "";
        sTypeField += "</SELECT></SPAN></DIV></DIV>";
        Response.Write(sTypeField);


        fldDisplayedEffDate.Hidden = true;
        fldDisplayedEffDateStyle.Hidden = true;

        blkContent = eWare.GetBlock("Content");
        blkContent.contents  = "<div ID=\"div_DispEffDate\" >";
        blkContent.contents += "<SPAN class=VIEWBOXCAPTION>Displayed Effective Date :</SPAN><br>";
        blkContent.contents += "<table cellpadding=0 cellspacing=0 border=0>";
        var sRadio0Checked = "";
        var sRadio1Checked = "";
        if (Id == -1)
        {
            // check the form values for the style
            _radioDispEffDate = getIdValue("_radioDispEffDate");
            if ( _radioDispEffDate > -1)
                sRadio0Checked = "CHECKED";
            else
                sRadio1Checked = "CHECKED";
            prpe_displayedeffectivedatestyle = getIdValue("prpe_displayedeffectivedatestyle");
            prpe_displayedeffectivedate = new String(Request.Form.Item("prpe_displayedeffectivedate"));
            if ( !Defined(prpe_displayedeffectivedate))
                prpe_displayedeffectivedate = "";
        }
        else
        {
            prpe_displayedeffectivedatestyle = rec("prpe_displayedeffectivedatestyle");
            prpe_displayedeffectivedate = rec("prpe_displayedeffectivedate");
            if (prpe_displayedeffectivedatestyle > -1)
                sRadio0Checked = "CHECKED";
            else
                sRadio1Checked = "CHECKED";
        }

        blkContent.contents += "<tr>\n";
        blkContent.contents += "<td style=\"width:100px;\"><input type=\"radio\" id=\"_radioDispEffDate\" name=\"_radioDispEffDate\" onclick=\"onClickEffectiveDateRadio();\" " + sRadio0Checked + " >";
        blkContent.contents += "<span class=\"VIEWBOXCAPTION\">Formatted:&nbsp;</span>\n</td>\n";
        blkContent.contents += "<td ><SELECT class=EDIT size=1 ID=\"prpe_displayedeffectivedatestyle\" name=\"prpe_displayedeffectivedatestyle\" onChange=\"handleDisplayedDateStyleChange();\">";
        blkContent.contents += "<option value=\"\" SELECTED>--None--</option></select></td>\n";
        blkContent.contents += "</tr>\n";
        blkContent.contents += "<tr>\n";
        blkContent.contents += "<td style=\"width:100px;\" ><input type=\"radio\" id=\"_radioDispEffDate\" name=\"_radioDispEffDate\" onclick=\"onClickEffectiveDateRadio();\"" + sRadio1Checked + " >";
        blkContent.contents += "<span class=\"VIEWBOXCAPTION\">Custom:&nbsp;</span></td>\n";
        blkContent.contents += "<td ><input CLASS=EDIT TYPE=TEXT NAME=\"prpe_DisplayedEffectiveDate\" ID=\"prpe_DisplayedEffectiveDate\" value=\"" + prpe_displayedeffectivedate + "\"></td></tr>";
        blkContent.contents += "</table></div>";
        blkContainer.AddBlock(blkContent);


        if (Id == -1 )
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        
        if (isUserInGroup(sSecurityGroups))
    	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

        eWare.AddContent(blkContainer.Execute(rec)); 
        eWare.Mode = Edit;        
        Response.Write(eWare.GetPage('Person'));

    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM " + sEntityName + " WHERE " + sEntityIdName + "="+ Id;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else // view mode
    {
        fldDisplayedEffDateStyle.Hidden = true;

        var prpt_Name = "&nbsp;";
        if (!isEmpty( rec("prpe_PersonEventTypeId") ))
        {
            recTypes = eWare.FindRecord("PRPersonEventType", "prpt_PersonEventTypeId=" + rec("prpe_PersonEventTypeId"));
            if (!isEmpty(recTypes("prpt_Name")))
                prpt_Name = recTypes("prpt_Name");
        }
        sTypeField += "<DIV style={display:none;} ><DIV ID=\"div_prpe_personeventtypeid\" ><SPAN CLASS=VIEWBOX>" + prpt_Name + "</SPAN></DIV></DIV>";
        Response.Write(sTypeField);

        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

        if (iTrxStatus == TRX_STATUS_EDIT)
        {   
            //sDeleteUrl = changeKey(sURL, "em", "3");
            //blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));

            if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
        }


        blkEntry.GetEntry("prpe_EducationalInstitution").Hidden = true;
        blkEntry.GetEntry("prpe_EducationalDegree").Hidden = true;
        blkEntry.GetEntry("prpe_BankruptcyType").Hidden = true;
        blkEntry.GetEntry("prpe_USBankruptcyVoluntary").Hidden = true;
        blkEntry.GetEntry("prpe_USBankruptcyCourt").Hidden = true;
        blkEntry.GetEntry("prpe_CaseNumber").Hidden = true;
        blkEntry.GetEntry("prpe_DischargeType").Hidden = true;

        // Only display those fields relevant to the event type
        switch(rec("prpe_PersonEventTypeId")) {
            case "3":
                blkEntry.GetEntry("prpe_EducationalInstitution").Hidden = false;
                blkEntry.GetEntry("prpe_EducationalDegree").Hidden = false;
                break;

            case "4":
                blkEntry.GetEntry("prpe_BankruptcyType").Hidden = false;
                blkEntry.GetEntry("prpe_USBankruptcyCourt").Hidden = false;
                blkEntry.GetEntry("prpe_USBankruptcyVoluntary").Hidden = false;
                break;

            case "5":
                blkEntry.GetEntry("prpe_CaseNumber").Hidden = false;
                blkEntry.GetEntry("prpe_DischargeType").Hidden = false;
                break;
        }



            	
        var sText = ""
        sql = "SELECT text = dbo.ufn_GetPersonEventText(" + rec("prpe_PersonEventId") + ")";
        qryText = eWare.CreateQueryObj(sql);
        qryText.SelectSql();
        if (!qryText.eof)  {
            if (qryText("text") != null) {
                sText = qryText("text");
            }
        }

        blkPEText = eWare.GetBlock("Content");
        blkPEText.contents = createAccpacBlockHeader("PEText", "Person Event Text");
        blkPEText.contents += "<table class=CONTENT width=100% ><tr><td valign=top >";
        blkPEText.contents += "<span class=VIEWBOX >" + sText + "&nbsp;</span></td></tr></table>";
        blkPEText.contents += createAccpacBlockFooter();
        blkContainer.AddBlock(blkPEText);    
    
        eWare.AddContent(blkContainer.Execute(rec)); 
        Response.Write(eWare.GetPage('Person'));
    }

    if (eWare.Mode == Edit)
    {
%>
    <script type="text/javascript" >
        <%= sTypePublishTimeList %>
        function initBBSI() 
        {
            AppendRow("_Captprpe_date", "div_prpe_personeventtypeid", true);
            onClickEffectiveDateRadio();
            setDisplayedDateStyleIndex(<% =prpe_DisplayedEffectiveDateStyle %>);
            AppendCell("_Captprpe_date", "div_DispEffDate");
            initialize();
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
    </script>
<%
    }

%>
<!-- #include file ="../RedirectTopContent.asp" -->
