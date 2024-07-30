<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsClassifications.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsClassifications" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls\CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Classifications" Src="UserControls/Classifications.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CommoditiesList" Src="UserControls/CommoditiesList.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <link href="Content/print.min.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/print.min.js"></script>

    <script type="text/javascript">
    </script>
    <style>
        td, td.text-left {text-align: left;}
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

        <div class="row nomargin">
            <div class="col-lg-5 col-md-5 col-sm-7 nopadding_l">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
            </div>
            <div class="col-lg-7 col-md-7 col-sm-5 nopadding">
                <asp:Panel ID="pnlCertifications" runat="server" CssClass="box_left">
                    <div class="row nomargin panels_box">
                        <div class="col-md-12 nopadding">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h4 class="blu_tab"><%= Resources.Global.Certifications %></h4>
                                </div>
                                <div class="panel-body nomargin pad10">
                                    <div class="row">
                                        <div class="col-md-12 form-inline">
                                            <span class="clr_blu"><%= Resources.Global.CertifiedOrganic %>:</span>
                                            <asp:Literal ID="litOrganic" runat="server" />
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12 form-inline">
                                            <span class="clr_blu"><%= Resources.Global.FoodSafetyCertified %>:</span>
                                            <asp:Literal ID="litFoodSafetyCertified" runat="server" />
                                        </div>
                                    </div>
                                    <div class="row mar_top_5" id="rowSelfReported" runat="server" visible="false">
                                        <div class="col-md-12">
                                            <asp:Literal runat="server" Text="<%$ Resources:Global,CertsSelfReportedMsg %>" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <%--License Numbers--%>
                <div class="row nomargin panels_box" id="LicensesDIV" runat="server">
                    <div class="col-md-12 nopadding">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h4 class="blu_tab"><%= Resources.Global.Licenses %></h4>
                            </div>
                            <div class="panel-body pad5">
                                <asp:GridView ID="gvLicenses"
                                    AllowSorting="false"
                                    runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover tab_bdy"
                                    GridLines="None">
                                    <Columns>
                                        <asp:BoundField HeaderText="<%$ Resources:Global, LicenseType %>" HeaderStyle-CssClass="text-nowrap" DataField="Name" />
                                        <asp:BoundField HeaderText="<%$ Resources:Global, LicenseNumber %>" HeaderStyle-CssClass="text-nowrap" DataField="License" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
                
                <%--Volume--%>
                <div class="row nomargin panels_box">
                    <div class="col-md-12 nopadding">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h4 class="blu_tab"><%= Resources.Global.Volume %></h4>
                            </div>
                            <div class="panel-body pad5">
                                <asp:GridView ID="gvVolume"
                                    AllowSorting="false"
                                    runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover tab_bdy"
                                    GridLines="None">
                                    <Columns>
                                        <asp:BoundField HeaderText="<%$ Resources:Global, Volume %>" HeaderStyle-CssClass="text-nowrap" DataField="VolumeName" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>

                <asp:UpdatePanel ID="updpnlEmployees" runat="server">
                    <ContentTemplate>
                        <%--Num Employees--%>
                        <div class="row nomargin panels_box">
                            <div class="col-md-12 nopadding">
                                <div class="panel panel-primary">
                                    <div class="panel-heading">
                                        <h4 class="blu_tab"><%= Resources.Global.Employees %></h4>
                                    </div>
                                    <div class="panel-body pad5">
                                        <div class="row nomargin_lr mar_top_10">
                                            <div class="col-xs-4 bold"><%= Resources.Global.NumberofEmployees %>:</div>
                                            <div class="col-xs-8">
                                                <asp:Literal ID="litNumberofEmployees" runat="server" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>

            <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />

            <%--Buttons row--%>
            <div class="row nomargin_lr mar_top">
                <div class="col-md-8 offset-md-4 mar_top_10">
                    <div class="row nomargin">
                        <div class="col-md-12 search_crit">
                            <span id="subMenuTabClassifications" runat="server">
                                <a href="#Classifications" class="btn gray_btn btnWidthStd" style="width: 150px;">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<%=Resources.Global.Classifications %>
                                </a>
                            </span>

                            <span id="subMenuTabCommodities" runat="server">
                                <a href="#CommoditiesList" class="btn gray_btn btnWidthStd" style="width: 150px;">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<%=Resources.Global.Commodities %>
                                </a>
                            </span>

                            <span id="subMenuTabProductsServicesSpecies" runat="server">
                                <a href="#ProductsServicesSpecies" class="btn gray_btn btnWidthStd" style="width: 210px;">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<%=Resources.Global.ProductsServicesSpecies %>
                                </a>
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <%--Classifications--%>
            <bbos:Classifications ID="ucClassifications" runat="server" />

            <%--Commodities--%>
            <bbos:CommoditiesList ID="ucCommoditiesList" runat="server" />

            <%--Affiliations--%>
            <div class="col-md-12 text-center nopadding_lr">
                <div class="col-md-4 nopadding_l">
                    <asp:UpdatePanel ID="updpnlProductProvided" runat="server">
                        <ContentTemplate>
                            <h4 class="blu_tab">
                                <asp:Label CssClass="text-center" Text="<%$ Resources:Global, Products %>" runat="server" />
                            </h4>

                            <div class="pad5">
                                <asp:GridView ID="gvProductProvided"
                                    AllowSorting="true"
                                    runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover tab_bdy"
                                    GridLines="None"
                                    OnSorting="GridView_Sorting"
                                    OnRowDataBound="GridView_RowDataBound">

                                    <Columns>
                                        <asp:BoundField HeaderText="<%$ Resources:Global, Product %>" HeaderStyle-CssClass="text-nowrap explicitlink" DataField="prprpr_Name" SortExpression="prprpr_Name" ItemStyle-CssClass="text-left" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>

                <div class="col-md-4">
                    <a name="ProductsServicesSpecies" class="anchor"></a>
                    <asp:UpdatePanel ID="updpnlServiceProvided" runat="server">
                        <ContentTemplate>
                            <h4 class="blu_tab">
                                <asp:Label CssClass="text-center" Text="<%$ Resources:Global, Services %>" runat="server" />
                            </h4>

                            <div class="pad5">
                                <asp:GridView ID="gvServiceProvided"
                                    AllowSorting="true"
                                    runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover tab_bdy"
                                    GridLines="None"
                                    OnSorting="GridView_Sorting"
                                    OnRowDataBound="GridView_RowDataBound">

                                    <Columns>
                                        <asp:BoundField HeaderText="<%$ Resources:Global, Service %>" HeaderStyle-CssClass="text-nowrap explicitlink" DataField="prserpr_Name" SortExpression="prserpr_Name" ItemStyle-CssClass="text-left" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>

                <div class="col-md-4 nopadding_r">
                    <asp:UpdatePanel ID="updpnlSpecie" runat="server">
                        <ContentTemplate>
                            <h4 class="blu_tab">
                                <asp:Label CssClass="text-center" Text="<%$ Resources:Global, Species %>" runat="server" />
                            </h4>
                            <div class="pad5">
                                <asp:GridView ID="gvSpecie"
                                    AllowSorting="true"
                                    runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover tab_bdy"
                                    GridLines="None"
                                    OnSorting="GridView_Sorting"
                                    OnRowDataBound="GridView_RowDataBound">

                                    <Columns>
                                        <asp:BoundField HeaderText="<%$ Resources:Global, Specie %>" HeaderStyle-CssClass="text-nowrap explicitlink" DataField="prspc_Name" SortExpression="prspc_Name" ItemStyle-CssClass="text-left" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
</script>
</asp:Content>
