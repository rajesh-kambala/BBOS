<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="LimitadoCompany.aspx.cs" Inherits="PRCo.BBOS.UI.Web.LimitadoCompany" Title="Untitled Page" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetails" Src="UserControls/CompanyDetails.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Classifications" Src="UserControls/Classifications.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Commodities" Src="UserControls/Commodities.ascx" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript" src="Scripts/print.min.js"></script>
    <script type="text/javascript">
        function printpage() {
            window.open('LimitadoCompanyPrint.aspx?CompanyId=<%=hidCompanyID.Text%>&IndustryType=<%=hidIndustryType.Text%>', '_blank');
        }
    </script>
    <style>
        table td {
            text-align: left;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box" id="pAll">
        <div class="col-xs-12">
            <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
            <asp:Label ID="hidRatingID" Visible="false" runat="server" />
            <asp:Label ID="hidIndustryType" Visible="false" runat="server" />

            <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, ListingSummary %>' />

            <div class="row nomargin">
                <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                    <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" LimitadoMode="true" />
                </div>

                <div class="col-lg-7 col-md-7 col-sm-12 nopadding_r mar_top20">
                    <div class="row nomargin text-center">
                        <div class="col-md-4 col-sm-4 col-xs-12">
                            <asp:LinkButton ID="btnPromo1" runat="server" BackColor="#4473c5" ForeColor="White" CssClass="form-control wrap2 dark-on-hover" OnClick="btnPromo1_Click" />
                        </div>
                        <div class="col-md-4 col-sm-4 col-xs-12">
                            <asp:LinkButton ID="btnPromo2" runat="server" BackColor="#6fae00" ForeColor="White" CssClass="form-control wrap2 dark-on-hover" OnClick="btnPromo2_Click" />
                        </div>
                        <div class="col-md-4 col-sm-4 col-xs-12">
                            <asp:LinkButton ID="btnPromo3" runat="server" BackColor="#ffc000" ForeColor="White" CssClass="form-control wrap2 dark-on-hover" OnClick="btnPromo3_Click" />
                        </div>
                    </div>

                    <div class="col-lg-8 col-md-8 col-sm-12 col-xs-12 nopadding">
                        <div class="col4_box padding_lr_15">
                        <div class="cmp_nme">
                            <h4 class="blu_tab">
                                <%=Resources.Global.Alerts %>
                            </h4>
                        </div>
                        <div class="tab_bdy pad10">
                            <div class="row nomargin">
                                <div class="col-md-12 nopadding">
                                    <asp:LinkButton ID="btnAlertAdd" runat="server" CssClass="btn gray_btn" OnClick="btnAlertAdd_Click">
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AddAlert %>" />
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnAlertRemove" runat="server" CssClass="btn gray_btn" OnClick="btnAlertRemove_Click">
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, RemoveAlert %>" />
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnManageAlerts" runat="server" CssClass="btn gray_btn" OnClick="btnManageAlerts_Click">
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ManageAlerts %>" />
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                    </div>
                </div>
            </div>

            <div class="clearfix"></div>

            <div class="row">
                <div class="col-md-4 col-sm-6 col-xs-12 nopadding">
                    <bbos:CompanyDetails ID="ucCompanyDetails" runat="server" Visible="true" Padding="true" LimitadoSimplified="true" />
                    <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="true" customBSClass="col4_box padding_lr_15" />
                </div>

                <div class="col-md-8 col-sm-6 col-xs-12 nopadding">
                    <bbos:Classifications ID="ucClassifications" runat="server" />
                    <bbos:Commodities ID="ucCommodities" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            var newHeight = $("#pCompanyDetailsHeader").height();
            $("#<%=btnPromo1.ClientID%>").height(newHeight);
            $("#<%=btnPromo2.ClientID%>").height(newHeight);
            $("#<%=btnPromo3.ClientID%>").height(newHeight);
        });
    </script>
</asp:Content>
