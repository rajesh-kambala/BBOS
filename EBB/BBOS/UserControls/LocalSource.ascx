<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LocalSource.ascx.cs" Inherits="PRCo.BBOS.UI.Web.LocalSource" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%--<asp:Label ID="hidCompanyID" Visible="false" runat="server" />
<asp:Label ID="hidRatingID" Visible="false" runat="server" />--%>

<asp:Panel ID="pnlLocalSource1" runat="server" Visible="false">
    <div class="cmp_nme">
        <h4 class="blu_tab">
            <%= Resources.Global.LocalSourceTitle %>
        </h4>
    </div>

    <div class="tab_bdy dtl_tab">
        <div class="row bor_bottom nomargin pad10" id="divLocalSource" runat="server">
            <div class="row bor_bottom nomargin pad10">
                <div class="col-md-6 col-sm-6 col-xs-12 nopadding">
                    <p class="clr_blu">
                        <asp:Literal runat="server" Text="<%$Resources:Global, AlsoOperates%>" />:
                    </p>
                </div>

                <div class="col-md-6 col-sm-6 col-xs-12 nopadding">
                    <p class="nopadding">
                        <asp:Literal ID="AlsoOperates" runat="server" />
                    </p>
                </div>
            </div>

            <div class="row bor_bottom nomargin pad10">
                <div class="col-md-6 col-sm-6 col-xs-12 nopadding">
                    <p class="clr_blu">
                        <asp:Literal runat="server" Text="<%$Resources:Global, GrowsOrganic%>" />:
                    </p>
                </div>

                <div class="col-md-6 col-sm-6 col-xs-12  nopadding">
                    <p class="nopadding">
                        <asp:Literal ID="CertifiedOrganic" runat="server" />
                    </p>
                </div>
            </div>

            <div class="row bor_bottom nomargin pad10">
                <div class="col-md-6 col-sm-6 col-xs-12 nopadding">
                    <p class="clr_blu">
                        <asp:Literal runat="server" Text="<%$Resources:Global, TotalAcres%>" />:
                    </p>
                </div>

                <div class="col-md-6 col-sm-6 col-xs-12  nopadding">
                    <p class="nopadding">
                        <asp:Literal ID="TotalAcres" runat="server" />
                    </p>
                </div>
            </div>

            <div class="row bor_bottom nomargin pad10" id="trLocalSource" visible="true" runat="server">
                <div class="col-md-12 nopadding">
                    <div class="col-md-12 clr_blu text-center">
                        <%=Resources.Global.LocalSourceDataProvidedBy %>
                        <br />
                        <a href="https://www.meistermedia.com" target="_blank" style="font-weight: bold; color: green;">Meister Media Worldwide, Inc.</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Panel>
<asp:Panel ID="pnlLocalSource2" runat="server" Visible="false" CssClass="accordion-item">
    <div class="accordion-header">
        <button
            class="accordion-button"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#flush_collapseLocalSource"
            aria-expanded="false"
            aria-controls="flush_collapseLocalSource">
            <h5><%=Resources.Global.LocalSourceData %></h5>
        </button>
    </div>
    <div
        id="flush_collapseLocalSource"
        class="accordion-collapse collapse show tw-p-4">
        <div class="bbs-card">
            <!-- Local Source Info -->
            <div
                class="bbs-card-body no-padding"
                id="contentMain_ucLocalSource_pnlLocalSourceData">
                <table class="table">
                    <tbody>
                        <!-- Blue Book Credit Score -->
                        <tr>
                            <td><%=Resources.Global.AlsoOperates%>:</td>
                            <td>
                                <asp:Literal ID="AlsoOperates2" runat="server" /></td>
                        </tr>
                        <tr>
                            <td><%=Resources.Global.GrowsOrganic%>:</td>
                            <td>
                                <asp:Literal ID="CertifiedOrganic2" runat="server" /></td>
                        </tr>
                        <tr>
                            <td><%=Resources.Global.TotalAcres%>:</td>
                            <td>
                                <asp:Literal ID="TotalAcres2" runat="server" /></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <!-- Alerts -->
            <div class="bbs-alert alert-info tw-mt-4" role="alert">
                <div class="alert-title">
                    <span class="msicon notranslate">info</span>
                    <span><%=Resources.Global.LocalSourceDataProvidedBy %>
                        <a href="https://www.meistermedia.com" class="link" target="_blank">Meister Media Worldwide, Inc.</a>
                    </span>
                </div>
            </div>
        </div>
    </div>
</asp:Panel>
