<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    var sSecurityGroups = "2,3,4,10";
    // This needs to be defined prior to the following include.
    // setting this variable to ARAgingBy makes only the date fields visible
    sScreenType = "ARAgingBy";
%>
<!-- #include file ="CompanyTradeActivityFilterInclude.asp" --> 

<%
    var isLumber = ((recCompany != null) ? (recCompany("comp_PRIndustryType") == "L") : false );
    var user_userid = eWare.getContextInfo("User", "User_UserId");

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var blkReportHeader = eWare.GetBlock('content');
    var sMsg = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You are currently viewing A/R Aging reports BY " + recCompany("comp_Name") + "</td></tr></table> ";
    blkReportHeader.contents = sMsg;
    blkContainer.AddBlock(blkReportHeader);

    
    if (eWare.Mode == View || eWare.Mode == Find)
    {
        //DumpFormValues();
        
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

        eWare.Mode = Edit;
        //blkFilter is created in PRCompanyTradeInclude.asp
        blkFilter.Width = "95%";
        blkContainer.AddBlock(blkFilter);    
        
    
        sWhere = "praa_CompanyId=" + comp_companyid;
        if (!isEmpty(sFormStartDate))
            sWhere += " AND praa_Date >= " + sDBStartDate;
        if (!isEmpty(sFormEndDate))
            sWhere += " AND praa_Date <= " + sDBEndDate;
            
        var amountFields;
        var pctFields;
        var totalField;
        var baseView;
        if (isLumber) {
            totalField = "praa_Total";
            amountFields = ["praa_TotalCurrent", "praa_Total1to30", "praa_Total31to60", "praa_Total61to90", "praa_Total91Plus" ];
            pctFields = ["praad_TotalAmountCurrentPercent" , "praad_TotalAmount1to30Percent", "praad_TotalAmount31to60Percent", "praad_TotalAmount61to90Percent", "praad_TotalAmount91PlusPercent" ];
            tableHeaders = [ "Current", "1-30", "31-60", "61-90", "91+"  ];
            baseView = "vPRARAgingDetailByLumber";
        } else {
            totalField = "praa_Total";
            amountFields = [ "praa_Total0to29", "praa_Total30to44", "praa_Total45to60", "praa_Total61Plus" ];
            pctFields = ["praad_TotalAmount0to29Percent", "praad_TotalAmount30to44Percent", "praad_TotalAmount45to60Percent", "praad_TotalAmount61PlusPercent" ];
            tableHeaders = [ "0-29", "30-44", "45-60", "61+" ];
            baseView = "vPRARAgingDetailByProduce";
        }

        sSQL = "SELECT DISTINCT praa_date, praa_RunDate, praa_ImportedByUserId, praa_ImportedDate, " 
                             + "praa_ARAgingId, praa_ARAgingDetailCount, " + totalField + ", "
                             + amountFields.join(", ") + ", " + pctFields.join(", ") + ", "
                             + "user_logon, user_firstname, user_lastname "
              + "FROM " + baseView + " "
                    + "LEFT OUTER JOIN users ON praa_ImportedByUserId = user_userid " 
             + "WHERE " + sWhere + " "
          + "ORDER BY praa_Date DESC, praa_ARAgingID DESC";

        //Response.Write("<p>" + sSQL + "</p>");

        recViewResults = eWare.CreateQueryObj(sSQL);
        recViewResults.SelectSQL();

        // create variable to quickly jump from $ to %
        sColHeaderStr = "$";
        // determine whether to show dollars or percents (dollars is the default)
        sColDisplay = "d";
        var colDisplay = new String(Request.QueryString("coldisplay"));
        if (!isEmpty(colDisplay))
        {
            if ( colDisplay == "p" ) 
            {
                sColDisplay = "p";
                sColHeaderStr = "%";
            }
        }
        
        blkARAging = eWare.GetBlock("content");
        sContent = createAccpacBlockHeader("ARAging", recViewResults.RecordCount+ " A/R Aging Files");
        sContent = sContent + "\n    <TABLE CLASS=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width='100%'>";
        
        sClass="ROW1";
        sContent = sContent + "\n        <TR>";
        sContent = sContent + "\n            <TD  CLASS=GRIDHEAD ALIGN=CENTER WIDTH=100>Date</TD>";
        sContent = sContent + "\n            <TD  CLASS=GRIDHEAD ALIGN=CENTER >Count</TD>";
        for (var i in tableHeaders) {
            sContent = sContent + "\n            <TD  CLASS=GRIDHEAD ALIGN=CENTER WIDTH=100>" + tableHeaders[i] + "<br/>(" + sColHeaderStr + ")</TD>";
        }
        sContent = sContent + "\n            <TD  CLASS=GRIDHEAD ALIGN=CENTER WIDTH=100>Total</TD>";
        sContent = sContent + "\n            <TD  CLASS=GRIDHEAD WIDTH=100 ALIGN=CENTER>Imported</TD>";
        sContent = sContent + "\n            <TD  CLASS=GRIDHEAD >Imported By</TD>";
        sContent = sContent + "\n        </TR>";
        
        sDetailUrl = eWare.URL("PRCompany/PRCompanyARAgingDetailListing.asp");

        if (recViewResults.RecordCount == 0)
        {
            sContent = sContent + "\n        <tr>";
            sContent = sContent + "\n            <td COLSPAN=9 ALIGN=CENTER CLASS=" + sClass + " >" +
                            "No A/R Aging Files were found." + "</td> ";
            sContent = sContent + "\n        </tr>";
        }
        else
        {
            while (!recViewResults.eof)
            {
                sContent = sContent + "\n        <tr>";
                sContent = sContent + "\n            <td align=center class=" + sClass + " >" 
                                    + "<a HREF=\""+ sDetailUrl+"&praa_ARAgingId="+ recViewResults("praa_ARAgingId") + "\">" 
                                    + getDateAsString(recViewResults("praa_Date")) + "</a></td> ";
                
                sTemp = recViewResults("praa_ARAgingDetailCount");
                sContent = sContent + "\n            <td align=\"center\" class=" + sClass + " >" +(isEmpty(sTemp)?"0":sTemp) + "</td> ";
                var displayFields = (sColDisplay == "d" ? amountFields : pctFields);
                for (var i in displayFields) {
                    sTemp = recViewResults(displayFields[i]);
                    sContent = sContent + "\n            <td align=RIGHT class=" + sClass + " >" +(isEmpty(sTemp)?"":formatDollar(sTemp)) + "</td> ";
                }

                sTemp = recViewResults(totalField);
                sContent = sContent + "\n            <td align=RIGHT class=" + sClass + " >" +(isEmpty(sTemp)?"":formatDollar(sTemp)) + "</td> ";

                sTemp = recViewResults("praa_ImportedDate");
                
                if (sTemp == "Sat Dec 30 00:00:00 CST 1899")
                    sTemp = "";
                sContent = sContent + "\n            <td align=\"center\" class=" + sClass + " >" +(isEmpty(String(sTemp))?"":getDateAsString(sTemp)) + "</td> ";
                
                
                sTemp = recViewResults("user_firstname");
                sTemp2 = recViewResults("user_lastname");
                sContent = sContent + "\n            <td align=LEFT class=" + sClass + " >" +(isEmpty(sTemp)?"":sTemp)+ " "  +(isEmpty(sTemp)?"":sTemp2)+ "</td> ";
                sContent = sContent + "\n        </tr>";
                recViewResults.NextRecord();
                if (sClass == "ROW1")
                    sClass="ROW2";
                else
                    sClass="ROW1";
            }
        }
        sContent = sContent + "\n</TABLE>";

        sContent = sContent + createAccpacBlockFooter();

        blkARAging.Contents=sContent;
        blkContainer.AddBlock(blkARAging);    

        // Show the buttons
        sContinueUrl = eWare.URL("PRCompany/PRCompanyTradeActivityListing.asp") + "&T=Company&Capt=Trade+Activity";
        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
        
        if (sColDisplay == "d")
        {
            sDollarPercentToggleUrl = changeKey(sURL, "coldisplay", "p");
            blkContainer.AddButton(eWare.Button("Display %", "recurr.gif", sDollarPercentToggleUrl));
        }
        else
        {
            sDollarPercentToggleUrl = changeKey(sURL, "coldisplay", "d");
            blkContainer.AddButton(eWare.Button("Display $", "recurr.gif", sDollarPercentToggleUrl));
        }

        if (isUserInGroup(sSecurityGroups ))
        {
            sManageTranslationsUrl = eWare.URL("PRCompany/PRCompanyARTranslationListing.asp") + "&prar_CompanyId=" + comp_companyid + "&T=Company&Capt=Trade+Activity";
            blkContainer.AddButton(eWare.Button("Manage All A/R Translations", "PrepareDatabase.gif", sManageTranslationsUrl));

            // notice we are reusing the Detail Listing for the New A/R Entry; without a praa_ARAgingid
            // value passed, the screen will only display the empty header information in Edit mode.
            sNewUrl = eWare.URL("PRCompany/PRCompanyARAging.asp") + "&comp_CompanyId=" + comp_companyid + "&T=Company&Capt=Trade+Activity";
            blkContainer.AddButton(eWare.Button("New A/R Aging Report", "new.gif", sNewUrl));
            
            //sImportUrl = eWare.URL("PRCompany/PRCompanyARAgingImport.aspx") + "&comp_CompanyId=" + comp_companyid + "&T=Company&Capt=Trade+Activity";
            //blkContainer.AddButton(eWare.Button("Import A/R Aging File", "new.gif", sImportUrl));

            var iframeSrc = eWare.URL("PRCompany/PRCompanyIFrame.asp") + "&T=Company&Capt=Trade+Activity";
            iframeSrc = removeKey(iframeSrc, "F");
            iframeSrc = removeKey(iframeSrc, "J");
            blkContainer.AddButton(eWare.Button("Import A/R Aging File", "new.gif", iframeSrc + "&FrameURL=" + Server.URLEncode("PRCompanyARAgingImport.aspx?comp_CompanyId=" + comp_companyid)));
        }
        
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
        
        Response.Write("<script type=\"text/javascript\">");
        Response.Write("    function initBBSI()"); 
        Response.Write("    {");
        Response.Write("        RemoveDropdownItemByName(\"DateTimeModesprtr_date\", \"Relative\");");
        //Response.Write("        document.all(\"prtr_datestart\").value = \"" + sFormStartDate + "\";");
        //Response.Write("        document.all(\"prtr_dateend\").value = \"" + sFormEndDate  + "\";");
        Response.Write("    }");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("</script>");
    }
%>
<!-- #include file="CompanyFooters.asp" -->
