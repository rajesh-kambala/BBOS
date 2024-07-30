<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsSummary.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsSummary" Title="Untitled Page" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetails" Src="UserControls/CompanyDetails.ascx" %>
<%@ Register TagPrefix="bbos" TagName="TESLongForm" Src="UserControls/TESLongForm.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PinnedNote" Src="UserControls/PinnedNote.ascx" %>
<%@ Register TagPrefix="bbos" TagName="LocalSource" Src="UserControls/LocalSource.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PerformanceIndicators" Src="UserControls/PerformanceIndicators.ascx" %>
<%@ Register TagPrefix="bbos" TagName="TradeAssociation" Src="UserControls/TradeAssociation.ascx" %>
<%@ Register TagPrefix="bbos" TagName="NewsArticles" Src="UserControls/NewsArticles.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CustomData" Src="UserControls/CustomData.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Notes" Src="UserControls/Notes.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript" src="Scripts/print.min.js"></script>
    <script type="text/javascript">
        function printpage() {
            window.open('CompanyDetailsSummaryPrint.aspx?CompanyId=<%=hidCompanyID.Text%>', '_blank');
        }

        function disablePurchConfPopup() {
            $('#pnlPurchConf').removeClass('modal-open');
            $('.modal-backdrop').remove();

            $('#<%=btnBusinessReport.ClientID%>').attr('onClick', 'return true;').attr('data-bs-toggle', '');
            $('#pnlPurchConf').hide();
            return true;
        }
    </script>
    <style>
        img {
            display: inline;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box" id="pAll">
        <div class="col-xs-12">
            <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
            <asp:Label ID="hidRatingID" Visible="false" runat="server" />

            <bbos:PrintHeader id="ucPrintHeader" runat="server" Title='<% $Resources:Global, ListingSummary %>' />

            <div class="row nomargin">
                <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                    <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
                </div>

                <div class="col-lg-7 col-md-7 col-sm-12 nopadding_r" id="pButtons">
                    <div class="row nomargin">
                        <div class="cmp_nme px-0">
                            <h4 class="blu_tab"><%=Resources.Global.Action %></h4>
                        </div>
                        <div class="row tab_bdy nomargin">
                            <div class="col-md-6 col-sm-12 search_crit padding_5">
                                <asp:LinkButton CssClass="btn LargeButton gray_btn" ID="btnRateCompany" runat="server">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, RateCompany %>" />
                                </asp:LinkButton>

                                <asp:LinkButton CssClass="btn LargeButton gray_btn" ID="btnBusinessReport" OnClick="btnBusinessReportOnClick" runat="server">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnGetBusinessReport %>" />
                                </asp:LinkButton>

                                <asp:LinkButton CssClass="btn LargeButton gray_btn" ID="btnAddToConnectionList" runat="server" OnClick="btnAddToConnectionListOnClick">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToConnectionList %>" />
                                </asp:LinkButton>

                                <asp:LinkButton CssClass="btn LargeButton gray_btn" ID="btnAlertAdd" runat="server" OnClick="btnAlertAdd_Click">
		                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AddAlert %>" />
                                </asp:LinkButton>
                                <asp:LinkButton CssClass="btn LargeButton gray_btn" ID="btnAlertRemove" runat="server" OnClick="btnAlertRemove_Click">
		                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, RemoveAlert %>" />
                                </asp:LinkButton>
                            </div>

                            <div class="col-md-6 col-sm-12 search_crit padding_5">
                                <asp:LinkButton CssClass="btn LargeButton gray_btn wrap3" ID="btnGetTradingAssistance" OnClick="btnGetTradingAssistanceOnClick" runat="server">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnGetTradingAssistance %>" />
                                </asp:LinkButton>

                                <asp:LinkButton CssClass="btn LargeButton gray_btn" ID="btnEditCompany" OnClick="btnEditCompany_Click" runat="server">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, EditCompanyData %>" />
                                </asp:LinkButton>

                                <asp:LinkButton CssClass="btn LargeButton gray_btn" ID="hlViewMap" OnClick="hlViewMap_Click" runat="server">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnViewMap %>" />
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnManageAlerts" CssClass="btn LargeButton gray_btn" runat="server" OnClick="btnManageAlerts_Click">
		                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ManageAlerts %>" />
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />

            <div class="clearfix"></div>
            <div class="row">
                <div class="col-md-4 col-12 nopadding  ">
                    <bbos:PinnedNote ID="ucPinnedNote" runat="server" />

                    <bbos:LocalSource ID="ucLocalSource" runat="server" />
                    <bbos:CompanyDetails ID="ucCompanyDetails" runat="server" Visible="true" />
                </div>

                <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="true" />

                <div class="col-md-4 col-12 nopadding">
                    <bbos:PerformanceIndicators ID="ucPerformanceIndicators" runat="server" Visible="true" />
                    <bbos:TradeAssociation ID="ucTradeAssociation" runat="server" Visible="true" />
                    <bbos:NewsArticles ID="ucNewsArticles" runat="server" Visible="true" ShowHyphensAfterDate="false" />

                    <asp:Panel ID="Categories" CssClass="small_horizontal_box" runat="server">
                        <div class="col4_box">
                            <div class="cmp_nme">
                                <h4 class="blu_tab"><% = Resources.Global.WatchdogLists %></h4>
                            </div>
                            <div class="tab_bdy pad5">
                                <table class="table">
                                    <tr>
                                        <asp:Repeater ID="repCategories" runat="server">
                                            <ItemTemplate>
                                                <% _categoryIndex++; %>
                                                <% =GetBeginColumnSeparator(_categoryCount, 2, _categoryIndex)%>
                                                <tr>
                                                    <td><%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%> <%# Eval("prwucl_Name") %></td>
                                                </tr>
                                                <% =GetEndColumnSeparator(_categoryCount, 2, _categoryIndex)%>
                                                <% _iRepeaterRowCount++; %>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </tr>
                                </table>

                                <asp:Panel ID="pnlCategoryRemove" runat="server" CssClass="Popup" align="center" Style="display: none">
                                    <iframe id="ifrmCategoryRemove" frameborder="0" style="width: 600px; height: 450px; overflow-y: hidden;" scrolling="yes" runat="server"></iframe>
                                </asp:Panel>

                                <cc1:ModalPopupExtender ID="mdeCategoryRemove" runat="server"
                                    TargetControlID="btnCategoryRemove"
                                    PopupControlID="pnlCategoryRemove"
                                    BackgroundCssClass="modalBackground" />

                                <div class="row pad10 bb_service">
                                    <div class="col-md-6 col-sm-12 search_crit">
                                        <asp:LinkButton CssClass="btn MediumButton gray_btn" ID="btnCategoryAddTo" runat="server" OnClick="btnAddToWatchdogOnClick">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToWatchdogList%>" />
                                        </asp:LinkButton>

                                        <asp:LinkButton CssClass="btn MediumButton gray_btn" runat="server" PostBackUrl="~/UserListList.aspx" ID="btnManageWatchdogGroups">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ManageWatchdogGroups %>" />
                                        </asp:LinkButton>
                                    </div>
                                    <div class="col-md-6 col-sm-12 search_crit">
                                        <span style="display: none;">
                                            <asp:LinkButton ID="btnCategoryRemove" Text="<%$ Resources:Global, RemoveFromWatchdogGroup %>" runat="server" /></span>
                                        <asp:LinkButton CssClass="btn MediumButton gray_btn" ID="btnCategoryRemove2" runat="server" OnClick="btnRemoveCategory_Click">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, RemoveFromWatchdogGroup %>" />
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>

                    <bbos:CustomData ID="ucCustomData" runat="server" Visible="true" />
                    <bbos:Notes ID="ucNotes" runat="server" Visible="true" />
                </div>
            </div>

            <asp:Panel ID="pnlCustomFieldEdit" runat="server" CssClass="Popup" align="center" Style="display: none">
                <iframe id="ifrmCustomFieldEdit" frameborder="0" style="width: 700px; height: 400px; overflow-y: hidden;" scrolling="yes" runat="server"></iframe>
            </asp:Panel>

            <span style="display: none;">
                <asp:Button ID="btnCustomFieldEdit" runat="server" />
            </span>

            <cc1:ModalPopupExtender ID="ModalPopupExtender2" runat="server"
                TargetControlID="btnCustomFieldEdit"
                PopupControlID="pnlCustomFieldEdit"
                BackgroundCssClass="modalBackground" />

            <asp:Panel ID="pnlListingReport" Style="display: none" CssClass="Popup" Width="325px" runat="server">
                <h4 class="blu_tab"><% =Resources.Global.PleaseConfirm %></h4>
                <div class="row mar_top">
                    <div class="col-md-12">
                        <% =Resources.Global.IncludeBranchesMsg %>
                    </div>
                </div>

                <div class="row mar_top">
                    <div class="col-md-12">
                        <asp:LinkButton ID="btnYes" runat="server" CssClass="btn gray_btn" Width="75px">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Yes %>" />
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnNo" runat="server" CssClass="btn gray_btn" Width="75px">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, No %>" />
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" Width="75px" OnClientClick="javascript:cancelListingReport();">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </asp:Panel>

            <bbos:TESLongForm ID="TESLongForm" runat="server" />

            <div class="modal fade" id="pnlPurchConf" role="dialog">
                <div class="modal-dialog">
                    <!-- Modal content-->
                    <div class="modal-content">
                        <div class="modal-body">
                            <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                            <div class="row">
                                <div class="col-md-12">
                                    <asp:Literal id="litPurchConfMsg" runat="server" />
                                </div>

                                <div class="col-md-12">
                                    <asp:LinkButton ID="btnPurchConfDownload" runat="server" CssClass="btn gray_btn" Width="150px" OnClick="btnPurchConfDownload_Click" OnClientClick="return disablePurchConfPopup();">
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Download %>" />
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnPurchConfEmail" runat="server" CssClass="btn gray_btn" Width="150px" OnClick="btnPurchConfEmail_Click" OnClientClick="return disablePurchConfPopup();">
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, EmailReport %>" />
                                    </asp:LinkButton>
                                </div>

                                <div class="col-md-12">
                                    <asp:LinkButton ID="btnPurchConfCancel" runat="server" CssClass="btn gray_btn" Width="150px" data-bs-dismiss="modal" >
		                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                                    </asp:LinkButton>
                                </div>

                                <div class="col-md-12 mar_top">
                                    <asp:CheckBox ID="chkDontShowAgain" runat="server" Text="<%$ Resources:Global, DontShowMsgAgain %>" CssClass="norm_lbl" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
