<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCOGeneral.asp" -->
<%
    var key1 = "";

    key1 = getIdValue("prss_ClaimantCompanyId");
    Response.Write("<br/>prss_ClaimantCompanyId: " + key1);
    if (key1 == "-1") {
        key1 = getIdValue("prss_RespondentCompanyId");
        Response.Write("<br/>prss_RespondentCompanyId: " + key1);
    }
    if (key1 == "-1") {
        key1 = getIdValue("prss_3rdPartyCompanyId");
        Response.Write("<br/>prss_3rdPartyCompanyId: " + key1);
    }


    var redirectUrl = eWare.URL("PRCompany/PRCompanySummary.asp");
            
    // depending upon where this link came from the url can be a mess
    // simply it and resend
    redirectUrl = changeKey(redirectUrl, "Key0", "1");
    redirectUrl = changeKey(redirectUrl, "Key1", key1);
    redirectUrl = removeKey(redirectUrl, "Key2");
    redirectUrl = removeKey(redirectUrl, "Key4");
    redirectUrl = removeKey(redirectUrl, "Key5");



    //Response.Write("<p>" + redirectUrl);
    Response.Redirect(redirectUrl);
%>