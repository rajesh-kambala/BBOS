<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
	doPage();
%>
<script type="text/javascript" language="javascript" runat="server">
function doPage()
{
    sBuffer = "";
    
    Response.Expires=0 
    Response.ExpiresAbsolute="July 9,1998 17:30:00"

    var checkaction = Request.QueryString("check");
    var hqid = Request.QueryString("HQID");
    var companyid = Request.QueryString("CompanyID");

    // Don't see the need for this line of code, commenting out for now.
    // var recCompany = eWare.FindRecord("Company", "comp_CompanyId=" + companyid);
        
    // note that this is set up to handle multiple actions in the future
    if (checkaction == "useserviceunits")
    {
        var personid = Request("PersonID");
        var sSQL = "Select pers_FullName, peli_PRUseServiceUnits from vPRListPerson where peli_CompanyId=" + companyid+
                    " and pers_PersonId=" + personid;
        recQuery = eWare.CreateQueryObj(sSQL);
        recQuery.SelectSql();
        if (recQuery("peli_PRUseServiceUnits") != 'Y')
            sBuffer = "N";
        else
            sBuffer = "Y";
    } else if (checkaction == "hasavailableunits") {
        var productid = Request("ProductID");
        var pricinglistid = Request("PricingListID");
        var sHasUnitsSQL = "Select dbo.ufn_HasAvailableUnits("+ hqid + ","+ productid + ", " + pricinglistid +") as nHasUnits ";

        recQuery = eWare.CreateQueryObj(sHasUnitsSQL);
        recQuery.SelectSql();
        if (recQuery("nHasUnits") == 0)
            sBuffer = "N";
        else
            sBuffer = "Y";
    }
	Response.Write(sBuffer);
}
</script>