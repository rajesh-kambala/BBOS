<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%

    doPage();

    function doPage() {
        var sSID = String(Request.Querystring("SID"));
        var sURL = eWare.URL("PRCompany/PRCompanyClassificationAssignContent2.aspx")+"&CompanyID=" + comp_companyid + "&UID=" + user_userid + "&SID=" + sSID
        var blkClassification = eWare.GetBlock('Content');
        blkClassification.contents = '<iframe ID="ifrmClassification" FRAMEBORDER="0" MARGINHEIGHT="0" NORESIZE SCROLLING="AUTO" style="height:3000px;width:95%;border:none;" src="'+sURL +'"></iframe>';

        var blkContainer = eWare.GetBlock('container');
        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddBlock(blkClassification);
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
    }
%>
<script type="text/javascript">
    document.getElementById("ewareHiddenTable").style.display="none";
</script>
<!-- #include file="CompanyFooters.asp" -->