<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

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
function doPage(){
    // because Sage listing are the primary source prior to this
    // page's navigation, comp_companyid is passed but key1 is never set.
    // This is problematic when the user clicks another tab or leaves this
    // screen by using anything but the action buttons on the right side.
    if (sURL.indexOf("Key1=") == -1){
        var sNewURL = changeKey(sURL, "Key1", comp_companyid);
        Response.Redirect(sNewURL);
        return;
    }

    //bDebug = true;
    DEBUG ("URL: " + sURL);
    DEBUG ("Mode: " + eWare.Mode);
    DEBUG ("Company ID: " + comp_companyid);
//    eWare.SetContext("Company", comp_companyid);
    var sSecurityGroups = "1,2,4,5,6,8,10";

    // we are cheating on this form and allowing the "Close Exceptions" button
    // to tie to a form submit, thus sending the eWare.Mode to a value of 99.
    // Therefore, if the mode is 99, perform the sql to close all exceptions for this
    // company and then redirect the page back to itself to reset to the mode to 0.
    if (eWare.Mode == 99)
    {
        sSQL = "Update PRExceptionQueue SET preq_Status = 'C', preq_ClosedById = " + user_userid + ", preq_UpdatedBy = " + user_userid +
                    ", preq_DateClosed = getDate(), preq_UpdatedDate = getDate(), preq_TimeStamp = getDate() " +
                    " WHERE preq_DateClosed is null and preq_CompanyId = " + comp_companyid
        qryCloseExceptions = eWare.CreateQueryObj(sSQL);
        qryCloseExceptions.ExecSQL();
        eWare.Mode = 0;
    }
    // now, continue on in view mode.
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    var recOpens = eWare.FindRecord('vPRCompanyExceptionQueue', "preq_DateClosed is null AND preq_CompanyId = "+ comp_companyid);
    DEBUG(recOpens.RecordCount );
    var blkList = null;
    if (recOpens.RecordCount == 0 ){
        blkList = eWare.GetBlock("Content");
        blkList.contents = createAccpacEmptyGridBlock("PRCompanyExceptionGrid_Open", 
                            "No Open Exceptions", "No Open Exceptions Exist");
    } else {
        blkList = eWare.GetBlock("PRCompanyExceptionGrid_Open");
        blkList.prevURL = sURL;
        blkList.PadBottom = false;
    }
    blkContainer.AddBlock(blkList);

    sClosedExceptionsURL = eWare.URL("PRCompany/PRCompanyExceptionListing_Closed.asp") + "&comp_companyid=" + comp_companyid + "&T=Company&Capt=Trade+Activity";

    sContinueUrl = eWare.URL("PRCompany/PRCompanyTradeActivityListing.asp") + "&T=Company&Capt=Trade+Activity";
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));

    if (recOpens.RecordCount > 0)
        blkContainer.AddButton(eWare.Button("Close Exceptions", "save.gif", 
            "javascript:if (confirm('Are you sure you want to close ALL open exceptions?')) {" + 
            "document.EntryForm.em.value='99';document.EntryForm.submit();}"));

    sMyCRMUrl = eWare.URL("PRExceptionQueue/PRExceptionQueueListing.asp")
    sMyCRMUrl = removeKey(sMyCRMUrl, "Key0");
    sMyCRMUrl += "&Key0=4&Key4=46";
    blkContainer.AddButton(eWare.Button("My CRM", "../Menu/menubut_MyDesk.gif", sMyCRMUrl));

     
    var blkClosed = eWare.GetBlock('Content');
    // let's try doing a better job of sizing the frame height
    var recClosed = eWare.FindRecord('vPRCompanyExceptionQueue', "preq_DateClosed is not null AND preq_CompanyId = "+ comp_companyid);
    var blkList = null;
    var sHeight = "64"; // 32 for the block tab, 18 for the header, 18 for the comment row
    var nRecordCount = recClosed.RecordCount ;
    DEBUG ("Record Count: " + nRecordCount );
    if (nRecordCount > 0 ){
        var nRows = nRecordCount;
        nUserValue = 10; // the default
        recUset = eWare.FindRecord("UserSettings", "uset_Key = 'NSET_GridSize' and uset_userid = " +user_userid);
        if (!isEmpty(recUset("Uset_Value"))){
            nUserValue = recUset("Uset_Value") ;
        }
        if (nUserValue  < nRows)
            nRows = nUserValue ;
        DEBUG ("nRows: " + nRows);
        sHeight = 32 + 17 + (nRows * 17);
    }      
   DEBUG ("Height: " + sHeight);      
//sHeight = 400;    
    blkClosed.contents = '<IFRAME ID="ifrmClosedContent" FRAMEBORDER="0" MARGINHEIGHT="0" ' +
            'MARGINWIDTH="0" NORESIZE WIDTH=100% SCROLLING="NO" HEIGHT="' + sHeight + '" src="'+sClosedExceptionsURL +'"></IFrame>';
    blkContainer.AddBlock(blkClosed);

    if (!isEmpty(comp_companyid)) {
        DEBUG(comp_companyid)
       eWare.AddContent(blkContainer.Execute(recOpens));
    }

    Response.Write(eWare.GetPage('Company'));

}
doPage();
%>
<!-- #include file ="CompanyFooters.asp" -->
