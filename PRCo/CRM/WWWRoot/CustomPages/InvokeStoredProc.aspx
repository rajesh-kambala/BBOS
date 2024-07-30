<%@ Page language="c#" AutoEventWireUp="True" 
                       Codebehind="InvokeStoredProc.aspx.cs" 
                       Inherits="PRCo.BBS.CRM.StoredProcRedirect" 
                       %>

<%
    string SID = Request.Params.Get("SID");
    //Response.Write (Request.ServerVariables.Get("URL") + "?" + Request.QueryString); 
%>                      
<HTML>
    <HEAD>
        <LINK REL="stylesheet" HREF="/<%= sAppName%>/eware.css"/>
        <LINK REL="stylesheet" HREF="/<%= sAppName%>/prco.css"/>
        <title>Processing</title>
    </HEAD>
    <body>
        <asp:Label id="lblMessage" runat="server"></asp:Label>
        <TABLE WIDTH="100%" ID="Table1">
            <TR>
                <TD>&nbsp;</TD>
                <TD WIDTH="99%">
                    <TABLE ID="_icTable" WIDTH="100%">
                        <TR>
                            <TD ID="_icTD">
                                <asp:label id="lblError" runat="server" Font-Bold="True"></asp:label>
                            </TD>
                        </TR>
                    </TABLE>
                </TD>
            </TR>
        </TABLE>
    </body>
</HTML>
