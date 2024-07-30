<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Alerts.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Alerts" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function ToggleCalendar() {
            // not rendered on the page if viewing results
            if (window.<%=ddlDateRange.ClientID%> == null) {
                return;
            }

            if (<%=ddlDateRange.ClientID%>.options[<%=ddlDateRange.ClientID%>.selectedIndex].value == "") {
                <%=txtDateFrom.ClientID%>.disabled = false;
                <%=txtDateTo.ClientID%>.disabled = false;
            } else {
                <%=txtDateFrom.ClientID%>.disabled = true;
                <%=txtDateTo.ClientID%>.disabled = true;
            }
        }

        function postStdValidation() {
            var szMsg = IsValidDateRange(<%=txtDateFrom.ClientID%>, <%=txtDateTo.ClientID%>);
            if (szMsg != "") {
                displayErrorMessage(szMsg);
                return false;
            }
            return true;
        }

        (function () {
            // Execute ToggleCalendar on load.
            if (window.addEventListener) {
                window.addEventListener("load", ToggleCalendar, false); // preferably standards compliant (firefox, etc)
            } else if (window.attachEvent) {
                window.attachEvent("onload", ToggleCalendar); // otherwise it's ie
            }
        })();
    </script>
    <style>
        .content-container div.row a.gray_btn {
            display: inline-block;
            width: 170px;
            margin-right: 10px;
            margin-bottom: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server">
        <div class="row nomargin panels_box">
            <asp:Panel ID="pnlCriteria" runat="server">
                <div class="col-md-12 col-sm-12 col-sx-12">
                    <div class="panel panel-primary" runat="server">
                        <div class="panel-heading">
                            <h4 class="blu_tab nomargin_top">
                                <%=Resources.Global.SearchAlerts %>
                            </h4>
                        </div>
                        <div class="row panel-body nomargin pad10 id=pnlCriteriaDetails">
                            <div class="col-md-12 nopadding">

                                <div class="form-group">
                                    <div class="row label_top" id="trDateRange1" runat="server">
                                        <asp:Label CssClass="clr_blu col-md-4" for="<%= ddlDateRange.ClientID%>" runat="server"><%= Resources.Global.DateRange %>:</asp:Label>
                                        <div class="col-md-8">
                                            <asp:DropDownList CssClass="form-control" ID="ddlDateRange" runat="server" />
                                        </div>
                                    </div>

                                    <div class="row label_top" id="trDateRange2" runat="server">
                                        <div class="col-md-8 offset-md-2">
                                            <div class="input-group">
                                                <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-control" Columns="12" MaxLength="10"
                                                    tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" />
                                                <cc1:CalendarExtender runat="server" ID="ceDateFrom" TargetControlID="txtDateFrom" />

                                                <span class="input-group-addon">-</span>

                                                <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-control" Columns="12" MaxLength="10"
                                                    tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" />
                                                
                                                <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
<%--                                <div class="form-group">
                                    <div class="row label_top" id="Div1" runat="server">
                                        <asp:Label CssClass="clr_blu col-md-2" for="<%= ddlSortOption.ClientID%>" runat="server"><%= Resources.Global.SortOption %>:</asp:Label>
                                        <div class="col-md-4">
                                            <asp:DropDownList CssClass="form-control" ID="ddlSortOption" runat="server" />
                                        </div>
                                    </div>
                                </div>--%>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-12 col-sm-12 col-xs-12 nopadding">
                    <%--Buttons--%>
                    <div class="col-md-12 nopadding">
                        <div class="search_crit">
                            <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSearchOnClick">
                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSearch %>" />
                            </asp:LinkButton>

                            <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearCriteria_Click">
                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearCriteria %>" />
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlResults" runat="server">
        <asp:Label ID="lblResults" runat="server" />
    </asp:Panel>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>