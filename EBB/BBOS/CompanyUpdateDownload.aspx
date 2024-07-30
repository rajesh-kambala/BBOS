<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyUpdateDownload.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyUpdateDownload" MaintainScrollPositionOnPostback="true" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <style>
        img {
            display: inline-block !important;
            padding-right: 15px;
        }
        td a {
            display: inline-block !important;
            position: relative !important;
            top: -5px !important;
            left: -5px !important;
        }
    </style>
    <div class="row">
        <div class="col-md-12">
            <asp:Literal ID="litMsg1" runat="server" />
        </div>
    </div>

    <div class="row">
        <div class="col-md-8 offset-md-2">
            <asp:GridView ID="gvDownloadFiles"
                AllowSorting="false"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="sch_result table table-striped table-hover tab_bdy"
                GridLines="None">
                <Columns>
                    <asp:TemplateField ItemStyle-CssClass="vertical-align-top" HeaderStyle-CssClass="vertical-align-top" HeaderText='<%$ Resources:Global,PostedDate %>'>
                        <ItemTemplate>
                            <%# PageBase.GetStringFromDate(Eval("FileDate"))%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="vertical-align-top" HeaderStyle-CssClass="vertical-align-top" HeaderText='<%$ Resources:Global,FileName %>'>
                        <ItemTemplate>
                            <img src="<%# UIUtils.GetFileIcon((string)Eval("FileName"))%>" /><a href="<%# GetURL(Eval("FileName")) %>" target="_blank"><%# Eval("FileName") %></a>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="vertical-align-top" HeaderStyle-CssClass="vertical-align-top" HeaderText='<%$ Resources:Global,FileSize %>'>
                        <ItemTemplate>
                            <%# Eval("FileSize")%>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <asp:Literal ID="litMsg2" runat="server" />
        </div>
    </div>
</asp:Content>
