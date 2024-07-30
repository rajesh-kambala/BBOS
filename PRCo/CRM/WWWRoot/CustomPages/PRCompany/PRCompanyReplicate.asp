<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%

    // get the user id
    user_userid = eWare.getContextInfo("User", "User_UserId");
    
    var sStoredProcAction = "";
    var RepType = getIdValue("RepType");
    var RepId = getIdValue("RepId");

    switch(RepType) {
        case "1": 
            sSummaryAction = eWare.Url("PRCompany/PRCompanyPhone.asp")+ "&phon_PhoneId="+ RepId + "&T=Company&Capt=Contact+Info";
            sStoredProcAction = "ReplicatePhone";
            sRepTable = "Phone";
            sRepTablePrefix = "phon";
            break;
        case "2": 
            sSummaryAction = eWare.Url("PRCompany/PRCompanyAddress.asp")+ "&addr_AddressId="+ RepId + "&T=Company&Capt=Contact+Info";
            sStoredProcAction = "ReplicateAddress";
            sRepTable = "Address";
            sRepTablePrefix = "adli";
            break;
        case "3": 
            sSummaryAction = eWare.Url("PRCompany/PRCompanyContactInfoListing.asp") + "&T=Company&Capt=Contact+Info";
            sStoredProcAction = "ReplicateEmailWeb";
            break;
        case "4": 
            sSummaryAction = eWare.Url("PRCompany/PRCompanyCommodityListing.asp") + "&T=Company&Capt=Profile";
            sStoredProcAction = "ReplicateCommodity";
            break;
        case "5":
            sSummaryAction = eWare.Url("PRCompany/PRCompanyClassificationListing.asp") + "&T=Company&Capt=Profile";
            sStoredProcAction = "ReplicateClassification";
            break;
        case "6":
            sSummaryAction = eWare.Url("PRCompany/PRProductListing.asp") + "&T=Company&Capt=Profile";
            sStoredProcAction = "ReplicateProductProvided";
            break;
        case "7":
            sSummaryAction = eWare.Url("PRCompany/PRServiceListing.asp") + "&T=Company&Capt=Profile";
            sStoredProcAction = "ReplicateServiceProvided";
            break;
        case "8":
            sSummaryAction = eWare.Url("PRCompany/PRSpecieListing.asp") + "&T=Company&Capt=Profile";
            sStoredProcAction = "ReplicateSpecie";
            break;
        case "9":
            sSummaryAction = eWare.Url("PRCompany/PRCompanyDLView.asp") + "&T=Company&Capt=Profile";
            sStoredProcAction = "ReplicateCompanyBrand";
            break;
        default:
            sSummaryAction = eWare.Url("PRCompany/PRCompanySummary.asp");
    }
    
    if (eWare.Mode == Save)
    {
        if (sStoredProcAction != "")
        {
            // get a list of the selected checkboxes and call the appropriate stored proc
            sReplicateToIds = new String(Request.Form.Item("hdn_SelectedCompanies"));
            if (isEmpty(sReplicateToIds))
            {
                Response.Write("No companies selected.");
            }
            else
            {
                sSaveLink = eWare.URL("InvokeStoredProc.aspx");
                sSaveLink = removeKey(sSaveLink, "J");
                sSaveLink = removeKey(sSaveLink, "F");
                sSaveLink +=
                        "&customact="+ sStoredProcAction + "&comp_companyid="+comp_companyid +
                        "&SourceId="+ RepId + 
                        "&UserId="+ user_userid + 
                        "&ReplicateToIds="+ sReplicateToIds + 
                        "&RedirectURL="+ Server.UrlEncode(sSummaryAction);
                        
//Response.Write("<p>" + sSaveLink + "</p>");                        
                Response.Redirect(sSaveLink);
            }
            eWare.Mode = View;
                
        }
    }
    if (eWare.Mode == View)
    {
        Response.Write("<script type=text/javascript src=\"PRCompanyreplicateInclude.js\"></script>");
        eWare.Mode = Edit;
        grdReplication = eWare.GetBlock("content");

        sContent = "<input type=\"HIDDEN\" id=\"hdn_SelectedCompanies\" name=\"hdn_SelectedCompanies\" />";
        sContent += createAccpacBlockHeader("PRReplication", "Related Company Listing");

        //determine the headquarter id
        sHQId = comp_companyid;
        if (recCompany("comp_PRType") != "H")
            sHQId = recCompany("comp_PRHQId");
        
        sSQL = "SELECT prtx_CreatedBy, RTRIM(user_FirstName) + ' ' + RTrim(user_LastName) AS prtx_UserName, comp_CompanyId, capt_us, comp_Name " +
                "FROM Company WITH (NOLOCK) " + 
                     "LEFT OUTER JOIN Custom_Captions WITH (NOLOCK) ON comp_PRType = capt_code and capt_family = 'comp_PRType' "+
                     "LEFT OUTER JOIN PRTransaction WITH (NOLOCK) ON prtx_companyid = comp_companyid and prtx_Status = 'O' "+
                     "LEFT OUTER JOIN Users WITH (NOLOCK) ON prtx_CreatedBy = user_userid " +
               "WHERE comp_companyid=" + sHQId + " or comp_PRHQId=" + sHQId + 
           " ORDER BY comp_PRType DESC, comp_CompanyId ";
        recCompanies = eWare.CreateQueryObj(sSQL);
        recCompanies.SelectSQL();
        
        sContent = sContent + "\n\n<table width=\"100%\" id=\"_CompaniesListing\" border=\"1px\" cellspacing=\"0\" cellpadding=\"1\" bordercolordark=\"#ffffff\" bordercolorlight=\"#ffffff\"> ";
        sContent = sContent + "\n<thead>" ;
        sContent = sContent + "\n<tr>";
        sContent = sContent + "\n  <td class=\"GRIDHEAD\" width=\"40px\" >Select</td> ";
        sContent = sContent + "\n  <td class=\"GRIDHEAD\" >BB ID</td> ";
        sContent = sContent + "\n  <td class=\"GRIDHEAD\" >Company Name</td> ";
        sContent = sContent + "\n  <td class=\"GRIDHEAD\" >Type</td> ";
        sContent = sContent + "\n  <td class=\"GRIDHEAD\" >Locked By</td> ";
        sContent = sContent + "\n</tr>";
        sContent = sContent + "\n</thead>";
        sContent = sContent + "\n<tbody>";

        while (!recCompanies.eof)
        {
            rc_prtx_createdby = recCompanies("prtx_CreatedBy");
            rc_prtx_username = recCompanies("prtx_UserName");
            if (isEmpty(rc_prtx_username))
                rc_prtx_username = "";
        
            rc_comp_companyid = recCompanies("comp_CompanyId");
            rc_comp_name = recCompanies("comp_Name");
            rc_comp_prtype = recCompanies("capt_us");
            
		    sClassTag = " class=\"ROW1\""; 
            sEnabledTag = " ";
            if (!isEmpty(rc_prtx_createdby) && (rc_prtx_createdby != user_userid))
                sEnabledTag = " DISABLED ";
            if (rc_comp_companyid == comp_companyid)
                sEnabledTag = " DISABLED ";
                
		    sSpaces = "&nbsp;&nbsp;";
		    sContent = sContent + "\n<tr id=\"_compRow_" + rc_comp_companyid + "\"" + sClassTag +">";
		    sContent = sContent + "\n    <td" + sClassTag + " valign=\"middle\" align=\"center\" id=\"_tdchkSelect_" + rc_comp_companyid + "\">"
            sContent = sContent + "<input type=\"checkbox\" id=\"_chkTypeSelect_" + rc_comp_companyid + "\" name=\"_chkTypeSelect_" + rc_comp_companyid + "\"";
            sContent = sContent + sEnabledTag + " CompanyId=\""+ rc_comp_companyid + "\" /></td>";                             
            sContent = sContent + "\n    <td" + sClassTag + " style=\"vertical-align:middle;\">" + rc_comp_companyid  + "</td>";                             
            sContent = sContent + "\n    <td" + sClassTag + " style=\"vertical-align:middle;\">" + rc_comp_name  + "</td>";                             
            sContent = sContent + "\n    <td" + sClassTag + " style=\"vertical-align:middle;\">" + rc_comp_prtype  + "</td>";                             
            sContent = sContent + "\n    <td" + sClassTag + " style=\"vertical-align:middle;\">" + rc_prtx_username  + "</td>";                             
            sContent = sContent + "\n</tr>"; 
            
            recCompanies.NextRecord();
	    }
        sContent = sContent + "\n</tbody>";
        sContent = sContent + "\n</table>";
        
        sContent = sContent + createAccpacBlockFooter();
        grdReplication.Contents=sContent;

        blkContainer.AddBlock(grdReplication);

        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

        blkContainer.DisplayButton(Button_Default) = false;

        if (!isEmpty(comp_companyid)) {
            eWare.AddContent(blkContainer.Execute());
        }

        Response.Write(eWare.GetPage('Company'));
    }
%>
<!-- #include file="CompanyFooters.asp" -->
