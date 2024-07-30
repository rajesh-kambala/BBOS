<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LimitadoSearch.aspx.cs" Inherits="PRCo.BBOS.UI.Web.LimitadoSearch" MasterPageFile="~/BBOS.Master" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <link rel="stylesheet" href="Content/ideal-image-slider.css" />
    <link rel="stylesheet" href="Content/ideal-image-slider_default.css" />
    <style>
        #slider {
            max-width: 1150px;
            margin: 15px auto;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div id="slider" class="hidden">
        <asp:Literal ID="microslider" runat="server" />
    </div>
    <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server">
        <div class="row nomargin panels_box">
            <div class="col-md-3 col-sm-3 col-xs-12 nopadding">
                <%--Search Criteria--%>
                <div class="col-md-12 nopadding">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <uc1:CompanySearchCriteriaControl ID="ucCompanySearchCriteriaControl" runat="server" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="txtCompanyName" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlFruit" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlVegetable" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlHerb" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlCountry" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlState" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>

                <%--Buttons--%>
                <div class="col-md-12 nopadding">
                    <div class="search_crit">
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Search %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearCriteria %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <div class="col-md-9 col-sm-8 col-xs-12">
                <div class="panel panel-primary" id="pnlCriteria" runat="server">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <%=Resources.Global.CompanySearchCriteria %>
                        </h4>
                    </div>
                    <div class="row panel-body nomargin pad10 id=pnlCriteriaDetails gray_bg">
                        <div class="col-md-12 nopadding">
                            <div class="form-group">
                                <div class="row mar_top_5">
                                    <asp:Label CssClass="clr_blu col-md-3" for="<%= txtCompanyName.ClientID%>" runat="server"><%= Resources.Global.CompanyName %>:</asp:Label>
                                    <div class="col-md-5">
                                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control" AutoPostBack="True" />
                                    </div>
                                    <div class="col-md-1 text-left">
                                        <a id="popCompanyName" runat="server" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                            <img src="images/info_sm.png" /></a>
                                    </div>
                                </div>

                                <div class="row mar_top_10">
                                    <asp:Label CssClass="clr_blu col-md-3" for="<%= lblFruit.ClientID%>" runat="server"><%= Resources.Global.Commodity %>:</asp:Label>
                                    <div class="col-md-3">
                                        <asp:Label ID="lblFruit" runat="server" CssClass="bold"><%= Resources.Global.Fruit %>:</asp:Label>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="lblVegetable" runat="server" CssClass="bold"><%= Resources.Global.Vegetable %>:</asp:Label>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="lblHerb" runat="server" CssClass="bold"><%= Resources.Global.Herb %>:</asp:Label>
                                    </div>
                                </div>
                                <div class="row mar_top_5">
                                    <div class="col-md-3 offset-md-3">
                                        <asp:DropDownList ID="ddlFruit" runat="server" CssClass="form-control" AutoPostBack="true" />
                                    </div>
                                    <div class="col-md-3">
                                        <asp:DropDownList ID="ddlVegetable" runat="server" CssClass="form-control" AutoPostBack="true" />
                                    </div>
                                    <div class="col-md-3">
                                        <asp:DropDownList ID="ddlHerb" runat="server" CssClass="form-control" AutoPostBack="true" />
                                    </div>
                                </div>

                                <div class="row mar_top_10">
                                    <asp:Label CssClass="clr_blu col-md-3" for="<%= ddlCountry.ClientID%>" runat="server"><%= Resources.Global.Country %>:</asp:Label>
                                    <div class="col-md-3">
                                        <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCountry_SelectedIndexChanged" />
                                    </div>
                                </div>

                                <div class="row mar_top_10">
                                    <asp:Label CssClass="clr_blu col-md-3" for="<%= ddlStateProvince.ClientID%>" runat="server"><%= Resources.Global.State %>:</asp:Label>
                                    <div class="col-md-3">
                                        <asp:DropDownList ID="ddlState" runat="server" CssClass="form-control" AutoPostBack="true" />
                                    </div>
                                </div>

                                <div class="row">
                                    <p>
                                       <% =GetSearchButtonMsg() %>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <div id="suspendedModal" class="modal fade">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><span style="font-size: x-large;"><b>Membership Service Suspended</b></span></h5>
                </div>
                <div class="modal-body">
                    <p style="font-size: x-large"><%=Resources.Global.MembershipServiceSuspended %></p>
                    <p>&nbsp;</p>
                    <p>
                        <asp:LinkButton ID="btnLogoff" runat="server" CssClass="btn gray_btn" OnClick="btnLogoff_Click" Width="100%">
    		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Logoff %>" />
                        </asp:LinkButton>
                    </p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript" src="en-us/javascript/ideal-image-slider.js"></script>
	<script type="text/javascript" src="en-us/javascript/iis-bullet-nav.min.js"></script>

    <script type="text/javascript">
        function ToggleInitialState() {
        }

        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');

        jQuery('.numbersOnly').keyup(function () {
            replaceNonDigits(this);
        });
    </script>

    <script type="text/javascript">
        var slider = new IdealImageSlider.Slider({
            selector: '#slider',
            effect: 'fade',
            interval: 5000
        });
        slider.addBulletNav();
        slider.start();
        $("#slider").removeClass("hidden");
	</script>

    <script type="text/javascript">
        $(".iis-slide").each(function () {
            var href = $(this).data('href');
            $(this).attr({
                href: href,
                target: '_top'
            });
        });
	</script>

    <script type="text/javascript">
        $(".messages").removeClass("explicitlink");


        $(document).ready(function () {
        });
    </script>
</asp:Content>
