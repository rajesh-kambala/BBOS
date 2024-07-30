<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsCompanyUpdates.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsCompanyUpdates" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">

    <div class="row nomargin panels_box">
        <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

        <div class="row nomargin">
            <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
            </div>
        </div>

        <div class="row nomargin panels_box">
            <div class="row nomargin">
                <div class="col-md-3 col-sm-12 nopadding">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><% =Resources.Global.CompanyUpdatesFilter %></h4>
                        </div>
                        <div class="panel-body nomargin pad10">
                            <div class="form-group">
                                <label for="fromDate"><% =Resources.Global.DateRange %>:</label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtDateFrom" CssClass="form-control" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" tsiRequired="true" runat="server" />
                                    <div class="input-group-addon" onclick="$('#<%=txtDateFrom.ClientID %>').focus();$('#<%=txtDateFrom.ClientID %>').click();">
                                        <img src="images/calendar.png" style="position: relative; left: 5px; top: 8px; cursor: pointer;" />
                                    </div>
                                    <cc1:CalendarExtender runat="server" ID="ceDatFrom" TargetControlID="txtDateFrom" />
                                </div>
                            </div>
                            <div class="form-group text-center">
                                <label for="usr"><% =Resources.Global.through %></label>
                            </div>
                            <div class="form-group">
                                <div class="input-group">
                                    <asp:TextBox ID="txtDateTo" CssClass="form-control" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" tsiRequired="true" runat="server" />
                                    <div class="input-group-addon" onclick="$('#<%=txtDateTo.ClientID %>').focus();$('#<%=txtDateTo.ClientID %>').click();">
                                        <img src="images/calendar.png" style="position: relative; left: 5px; top: 8px; cursor: pointer;" />
                                    </div>
                                    <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="<%=cbKeyChangesOnly.ClientID%>" class="text-nowrap"><% =Resources.Global.KeyChangesOnly %>:</label>
                                <asp:CheckBox ID="cbKeyChangesOnly" CssClass="text-nowrap" runat="server" />
                                
                                <a id="WhatIsKeyChanges" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                    <img src="images/info_sm.png" />
                                </a>
                            </div>

                            <asp:LinkButton CssClass="btn gray_btn" ID="btnFilter" OnClick="btnFilterOnClick" runat="server">
								<i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Filter %>" />
                            </asp:LinkButton>
                            <br />
                            <asp:LinkButton CssClass="btn gray_btn" ID="btnCompanyUpdateReport" OnClick="btnCompanyUpdateReportOnClick" runat="server">
								<i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnCompanyUpdateReport %>" />
                            </asp:LinkButton>
                            <br />
                            <asp:LinkButton CssClass="btn gray_btn" ID="btnBusinessReport" OnClick="btnBusinessReportOnClick" runat="server">
								<i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnGetBusinessReport %>" />
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

                <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="true" />

                <div class="col-md-5 col-sm-12 nopadding">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><% =Resources.Global.RatingDefinitions %></h4>
                        </div>
                        <div class="panel-body nomargin pad10">
                            <div class="row Definition nomargin">
                                <asp:Label ID="lblRatingNumeralDefinitions" CssClass="PopupLink" Text="<%$ Resources:Global, AllRatingDefinitions %>" runat="server" />
                            </div>

                            <asp:Panel ID="pnlRatingNumeralDefinition" Style="display: none; height: 500px;" CssClass="Popup" Width="350px" runat="server" />
                            <cc1:PopupControlExtender ID="pceRatingNumeralDefinition" runat="server" TargetControlID="lblRatingNumeralDefinitions" PopupControlID="pnlRatingNumeralDefinition" OffsetX="-100" Position="bottom" />
                            <cc1:DynamicPopulateExtender ID="dpeRatingNumeralDefinition" runat="server" TargetControlID="pnlRatingNumeralDefinition" PopulateTriggerControlID="lblRatingNumeralDefinitions" ServiceMethod="GetRatingNumeralsDefinitions" ServicePath="AJAXHelper.asmx" CacheDynamicResults="true" />

                            <div class="pad5">
                                <asp:GridView ID="gvCompanyUpdates"
                                    AllowSorting="true"
                                    runat="server"
                                    
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover tab_bdy"
                                    GridLines="None"
                                    OnSorting="GridView_Sorting"
                                    OnRowDataBound="GridView_RowDataBound">
                                    <Columns>
                                        <asp:TemplateField HeaderStyle-Width="20%" HeaderText="<%$ Resources:Global, DateOfUpdate %>" HeaderStyle-CssClass="text-nowrap explicitlink" SortExpression="prcs_PublishableDate" ItemStyle-VerticalAlign="Top" ItemStyle-CssClass="text-left">
                                            <ItemTemplate>
                                                <%# UIUtils.GetStringFromDate(Eval("prcs_PublishableDate"))%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-Width="20%" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-nowrap text-center explicitlink" HeaderText="<%$ Resources:Global, Key %>" SortExpression="prcs_KeyFlag" ItemStyle-VerticalAlign="Top">
                                            <ItemTemplate>
                                                <%# UIUtils.GetStringFromBool(Eval("prcs_KeyFlag"))%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-Width="60%" HeaderText="<%$ Resources:Global, UpdateItem %>" HeaderStyle-CssClass="text-nowrap">
                                            <ItemTemplate>
                                                <%# Eval("ItemText") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        function RatingNumeralDefinitionLoad() {
            var popup = $find('pceRatingNumeralDefinition');
            if (!popup) return;

            popup.add_populated(function () {
                //EnableRowHighlight(document.getElementById('tblAllRatingNumeralDefinitions'));
            });
        }

        Sys.Application.add_load(RatingNumeralDefinitionLoad);
        btnSubmitOnEnter = document.getElementById('<% =btnFilter.ClientID %>');
    </script>
</asp:Content>
