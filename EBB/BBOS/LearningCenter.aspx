<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="LearningCenter.aspx.cs" Inherits="PRCo.BBOS.UI.Web.LearningCenter" MaintainScrollPositionOnPostback="true" %>
<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PublicationArticles" Src="UserControls/PublicationArticles.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="TSI.Utils" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function postStdValidation() {
            szMsg = IsValidDateRange(txtDateFrom, txtDateTo);
            if (szMsg != "") {
                displayErrorMessage(szMsg);
                return false;
            }
            return true;
        }
    </script>
    <style>
        .main-content-old {
            width: 100%;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="col-lg-10 col-md-9 col-sm-8 col-xs-12">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><% =Resources.Global.SearchLearningCenterArticles %></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <div class="row">
                        <div class="col-md-12">
                            <asp:Panel ID="pnlKeyWords" runat="server">
                                <div class="row">
                                    <div class="col-md-3">
                                        <asp:Label CssClass="clr_blu" for="<%= txtKeyWords.ClientID%>" runat="server"><% =Resources.Global.KeyWords %>:</asp:Label>
                                    </div>
                                    <div class="col-md-7">
                                        <asp:TextBox ID="txtKeyWords" runat="server" CssClass="form-control" />
                                    </div>
                                </div>
                            </asp:Panel>

                            <div class="row mar_top_5">
                                <div class="col-md-3">
                                    <asp:Label CssClass="clr_blu" for="<%= txtDateFrom.ClientID%>" runat="server"><% =Resources.Global.DateRange %>:</asp:Label>
                                </div>
                                <div class="col-md-9 form-inline">
                                    <asp:TextBox ID="txtDateFrom" Columns="10" CssClass="form-control" tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" runat="server" />
                                    <cc1:CalendarExtender runat="server" ID="ceDateFrom" TargetControlID="txtDateFrom" />
                                    <asp:Label ID="lblThrough" CssClass="clr_blu" Text="<%$ Resources:Global, through %>" runat="server" />
                                    <asp:TextBox ID="txtDateTo" Columns="10" CssClass="form-control" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" runat="server" />
                                    <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtDateTo" />
                                </div>
                            </div>

                            <div class="row text-left mar_top">
                                <div class="col-md-9 offset-md-3">
                                    <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSearchOnClick">
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Search %>" />
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="bntClear" runat="server" CssClass="btn gray_btn" OnClick="btnClearOnClick">
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearCriteria %>" />
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mar_top_10">
                <div class="col-md-12 form-inline">
                    <asp:Label ID="lblRecordCount" runat="server" CssClass="RecordCnt" Visible="false" />
                    <span id="pnlRecordCnt" runat="server" visible="false">
                        <span class="RecordCnt" id="lblSelectedCount"></span>
                    </span>
                </div>
            </div>

            <div class="row" id="rowArticles" runat="server" visible="false">
                <div class="col-md-12">
                    <hr />
                </div>
                <div class="col-md-12">
                    <bbos:PublicationArticles ID="ucPublicationArticles" runat="server" DisplayReadMore="false" HideDate="true" />
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4 col-xs-12 nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="LearningCenter" MaxAdCount="4" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>

    <!-- Start Debugging Data -->
    <table id="tblDebug" visible="false" runat="server" width="100%">
        <tr>
            <td colspan="2">
                <i>SQL Returned:</i><br />
                <asp:Label ID="lblSQL" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <i>Parameters Returned:</i>
                <br />
                <asp:Label ID="lblParameters" runat="server"></asp:Label>
                <hr />
            </td>
        </tr>
    </table>
    <!-- End -->
</asp:Content>
