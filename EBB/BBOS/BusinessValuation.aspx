<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="BusinessValuation.aspx.cs" Inherits="PRCo.BBOS.UI.Web.BusinessValuation" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Panel ID="pnlSubmitBusinessValuation" runat="server" Visible="true">
        <asp:Literal ID="businessValuationText" runat="server" />

        <p class="px-4 pb-3">
            <asp:Literal ID="businessValuationText_CurrentYearReceived" runat="server" />
            <br /><br />
            <asp:LinkButton
                type="button"
                ID="btnPay"
                runat="server" Visible="false"
                CssClass="bbsButton bbsButton-primary" OnClick="btnPay_Click">
                <span class="msicon notranslate">search</span>
                <span><asp:Literal runat="server" Text="<%$Resources:Global, PayForBusinessValuation%>" /></span>
            </asp:LinkButton>
        </p>

        <asp:Panel ID="pnlUploads" runat="server" CssClass="my-4">
            <div class="row py-1">
                <div class="col-3 offset-3">
                    <div class="clr_blu"><% =Resources.Global.MostRecentIncomeStatement %>:</div>
                </div>
                <div class="col-6">
                    <asp:FileUpload ID="fuIncomeStatement" ClientIDMode="Static" runat="server" Width="100%" />
                </div>
            </div>
            <div class="row py-1">
                <div class="col-3 offset-3">
                    <div class="clr_blu"><% =Resources.Global.MostRecentBalanceSheet %>:</div>
                </div>
                <div class="col-6">
                    <asp:FileUpload ID="fuBalanceSheet" ClientIDMode="Static" runat="server" Width="100%" />
                </div>
            </div>
            <div class="row py-1">
                <div class="col-3 offset-3">
                    <div class="clr_blu"><% =Resources.Global.OtherDocOptional %>:</div>
                </div>
                <div class="col-6">
                    <asp:FileUpload ID="fuOtherDoc" ClientIDMode="Static" runat="server" Width="100%" />
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlButtons" runat="server" CssClass="row pb-4">
            <div class="col-6 offset-6">
                <div class="btn-group">
                    <asp:LinkButton
                        type="button"
                        ID="btnUpload"
                        runat="server"
                        CssClass="bbsButton bbsButton-primary" OnClick="btnUpload_Click">
                            <span class="msicon notranslate">search</span>
                            <span><asp:Literal runat="server" Text="<%$Resources:Global, Upload%>" /></span>
                    </asp:LinkButton>
                    &nbsp;
                    <asp:LinkButton
                        type="button"
                        ID="btnCancel"
                        runat="server"
                        CssClass="bbsButton"
                        OnClick="btnCancel_Click">
                            <span class="msicon notranslate">search</span>
                            <span><asp:Literal runat="server" Text="<%$Resources:Global, Cancel%>" /></span>
                    </asp:LinkButton>
                </div>
            </div>
        </asp:Panel>

        <asp:Panel id="pnlDownloadLink" runat="server" Visible="false">
            <div class="px-4 pb-3">
                <%=Resources.Global.BusinessValuationComplete_Part1%>&nbsp;<%=Resources.Global.BusinessValuationComplete_Part2 %>&nbsp;<a href="<%=PageConstants.MEMBERSHIP_SUMMARY %>" class="explicitlink"><%=Resources.Global.ManageMembership %></a>&nbsp;<%=Resources.Global.BusinessValuationComplete_Part3%>
            </div>
        </asp:Panel>
    </asp:Panel>

    <asp:Panel ID="pnlThankYou" runat="server" Visible="false" CssClass="row pb-5">
        <asp:Literal ID="businessValuationThankYou" runat="server" />
    </asp:Panel>
</asp:Content>
