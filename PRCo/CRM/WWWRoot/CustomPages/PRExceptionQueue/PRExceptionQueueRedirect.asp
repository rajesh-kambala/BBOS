<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
function doPage()
{
    /*  This page will simply determine the source of the PRExceptionQueue record and
     *  redirect to the appropriate entity property page
     */
    var sErrorAction = eWare.Url(F) 

    // Determine the exception to redirect
    preq_exceptionqueueid = getIdValue("preq_ExceptionQueueId");
    if (preq_exceptionqueueid == "-1"){
        Response.Redirect(sErrorAction);
        return;
    }

    recExceptionQueue = eWare.FindRecord("PRExceptionQueue", "preq_ExceptionQueueId="+preq_exceptionqueueid);

    // dynamically redirect to the exception entity
    nReportId = recExceptionQueue("preq_TradeReportId");
    nCompanyId = recExceptionQueue("preq_CompanyId");
    if (recExceptionQueue("preq_Type") == "TES")
    {    
        sReportUrl = eWare.URL("PRCompany/PRCompanyTradeReport.asp") ;
        // removing and resetting these values will hopefully prevent accpac 
        // navigation issues when jumping to the company and coming back to MY CRM
        sReportUrl = removeKey(sReportUrl, "Key0");
        sReportUrl = removeKey(sReportUrl, "F");
        sReportUrl = removeKey(sReportUrl, "J");
        Response.Redirect(sReportUrl + "&Key0=1&Key1="+ nCompanyId + "&prtr_TradeReportId="+nReportId);
    } else if (recExceptionQueue("preq_Type") == "BBScore")
    {
        sReportUrl = eWare.URL("PRCompany/PRBBScore.asp") ;
        // removing and resetting these values will hopefully prevent accpac 
        // navigation issues when jumping to the company and coming back to MY CRM
        sReportUrl = removeKey(sReportUrl, "Key0");
        sReportUrl = removeKey(sReportUrl, "F");
        sReportUrl = removeKey(sReportUrl, "J");
        Response.Redirect(sReportUrl + "&Key0=1&Key1="+ nCompanyId + "&prbs_BBScoreId="+nReportId);
    } else if (recExceptionQueue("preq_Type") == "AR")
    {
        sReportUrl = eWare.URL("PRCompany/PRCompanyARAgingOnListing.asp") ;
        // removing and resetting these values will hopefully prevent accpac 
        // navigation issues when jumping to the company and coming back to MY CRM
        recARAgingDetail = eWare.FindRecord("PRARAgingDetail", "praad_ARAgingDetailId="+nReportId);
        sReportUrl = removeKey(sReportUrl, "Key0");
        sReportUrl = removeKey(sReportUrl, "F");
        sReportUrl = removeKey(sReportUrl, "J");
        Response.Redirect(sReportUrl + "&Key0=1&Key1="+ nCompanyId + "&praa_ARAgingId="+recARAgingDetail("praad_ARAgingId"));
    }
}
doPage();

%>
