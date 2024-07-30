<%
    var sSourcingFormLoadCommands = "";
    var sSellingFormLoadCommands = "";
    var sTrkFormLoadCommands = "";

    var recSrcDoms = null;
    var sSrcDoms = ",";
    var recSrcInts = null;
    var sSrcInts = ",";
    var recSellDoms = null;
    var sSellDoms = ",";
    var recSellInts = null;
    var sSellInts = ",";
    var sTrkDoms =",";
    var sTrkInts =",";


    if ( (bShowSourcing || bShowSelling || bShowTrkRegions) && (eWare.Mode == View || eWare.Mode == Edit) )
    {
        var sRowClass = "ROW1";
        

        var sSelect_Core = "SELECT prcd_RegionId, prd2_Name FROM PRCompanyRegion " + 
                "INNER JOIN PRRegion ON prcd_RegionId = prd2_RegionId " +
                "WHERE prcd_CompanyId="+comp_companyid + " and prcd_Type=";

        var sOrderBy = " ORDER BY prd2_Name";

        var sSelect_SrcDom = sSelect_Core + "'SrcD'" + sOrderBy;
        var sSelect_SrcInt = sSelect_Core + "'SrcI'" + sOrderBy;
        var sSelect_SellDom = sSelect_Core + "'SellD'" + sOrderBy;
        var sSelect_SellInt = sSelect_Core + "'SellI'" + sOrderBy;

        var sSelect_TrkDom = sSelect_Core + "'TrkD'" + sOrderBy;
        var sSelect_TrkInt = sSelect_Core + "'TrkI'" + sOrderBy;

                    
        // Build the table headers
        var sSrcDomRegTable = "<table width=\"100%\" id=\"_SourcingDomesticRegionListing\"" + 
                " class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff> "+
                "<thead><tr><td class=\"GRIDHEAD\" width=\"100%\">Domestic Regions &nbsp;</td></tr></thead><tbody>";

        var sSellDomRegTable = "<table width=\"100%\" id=\"_SellingDomesticRegionListing\"" + 
                " class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff> "+
                "<thead><tr><td class=\"GRIDHEAD\" WIDTH=\"100%\">Domestic Regions &nbsp;</td></tr></thead><tbody>";

        var sSrcIntRegTable = "<table width=\"100%\" id=\"_SourcingInternationalRegionListing\"" + 
                " class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff> "+
                "<thead><tr><td class=\"GRIDHEAD\" WIDTH=\"100%\">International Regions</td></tr></thead><tbody>";

        var sSellIntRegTable = "<table width=\"100%\" id=\"_SellingInternationalRegionListing\"" + 
                " class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff> "+
                "<thead><tr><td class=\"GRIDHEAD\" WIDTH=\"100%\">International Regions</td></tr></thead><tbody>";

        var sTrkDomRegTable = "<table width=\"100%\" id=\"_TrkDomesticRegionListing\"" + 
                " class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff> "+
                "<thead><tr><td class=\"GRIDHEAD\" WIDTH=\"100%\">Domestic Regions</td></tr></thead><tbody>";

        var sTrkIntRegTable = "<table width=\"100%\" id=\"_TrkInternationalRegionListing\"" + 
                " class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff> "+
                "<thead><tr><td class=\"GRIDHEAD\" WIDTH=\"100%\">International Regions</td></tr></thead><tbody>";




        sTableRowNone = "<tr class=\"ROW1\"><td align=\"middle\">-- None --</td></tr>";
        // closes any of the above tables
        sTableFooter = "</tbody></table>";

        if (bShowSourcing)
        {

            recSrcDoms = eWare.CreateQueryObj(sSelect_SrcDom);
            recSrcDoms.SelectSQL();
            if (recSrcDoms.RecordCount == 0 && eWare.Mode == View)
                sSrcDomRegTable += sTableRowNone;
            while (!recSrcDoms.eof)
            {
                if (eWare.Mode == View)
                {
                    // build the table rows for the existing records; we'll add teh rows to the table below
                    prcd_RegionId = recSrcDoms("prcd_RegionId");
                    prd2_Name = recSrcDoms("prd2_Name");
                    sSrcDomRegTable += "<tr id=\"_SDRRow_" + prcd_RegionId + "\"><td class=\"" + sRowClass + "\">";
                    sSrcDomRegTable += "<span id=\"_SDRDisplay_" + prcd_RegionId + "\" class=\"" + sRowClass + "\">" + prd2_Name + "</span>";
                    sSrcDomRegTable += "</td></tr>";                             
                    if 	(sRowClass == "ROW1") sRowClass = "ROW2";
                    else sRowClass = "ROW1";
                }
                // save this value for selecting checkboxes later
                sSrcDoms += recSrcDoms("prcd_RegionId")+ ",";
                recSrcDoms.NextRecord();
            }

            recSrcInts = eWare.CreateQueryObj(sSelect_SrcInt);
            recSrcInts.SelectSQL();
            if (recSrcInts.RecordCount == 0 && eWare.Mode == View)
                sSrcIntRegTable += sTableRowNone;
            while (!recSrcInts.eof)
            {
                if (eWare.Mode == View)
                {
                    // build the table rows for the existing records; we'll add teh rows to the table below
                    prcd_RegionId = recSrcInts("prcd_RegionId");
                    prd2_Name = recSrcInts("prd2_Name");
                    sSrcIntRegTable += "<tr id=\"_SIRRow_" + prcd_RegionId + "\"><td class=\"" + sRowClass + "\">";
                    sSrcIntRegTable += "<span id=\"_SIRDisplay_" + prcd_RegionId + "\" class=\"" + sRowClass + "\">" + prd2_Name + "</span>";
                    sSrcIntRegTable += "</td></tr>";                             
                    if 	(sRowClass == "ROW1") sRowClass = "ROW2";
                    else sRowClass = "ROW1";
                }
                // save this value for selecting checkboxes later
                sSrcInts += recSrcInts("prcd_RegionId")+ ",";
                recSrcInts.NextRecord();
            }
        }
        
        if (bShowSelling)
        {

            recSellDoms = eWare.CreateQueryObj(sSelect_SellDom);
            recSellDoms.SelectSQL();
            if (recSellDoms.RecordCount == 0 && eWare.Mode == View)
                sSellDomRegTable += sTableRowNone;
            while (!recSellDoms.eof)
            {
                if (eWare.Mode == View)
                {
                    // build the table rows for the existing records; we'll add teh rows to the table below
                    prcd_RegionId = recSellDoms("prcd_RegionId");
                    prd2_Name = recSellDoms("prd2_Name");
                    sSellDomRegTable += "<tr id=\"_LDRRow_" + prcd_RegionId + "\"><td class=\"" + sRowClass + "\">";
                    sSellDomRegTable += "<span id=\"_LDRDisplay_" + prcd_RegionId + "\" class=\"" + sRowClass + "\">" + prd2_Name + "</span>";
                    sSellDomRegTable += "</td></tr>";                             
                    if 	(sRowClass == "ROW1") sRowClass = "ROW2";
                    else sRowClass = "ROW1";
                }
                // save this value for selecting checkboxes later
                sSellDoms += recSellDoms("prcd_RegionId")+ ",";
                recSellDoms.NextRecord();
            }

            recSellInts = eWare.CreateQueryObj(sSelect_SellInt);
            recSellInts.SelectSQL();
            if (recSellInts.RecordCount == 0 && eWare.Mode == View)
                sSellIntRegTable += sTableRowNone;
            while (!recSellInts.eof)
            {
                if (eWare.Mode == View)
                {
                    // build the table rows for the existing records; we'll add the rows to the table below
                    prcd_RegionId = recSellInts("prcd_RegionId");
                    prd2_Name = recSellInts("prd2_Name");
                    sSellIntRegTable += "<tr id=\"_LIRRow_" + prcd_RegionId + "\"><td class=\"" + sRowClass + "\">";
                    sSellIntRegTable += "<span id=\"_LIRDisplay_" + prcd_RegionId + "\" class=\"" + sRowClass + "\">" + prd2_Name + "</span>";
                    sSellIntRegTable += "</td></tr>";                             
                    if 	(sRowClass == "ROW1") sRowClass = "ROW2";
                    else sRowClass = "ROW1";
                }
                // save this value for selecting checkboxes later
                sSellInts += recSellInts("prcd_RegionId")+ ",";
                recSellInts.NextRecord();
            }
        }
        

        if (bShowTrkRegions)
        {

            recTrkDoms = eWare.CreateQueryObj(sSelect_TrkDom);
            recTrkDoms.SelectSQL();
            if (recTrkDoms.RecordCount == 0 && eWare.Mode == View)
                sTrkDomRegTable += sTableRowNone;
            while (!recTrkDoms.eof)
            {
                if (eWare.Mode == View)
                {
                    // build the table rows for the existing records; we'll add teh rows to the table below
                    prcd_RegionId = recTrkDoms("prcd_RegionId");
                    prd2_Name = recTrkDoms("prd2_Name");
                    sTrkDomRegTable += "<tr id=\"_SDRRow_" + prcd_RegionId + "\"><td class=\"" + sRowClass + "\">";
                    sTrkDomRegTable += "<span id=\"_SDRDisplay_" + prcd_RegionId + "\" class=\"" + sRowClass + "\">" + prd2_Name + "</span>";
                    sTrkDomRegTable += "</td></tr>";                             
                    if 	(sRowClass == "ROW1") sRowClass = "ROW2";
                    else sRowClass = "ROW1";
                }
                // save this value for selecting checkboxes later
                sTrkDoms += recTrkDoms("prcd_RegionId")+ ",";
                recTrkDoms.NextRecord();
            }

            recTrkInts = eWare.CreateQueryObj(sSelect_TrkInt);
            recTrkInts.SelectSQL();
            if (recTrkInts.RecordCount == 0 && eWare.Mode == View)
                sTrkIntRegTable += sTableRowNone;
            while (!recTrkInts.eof)
            {
                if (eWare.Mode == View)
                {
                    // build the table rows for the existing records; we'll add teh rows to the table below
                    prcd_RegionId = recTrkInts("prcd_RegionId");
                    prd2_Name = recTrkInts("prd2_Name");
                    sTrkIntRegTable += "<tr id=\"_SIRRow_" + prcd_RegionId + "\"><td class=\"" + sRowClass + "\">";
                    sTrkIntRegTable += "<span id=\"_SIRDisplay_" + prcd_RegionId + "\" class=\"" + sRowClass + "\">" + prd2_Name + "</span>";
                    sSrcIntRegTable += "</td></tr>";                             
                    if 	(sRowClass == "ROW1") sRowClass = "ROW2";
                    else sRowClass = "ROW1";
                }
                // save this value for selecting checkboxes later
                sTrkInts += recTrkInts("prcd_RegionId")+ ",";
                recTrkInts.NextRecord();
            }
        }
        


        if (eWare.Mode == Edit) 
        {
            recMain = eWare.CreateQueryObj("SELECT prd2_RegionId, prd2_Name, prd2_Level, prd2_ParentId FROM dbo.ufn_GetRegions('D') ORDER BY seq");
            recMain.SelectSQL();

            var iCurrLevel = 1;
            sRowClass = "ROW1";
            sLastParentRegionId = "";
            sLastRegionId = "";
            arrParentIds = new Array();
            while (!recMain.eof) 
            {
                prd2_RegionId = recMain("prd2_RegionId");
                iLevel = recMain("prd2_Level");
                prd2_Name = recMain("prd2_Name");
                prd2_ParentId = recMain("prd2_ParentId");
                
                if (arrParentIds.length == 0 || 
                    prd2_ParentId != arrParentIds[arrParentIds.length-1])
                {
                    if (prd2_ParentId == sLastRegionId)
                        arrParentIds[arrParentIds.length] = prd2_ParentId;
                    else
                    {
                        while (arrParentIds.length > 0 && 
                               arrParentIds[arrParentIds.length-1] != prd2_ParentId)
                            arrParentIds.pop();   
                    }
                }
                iCurrLevel = arrParentIds.length;
                
                sSpaces = "";
                for (i=0; i < iCurrLevel; i++) 
                {
                    sSpaces = sSpaces + "&nbsp;&nbsp;&nbsp;&nbsp;";
                }
                // tags for the table rows and cells
                sLevelTag = " Level=" + iLevel;
                sClassTag = " class=\"" + sRowClass + "\""; 

                if (bShowSourcing)
                {
                    // Build Sourcing
                    // set the selected checkbox
                    sChecked = "";
                    if (sSrcDoms.indexOf(","+prd2_RegionId+",") > -1)
                        sChecked = " CHECKED ";
                    sSrcSelectTag  = "<input type=\"checkbox\" class=\"smallcheck\"" +
                                  " id=\"_SDRSelect_" + prd2_RegionId +  
                                  "\" onclick=\"onRegionSelectClick()\" " + 
                                  sChecked + ">";
                    // _SDR = _Src-DomReg                                  
                    sSrcDomRegTable += "<tr id=_SDRRow_" + prd2_RegionId + sLevelTag + ">";
                    sSrcDomRegTable += "<td id=_SDRTD3_" + prd2_RegionId + sClassTag+ ">" + sSpaces + sSrcSelectTag +"&nbsp;" ;
                    sSrcDomRegTable += "<span id=_SDRDisplay_" + prd2_RegionId + sClassTag + ">" + prd2_Name + "</span>";
                    sSrcDomRegTable += "</td></tr>";                             
                }
                
                if (bShowSelling)
                {
                    // Build Selling
                    // set the selected checkbox
                    sChecked = "";
                    if (sSellDoms.indexOf(","+prd2_RegionId+",") > -1)
                        sChecked = " CHECKED ";
                    sSellSelectTag  = "<input type=\"checkbox\" class=\"smallcheck\"" +
                                  " id=_LDRSelect_" + prd2_RegionId +  
                                  " onclick=\"onRegionSelectClick()\" " + 
                                  sChecked + ">";
                    sSellDomRegTable += "<tr id=_LDRRow_" + prd2_RegionId + sLevelTag + ">";
                    sSellDomRegTable += "<td id=_LDRTD3_" + prd2_RegionId + sClassTag+ ">" + sSpaces + sSellSelectTag +"&nbsp;" ;
                    sSellDomRegTable += "<span id=_LDRDisplay_" + prd2_RegionId + sClassTag + ">" + prd2_Name + "</span>";
                    sSellDomRegTable += "</td></tr>";                             
                }

                if (bShowTrkRegions)
                {
                    // Build Selling
                    // set the selected checkbox
                    sChecked = "";
                    if (sTrkDoms.indexOf(","+prd2_RegionId+",") > -1)
                        sChecked = " CHECKED ";
                    sTrkSelectTag  = "<input type=\"checkbox\"class=\"smallcheck\"" +
                                  " id=_TDRSelect_" + prd2_RegionId +  
                                  " onclick=\"onRegionSelectClick()\" " + 
                                  sChecked + ">";
                    sTrkDomRegTable += "<tr id=_TDRRow_" + prd2_RegionId + sLevelTag + ">";
                    sTrkDomRegTable += "<td id=_TDRTD3_" + prd2_RegionId + sClassTag+ ">" + sSpaces + sTrkSelectTag +"&nbsp;" ;
                    sTrkDomRegTable += "<span id=_TDRDisplay_" + prd2_RegionId + sClassTag + ">" + prd2_Name + "</span>";
                    sTrkDomRegTable += "</td></tr>";                             
                }

                if 	(sRowClass == "ROW1") sRowClass = "ROW2";
                else sRowClass = "ROW1";
                
                sLastRegionId = prd2_RegionId;
                recMain.NextRecord();
            }

            // Build the International Region tables
            sSQL = "SELECT ";
            sSQL = sSQL + "prd2_RegionId, prd2_Name,  prd2_Level, prd2_ParentId ";
            sSQL = sSQL + "FROM PRRegion WHERE prd2_Type = 'I' ";
            sSQL = sSQL + "ORDER BY prd2_Name";

            recMain = eWare.CreateQueryObj(sSQL);
            recMain.SelectSQL();

            var iCurrLevel = 1;
            sRowClass = "ROW1";
            sLastParentRegionId = "";
            sLastRegionId = "";
            arrParentIds = new Array();
            while (!recMain.eof) 
            {
                prd2_RegionId = recMain("prd2_RegionId");
                iLevel = recMain("prd2_Level");
                prd2_Name = recMain("prd2_Name");
                prd2_ParentId = recMain("prd2_ParentId");
                
                if (arrParentIds.length == 0 || 
                    prd2_ParentId != arrParentIds[arrParentIds.length-1])
                {
                    if (prd2_ParentId == sLastRegionId)
                        arrParentIds[arrParentIds.length] = prd2_ParentId;
                    else
                    {
                        while (arrParentIds.length > 0 && 
                               arrParentIds[arrParentIds.length-1] != prd2_ParentId)
                            arrParentIds.pop();   
                    }
                }
                iCurrLevel = arrParentIds.length;
                
                sSpaces = "";
                for (i=0; i < iCurrLevel; i++) 
                {
                    sSpaces = sSpaces + "&nbsp;&nbsp;&nbsp;&nbsp;";
                }
                // tags for the table rows and cells
                sLevelTag = " Level=" + iLevel;
                sClassTag = " CLASS=\"" + sRowClass + "\""; 

                // Build Sourcing
                sChecked = "";
                if (sSrcInts.indexOf(","+prd2_RegionId+",") > -1)
                    sChecked = " CHECKED ";
                sSrcSelectTag  = "<INPUT TYPE=CHECKBOX class=\"smallcheck\"" +
                              " ID=_SIRSelect_" + prd2_RegionId +  
                              " ONCLICK=\"onRegionSelectClick()\" " + 
                              sChecked +">";
                sSrcIntRegTable += "<TR ID=_SIRRow_" + prd2_RegionId + sLevelTag + ">";
                sSrcIntRegTable += "<TD ID=_SIRTD3_" + prd2_RegionId + sClassTag+ ">" + sSpaces + sSrcSelectTag +"&nbsp;" ;
                sSrcIntRegTable += "<span ID=_SIRDisplay_" + prd2_RegionId + sClassTag + ">" + prd2_Name + "</span>";
                sSrcIntRegTable += "</TD></TR>";                             


                // Build Selling
                sChecked = "";
                if (sSellInts.indexOf(","+prd2_RegionId+",") > -1)
                    sChecked = " CHECKED ";
                sSellSelectTag  = "<INPUT TYPE=CHECKBOX class=\"smallcheck\"" +
                              " ID=_LIRSelect_" + prd2_RegionId +  
                              " ONCLICK=\"onRegionSelectClick()\" " + 
                              sChecked+">";
                
                sSellIntRegTable += "<TR ID=_LIRRow_" + prd2_RegionId + sLevelTag + ">";
                sSellIntRegTable += "<TD ID=_LIRTD3_" + prd2_RegionId + sClassTag+ ">" + sSpaces + sSellSelectTag +"&nbsp;" ;
                sSellIntRegTable += "<span ID=_LIRDisplay_" + prd2_RegionId + sClassTag + ">" + prd2_Name + "</span>";
                sSellIntRegTable += "</TD></TR>";                             

                if (bShowTrkRegions)
                {
                    // Build Trucking
                    sChecked = "";
                    if (sTrkInts.indexOf(","+prd2_RegionId+",") > -1)
                        sChecked = " CHECKED ";
                    sTrkSelectTag  = "<INPUT TYPE=CHECKBOX class=\"smallcheck\"" +
                                  " ID=_TIRSelect_" + prd2_RegionId +  
                                  " ONCLICK=\"onRegionSelectClick()\" " + 
                                  sChecked+">";
                
                    sTrkIntRegTable += "<TR ID=_TIRRow_" + prd2_RegionId + sLevelTag + ">";
                    sTrkIntRegTable += "<TD ID=_TIRTD3_" + prd2_RegionId + sClassTag+ ">" + sSpaces + sTrkSelectTag +"&nbsp;" ;
                    sTrkIntRegTable += "<span ID=_TIRDisplay_" + prd2_RegionId + sClassTag + ">" + prd2_Name + "</span>";
                    sTrkIntRegTable += "</TD></TR>";
                }


                if 	(sRowClass == "ROW1")
                    sRowClass = "ROW2";
                else
                    sRowClass = "ROW1";

                sLastRegionId = prd2_RegionId;
                recMain.NextRecord();
            }
        } // end if (eWare.Mode == Edit)
        
        sSrcDomRegTable += sTableFooter;
        sSellDomRegTable += sTableFooter;

        sSrcIntRegTable += sTableFooter;
        sSellIntRegTable += sTableFooter;

        if (bShowTrkRegions)
        {
            sTrkIntRegTable += sTableFooter;
            sTrkDomRegTable += sTableFooter;
        }


        if (bShowSourcing)
        {             
%>
            <table style="display:none"><tr id="_tr_SourcingRegions">
                <td valign="top" colspan="2" > 
                    <input id="HIDDEN_SDR" name="HIDDEN_SDR" type="hidden" value="<%= sSrcDoms %>"/>
                    <table style="border:1px solid gray;" cellspacing="0" cellpadding="1" ><tr>
                    <td> <%= sSrcDomRegTable %> </td>
                    </tr></table>
                </td>
                <td valign="top" colspan="2" > 
                    <input id="HIDDEN_SIR" name="HIDDEN_SIR" type="hidden" value="<%= sSrcInts %>"/>
                    <table  style="border:1px solid gray;" cellspacing="0" cellpadding="1" ><tr>
                    <td> <%= sSrcIntRegTable %> </td>
                    </tr></table>
                </td>
            </tr></table>
<%
            sSourcingFormLoadCommands = "AppendRow('_Captprcp_srctakephysicalpossessionpct','_tr_SourcingRegions');\n ";
            //sSourcingFormLoadCommands = "AppendRow('_Captprcp_salvagedistressedproduce','_tr_SourcingRegions');\n ";

            if (eWare.Mode == Edit)
            {
                sSourcingFormLoadCommands += 
                    "$(document).ready(function($) { $('#_SourcingDomesticRegionListing').tableScroll({height:170}); $('#_SourcingInternationalRegionListing').tableScroll({height:170}); });";
            }
        }


        if (bShowSelling)
        {
%>

            <table style="display:none"><tr id="_tr_SellingRegions">
                <td valign="top" colspan="2" > 
                    <input id="HIDDEN_LDR" name="HIDDEN_LDR" type="hidden" value="<%= sSellDoms %>" />
                    <table style="border:1px solid gray;" cellspacing="0" cellpadding="1" ><tr>
                    <td> <%= sSellDomRegTable %> </td>
                    </tr></table>
                </td>
                <td valign="top" colspan="2" > 
                    <input id="HIDDEN_LIR" name="HIDDEN_LIR" type="hidden" value="<%= sSellInts %>" />
                    <table style="border:1px solid gray;" cellspacing="0" cellpadding="1" ><tr>
                    <td> <%= sSellIntRegTable %> </td>
                    </tr></table>
                </td>
            </tr></table>
<%        
            if (recCompany.comp_PRIndustryType ==  "L") {
                sSellingFormLoadCommands = "AppendRow('_Captprcp_sellsecmanpct','_tr_SellingRegions');\n " ;
            } else {
                //sSellingFormLoadCommands = "AppendRow('_Captprcp_selldomesticbuyerspct','_tr_SellingRegions');\n " 
                sSellingFormLoadCommands = "AppendRow('_Captprcp_growsownproducepct','_tr_SellingRegions');\n " 
            }
            
            
            if (eWare.Mode == Edit)
            {
                sSellingFormLoadCommands += 
                    "$(document).ready(function($) { $('#_SellingDomesticRegionListing').tableScroll({height:170}); $('#_SellingInternationalRegionListing').tableScroll({height:170}); });";
            }
        }


        if (bShowTrkRegions)
        {
%>
            <table style="display:none;width:100%;"><tr id="_tr_TrkRegions">
                <td valign="top" colspan="2" > 
                    <input id="HIDDEN_TDR" name="HIDDEN_TDR" type="hidden" value="<%= sTrkDoms %>" />
                    <table style="border:1px solid gray;" cellspacing="0" cellpadding="1" ><tr>
                    <td> <%= sTrkDomRegTable %> </td>
                    </tr></table>
                </td>
                <td valign="top" colspan="2" > 
                    <input id="HIDDEN_TIR" name="HIDDEN_TIR" type="hidden" value="<%= sTrkInts %>" />
                    <table style="border:1px solid gray;" cellspacing="0" cellpadding="1" ><tr>
                    <td> <%= sTrkIntRegTable %> </td>
                    </tr></table>
                </td>
            </tr></table>

            <TABLE style={display:none;} ID=tblNonVisible ><TR class=InfoContent ID="tr_GeographicAreasServed"><TD COLSPAN=10 ALIGN=LEFT >Geographic Areas Served</TD></TR></TABLE>


<%        

            if (eWare.Mode == Edit) 
            {
                sTrkFormLoadCommands = "AppendRow('prcp_volume','_tr_TrkRegions');\n " ;
                sTrkFormLoadCommands += "AppendRow('prcp_volume','tr_GeographicAreasServed');\n " ;

            } else {
                sTrkFormLoadCommands = "AppendRow('_Captprcp_volume','_tr_TrkRegions');\n " ;
                sTrkFormLoadCommands += "AppendRow('_Captprcp_volume','tr_GeographicAreasServed');\n " ;
                //sTrkFormLoadCommands = "InsertDivider('Geographic Areas Served', '_tr_TrkRegions');\n";
            }
            
            if (eWare.Mode == Edit)
            {
                sTrkFormLoadCommands += 
                    "$(document).ready(function($) { $('#_TrkDomesticRegionListing').tableScroll({height:170}); $('#_TrkInternationalRegionListing').tableScroll({height:170}); });";
            }
        }
    }
%>    




