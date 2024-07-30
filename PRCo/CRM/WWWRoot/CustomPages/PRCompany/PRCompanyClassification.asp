<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%

    doPage();


function doPage() {

    var sURL = eWare.URL("PRCompany/PRCompanyClassificationContent.asp")+"&comp_companyid=" + comp_companyid + "&prc2_companyclassificationid=" + getIdValue("prc2_companyclassificationid" );
    var blkClassifications = eWare.GetBlock('Content');
    blkClassifications.contents = '<iframe ID="ifrmClassification" FRAMEBORDER="0" MARGINHEIGHT="0" ' +
        ' NORESIZE SCROLLING="AUTO" style="height:800px;width:95%;border:none;" src="'+sURL +'"></iframe>';

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkClassifications);
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));
}
%>
<!-- #include file="CompanyFooters.asp" -->