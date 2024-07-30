<%@ Page language="c#" %>

<%
    NameValueCollection appSettings = ConfigurationManager.AppSettings;
    string sAppName = appSettings["AppName"];

    string SID = Request.Params.Get("SID");
    //Response.Write (Request.ServerVariables.Get("URL") + "?" + Request.QueryString); 

    Exception prco_Exception = (Exception)Session.Contents["prco_exception"];
    string Description = prco_Exception.Message;
    string continueUrl = (string)Session.Contents["prco_exception_continueurl"];
    string szAdditionalInfo = (string)Session.Contents["prco_additional_info"];
%>

<HTML>
    <HEAD>
        <LINK REL="stylesheet" HREF="/<%= sAppName%>/eware.css"/>
        <LINK REL="stylesheet" HREF="/<%= sAppName%>/prco.css"/>
        <title>Error</title>
    </HEAD>
    <body>
    
    <TABLE WIDTH="100%" ID="Table1">
    <TR>
        <TD>&nbsp;</TD>
        <TD style="width:99%;">
        
    <TABLE WIDTH="100%" ID="Table2" border="0">
        <TBODY>
            <TR>
                <TD style="width:80%;" VALIGN="top">

    
		<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 >
		<TR>
		<TD>
		<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 >
			<TR>
				<TD VALIGN=BOTTOM><IMG SRC="../img/backgrounds/paneleftcorner.jpg" HSPACE=0 BORDER=0 ALIGN=TOP></TD>
				<TD NOWRAP=true WIDTH=10% CLASS=PANEREPEAT>Application Error</TD>
				<TD VALIGN=BOTTOM><IMG SRC="../img/backgrounds/panerightcorner.gif" HSPACE=0 BORDER=0 ALIGN=TOP></TD>
				<TD ALIGN=BOTTOM CLASS=TABLETOPBORDER>&nbsp;</TD>
				<TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD>
				<TD ALIGN=BOTTOM WIDTH=90% CLASS=TABLETOPBORDER >&nbsp;</TD>
			</TR>
	        <tr>
				<td class=tableborderleft>&nbsp;</td>
				<td colspan=3 class=VIEWBOX><b>There has been an error</b></td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td>
			</tr>
		    <tr>
				<td class=tableborderleft>&nbsp;</td>
				<td class=VIEWBOX><span class=VIEWBOXCAPTION>Error Description:</span></td>
				<td class=viewbox>&nbsp;</td><td width="100%" class=VIEWBOX><%=Description%></td>
				<td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td>
			</tr>
		    <tr>
				<td class=tableborderleft>&nbsp;</td>
				<td class=VIEWBOX valign=top><span class=VIEWBOXCAPTION>Stack Trace:</span></td>
				<td class=viewbox>&nbsp;</td><td width="100%" class=VIEWBOX><pre><%=prco_Exception.StackTrace%></pre></td>
				<td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td>
			</tr>
		    <tr>
				<td class=tableborderleft>&nbsp;</td>
				<td class=VIEWBOX valign=top><span class=VIEWBOXCAPTION>Additional Info:</span></td>
				<td class=viewbox>&nbsp;</td><td width="100%" class=VIEWBOX><pre><%=szAdditionalInfo%></pre></td>
				<td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td>
			</tr>
			<tr HEIGHT=1>
				<td WIDTH=1px colspan=6 class=tableborderbottom></td>
			</tr>
		</TABLE>
		</TD>
		<TD >&nbsp;</TD>
		<TD VALIGN=TOP WIDTH=5%>
			<TABLE>
				<TR>
					<TD CLASS=Button>
						<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0>
							<TR>
								<TD><A CLASS=ButtonItem ACCESSKEY="o" HREF="<%=continueUrl%>"><IMG SRC="/CRM/img/Buttons/continue.gif" BORDER=0 ALIGN=MIDDLE></A></TD>
								<TD>&nbsp;</TD>
								<TD><A CLASS=ButtonItem ACCESSKEY="o" HREF="<%=continueUrl%>">C<FONT STYLE="text-decoration:underline">o</FONT>ntinue</A></TD>
							</TR>
						</TABLE>
					</TD>
				</TR>
			</TABLE>
		</TD>
		</TR>
		</TABLE>

        </td>                                        

        </tr>
        </table>
    </TD>
    </TR>
</TABLE>

    </body>
</HTML>


