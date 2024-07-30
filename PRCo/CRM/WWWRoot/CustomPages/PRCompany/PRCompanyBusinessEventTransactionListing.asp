<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
    var prbe_BusinessEventId = getIdValue("prbe_BusinessEventId");
    // indicate that this is new

    List = eWare.GetBlock("CompanyPRTransactionGrid");
    List.prevURL = sURL;

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(List);

    if (prbe_BusinessEventId != "-1")
    {
        sContinueAction = eWare.Url("PRCompany/PRCompanyBusinessEvent.asp")+ "&prbe_BusinessEventId="+ prbe_BusinessEventId;
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sContinueAction));

        eWare.AddContent(blkContainer.Execute("prtx_BusinessEventId=" + prbe_BusinessEventId));
    }
    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->
