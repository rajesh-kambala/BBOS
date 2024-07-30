<%
        blkFilter = eWare.GetBlock("PROpportunitySearchBox");
        blkFilter.Title = "Filter By";

        entry = blkFilter.GetEntry("oppo_Priority");
        entry.LookupFamily = "oppo_Priority";

        entry = blkFilter.GetEntry("oppo_Status");
        entry.LookupFamily = "oppo_PRStatus";
        entry.DefaultValue = "Open";
        
        entry = blkFilter.GetEntry("prst_StateID");
        entry.Caption = "Listing State";

        var sGridFilterWhereClause = "";
        
     
        if (eWare.Mode != 6)
        {  
            // get the form variables that may or may not exist
            var sFormStartDate = String(Request.Form.Item("oppo_opened_start"));
            if (sFormStartDate != null && !isEmpty(sFormStartDate)) {
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "oppo_Opened >='" + getDBDate(sFormStartDate) + "'";
            }
        
            var sFormEndDate = String(Request.Form.Item("oppo_opened_end"));
            if (sFormEndDate != null && !isEmpty(sFormEndDate)) {
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + "oppo_Opened <='" + getDBDate(sFormEndDate) + " 23:59:59'";
            }
        
            // get the form variables that may or may not exist
            var sUserIdToSelect = "";
            var oppo_assigneduserid = getValue(Request.Form.Item("oppo_assigneduserid"));
            if (!isEmpty(oppo_assigneduserid))
            {
                if (!isEmpty(oppo_assigneduserid))
                {
                    sGridFilterWhereClause = (sGridFilterWhereClause == ""?"":" AND ") + "oppo_AssignedUserId =" + oppo_assigneduserid;
                    sUserIdToSelect = oppo_assigneduserid;
                }
            }

            var oppo_primarycompanyid = getValue(Request.Form.Item("oppo_primarycompanyid"));
            if (!isEmpty(oppo_primarycompanyid))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_primarycompanyid = " + oppo_primarycompanyid;

            var oppo_status = getValue(Request.Form.Item("oppo_status"));
            if (szFirstTime != "N") 
                oppo_status = "Open";

            if (!isEmpty(oppo_status))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_status = '" + oppo_status + "'";


            var oppo_stage = getValue(Request.Form.Item("oppostage"));
            if (!isEmpty(oppo_stage))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_stage = '" + oppo_stage + "'";

            var comp_prlistingcityid = getValue(Request.Form.Item("comp_prlistingcityid"));
            if (!isEmpty(comp_prlistingcityid))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"comp_PRListingCityID = " + comp_prlistingcityid;

            var listingstateid = getValue(Request.Form.Item("prst_stateid"));
            if (!isEmpty(listingstateid))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"ListingStateID = " + listingstateid;

            var oppo_priority = getValue(Request.Form.Item("oppo_priority"));
            if (!isEmpty(oppo_priority))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_priority = '" + oppo_priority + "'";

            // This is actually the cateogry
            var oppo_type = getValue(Request.Form.Item("oppo_type"));
            if (!isEmpty(oppo_type)) {
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_type = '" + oppo_type + "'";
            }

            var oppoIndustryType = new String(getValue(Request.Form.Item("oppoindustrytype")));
            if (!isEmpty(oppoIndustryType)) {

                oppoIndustryType = "'" + oppoIndustryType.replace(/, /g, "','") + "'";
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"comp_PRIndustryType IN (" + oppoIndustryType + ")";

            }

            var oppo_prpipeline = getValue(Request.Form.Item("oppo_prpipeline"));
            if (!isEmpty(oppo_prpipeline)) {
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_prpipeline = '" + oppo_prpipeline + "'";
            }

            var oppocertainty = getValue(Request.Form.Item("oppo_prcertainty"));
            if (!isEmpty(oppocertainty)) {
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"oppo_prcertainty = '" + oppocertainty + "'";
            }


            // now create the formload section to reload all the values with the submitted values
            sFormLoadCommands = "";
            sFormLoadCommands += "RemoveDropdownItemByName('oppo_assigneduserid', '--None--');\n";
            sFormLoadCommands += "RemoveDropdownItemByName('oppo_status', '--None--');\n";
            sFormLoadCommands += "RemoveDropdownItemByName('oppostage', '--None--');\n";
            sFormLoadCommands += "RemoveDropdownItemByName('oppo_type', '--None--');\n";
            sFormLoadCommands += "RemoveDropdownItemByName('oppo_priority', '--None--');\n";
            sFormLoadCommands += "RemoveDropdownItemByName('comp_prindustrytype', '--None--');\n";
            sFormLoadCommands += "RemoveDropdownItemByName('oppo_prpipeline', '--None--');\n";
            sFormLoadCommands += "RemoveDropdownItemByName('oppo_prcertainty', '--None--');\n";            
            sFormLoadCommands += "RemoveDropdownItemByName('DateTimeModesoppo_opened', 'Relative');\n";

            sFormLoadCommands += "SelectDropdownItemByValue('oppo_assigneduserid', '" + oppo_assigneduserid + "');\n";
            sFormLoadCommands += "SelectDropdownItemByValue('oppostage', '" + oppo_stage + "');\n";
            sFormLoadCommands += "SelectDropdownItemByValue('oppo_type', '" + oppo_type + "');\n";
            sFormLoadCommands += "SelectDropdownItemByValue('oppo_priority', '" + oppo_priority + "');\n";
            sFormLoadCommands += "SelectDropdownItemByValue('oppo_status', '" + oppo_status + "');\n";
            sFormLoadCommands += "SelectDropdownItemByValue('oppo_prpipeline', '" + oppo_prpipeline + "');\n";

        }        

        var sLoadPipelineAd = BuildAddDropdownItem("oppo_PRPipelineAd");
        var sLoadPipelineM = BuildAddDropdownItem("oppo_PRPipelineM");
        var sLoadPipelineUp = BuildAddDropdownItem("oppo_PRPipelineU");

function BuildAddDropdownItem(sCaptFamily) {
    sSQL = "SELECT RTRIM(capt_code) AS capt_code, capt_us FROM custom_captions WITH (NOLOCK) WHERE capt_family = '" + sCaptFamily + "' ORDER BY capt_order";
    recPRPipeline = eWare.CreateQueryObj(sSQL);
    recPRPipeline.SelectSQL();
        
    var sBuffer = "";
        
    while (!recPRPipeline.EOF){        
        sBuffer += "AddDropdownItem('oppo_prpipeline', '" + recPRPipeline("capt_us") + "', '" + recPRPipeline("capt_code") + "')\n";                
        recPRPipeline.NextRecord();
    }
            
    return sBuffer;
}
%>

