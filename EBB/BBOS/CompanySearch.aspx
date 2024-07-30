<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompanySearch.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearch" MasterPageFile="~/BBOS.Master" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
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
                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtCompanyName" EventName="TextChanged" />
                            <%--<asp:AsyncPostBackTrigger ControlID="txtBBNum" EventName="TextChanged" />--%>
                            <asp:AsyncPostBackTrigger ControlID="ddlCompanyType" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlListingStatus" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtPhoneAreaCode" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtPhone" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtFaxAreaCode" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtFaxNumber" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="chkFaxNotNull" EventName="CheckedChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtEmail" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="chkEmailNotNull" EventName="CheckedChanged" />
                            <asp:AsyncPostBackTrigger ControlID="chkNewListingsOnly" EventName="CheckedChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlNewListingRange" EventName="SelectedIndexChanged" />
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
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearThisCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearAllCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearAllCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSaveSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SaveSearchCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="btn gray_btn" OnClientClick="return confirmOverrwrite('LoadSearch')" OnClick="btnLoadSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, LoadSearchCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnNewSearch" runat="server" CssClass="btn gray_btn" OnClientClick="return confirmOverrwrite('NewSearch')" OnClick="btnNewSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, NewSearch %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <div class="col-md-9 col-sm-8 col-xs-12">
                <asp:Panel ID="pnlIndustryType" runat="server">
                    <div class="row nomargin">
                        <div class="col-md-12 nopadding ind_typ gray_bg mar_top_16">
                            <div class="row">
                                <div class="col-md-3 text-nowrap">
                                    <span class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true" data-bs-title="<%=Resources.Global.IndustryTypeText %>">help
                                    </span>

                                    <span class="fontbold"><strong class=""><%= Resources.Global.IndustryType %>:</strong></span>
                                </div>
                                <div class="col-md-9">
                                    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                        <ContentTemplate>
                                            <asp:RadioButtonList ID="rblIndustryType" runat="server" RepeatColumns="3" AutoPostBack="True"
                                                Font-Size="Smaller" />
                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <div class="panel panel-primary" id="pnlCriteria" runat="server">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <%=Resources.Global.CompanySearchCriteria %>
                        </h4>
                    </div>
                    <div class="row panel-body nomargin pad10 id=pnlCriteriaDetails gray_bg">
                        <div class="col-md-12 nopadding">
                            <div class="form-group">
                                <div class="row" id="trNewListings" runat="server">
                                    <asp:Label ID="lblNewListingsOnly" CssClass="clr_blu col-md-3 mar_top_2_imp" for="<%= chkNewListingsOnly.ClientID%>" runat="server"><%= Resources.Global.NewListingsOnly %>:</asp:Label>

                                    <div class="col-md-6 form-inline">
                                        <asp:CheckBox ID="chkNewListingsOnly" runat="server" AutoPostBack="True" CssClass="nomargin_top" />
                                        <span id="NewListingRange">
                                            <asp:Label ID="lblListedInPast" runat="server"><%= Resources.Global.ListedInPast %></asp:Label>&nbsp;
                                            <asp:DropDownList ID="ddlNewListingRange" runat="server" CssClass="form-control" AutoPostBack="True" Width="100px" />
                                        </span>
                                    </div>
                                </div>

                                <div class="row mar_top_5">
                                    <asp:Label CssClass="clr_blu col-md-3" for="<%= txtCompanyName.ClientID%>" runat="server"><%= Resources.Global.CompanyName %>:</asp:Label>
                                    <div class="col-md-5">
                                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control" AutoPostBack="True" />
                                    </div>
                                    <div class="col-md-1 text-left">
                                        <span class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true" data-bs-title="<%=Resources.Global.WhatIsThisCompanyName %>">help
                                        </span>
                                    </div>
                                </div>

                                <div class="row mar_top_5" id="trType" runat="server">
                                    <asp:Label CssClass="clr_blu col-md-3" for="<%= txtBddlCompanyTypeBNum.ClientID%>" runat="server"><%= Resources.Global.Type %>:</asp:Label>
                                    <div class="col-md-2">
                                        <asp:DropDownList ID="ddlCompanyType" runat="server" CssClass="form-control" AutoPostBack="True" />
                                    </div>
                                </div>

                                <div class="row mar_top_5" id="trListingStatus" runat="server">
                                    <asp:Label ID="lblListingStatus" CssClass="clr_blu col-md-3" for="<%= ddlListingStatus.ClientID%>" runat="server"><%= Resources.Global.ListingStatus %>:</asp:Label>
                                    <div class="col-md-3">
                                        <asp:DropDownList ID="ddlListingStatus" runat="server" CssClass="form-control" AutoPostBack="True" />
                                    </div>
                                </div>

                                <div class="row mar_top_5" runat="server">
                                    <asp:Label ID="lblPhone" CssClass="clr_blu col-md-3" for="<%= txtPhoneAreaCode.ClientID%>" runat="server"><%= (Resources.Global.CompanyPhone).Replace("\"", "") %>:</asp:Label>
                                    <div class="col-md-5">
                                        <div class="input-group">
                                            <asp:TextBox ID="txtPhoneAreaCode" runat="server" CssClass="form-control" AutoPostBack="True" Columns="5" />
                                            <div class="input-group-addon">&nbsp;-&nbsp;</div>
                                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" AutoPostBack="True" Columns="19" />
                                        </div>
                                    </div>
                                </div>

                                <div class="row mar_top_5" id="trFax" runat="server">
                                    <asp:Label ID="lblFax" CssClass="clr_blu col-md-3" for="<%= txtFaxAreaCode.ClientID%>" runat="server"><%= Resources.Global.CompanyFax %>:</asp:Label>
                                    <div class="col-md-5">
                                        <div class="input-group">
                                            <asp:HiddenField ID="hdnFaxSecurityEnabled" runat="server" />
                                            <asp:TextBox ID="txtFaxAreaCode" runat="server" CssClass="form-control" Columns="5" AutoPostBack="True" />
                                            <div class="input-group-addon">&nbsp;-&nbsp;</div>
                                            <asp:TextBox ID="txtFaxNumber" runat="server" CssClass="form-control" AutoPostBack="True" Columns="19" />
                                        </div>
                                    </div>
                                    <div class="col-md-4 label_top">
                                        <asp:CheckBox ID="chkFaxNotNull" runat="server" AutoPostBack="True" />
                                        <asp:Label ID="lblMustHaveFax" runat="server"><%= Resources.Global.MustHaveFax %></asp:Label>
                                    </div>
                                </div>

                                <div class="row mar_top_5" runat="server">
                                    <asp:Label ID="lblEmail" CssClass="clr_blu col-md-3" for="<%= txtEmail.ClientID%>" runat="server"><%= Resources.Global.CompanyEmail %>:</asp:Label>

                                    <div class="col-md-5">
                                        <asp:HiddenField ID="hdnEmailSecurityEnabled" runat="server" />
                                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" AutoPostBack="True" />
                                    </div>
                                    <div class="col-md-4 label_top">
                                        <asp:CheckBox ID="chkEmailNotNull" runat="server" AutoPostBack="True" />
                                        <asp:Label ID="lblMustHaveEmail" runat="server"><%= Resources.Global.MustHaveEmail %></asp:Label>
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
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        function ToggleInitialState() {
            if (document.getElementById('<%= hdnFaxSecurityEnabled.ClientID %>').value != 0) {
                ToggleMustHave(document.forms[0].<%= chkFaxNotNull.ClientID %>, 'Fax');
            }

            if (document.getElementById('<%= hdnEmailSecurityEnabled.ClientID %>').value != 0) {
                ToggleMustHave(document.forms[0].<%= chkEmailNotNull.ClientID %>, 'Email');
            }
            ToggleNewListing(document.forms[0].<%= chkNewListingsOnly.ClientID%>);
        }

        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');

        jQuery('.numbersOnly').keyup(function () {
            replaceNonDigits(this);
        });
    </script>
</asp:Content>
