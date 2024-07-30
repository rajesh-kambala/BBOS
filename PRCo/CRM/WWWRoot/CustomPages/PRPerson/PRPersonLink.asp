<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

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
function doPage()
{    
    //bDebug=true;
    DEBUG(sURL);
    
    var sSecurityGroups = sDefaultPersonSecurity;

    var blkHistory=eWare.GetBlock("PRPersonLinkHistory");
    var blkUpdateSettings=eWare.GetBlock("PRPersonLinkUpdateSettings");
    var blkMembershipSettings=eWare.GetBlock("PRPersonLinkMembershipSettings");

    blkHistory.Title="Person History";
    blkUpdateSettings.Title="Update Settings";
    blkMembershipSettings.Title="Membership Settings";

    peli_personlinkid = getIdValue("peli_personlinkid");
    if (peli_personlinkid != -1){
        recPersonLink = eWare.FindRecord("Person_Link", "peli_PersonLinkId=" + peli_personlinkid);
    } else {
        recPersonLink = eWare.CreateRecord("Person_Link");

        blkHistory.GetEntry("peli_PREBBPublish").DefaultValue = 'Y';
        
        blkUpdateSettings.GetEntry("peli_PRCSReceiveMethod").DefaultValue = '3';
        blkUpdateSettings.GetEntry("peli_PRCSSortOption").DefaultValue = 'I';
        blkUpdateSettings.GetEntry("peli_PRAUSReceiveMethod").DefaultValue = '3';
        blkUpdateSettings.GetEntry("peli_PRAUSChangePreference").DefaultValue = '2';
        blkUpdateSettings.GetEntry("peli_PRReceivesCreditSheetReport").DefaultValue = 'Y';

        blkMembershipSettings.GetEntry("peli_PRSubmitTES").DefaultValue = 'Y';
        blkMembershipSettings.GetEntry("peli_PRUpdateCL").DefaultValue = 'Y';
        blkMembershipSettings.GetEntry("peli_PRUseServiceUnits").DefaultValue = 'Y';
        blkMembershipSettings.GetEntry("peli_PRUseSpecialServices").DefaultValue = 'Y';
        blkMembershipSettings.GetEntry("peli_PREditListing").DefaultValue = 'Y';
        blkMembershipSettings.GetEntry("peli_PRReceiveBRSurvey").DefaultValue = 'Y';
    }

    sContinueUrl = eWare.URL("PRPerson/PRPersonLinkListing.asp") + "&pers_personid="+ pers_personid + "&T=Person&Capt=History";
    sCancelUrl = eWare.URL("PRPerson/PRPersonLink.asp") + "&peli_personlinkid="+peli_personlinkid+"&pers_personid="+ pers_personid + "&T=Person&Capt=History";

    // adding delete processing (will be restricted to Listing specialists)
    if (eWare.Mode == PreDelete)
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM Person_Link WHERE peli_PersonLinkId="+ peli_personlinkid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sContinueUrl);
        return;
    }
    
    if (eWare.Mode == Save)
    {
        //DumpFormValues();
        blkContainer.AddBlock(blkHistory);
        blkContainer.AddBlock(blkUpdateSettings);
        blkContainer.AddBlock(blkMembershipSettings);
        
        sPRRole = Request.Form.Item("peli_prrole");
        recPersonLink.peli_PersonId = pers_personid;
        if (blkContainer.Validate())
        {
            eWare.AddContent(blkContainer.Execute(recPersonLink));
            //Enable these lines for testing without redirect
            //blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
            //eWare.Mode = View;
            //sResponse = eWare.GetPage();
            //Response.Write(sResponse);

            recPersonLink.peli_prrole = sPRRole;
            
            // If the user is no longer connected, we need to disable
            // the web and Alerts settings
            if (Request.Form.Item("peli_prstatus") == "3") {
                recPersonLink.peli_WebStatus = "";
                recPersonLink.peli_PRAUSReceiveMethod = "";
            }

            if(getFormValue("peli_prownershiprole") == "RCO")
                recPersonLink.peli_prcanviewbusinessvaluations = "Y";
            
            // Note: when this is saved, insert/update trigger will remove 
            recPersonLink.SaveChanges();
            Response.Redirect(sContinueUrl);
        }
        else
        {
            blkContainer = eWare.GetBlock("container");
            blkContainer.DisplayButton(Button_Default) =  false;
            eWare.Mode = Edit;   
        }
    }
   
    var dCurrentPercentage = 0; 
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

    // check the current percentage of ownership
    if (peli_personlinkid != -1){
        sSQL = "SELECT dbo.ufn_GetOwnershipPercentage(" + recPersonLink("peli_CompanyId") + ") As CurrentPercentage";
        recCurrentPercentage = eWare.CreateQueryObj(sSQL,"");
        recCurrentPercentage.SelectSQL();
        dCurrentPercentage = recCurrentPercentage("CurrentPercentage"); 
    }

    // determine if any of the addtional banners should show
    var sBannerMsg = "";
    var blkBanners = eWare.GetBlock('content');
    var sInnerMsg = "";
    var sDisplayTag = " style=\"display:none\" ";
    if (dCurrentPercentage > 100) {
        sDisplayTag = " ";
    }
    sMsg = "Total Ownership Percentage for all company personnel equals " +
           "<span id=\"spnTotalPct\"> " + dCurrentPercentage + "</span>%. This value should not exceed 100%.";
    sInnerMsg = "<tr class=\"ErrorContent\"><td>" + sMsg + "</td></tr>";
    sBannerMsg = "<table " + sDisplayTag + " id=\"tbl_PctWarning\" width=\"100%\" cellspacing=0 class=\"MessageContent\">" + sInnerMsg + "</table> ";
    
    var bAttentionLine = false;    
    if (peli_personlinkid != -1){
      
        recAttnLine = eWare.FindRecord("PRAttentionLine", "prattn_PersonID=" + recPersonLink("peli_PersonId") + " AND prattn_CompanyID=" + recPersonLink("peli_CompanyId") );
        if (!recAttnLine.eof) {
            bAttentionLine = true;

            if (eWare.Mode == View) {
                var sAttnLineURL = eWare.Url("PRCompany/PRCompanyAttentionLine.asp") + "&comp_CompanyId=" + recPersonLink("peli_CompanyId");
                sBannerMsg += "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>This person is associated with an <a href=\"" + sAttnLineURL + "\">attention line</a>.</td></tr></table>";
            }                
        }
    }
    
    var bActiveOnOtherCompanies = false;
    if (peli_personlinkid != -1){
      
        recOtherCompanies = eWare.FindRecord("Person_Link", "peli_PersonId=" + recPersonLink("peli_PersonId") + " AND peli_CompanyID<>" + recPersonLink("peli_CompanyId") + " AND peli_PRStatus IN ('1', '2')");
        if (!recOtherCompanies.eof) {
            bActiveOnOtherCompanies = true;
        }
    }

    var bHasLSSLicense = false;

     if (peli_personlinkid != -1){
        sSQL = "SELECT prwu_PersonLinkID, prwu_BBID, * FROM PRWebUserLocalSource INNER JOIN PRWebUser prwu WITH (NOLOCK) ON prwu_WebUserID = prwuls_WebUserID WHERE prwu_PersonLinkID = " + recPersonLink("peli_personlinkid") + " AND prwu_BBID = " + recPersonLink("peli_CompanyId") + " AND prwuls_ServiceCode = 'LSSLic'";
        recLSSLicense = eWare.CreateQueryObj(sSQL,"");
        recLSSLicense.SelectSQL();
        if (!recLSSLicense.eof) {
            bHasLSSLicense = true;
        }
    }

    var bHasBBOSLicense = false;

    if (peli_personlinkid != -1)
    {
        sSQL = "SELECT prwu_ServiceCode FROM PRWebUser WHERE prwu_PersonLinkID = " + recPersonLink("peli_personlinkid") + " AND prwu_BBID = " + recPersonLink("peli_CompanyId");
        recBBOSLicense = eWare.CreateQueryObj(sSQL,"");
        recBBOSLicense.SelectSQL();
        if (!recBBOSLicense.eof) 
        {
            sColName = recBBOSLicense("prwu_ServiceCode");
            if (!isEmpty(sColName))
            {
                bHasBBOSLicense = true;
            }
        }
    }
    
    blkBanners.contents = sBannerMsg;
    blkContainer.AddBlock(blkBanners);

    Response.Write("<script type=\"text/javascript\" src=\"PRPersonLinkInclude.js\"></script>");
    Response.Write("<table style=\"display:none;\" ><tr><td id=\"tdSpacer\"></td><td id=\"tdSpacer2\"></td><td id=\"tdSpacer3\"></td></tr>");
    Response.Write("<tr id=\"trSpacer1\"><td>&nbsp;</td></tr>");
    Response.Write("<tr id=\"trSpacer2\"><td>&nbsp;</td></tr>");
    Response.Write("</table>");

    var companyTypeCode = "";
    var industryTypeCode = "";
    if (peli_personlinkid != -1) {
		recCompany = eWare.FindRecord("Company", "comp_CompanyId=" + recPersonLink("peli_CompanyId"));
		companyTypeCode = recCompany("comp_PRType");

        industryTypeCode = recCompany("comp_PRIndustryType");
        if (recCompany("comp_PRIndustryType") == "L") {
            blkUpdateSettings.GetEntry("peli_PRCSReceiveMethod").Hidden = true;
            blkUpdateSettings.GetEntry("peli_PRCSSortOption").Hidden = true;
        } else {
            blkUpdateSettings.GetEntry("peli_PRReceivesCreditSheetReport").Hidden = true;

            var recExUpd = eWare.CreateQueryObj("SELECT prse_ServiceCode FROM PRService WHERE prse_ServiceCode='EXUPD' AND (prse_HQID=" + recCompany("comp_PRHQId") + " OR prse_CompanyID=" + recCompany("Comp_CompanyId") + ")");

            recExUpd.SelectSQL();
    	    if (!recExUpd.eof) {
                blkUpdateSettings.GetEntry("peli_PRCSReceiveMethod").Caption = "Express Update Receive Method";
                blkUpdateSettings.GetEntry("peli_PRCSSortOption").Caption = "Express Update Sort Option";
            }
        }
	}
        
    // Since we cannot display a new PersonLink in "View" mode, change it to edit
    if (peli_personlinkid == -1)
        eWare.Mode = Edit;
        
    if (eWare.Mode == Edit)
    {

        if (Request.Form.Item("hidAutoTitleChange") == "Y") {
            recTitleChange = eWare.CreateRecord("Person_Link");
            recTitleChange.peli_PRStatus= 3;
            recTitleChange.peli_PREndDate = (new Date()).getFullYear().toString();
            
            recTitleChange.PeLi_PersonId = recPersonLink.PeLi_PersonId
            recTitleChange.PeLi_CompanyID = recPersonLink.PeLi_CompanyID
            recTitleChange.PeLi_Type = recPersonLink.PeLi_Type
            recTitleChange.peli_PRCompanyId = recPersonLink.peli_PRCompanyId
            recTitleChange.peli_PRRole = recPersonLink.peli_PRRole
            recTitleChange.peli_PROwnershipRole = recPersonLink.peli_PROwnershipRole
            recTitleChange.peli_PRTitleCode = recPersonLink.peli_PRTitleCode
            recTitleChange.peli_PRDLTitle = recPersonLink.peli_PRDLTitle
            recTitleChange.peli_PRTitle = recPersonLink.peli_PRTitle
            recTitleChange.peli_PRResponsibilities = recPersonLink.peli_PRResponsibilities
            recTitleChange.peli_PRPctOwned = recPersonLink.peli_PRPctOwned
            recTitleChange.peli_PREBBPublish = recPersonLink.peli_PREBBPublish
            recTitleChange.peli_PRBRPublish = recPersonLink.peli_PRBRPublish
            recTitleChange.peli_PRExitReason = recPersonLink.peli_PRExitReason
            recTitleChange.peli_PRRatingLine = recPersonLink.peli_PRRatingLine
            recTitleChange.peli_PRStartDate = recPersonLink.peli_PRStartDate
            recTitleChange.peli_WebStatus = recPersonLink.peli_WebStatus
            recTitleChange.peli_WebPassword = recPersonLink.peli_WebPassword
            recTitleChange.peli_PRAUSReceiveMethod = recPersonLink.peli_PRAUSReceiveMethod
            recTitleChange.peli_PRAUSChangePreference = recPersonLink.peli_PRAUSChangePreference
            recTitleChange.peli_PRWhenVisited = recPersonLink.peli_PRWhenVisited
            recTitleChange.peli_PRReceivesBBScoreReport = recPersonLink.peli_PRReceivesBBScoreReport
            recTitleChange.peli_PRSubmitTES = recPersonLink.peli_PRSubmitTES
            recTitleChange.peli_PRUpdateCL = recPersonLink.peli_PRUpdateCL
            recTitleChange.peli_PRUseServiceUnits = recPersonLink.peli_PRUseServiceUnits
            recTitleChange.peli_PRUseSpecialServices = recPersonLink.peli_PRUseSpecialServices
            recTitleChange.peli_PRConvertToBBOS = recPersonLink.peli_PRConvertToBBOS
            recTitleChange.peli_PRReceivesTrainingEmail = recPersonLink.peli_PRReceivesTrainingEmail
            recTitleChange.peli_PRReceivesPromoEmail = recPersonLink.peli_PRReceivesPromoEmail
            recTitleChange.peli_PRReceivesCreditSheetReport = recPersonLink.peli_PRReceivesCreditSheetReport
            recTitleChange.peli_PRWillSubmitARAging = recPersonLink.peli_PRWillSubmitARAging
            recTitleChange.peli_PREditListing = recPersonLink.peli_PREditListing        
            recTitleChange.peli_PRReceiveBRSurvey = recPersonLink.peli_PRReceiveBRSurvey        
            recTitleChange.peli_PRCSReceiveMethod = recPersonLink.peli_PRCSReceiveMethod        
            recTitleChange.peli_PRCSSortOption = recPersonLink.peli_PRCSSortOption
            recTitleChange.peli_PRCanViewBusinessValuations = recPersonLink.peli_PRCanViewVusinessValuations
            
            recTitleChange.SaveChanges();
        }
    
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"../ScrollableTable.js\"></script>");
        
        blkHistory.Title="Person History";
        blkHistory.GetEntry("peli_CompanyId").OnChangeScript = "handleCompanyChange();";
        blkHistory.GetEntry("peli_PRRole").Hidden = true;
        blkHistory.GetEntry("peli_PRPctOwned").DefaultValue = 0;
        blkHistory.GetEntry("peli_PROwnershipRole").AllowBlank = false;
        if (peli_personlinkid == -1) {
            blkHistory.GetEntry("peli_PROwnershipRole").DefaultValue = "RCR";   
        }

        blkHistory.GetEntry("peli_PRStatus").AllowBlank = false;
        blkHistory.GetEntry("peli_PRStatus").OnChangeScript = "handleStatusChange();";
        if (peli_personlinkid == -1) {
            blkHistory.GetEntry("peli_PRStatus").DefaultValue = 1;   
        }
        
        blkHistory.GetEntry("peli_PRExitReason").OnChangeScript = "handleExitReasonChange();";


        blkUpdateSettings.GetEntry("peli_PRAUSReceiveMethod").OnChangeScript = "handleSReceiveMethodChange();";
        blkUpdateSettings.GetEntry("peli_PRCSReceiveMethod").OnChangeScript = "handleSReceiveMethodChange();";


        blkContainer.AddBlock(blkHistory);
        blkContainer.AddBlock(blkUpdateSettings);
        blkContainer.AddBlock(blkMembershipSettings);


        if (peli_personlinkid == -1)
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sContinueUrl));
        else    
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelUrl));

        if (isUserInGroup(sSecurityGroups)) {
    	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"checkDupHistory(" + pers_personid + ", " + peli_personlinkid + ");"));
        }            

        blkContainer.CheckLocks = false;
        
        eWare.AddContent(blkContainer.Execute(recPersonLink));
        sResponse = eWare.GetPage('Person');
        Response.Write(sResponse);
    
        var sAssignedRoles = recPersonLink("peli_PRRole");
        if (isEmpty(sAssignedRoles))
            sAssignedRoles = "";


        // We'll need a list of roles 
        sSQL = " SELECT capt_captionid, capt_code, capt_US ";
        sSQL += "  FROM custom_captions WITH (NOLOCK) ";
        sSQL += " WHERE capt_familytype = 'Choices' AND capt_family = 'peli_PRRole' ";
        sSQL += " ORDER BY capt_Order ";
        recRoles = eWare.CreateQueryObj(sSQL);
        recRoles.SelectSQL();

%>        
<input type="hidden" id="hdn_CompanyOwnershipPercent" name="hdn_CompanyOwnershipPercent" value="0" />
<table id="Table1" border="1" >
  <tr>
    <td rowspan="40" align="left" valign="top" id="_td_tblRolesSection">
      <table  width="250" class="VIEWBOXCAPTION" id="_tblRolesSection" cellpadding="0" cellspacing="0" border="0"> 
        <tr>
          <td>&nbsp;</td>
          <td>
            <table width="100%" id="_tblRoleEditSection" cellpadding=0 cellspacing=0>
              <tr><td style="border:1px solid gray;vertical-align:top;padding-top:5px;" class="VIEWBOXCAPTION" ><span>&nbsp;Company Roles:<br/></span>
                         <input type="hidden" id="_txt_SelectedRoles" name="peli_prrole" value="<%=sAssignedRoles%>" />
                  </td> 
              </tr>
              <tr>
                <td style="border:1px solid gray">
                  <div style="height:350px;overflow:auto">
                  <table width="100%" id="_RolesListing" class="CONTENT" cellspacing="0" cellpadding="1" bordercolordark="#ffffff" bordercolorlight="#ffffff" > 
                    <thead align="center">
                      <tr>
                        <td class="GRIDHEAD" style="width:40px">Select</td> 
                        <td class="GRIDHEAD" style="width:100px"">Role</td>
                      </tr> 
                    </thead>
                    <tbody>
<%
        if (!recRoles.eof && recRoles.RecordCount > 0)
        {
            while (!recRoles.eof) 
            {
                capt_captionid = recRoles("capt_captionid");
                capt_code = recRoles("capt_code");
                sRole = recRoles("capt_us");//eWare.getTrans("peli_PRRole", capt_code);
                
                if (isEmpty(sRole))
                    sRole = "";

                   
                sChecked = "";
                if (!recPersonLink.eof)
                {
                    if (sAssignedRoles.indexOf(","+capt_code+",") != -1)
                        sChecked = " CHECKED ";
                }
%>
                      <tr id="_tr_peli_Role<%=capt_captionid%>" RoleCode="<%=capt_code%>" > 
                        <td valign="middle" align="center" id="_tdchkRoleSelect_<%=sRole%>" class="ROW2">
                             <input type=CHECKBOX 
                                    id="_chkRoleSelect_<%=capt_code%>" 
                                    name="_chkRoleSelect_<%=capt_code%>" <%=sChecked%>
                                    RoleCode="<%=capt_code%>"
                                    onclick="onRoleCheckboxClick()" />
                        </td> 
                        <td id="_tdRole_<%=capt_captionid%>" style="vertical-align:middle;" class="ROW2" ><%=sRole%></td> 
                      </tr>
<%
                recRoles.NextRecord();
            }
        }
%>
                    </tbody> 
                  </table> <!-- _RolesListing -->
                  </div>
                </td>
              </tr>
            </table> <!-- _tblRolesEditSection -->
          </td>
          <td>&nbsp;&nbsp;&nbsp;</td>
        </tr>
        <tr><td>&nbsp;</td>
        </tr>

        <tr><td>&nbsp;</td>
        </tr>

      </table> <!--_tblRolesSection -->
    </td>
  </tr>
</table>
<%            
        DEBUG ("PersonLinkId: " + peli_personlinkid );
            
        // determine if this user has any existing phone, email, or address records
        var sContactInfoExists = "";

        sSQL = "select 1 from Address_Link WITH (NOLOCK) where adli_PersonId = " + pers_personid + " UNION " +
               "select 1 from vPRPersonPhone WITH (NOLOCK) where plink_EntityID = " + pers_personid + " UNION " +
               "select 1 from vPersonEmail WITH (NOLOCK) where elink_EntityID = " + pers_personid ;
        recContactInfo = eWare.CreateQueryObj(sSQL);
        recContactInfo.SelectSQL();
        if (!recContactInfo.eof)
            sContactInfoExists = "bContactInfoExists = true;";
            

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        if (!isEmpty(recPersonLink("peli_prtitlecode")))
            Response.Write("\n        sOrigPublishedTitle = \"" + recPersonLink("peli_prtitlecode")+ "\";");

        if (!isEmpty(recPersonLink("peli_prdltitle")))
            Response.Write("\n        sOrigDLTitle = \"" + recPersonLink("peli_prdltitle")+ "\";");

        if (peli_personlinkid != -1)
            Response.Write("\n        sPeliId='" + peli_personlinkid + "';");

        Response.Write("\n        sPersonID='" + pers_personid + "';");
    

        Response.Write("\n        companyTypeCode='" + companyTypeCode + "';");
        Response.Write("\n        " + sContactInfoExists);

        if (bAttentionLine) {
            Response.Write("\n    bAttentionLineExists = true;");
        }

        if (bActiveOnOtherCompanies) {
            Response.Write("\n    bActiveOnOtherCompanies = true;");
        }
        
        if (peli_personlinkid == -1) {
            Response.Write("\n        bIsNew=true;");
        }

        if(bHasLSSLicense) 
            Response.Write("\n        bHasLSSLicense=true;");
        else
            Response.Write("\n        bHasLSSLicense=false;");

        if(bHasBBOSLicense) 
            Response.Write("\n        bHasBBOSLicense=true;");
        else
            Response.Write("\n        bHasBBOSLicense=false;");

        // call handleCompanyChange() to set the already selected Company Roles to disabled
        Response.Write("\n        handleCompanyChange();");

        // disable any necessary fields based upon role
        if (eWare.Mode == Edit)
            Response.Write("\n        ToggleRoles();");
            
        if (recPersonLink("peli_PRStatus") == 3) 
            Response.Write("\n        enableAllRoles(false);");
        
        Response.Write("\n        AppendCell(\"_Captpeli_prstatus\", \"_td_tblRolesSection\");");
        Response.Write("\n        AppendCell(\"_Captpeli_prstartdate\", \"tdSpacer\", true);");
        Response.Write("\n        AppendCell(\"_Captpeli_prwhenvisited\", \"tdSpacer2\", true);");
        Response.Write("\n        AppendCell2Checkbox(\"_IDpeli_prwillsubmitaraging\", \"tdSpacer3\", true);");

        //Response.Write("\n        RemoveDropdownItemByName(\"peli_prcsreceivemethod\", \"--None--\");");
        //Response.Write("\n        RemoveDropdownItemByName(\"peli_prcssortoption\", \"--None--\");");
        //Response.Write("\n        RemoveDropdownItemByName(\"peli_prausreceivemethod\", \"--None--\");");
        //Response.Write("\n        RemoveDropdownItemByName(\"peli_prauschangepreference\", \"--None--\");");
                   
           



	    Response.Write("\n        var hdnCOP = document.getElementById(\"hdn_CompanyOwnershipPercent\");");
        if (peli_personlinkid != -1) {
    	    Response.Write("\n    hdnCOP.value = '" + dCurrentPercentage + "';");        
		}

        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");

    }
    else
    {
        eWare.Mode = View;

        blkContainer.AddBlock(blkHistory);
        blkContainer.AddBlock(blkUpdateSettings);
        blkContainer.AddBlock(blkMembershipSettings);

        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));
                blkContainer.AddButton(eWare.Button("Auto Title Change","edit.gif", "javascript:autoTitleChange();"));
                
    	    if (isUserInGroup("2,4,6,10"))
    	    {
                if (bAttentionLine) {
                    var sDeleteUrl="javascript:alert('Please reassign the attention line to another person prior to removing this record.');";
                } else {
                    var sDeleteUrl = changeKey(sURL, "em", "3");
                    sDeleteUrl = "javascript:if (confirm('Are you sure you want to permanently delete this person history?')) {location.href='"+sDeleteUrl+"';}";
                }

               blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
            }
    	}

        // Add the Web User Link 
        var recWebUser = eWare.FindRecord("PRWebUser", "prwu_PersonLinkId="+ peli_personlinkid + " and prwu_AccessLevel > 0 ");
        if (recWebUser.RecordCount > 0)
        {
            var sWebUserURL = eWare.URL("PRPerson/PRWebUser.asp") + "&prwu_WebUserId="+recWebUser("prwu_WebUserId");
            blkContainer.AddButton(eWare.Button("BBOS User Record", "Continue.gif", sWebUserURL));                
        }
        
        eWare.AddContent(blkContainer.Execute(recPersonLink));
        //eWare.AddContent(blkContainer.Execute());
        sResponse = eWare.GetPage('person');
        Response.Write(sResponse);

        Response.Write("<input type=\"hidden\" name=\"hidAutoTitleChange\">" );
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI"); 
        Response.Write("\n    {");
        Response.Write("\n        AppendRow(\"_Captpeli_prstatus\", \"trSpacer1\");");
        Response.Write("\n        AppendRow(\"_Captpeli_prexitreason\", \"trSpacer2\");");
        Response.Write("\n        AppendCell(\"_Captpeli_prstartdate\", \"tdSpacer\", true);");
        Response.Write("\n        AppendCell(\"_Captpeli_prwillsubmitaraging\", \"tdSpacer2\", true);");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }
}
doPage();
%>
<!-- #include file ="../RedirectTopContent.asp" -->
