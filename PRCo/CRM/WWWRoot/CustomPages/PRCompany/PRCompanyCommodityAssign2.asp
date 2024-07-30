<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%

    doPage();

    function doPage() {
        var sSID = String(Request.Querystring("SID"));
        var sURL = eWare.URL("PRCompany/PRCompanyCommodityAssignContent2.aspx")+"&CompanyID=" + comp_companyid + "&UID=" + user_userid + "&SID=" + sSID
        var blkCommodity = eWare.GetBlock('Content');
        blkCommodity.contents = '<iframe ID="ifrmCommodity" FRAMEBORDER="0" MARGINHEIGHT="0" NORESIZE SCROLLING="AUTO" style="height:3000px;width:95%;border:none;" src="'+sURL +'"></iframe>';

        var blkContainer = eWare.GetBlock('container');
        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddBlock(blkCommodity);
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
    }
%>
<script type="text/javascript">
    document.getElementById("ewareHiddenTable").style.display="none";
</script>
<!-- #include file="CompanyFooters.asp" -->