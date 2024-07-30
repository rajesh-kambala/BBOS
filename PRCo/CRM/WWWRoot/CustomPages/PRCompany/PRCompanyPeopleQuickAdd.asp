<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCOGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009-2024

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

doPage();
Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

function doPage()
{
    var comp_companyid = Request.Querystring("comp_companyid");
    
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
        
    var Key0 = new String(Request.QueryString("Key0"));
    var Key1 = new String(Request.QueryString("Key1"));
    var Key2 = new String(Request.QueryString("Key2"));

    var isChangeQueue = false;
    var changeQueueID = Request.Querystring("prchrq_ChangeQueueID");

    if (!isEmpty(changeQueueID))
        isChangeQueue = true;
  
    // Accpac makes assumptions based on the existence of 
    // these keys.  Remove all of them, add a few others to
    // indicate this is a new person, and redirect to ourselves.
    if ("" + Key1 != "undefined" )
    {
        sRedirectUrl = eWare.URL("PRCompany/PRCompanyPeopleQuickAdd.asp")
        sRedirectUrl = removeKey(sRedirectUrl, "Key0");       
        sRedirectUrl = removeKey(sRedirectUrl, "Key1");
        sRedirectUrl = removeKey(sRedirectUrl, "Key2");       
        sRedirectUrl = removeKey(sRedirectUrl, "P");       
        sRedirectUrl = removeKey(sRedirectUrl, "F");       
        sRedirectUrl += "&Mode=1&CLk=T&T=new&NormalRec=Y&comp_companyid="+comp_companyid;

        if(isChangeQueue)
        {
            sRedirectUrl += "&prchrq_ChangeQueueID=" + changeQueueID;
            
            // Before we redirect, build our cancel link now in order to restore our context.
            //Inject custom url
            var SID = new String(Request.QueryString("SID"));
            var h = Request.ServerVariables("SERVER_NAME") + Request.ServerVariables("URL") + "?"; // + Request.ServerVariables("QUERY_STRING");
            var PRIntPos = h.indexOf("CustomPages/PRCompany/PRCompanyPeopleQuickAdd.asp");
            if(PRIntPos >= 0)
            {
                h = h.substring(0,PRIntPos);
                h = h + "eware.dll/Do?SID=" + SID + "&Act=432&Mode=1&CLk=T&dotnetdll=TravantCRM&dotnetfunc=RunChangeQueueListing&J=BBOS Change Queue&T=find";
            }

            Session("PRCompanyPeopleQuickAddReturnLink") = h;
        }
        else
        {
            // Before we redirect, build our cancel link now in order to restore our context.
            Session("PRCompanyPeopleQuickAddReturnLink") = eWare.Url("PRCompany/PRCompanyPeople.asp") + "&T=Company&Capt=Personnel";
        }
        
        Response.Redirect(sRedirectUrl );
        return;        
    }    

    if (eWare.Mode == View) {
        eWare.Mode = Edit;
    }
    var bRedirect = false;
    var bValidated = false;

    blkContainer.CheckLocks = false;

    var blkPerson = eWare.GetBlock("PRPersonQuickAdd");
    blkPerson.Title = "Person";

    var blkPersonLink = eWare.GetBlock("PRPersonLinkQuickAdd");
    blkPersonLink.Title = "Person History";

    var blkPersonEmail = eWare.GetBlock("PREmailQuickAdd");
    blkPersonEmail.Title = "Email";

    var blkPersonPhone = eWare.GetBlock("PRPhoneQuickAdd");
    blkPersonPhone.Title = "Phone";

    blkPersonPhone.GetEntry("plink_Type").LookupFamily = "Phon_TypePerson";

    blkTrx=eWare.GetBlock("PRTransactionNewEntry");
    blkTrx.Title = "Transaction";

    if (eWare.Mode == Save) {
        recPerson = eWare.CreateRecord("Person");    
        blkPerson.ArgObj = recPerson;

        recTrx = eWare.CreateRecord("PRTransaction");
        blkTrx.ArgObj = recTrx;

        if ((blkPerson.Validate()) &&
            (blkTrx.Validate()) &&
            (blkPersonLink.Validate())) {

            blkPerson.Execute();
            blkTrx.Execute();
            
            // If the user wants the transaction closed when we're all done,
            // we must make sure it's open for the duration of this
            // operation.
            var sOldStatus = recTrx.prtx_Status;
            if (sOldStatus == "C") {
                recTrx.prtx_Status = "O";
            }

            // We need to update the transaction a second time becuase
            // we didn't have a PersonID until now.
            recTrx.prtx_PersonId = recPerson.pers_personid;
            recTrx.SaveChanges();

            var recPersonLink = eWare.CreateRecord("Person_Link");
            recPersonLink.peli_PersonID = recPerson.pers_personid;
            recPersonLink.peli_PRStatus = "1";
            recPersonLink.peli_PRSubmitTES = "Y";
            recPersonLink.peli_PRUpdateCL = "Y";
            recPersonLink.peli_PRUseServiceUnits = "Y";
            recPersonLink.peli_PRUseSpecialServices = "Y";
            recPersonLink.peli_PRReceivesCreditSheetReport = "Y";
            recPersonLink.peli_PRReceivesTrainingEmail  = "Y";
            recPersonLink.peli_PRReceivesCreditSheetReport = "Y";
            recPersonLink.peli_PRReceivesPromoEmail  = "Y";
            recPersonLink.peli_PREditListing  = "Y";
            recPersonLink.peli_PRReceiveBRSurvey  = "Y";
           
            var szRole = GetRoleFromTitle();
            if (szRole != null) {
                recPersonLink.peli_PRRole = szRole;
            }
            blkPersonLink.ArgObj = recPersonLink;
            blkPersonLink.Execute(recPersonLink);
            recPersonLink.peli_CompanyID = comp_companyid;


            if (getFormValue("peli_prtitlecode") == "PROP") {
                recPersonLink.peli_PRPctOwned = 100;
            }

            if(getFormValue("peli_prownershiprole") == "RCO")
                recPersonLink.peli_prcanviewbusinessvaluations = "Y";
    
            recPersonLink.SaveChanges();

            if (getFormValue("emai_emailaddress") != "") {
                var recPersonEmail = eWare.CreateRecord("Email");
                recPersonEmail.emai_PRPublish = "Y";
                recPersonEmail.emai_PRPreferredPublished = "Y";
                recPersonEmail.emai_PRPreferredInternal = "Y";
                recPersonEmail.emai_PRDescription = "E-Mail";
                blkPersonEmail.ArgObj = recPersonEmail;
                blkPersonEmail.Execute(recPersonEmail);

                recPersonEmail.emai_CompanyID = comp_companyid;
                recPersonEmail.SaveChanges();

                recEmailLink = eWare.CreateRecord("EmailLink");
		        recEmailLink.ELink_RecordID = recPerson.pers_personid;
                recEmailLink.ELink_EntityID = 13;
                recEmailLink.ELink_EmailId = recPersonEmail.emai_EmailID;
                recEmailLink.ELink_Type =  "E";
                recEmailLink.SaveChanges();
            }

            if (getFormValue("phon_Number") != "") {
                var recPersonPhone = eWare.CreateRecord("Phone");
                recPersonPhone.phon_PRIsPhone = "Y";
                
                recPersonPhone.phon_PRPreferredInternal = "Y";
                
                var plink = Request.Form("plink_type");
                var prdesc = "";
                if(plink == "C") prdesc="Cell";
                else if(plink == "E") prdesc="Company Extension";
                else if(plink == "EFAX") prdesc="E-FAX";
                else if(plink == "F") prdesc="Direct Office FAX";
                else if(plink == "G") prdesc="Pager";
                else if(plink == "O") prdesc="Other";
                else if(plink == "P") prdesc="Direct Office Phone";
                else if(plink == "R") prdesc="Residence";
                if(prdesc != "")
                    recPersonPhone.phon_PRDescription = prdesc;

                if(getFormValue("phon_CountryCode") == "")                
                    recPersonPhone.phon_CountryCode = "1";
                else
                    recPersonPhone.phon_CountryCode = getFormValue("phon_CountryCode");

                recPersonPhone.phon_AreaCode = getFormValue("phon_AreaCode");
                recPersonPhone.phon_Number = getFormValue("phon_Number");

                if (getFormValue("phon_prpublish") == "on") {
                    recPersonPhone.phon_PRPublish = "Y";
                    recPersonPhone.phon_PRPreferredPublished = "Y";
                }

                recPersonPhone.phon_CompanyID = comp_companyid;
                recPersonPhone.SaveChanges();

                recPhoneLink = eWare.CreateRecord("PhoneLink");
		        recPhoneLink.PLink_RecordID = recPerson.pers_personid;
                recPhoneLink.PLink_EntityID = 13;
                recPhoneLink.PLink_PhoneId = recPersonPhone.phon_PhoneId;
                recPhoneLink.PLink_Type =  getFormValue("plink_Type");
                recPhoneLink.SaveChanges();
            }

            // Now the Person and transaction will exist. Add a detail record
            sSQL = "EXECUTE usp_CreateTransactionDetail " + 
                        "@prtx_TransactionId = " + recTrx.prtx_TransactionId + ", " +
                        "@Entity = 'Person', " +
                        "@Action = 'Insert', " +
                        "@NewValue = '" + recPerson.pers_FirstName.replace(/'/g, "''") + " " + recPerson.pers_LastName.replace(/'/g, "''") + " Created', " +
                        "@UserId = " + user_userid;
            recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.ExecSql()

            // CRM changed how they handle hidden fields.
            // So look here to see if we should close the transaction.
            if (getFormValue("_HIDDENprtx_status")  == "C") {
                recTrx.prtx_Status = "C";
                recTrx.prtx_CloseDate = getDBDateTime(new Date());;
                recTrx.SaveChanges();
            }
            
            bRedirect = true;
            bValidated = true;
            
            //Response.Write("<p>cbHERole:" + getFormValue("cbHERole") + "</p>");

            if (isChangeQueue) {
                var changeQueueListingURL = eWare.Url("TravantCRM.dll-RunChangeQueueListing");
                changeQueueListingURL = changeQueueListingURL.replace("TravantCRM.dll", "TravantCRM"); 
                Response.Redirect(changeQueueListingURL);
            } else if (recCompany("comp_PRHasCustomPersonSort") == "Y") {
                var sequenceURL = eWare.URL("PRCompany/PRCompanyPeopleSequence.asp") + "key0=1&key1=" + recCompany("comp_companyid") + "&comp_companyid=" + recCompany("comp_companyid") + "&T=Company&Capt=Personnel";
                Response.Redirect(sequenceURL);
            } else {
                Response.Redirect(Session("PRCompanyPeopleQuickAddReturnLink"));
            }
            return;
        }        
    }        
        
    if ((eWare.Mode == Edit) || (!bValidated)) {
        var epeli_CompanyId = blkPersonLink.GetEntry("peli_CompanyId");
        epeli_CompanyId.ReadOnly = true;
        epeli_CompanyId.DefaultValue = comp_companyid;

        var epeli_PROwnershipRole = blkPersonLink.GetEntry("peli_PROwnershipRole");
        epeli_PROwnershipRole.AllowBlank = false;
        epeli_PROwnershipRole.DefaultValue = "RCR";
        
        blkPersonLink.GetEntry("peli_PREBBPublish").DefaultValue = "Y";

        blkPersonEmail.GetEntry("emai_emailaddress").OnChangeScript = "trimString(this);";
      
        // Set up the transaction information
        entry = blkTrx.GetEntry("prtx_Status");
        entry.ReadOnly = true;
        entry.DefaultValue = "O";      
        blkTrx.GetEntry("prtx_CloseDate").hidden = true;
        if (isChangeQueue) 
            blkTrx.GetEntry("prtx_Explanation").DefaultValue = "Person record created from BBOS request from BB #" + comp_companyid + " - " + recCompany("comp_Name");
        else
            blkTrx.GetEntry("prtx_Explanation").DefaultValue = "Person record created by auto-entry from BB #" + comp_companyid + " - " + recCompany("comp_Name");

        var phon_countrycode = blkPersonPhone.GetEntry("phon_countrycode");
        phon_countrycode.DefaultValue = "1"; //Defect 6792

        var sCancelURL = Session("PRCompanyPeopleQuickAddReturnLink");

        if (isChangeQueue) {
            sCancelURL = eWare.Url("TravantCRM.dll-RunChangeQueueDetail") + "&prchrq_ChangeQueueID=" + changeQueueID;
            sCancelURL = sCancelURL.replace("TravantCRM.dll", "TravantCRM"); 
        }

        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelURL));

        // It is important to remove Key1.  If Accpac finds this key when saving
        // it will try to create a Person_Link record too.
        var sSaveUrl = removeKey(changeKey(sURL, "em", Save), "Key1");
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.action='" + sSaveUrl + "';save();"));
        
        var sCloseTrxDisplay = "<table style=\"display:none\"><tr ID=\"tr_closetrx\"><td id=\"td_closetrx\" class=\"VIEWBOXCAPTION\">" + 
            "<input type=\"checkbox\" class=\"EDIT\" " +
            "onclick=\"if (this.checked==true) document.getElementById('_HIDDENprtx_status').value='C'; else document.getElementById('_HIDDENprtx_status').value='O';\" " + 
            ">Close Transaction Upon Save</td></tr></table>" ;
        Response.Write(sCloseTrxDisplay);
        sCloseTrxDraw = " AppendCell(\"_Captprtx_status\", \"td_closetrx\");\n";

        var sDisbled = "";
        var recHERole = eWare.FindRecord("Person_Link", "peli_PRStatus = '1' AND peli_PRRole LIKE '%,HE,%' AND peli_CompanyId=" + comp_companyid);
        if (!recHERole.EOF) {
            sDisbled = " disabled=true ";
        }     

        var sCustomFields = "<table style=\"display:none\"><tr id=\"tr_HERole\"><td id=\"td_HERole\">" + 
                            "<span class=\"VIEWBOXCAPTION\"><label for=\"cbHERole\">Head Executive</label>:</span><br/>" + 
                            "<span class=\"VIEWBOXCAPTION\"><input type=\"checkbox\" name=\"cbHERole\" id=\"cbHERole\" class=\"EDIT\" " + sDisbled + "></span>" +
                            "</td></tr></table>" ;
        Response.Write(sCustomFields);
    
        var sCustomFieldsDraw = " AppendCell2Checkbox(\"_HIDDENpeli_prebbpublish\", \"td_HERole\", false);\n";

        if (isChangeQueue) {
            PopulateFromChangeQueue(changeQueueID, blkPerson, blkPersonEmail, blkTrx);
        }
%>
        <script type="text/javascript">
            function onTitleCodeChange()
            {
                var cboTitle = document.EntryForm.peli_prtitlecode;
                var sTitleCode = cboTitle.options[cboTitle.selectedIndex].value;
                var sTitleText = cboTitle.options[cboTitle.selectedIndex].innerText;
                
                document.EntryForm.peli_prtitle.value = sTitleText;
                
                cboPRBRPublish = document.EntryForm.peli_prbrpublish;
                if ( ',PROP,MM,CHR,CEO,PRES,PAR,COO,CFO,SVP,VP,SEC,TRE,SHR,MEM,MDIR,DIR,TRU,OWN,'.indexOf(','+sTitleCode+',') >-1 )
                    cboPRBRPublish.checked = true;    
                else
                    cboPRBRPublish.checked = false;        
                    
                    
                // now handle the Responsible Connected listing
                cboPROwnershipRole = document.EntryForm.peli_prownershiprole;
                if (',PROP,OWN,SHR,'.indexOf(','+sTitleCode+',') >-1 )
                {   
                    sValue = 'RCO';
                    SelectDropdownItemByValue('peli_prownershiprole', sValue);
                }

                setCreditSheetChangeVal();
            }      

            function setCreditSheetChangeVal() {

                var firstName = $("#pers_firstname").val();
                var lastName = $("#pers_lastname").val();
                var title = $("#peli_prtitle").val();
                $("#txtCSChange").val(firstName + " " + lastName + ", " + title + ", Now Connected");;
            }

            function validate() {
            
                var focusControl= null;
                var sAlertMsg = "";
            
                // For certain generic titles, a responsibly connected role is required.
                var cboTitle = document.EntryForm.peli_prtitlecode;
                var sTitleText = cboTitle[cboTitle.selectedIndex].innerText;
                var sTitleCode = cboTitle.options[cboTitle.selectedIndex].value;

                var cboPROwnershipRole = document.EntryForm.peli_prownershiprole;
                var sSelectedOwnershipCode = cboPROwnershipRole[cboPROwnershipRole.selectedIndex].value;
                
                if (sTitleCode == "") {
                    sAlertMsg += " - A Generic Title is required.\n";
                    if (focusControl == null)
                        focusControl = cboTitle;
                }

                if (',MM,CHR,CEO,PRES,PAR,COO,CFO,SVP,TRE,'.indexOf(','+sTitleCode+',') > -1 )
                {
                    if (sSelectedOwnershipCode == 'RCR')
                    {
                        sAlertMsg += " - When a Generic Title of '" + sTitleText + "' is selected, an Ownership Role is required.\n";
                        if (focusControl == null)
                            focusControl = cboPROwnershipRole;
                    }    
                }       
                
                if (',PROP,OWN,SHR,'.indexOf(','+sTitleCode+',') >-1 )
                {   
                    if (sSelectedOwnershipCode != 'RCO')
                    {
                        sAlertMsg += " - When a Generic Title of '" + sTitleText + "' is selected, an Ownership Role of 'Owner (Responsibly Connected)' is required.\n";
                        if (focusControl == null)
                            focusControl = cboPROwnershipRole;
                    }                     
                }

                // this requires an authorized by user id or authorization information
                if (document.getElementById("prtx_authorizedbyid").value == '' && document.getElementById("prtx_authorizedinfo").value  == '')
                {
                    sAlertMsg += " - Either an Authorized By User or Authorization Information must be entered.\n";
                }

                var cboNotificationType = document.EntryForm.prtx_notificationtype;
                var sNotificationType = cboNotificationType.options[cboNotificationType.selectedIndex].value;
                if (sNotificationType == "") {
                    sAlertMsg += " - Notification Type is a required field.\n";
                    if (focusControl == null)
                        focusControl = cboNotificationType;
                }

                var cboNotificationStimulus = document.EntryForm.prtx_notificationstimulus;
                var sNotificationStimulus = cboNotificationStimulus.options[cboNotificationStimulus.selectedIndex].value;
                if (sNotificationStimulus == "") {
                    sAlertMsg += " - Notification Stimulus is a required field.\n";
                    if (focusControl == null)
                        focusControl = cboNotificationStimulus;
                }

                if (document.getElementById("prtx_explanation").value == '')
                {
                    sAlertMsg += " - An Explanation must be entered.\n";
                }

                if (document.getElementById("emai_emailaddress").value.indexOf(",") != -1) {
                    sAlertMsg += " - Email Address cannot contain a comma.\n";
                }

                if (document.getElementById("phon_areacode").value != "" || document.getElementById("phon_number").value != "") {
                    if (document.getElementById("phon_countrycode").value == "" || document.getElementById("phon_areacode").value == "" || document.getElementById("phon_number").value == "") {
                        sAlertMsg += " - Country/Area/City Code, Phone Number, and Phone Type are required fields when entering a phone number.\n";
                    }
                    else if (document.getElementById("plink_type").value == "") {
                        sAlertMsg += " - Phone Type is a required field.\n";
                    }
                }

               if (sAlertMsg != "")
                {
                    alert ("The following changes are required to save the Person History record:\n\n" + sAlertMsg);
                    if (focusControl != null)
                        focusControl.focus();
                    return false;
                }                         
                
                return true;
            }
            
            var bSaveFlag = false;            
            function save()
            {
                if (bSaveFlag == true) {
                    return;
                }
                bSaveFlag = true;            
                
                if (validate() == true)
                {
                    document.EntryForm.submit();
                } else {
                    bSaveFlag = false;            
                }
            }            
            
            function handleEnterKey() {
                var keycode = (event.keyCode ? event.keyCode : event.which);
                if ((keycode == '13') &&
                    (eent.srcElement.type != 'textarea')) {
                    save();
                    event.cancelBubble = true;
                    event.returnValue = false;
                    return false;
                }
            }

            function initBBSI() {
                <% Response.Write(sCloseTrxDraw) %>
                <% Response.Write(sCustomFieldsDraw) %>
                

                document.getElementById("prtx_effectivedate").value = getDateAsString();
                document.getElementById("pers_lastname").focus();

                onTitleCodeChange();
                
                document.getElementById("peli_companyid").value = <% =comp_companyid%>;
                document.getElementById("_Datapeli_companyid").style.width = "250px";
            }
        </script>
<%
    }

    if (!bRedirect) {
    
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

        blkContainer.AddBlock(blkPerson);
        blkContainer.AddBlock(blkPersonLink);
        blkContainer.AddBlock(blkPersonEmail);
        blkContainer.AddBlock(blkPersonPhone);
        
        if(isChangeQueue)
        {
            AddBBOSLicenseBlock();

            var changeDefault = blkPerson.GetEntry("pers_FirstName").DefaultValue
                + " " + blkPerson.GetEntry("pers_LastName").DefaultValue;
                + ", " + blkPersonLink.GetEntry("peli_prtitle").DefaultValue + 
                + ", Now Connected";

            AddCreditSheetBlock(changeDefault);
        }

        blkContainer.AddBlock(blkTrx);

        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage("Company")); 
%>

        <script type="text/javascript">
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
            if (window.document.forms[0].addEventListener) { 
                window.document.forms[0].addEventListener("keypress", handleEnterKey); 
            } else {
                window.document.forms[0].attachEvent("onkeypress", handleEnterKey); 
            }
        </script>
<%

    }
}    

function PopulateFromChangeQueue(changeQueueID, blkPerson, blkPersonEmail, blkTrx) {
    var personID;
    
    var sql = "SELECT peli_PersonID FROM PRChangeQueue INNER JOIN PRWebUser ON prchrq_WebUserID=prwu_WebUserID INNER JOIN Person_Link ON prwu_PersonLinkID=peli_PersonLinkID WHERE prchrq_ChangeQueueID=" + changeQueueID;
    var recChangeQueue = eWare.CreateQueryObj(sql);
    recChangeQueue.SelectSQL();

    if (!recChangeQueue.eof)
    {
        personID = getValue(recChangeQueue("peli_PersonID"))
    }

    var firstName;
    var lastName;
    var gender;
    var email;
    var phoneNumber;

    sql = "SELECT * FROM vPRChangeQueueDetail WHERE prchrqd_ChangeQueueID=" + changeQueueID;
    var recChangeQueueDetails = eWare.CreateQueryObj(sql);
    recChangeQueueDetails.SelectSQL();

    while (!recChangeQueueDetails.eof)
    {
        firstName = GetChangeValue(recChangeQueueDetails, "pers_FirstName", firstName);
        lastName = GetChangeValue(recChangeQueueDetails, "pers_LastName", lastName);
        gender = GetChangeValue(recChangeQueueDetails, "pers_Gender", gender);
        email = GetChangeValue(recChangeQueueDetails, "emai_EmailAddress", email);

        recChangeQueueDetails.NextRecord();
    }

    blkPerson.GetEntry("pers_FirstName").DefaultValue = firstName;
    blkPerson.GetEntry("pers_LastName").DefaultValue = lastName;
    blkPerson.GetEntry("pers_Gender").DefaultValue = gender;
    
    blkPersonEmail.GetEntry("emai_EmailAddress").DefaultValue = email;

    blkTrx.GetEntry("prtx_authorizedbyid").DefaultValue = personID;
    blkTrx.GetEntry("prtx_notificationtype").DefaultValue = "O";  // Other
    blkTrx.GetEntry("prtx_notificationstimulus").DefaultValue = "4"; // Unsolictied
}

function GetChangeValue(recChangeQueueDetails, fieldName, currentValue)
{
    var changeFieldName = getValue(recChangeQueueDetails("prchrqd_FieldName"))
    
    if (fieldName == changeFieldName)
        return getValue(recChangeQueueDetails("prchrqd_NewValue"))

    return currentValue;
}


function GetRoleFromTitle() {

    var sTitleCode = "," + getFormValue("peli_prtitlecode") + ",";
    var sRole = "";

    if (!isEmpty(getFormValue("cbHERole"))) {
        sRole += ",HE";
    }

    // the following values set the Executive role 
    if (",PROP,MM,CHR,CEO,PRES,PAR,COO,CFO,SVP,VP,SEC,TRE,SHR,MDIR,DIR,OWN,MEM,TRU,".indexOf(sTitleCode) >-1 ) {
        sRole += ",E";
    }

    // the following values set the Operations role 
    if (",COO,OMGR,CS,DIRO,OPER,QC,".indexOf(sTitleCode) >-1 ) {
        sRole += ",O";
    }

    // the following values set the Finance role 
    if (",CFO,TRE,CRTL,".indexOf(sTitleCode) >-1 ) {
        sRole += ",F";
    }

    // the following values set the Manager role 
    if (",GM,MGR,OMGR,SMGR,DIRO,CRED,".indexOf(sTitleCode) >-1 ) {
        sRole += ",M";
    }

    // the following values set the Sales role 
    if (",SMGR,SALE,BUY,BRK,".indexOf(sTitleCode) >-1 ) {
        sRole += ",S";
    }

    // the following values set the Buying/Purchasing role 
    if (",BUY,BRK,BUYR,".indexOf(sTitleCode) >-1 ) {
        sRole += ",B";
    }

    // the following values set the Transportation/Dispatch role 
    if (",TRN,DISP,".indexOf(sTitleCode) >-1 ) {
        sRole += ",T";
    }

    // the following values set the Marketing role 
    if (",MRK,".indexOf(sTitleCode) >-1 ) {
        sRole += ",K";
    }    

    // the following values set the Credit role 
    if (",CRED,ACC,".indexOf(sTitleCode) >-1 ) {
        sRole += ",C";
    }    

    // the following values set the Adminstration role 
    if (",ADMIN,".indexOf(sTitleCode) >-1 ) {
        sRole += ",A";
    }       

    // the following values set the IT role 
    if (",IT,".indexOf(sTitleCode) >-1 ) {
        sRole += ",I";
    }

    // the following values set the FS role 
    if (",FS,".indexOf(sTitleCode) >-1 ) {
        sRole += ",FS";
    }
   
    if (sRole == "") {
        return null;
    } else {
        return sRole + ",";
    }
}

function AddBBOSLicenseBlock() 
{   
    var sPrimaryName = "&nbsp;";

    sSQL = "SELECT ItemCodeDesc FROM PRService WHERE prse_Primary = 'Y' AND prse_HQID=" + recCompany("comp_PRHQID"); 
    recPrimary = eWare.CreateQueryObj(sSQL);
    recPrimary.SelectSQL();
    if (!recPrimary.eof) {
        sPrimaryName = recPrimary("ItemCodeDesc");
    }

    sSQL = "SELECT prod_code, prod_PRWebAccessLevel, cast(capt_US AS varchar(100)) AS WebAccessDescription, ISNULL(SUM(QuantityOrdered), 0) As OrderedCount, ISNULL(AssignedCount, 0) As AssignedCount, prod_productfamilyid " +
             "FROM NewProduct WITH (NOLOCK) " +
                  "INNER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'prwu_AccessLevel' and capt_Code = prod_PRWebAccessLevel  " +
                  "LEFT OUTER JOIN PRService ON prod_code = prse_ServiceCode AND prse_HQID = " + recCompany("comp_PRHQID") + " " +
                  "LEFT OUTER JOIN (SELECT prwu_HQID, prwu_ServiceCode, COUNT(1) As AssignedCount " +
					                 "FROM PRWebUser WITH (NOLOCK) " +
					                "WHERE prwu_ServiceCode IS NOT NULL " +
					               "GROUP BY prwu_HQID, prwu_ServiceCode) T1 ON prod_code = prwu_ServiceCode and prwu_HQID = " + recCompany("comp_PRHQID") + " " +
            "WHERE prod_productfamilyid IN (6,14) " +
              "AND prod_IndustryTypeCode LIKE '%" + recCompany("comp_PRIndustryType") + "%' " +
         "GROUP BY prod_code, prod_PRWebAccessLevel, cast(capt_US AS varchar(100)), AssignedCount, prod_PRSequence, prod_productfamilyid " +
           "ORDER BY prod_PRSequence";

    var sServiceCreation = "";
    sServiceCreation = "\toService = new Service(); oService.init('None', 0, 'Disabled Access', 9999, 0000, false); arrServices[arrServices.length] = oService;\n";

    if (recCompany("comp_PRHasITAAccess") == "Y") {
        sServiceCreation += "\toService = new Service(); oService.init('ITALIC', 100, '" + eWare.GetTrans("prwu_AccessLevel", "100") + "', 9999, 0000, false); arrServices[arrServices.length] = oService;\n";
    }

    var additionalLicensesDesc = new Array();
    var additionalLicenseAccessMax = new Array();
    var assignedLicenses = new Array();
    var additionalLicenseIndex = 0;

    recServices = eWare.CreateQueryObj(sSQL);
    recServices.SelectSQL();
    while (!recServices.eof){

        var trialDesc = "";
        var isTrial = "false";
        if (recServices("prod_productfamilyid")  == 14) {
            trialDesc = "Trial ";
            var isTrial = "true";
        }

        sServiceCreation += "\toService = new Service(); oService.init('" + recServices("prod_code") + "', " + recServices("prod_PRWebAccessLevel") + ", '" + trialDesc + recServices("WebAccessDescription") + "', " + recServices("OrderedCount") + ", " + recServices("AssignedCount") + ", " + isTrial + "); arrServices[arrServices.length] = oService;\n";

        var nAccessLevel = parseInt(recServices("prod_PRWebAccessLevel"));
        var quantity = parseInt(recServices("OrderedCount"));
        var assigned = parseInt(recServices("AssignedCount"));

        additionalLicensesDesc[additionalLicenseIndex] = trialDesc + recServices("WebAccessDescription")
        additionalLicenseAccessMax[additionalLicenseIndex] = quantity;
        assignedLicenses[additionalLicenseIndex] = assigned;
        additionalLicenseIndex++;

        recServices.NextRecord();
    }

    // 
    // Create the Company Web Access Settings Block
    //
    blkWebAccess = eWare.GetBlock("Content");

    sContent = createAccpacBlockHeader("WebAccess", "Company BBOS Access Settings");
    sContent += "<table class=\"CONTENT\" width=\"100%\" style=\"padding:10px\">" ;
    sContent += "<tr ID=\"tr_WebAccess\">";
    sContent += "<td valign=\"top\" width=\"400px\"><span class=\"VIEWBOXCAPTION\">Primary Membership:</span><br/><span id=\"spanPrimary\" class=\"VIEWBOX\">"+sPrimaryName+"</span></td>";
    sContent += "</tr>";

    sContent += "<tr class=CONTENT >";
    for (var i=0; i<additionalLicensesDesc.length; i++) {
        if(additionalLicenseAccessMax[i] > 0)
        {
            sContent += "<td valign=\"top\" width=\"400px\"><span class=\"VIEWBOXCAPTION\">Maximum " + additionalLicensesDesc[i] + " Users:</span><br/><span class=\"VIEWBOX\">" + additionalLicenseAccessMax[i] + "</span></td>";
            sContent += "<td valign=\"top\" width=\"400px\"><span class=\"VIEWBOXCAPTION\">Assigned " + additionalLicensesDesc[i] + " Users:</span><br/><span class=\"VIEWBOX\">" + assignedLicenses[i] + "</span></td>";
            if(additionalLicenseAccessMax[i] > assignedLicenses[i])
            {
                sContent += "<td valign=\"top\" width=\"400px\"><span class=\"VIEWBOXCAPTION\">Assign BBOS License:</span><br/><span class=\"VIEWBOX\"><input type=\"checkbox\" class=\"EDIT\"></input></span></td>";
            }
        }
    
        if ((i+1)%3 == 0) {
            sContent += "</tr><tr>";
        }
    }
    sContent += "</tr>";
    sContent += "</table>";
    sContent += createAccpacBlockFooter();
    blkWebAccess.contents = sContent;
    blkContainer.AddBlock(blkWebAccess);
} 

function AddCreditSheetBlock(changeDefault)
{   
    blkCSItem = eWare.GetBlock("Content");
    sContent = createAccpacBlockHeader("CreditSheetItem", "Credit Sheet Item");

    sContent += "<table class=\"CONTENT\" width=\"100%\" style=\"padding:10px\" " ;
        sContent += "<tr ID=\"tr_CreditSheetItem\">";
            sContent += "<td valign=\"top\" width=\"600px\"><span class=\"VIEWBOXCAPTION\">Change</span><br/><span id=\"spanCS\" class=\"VIEWBOX\"><input type=\"text\" id=\"txtCSChange\" class=\"EDIT\" style=\"width:90%\" value=\" " + changeDefault + " \"></input></span></td>";
        sContent += "</tr>";
    sContent += "</table>";

    sContent += createAccpacBlockFooter();
    blkCSItem.contents = sContent;
    blkContainer.AddBlock(blkCSItem);
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
<!-- #include file="CompanyFooters.asp" -->