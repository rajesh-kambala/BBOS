<!-- #include file ="..\accpaccrm.js" -->

<%
try 
{
    // check if the save operation has been confirmed
    // if so...
    var customact = new String(Request.Querystring("customact"));
    if (customact.toString() == "confirm")
    {
        Response.Redirect(eWare.URL("PRPACALicense/PRImportPACALicenseFind.asp"));    
    }
    // remove the tab menu at the top of the page
    eWare.setContext("Find");

    if( eWare.Mode != Save ){
        F=Request.QueryString("F");
        if( F == "PRPACALicenseNew.asp" ) eWare.Mode=Edit;
    }

    // in order to process this page, a valid ImportPACALicense must exist on the context
    var pril_ImportPACALicenseId = Session("pril_ImportPACALicenseId");
    if (pril_ImportPACALicenseId == null || pril_ImportPACALicenseId.toString() == 'undefined' || pril_ImportPACALicenseId == '')
    {
	    throw "Existing Import PACA License record is not available.";
    }
    else
    {
        // Once we get the value clean up the session
        //Session.Contents.Remove("pril_ImportPACALicenseId");
    }
    pril_record = eWare.FindRecord("PRImportPACALicense", "pril_ImportPACALicenseId="+pril_ImportPACALicenseId);
    
    
    // these fields will load the summary html below
    sDispTitle="Imported PACA License";

    // Now display the current PACA License record
    Container=eWare.GetBlock("container");
    Entry=eWare.GetBlock("PRPACALicenseNewEntry");
    Entry.Title="PACA License";
    Container.AddBlock(Entry);
    Container.DisplayButton(1)=false;

    var Id = new String(Request.Querystring("prpa_PACALicenseId"));
    if (Id.toString() == 'undefined') {
        Id = new String(Request.Querystring("Key58"));
    }

    var sBBId = "";
    if (Id != 0) {
        record = eWare.FindRecord("PRPACALicense", "prpa_PACALicenseId="+Id);
        sBBId = record.prpa_CompanyId;

        var sCancelLink = eWare.URL("PRPACALicense/PRImportPACALicenseSummary.asp")+"&pril_ImportPACALicenseId=" + pril_ImportPACALicenseId;

        eWare.AddContent(Container.Execute(record));
%>
<FORM NAME="frmConfirm" >
<input id="pril_ImportPACALicenseId" name="pril_ImportPACALicenseId" type="hidden" value="<%= pril_ImportPACALicenseId %>">
<input id="prpa_PACALicenseId" NAME="prpa_PACALicenseId"type="hidden" value="<%= Id %>" >

<TABLE WIDTH=100% ID="Table1">
<TR>
    <TD>&nbsp;</TD>
    <TD WIDTH=99%><SPAN ID=WkRl></SPAN>
        <TABLE ID="Table2"><TR><TD HEIGHT=10></TD></TR></TABLE>
        <TABLE WIDTH=100% COLS=2 ID="Table3">
            <TR><TD WIDTH=90% VALIGN=TOP>

<!-- Use this tabled structure to ensure that the spacing for the caption is the same as blocks-->
<TABLE WIDTH=100% CELLPADDING=0 CELLSPACING=0 BORDER=0 ID="Table4">
<TR>
    <TD WIDTH=90%>
        <TABLE CELLPADDING=5 WIDTH=100% BORDER=0 ID="Table5">
        <TR>
            <TD VALIGN=TOP>
                <TABLE WIDTH=100% CELLPADDING=0 CELLSPACING=0 BORDER=0 ID="Table6">
                <TR>
                <TD WIDTH=95%>
                    <TABLE WIDTH=100% CELLPADDING=0 CELLSPACING=0 BORDER=0 ID="Table7">
                    <TR>
                        <TD>Confirm that the Imported PACA License will become the current license for BB Id <%= sBBId %>.  The existing PACA License will be available as a history record.</TD>

                    </TR>
                    </TABLE>
                </TD>
                <TD>&nbsp;</TD>
                </TR>
                </TABLE>
            </TD>
        </TR>
        </TABLE>
    </TD>
    <TD>
    
    </TD>
    <!-- Add the button actions -->
    <TD VALIGN=TOP WIDTH=5%>
        <TABLE ID="Table8">
            <TR>
                <TD CLASS=Button>
                    <TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 ID="Table9">
                        <TR>
                            <TD>
                                <A CLASS=ButtonItem ONFOCUS="if (event && event.altKey) click();" ACCESSKEY="C" HREF="javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='customact=confirm';document.EntryForm.action=x;document.EntryForm.submit();">
                                <IMG SRC="/<%= sInstallName %>/img/Buttons/Save.gif" BORDER=0 ALIGN=MIDDLE></A>
                            </TD>
                            <TD>&nbsp;</TD>
                            <TD>
                                <A CLASS=ButtonItem ONFOCUS="if (event && event.altKey) click();" ACCESSKEY="C" HREF="javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='customact=confirm';document.EntryForm.action=x;document.EntryForm.submit();">
                                <FONT STYLE="text-decoration:underline">C</FONT>onfirm</A>
                            </TD>
                        </TR>
                    </TABLE>
                </TD>
            </TR>
            <TR>
                <TD CLASS=Button>
                    <TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 ID="Table10">
                        <TR>
                            <TD><A CLASS=ButtonItem HREF="<%= sCancelLink %>">
                                <IMG SRC="/<%= sInstallName %>/img/Buttons/cancel.gif" BORDER=0 ALIGN=MIDDLE></A>
                            </TD>
                            <TD>&nbsp;</TD>
                            <TD><A CLASS=ButtonItem HREF="<%= sCancelLink %>">Cancel</A>
                            </TD>                
                        </TR>
                    </TABLE>
                </TD>
            </TR>
        </TABLE>
    </TD>    
</TR>
</TABLE>

<!-- #include file ="PRImportPACALicenseSummaryTable.asp" -->

            </TD></TR>
        </TABLE>
    </TD>
</TR>
</TABLE>
</FORM>
<%


        Response.Write(eWare.GetPage());
    }
}	
catch(exception) 
{
    // Error Handling
    Response.Write("<table class=content><tr><td colspan=2 class=gridhead><b>"+ exception + "</b></td></tr></table>");
    if ((new String(exception.name)).toString() != 'undefined')
    {
        Response.Write("<table class=content><tr><td class=row1><b>Error Name:</b> </td><td class=row1>"+exception.name+"</td></tr>")
        Response.Write("<tr><td class=row1><b>Error Number:</b> </td><td class=row1>"+exception.number+"</td></tr>")
        Response.Write("<tr><td class=row2><b>Error Description:</b></td><td class=row2>"+exception.description+"</td></tr></table>");
    }
}

%>
