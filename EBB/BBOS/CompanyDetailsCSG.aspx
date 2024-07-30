<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsCSG.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsCSG" %>

<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
</script>
<style>
    th.blu_tab, th.blu_tab_center {
        background-color: #235495 !important;
        color: #fff !important;
        margin-top: 0 !important;
        text-align: left;
        padding: 10px 15px;
        font-size: 1.0rem;
        font-weight: bold;
    }
</style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
            </div>

            <div class="col-lg-3 col-md-3 col-sm-12 text-left nopadding_r mar_top20">
                <div class="row">
                    <div class="col-lg-5 col-md-7 col-sm-3 col-xs-4 text-nowrap" style="font-style: italic; font-size: 14px; vertical-align: middle">
                        <%=Resources.Global.DataLicensedProvidedByCSG %>
                    </div>

                    <div class="col-lg-4 col-md-4 offset-md-1 col-sm-8 col-xs-8 text-left">
                        <a href="https://www.chainstoreguide.com" target="_blank">
                            <asp:Image ID="imgCSGLogo" AlternateText="<%$ Resources:Global, CSGLogo %>" Width="124" runat="server"/>
                        </a>
                    </div>
                </div>
                <div class="row mar_top">
                    <div class="col-md-8 clr_blu">
                        <%=Resources.Global.TotalUnits %>:
                    </div>
                    <div class="col-md-4">
                        <asp:Label ID="lblTotalUnits" runat="server" />
                    </div>
                </div>
                <div class="row mar_top_5">
                    <div class="col-md-8 clr_blu">
                        <%=Resources.Global.TotalSellingSquareFootage %>:
                    </div>
                    <div class="col-md-4">
                        <asp:Label ID="lblSquareFootage" runat="server" />
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-12 col-sm-12 nopadding_lr">
                <bbos:Advertisements ID="Advertisement" Title="" PageName="CompanyDetailsCSG.aspx" CampaignType="CSG" runat="server" />
            </div>
        </div>

        <div class="row nomargin_lr mar_top20">
            <div class="col-md-12 nopadding">
                <asp:GridView ID="gvTradeNames"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="none">

                    <Columns>
                        <asp:BoundField HeaderText="<%$ Resources:Global, TradeNames %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap blu_tab h4" DataField="ValueList" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-12 nopadding">
                <asp:GridView ID="gvAreasOfOperations"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="none">

                    <Columns>
                        <asp:BoundField HeaderText="<%$ Resources:Global, AreasOfOperations %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap blu_tab h4" DataField="ValueList" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-12 nopadding">
                    <asp:GridView ID="gvDistributionCenters"
                        AllowSorting="true"
                        runat="server"
                        AutoGenerateColumns="false"
                        CssClass="table table-striped table-hover tab_bdy"
                        GridLines="none">

                        <Columns>
                            <asp:BoundField HeaderText="<%$ Resources:Global, DistributionCenters %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap blu_tab h4" DataField="ValueList" />
                        </Columns>
                    </asp:GridView>
    </div>
    </div>

        <div class="row nomargin">
            <div class="col-md-12 nopadding">
                <div class="cmp_nme">
                    <h4 class="blu_tab"><%=Resources.Global.Contacts %></h4>
                </div>
                <asp:GridView ID="gvContacts"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="None"
                    HeaderStyle-VerticalAlign="Top">
                    <Columns>
                        <asp:BoundField HeaderText="<%$ Resources:Global, ContactName %>" HeaderStyle-CssClass="text-nowrap" DataField="Name" SortExpression="prcsgp_LastName" ItemStyle-CssClass="text-nowrap text-left" />
                        <asp:BoundField HeaderText="<%$ Resources:Global, Title %>" HeaderStyle-CssClass="text-nowrap" DataField="prcsgp_Title" SortExpression="prcsgp_Title" ItemStyle-CssClass="text-nowrap text-left" />
                        <asp:TemplateField HeaderText="<%$ Resources:Global, EmailAddress %>" ItemStyle-CssClass="text-nowrap text-left">
                            <ItemTemplate>
                                <asp:HyperLink runat="server" Text='<%# Eval("prcsgp_Email") %>' NavigateUrl='<%# Eval("prcsgp_Email", "mailto:{0}") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
