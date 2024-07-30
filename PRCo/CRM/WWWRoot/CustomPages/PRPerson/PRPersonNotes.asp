<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->
<%
    // load the url with any info that the standard accpac screen with modified javascript handling will need.
    var sAccpacNotesUrl = eWare.URL(186);
    sAccpacNotesUrl = sAccpacNotesUrl.substr(0, sAccpacNotesUrl.indexOf("?")+1);
    sAccpacNotesUrl = sAccpacNotesUrl + Request.QueryString +"&shouldredirect=0&trx="+iTrxStatus;
    sAccpacNotesUrl = sAccpacNotesUrl + "&lockUsername=" + recTrxUser.user_FirstName + "&nbsp;" + recTrxUser.user_LastName;
    sAccpacNotesUrl = removeKey(sAccpacNotesUrl, "T");
    
    Response.Redirect(sAccpacNotesUrl);
%>
