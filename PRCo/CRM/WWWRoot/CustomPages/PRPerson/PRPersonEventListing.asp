<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="PersonIdInclude.asp" -->
<%
    var sSecurityGroups = sDefaultPersonSecurity;

    var sAddNewPage = "PRPerson/PRPersonEvent.asp";
    var sNewCaption = "New Person Event";

    lstMain = eWare.GetBlock("PRPersonEventGrid");
    var f_value = new String(Request.QueryString("F"));
    if (isEmpty(f_value))
    {
        f_value = "PRCompany/PRPersonSummary.asp";
    }

    lstMain.prevURL = eWare.URL(f_value);;

    blkContainer = eWare.GetBlock('container');
    blkContainer.AddBlock(lstMain);
    blkContainer.DisplayButton(Button_Default) = false;
    if (isUserInGroup(sSecurityGroups))
        blkContainer.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRPerson/PRPersonEvent.asp")));

    if (!isEmpty(pers_personid)) 
    {
        eWare.AddContent(blkContainer.Execute("prpe_PersonId=" + pers_personid));
    }

    Response.Write(eWare.GetPage('Person'));

%>
<!-- #include file ="../RedirectTopContent.asp" -->
