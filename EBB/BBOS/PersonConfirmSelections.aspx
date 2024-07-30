<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PersonConfirmSelections.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonConfirmSelections" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
    <style>
        input[type=radio], label {
            width: auto!important;
        }
        .content-container div.row a.gray_btn {
            display: inline;
            width: auto;
            margin-right: 10px;
            margin-bottom: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidTriggerPage" runat="server" />

    <div class="col-md-12">
        <div class="row Title" style="margin-bottom: 15px;">
            <asp:Literal ID="litHeaderText" runat="server" />
        </div>

        <div class="row">
            <div class="row nomargin panels_box">
                <div class="row nomargin">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <div class="col-md-4">
                                <div class="panel panel-primary">
                                    <div class="panel-heading">
                                        <h4 class="blu_tab">
                                            <asp:Literal ID="litSelect" runat="server" />
                                        </h4>
                                    </div>
                                    <div class="panel-body nomargin pad10 space">
                                        <div class="row nomargin" id="trExport" runat="server">
                                            <asp:RadioButton ID="rbExport" GroupName="rbExport" Text="<%$Resources:Global, ContactExport %>" runat="server" OnCheckedChanged="rbExportType_CheckedChanged" AutoPostBack="true" />
                                        </div>
                                        <div class="row nomargin" id="trReport" runat="server">
                                            <asp:RadioButton ID="rbReport" GroupName="rbExport" Text="<%$Resources:Global, ContactReport %>" runat="server" OnCheckedChanged="rbExportType_CheckedChanged" AutoPostBack="true" />
                                            </tr>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <asp:Panel ID="fsExportOptions" runat="server">
                                <div class="col-md-4">
                                    <div class="panel panel-primary">
                                        <div class="panel-heading">
                                            <h4 class="blu_tab"><%= Resources.Global.ContactFormatOptions%></h4>
                                        </div>
                                        <div class="panel-body nomargin pad10">
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <asp:Label ID="Label1" CssClass="clr_blu" for="<%= ddlExportFormat.ClientID%>" runat="server"><%= Resources.Global.ContactExportFormat %>:</asp:Label>
                                                </div>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="ddlExportFormat" runat="server" CssClass="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </asp:Panel>

                            <asp:Panel ID="fsReportOptions" runat="server">
                                <div class="col-md-5">
                                    <div class="panel panel-primary">
                                        <div class="panel-heading">
                                            <h4 class="blu_tab"><%= Resources.Global.ReportOptions%></h4>
                                        </div>
                                        <div class="panel-body nomargin pad10">
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <asp:Label ID="lblCustomHeaderText" CssClass="clr_blu" for="<%= txtCustomHeader.ClientID%>" runat="server"><%= Resources.Global.CustomHeaderText %>:</asp:Label>
                                                </div>
                                                <div class="col-md-8">
                                                    <asp:TextBox ID="txtCustomHeader" runat="server" Columns="30" CssClass="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </asp:Panel>

                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="rbExport" EventName="CheckedChanged" />
                            <asp:AsyncPostBackTrigger ControlID="rbReport" EventName="CheckedChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </div>

    <asp:Panel ID="Panel1" Style="margin-top: 15px; margin-bottom: 15px; margin-left: auto; margin-right: auto; width: 800px; text-align: left;" Visible="false" runat="server">
        <asp:Literal ID="Literal1" runat="server" Text="<%$Resources:Global, LocalSourceDataProvidedByMeisterNotIncluded %>" />
    </asp:Panel>

    <div class="row"></div>

    <%--Buttons--%>
    <div class="row nomargin_lr text-left mar_top20">
        <asp:LinkButton ID="btnGenerateReport" runat="server" CssClass="btn gray_btn" OnClick="btnGenerateReport_Click">
	        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, GenerateReport %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnGenerateExport" runat="server" CssClass="btn gray_btn" OnClick="btnGenerateExport_Click">
	        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, GenerateExport %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnReviseSelections" runat="server" CssClass="btn gray_btn" OnClick="btnReviseSelections_Click">
    	    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ReviseSelections %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
    	    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Cancel %>" />
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlMsg" Style="margin-top: 15px; margin-bottom: 15px; margin-left: auto; margin-right: auto; width: 800px; text-align: left;" Visible="false" runat="server">
        <asp:Literal ID="litMsg" runat="server" Text="<%$Resources:Global, LocalSourceDataProvidedByMeisterNotLicensed %>" />
    </asp:Panel>

    <div class="row mar_top">
        <asp:Label ID="lblRecordCount" runat="server" class="RecordCnt" />
    </div>

    <div class="clearfix"></div>

    <asp:GridView ID="gvSelectedPersons"
        AllowSorting="true"
        runat="server"
        AutoGenerateColumns="false"
        CssClass="sch_result table table-striped table-hover"
        GridLines="none"
        OnSorting="GridView_Sorting"
        OnRowDataBound="GridView_RowDataBound"
        SortField="LastName">
        
        <Columns>
            <asp:TemplateField HeaderStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, PersonName %>" SortExpression="LastName">
                <ItemTemplate>
                    <%# GetPersonDataForCell((int)Eval("PersonId"), (string)Eval("PersonName"), false, SOURCE_TABLE_PERSON)%>
                </ItemTemplate>
            </asp:TemplateField>

            <%--BBNumber Column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap  vertical-align-top" ItemStyle-CssClass="text-left">
                <ItemTemplate>
                    <%# GetBBNumbers((int)Eval("PersonID"))%>
                </ItemTemplate>
            </asp:TemplateField>

            <%--Icons Column--%>
            <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                <ItemTemplate>
                    <%# GetCompanyNames((int)Eval("PersonID"), "Person", true, false)%>
                </ItemTemplate>
            </asp:TemplateField>

            <%--Company Name column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="text-nowrap">
                <ItemTemplate>
                    <%# GetCompanyNames((int)Eval("PersonID"), "Person", false, true)%>
                    <%--<asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>--%>
                </ItemTemplate>
            </asp:TemplateField>

            <%--Location column--%>
            <asp:TemplateField HeaderText="<%$ Resources:Global, Location %>" HeaderStyle-CssClass="text-nowrap">
                <ItemTemplate>
                    <%# GetCompanyLocations((int)Eval("PersonID"), "Person")%>
                    <%--<asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>--%>
                </ItemTemplate>
            </asp:TemplateField>

            <%--<asp:TemplateField HeaderStyle-CssClass="text-nowrap">
                <HeaderTemplate>
                    <table cellpadding="0" cellspacing="0" style="margin: 0; padding: 0; text-align: left">
                        <tr>
                            <td style="width: 75px; margin: 0px; padding: 0 0 0 10px; text-align: center;"><% =Resources.Global.BBNumber%></td>
                            <td style="width: 350px; margin: 0px; padding: 0 0 0 10px;"><% =Resources.Global.CompanyName%></td>
                            <td style="width: 350px; margin: 0px; padding: 0 0 0 10px;"><% =Resources.Global.Location%></td>
                        </tr>
                    </table>
                </HeaderTemplate>
                <ItemTemplate>
                    <%# GetPersonCompanies((int)Eval("PersonID"))%>
                </ItemTemplate>
            </asp:TemplateField>--%>
        </Columns>
    </asp:GridView>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
