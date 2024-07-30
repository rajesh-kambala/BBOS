<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRCoWorkflowTransition.aspx.cs" Inherits="PRCo.BBS.CRM.PRCoWorkflowTransition" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
    <HEAD>
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
</html>
