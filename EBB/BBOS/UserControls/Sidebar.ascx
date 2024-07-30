<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Sidebar.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.Sidebar" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="TESLongForm" Src="TESLongForm.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CustomData" Src="CustomData.ascx" %>

<aside class="offcanvas-lg offcanvas-start nav-sidebar" id="bdSidebar">
    <div class="offcanvas-header border-bottom">
        <h5 class="offcanvas-title" id="bdSidebarOffcanvasLabel"><%=Resources.Global.CompanyDetails %></h5>
        <button type="button" class="bbsButton bbsButton-tertiary" data-bs-dismiss="offcanvas" aria-label="Close" data-bs-target="#bdSidebar">
            <span class="msicon notranslate">close</span>
        </button>
    </div>

    <div class="accordion accordion-flush" id="accordionFlushExample">
        <div class="accordion-item">
            <div class="accordion-header">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#<%=menu_Company.ClientID %>" aria-expanded="false" aria-controls="<%=menu_Company.ClientID %>">
                    <span class="group-label"><%=Resources.Global.CompanyDetails %></span>
                </button>
            </div>
            <div id="menu_Company" runat="server" class="accordion-collapse show"  >
                <asp:HyperLink ID="hlCompanyProfile" runat="server">
                    <button type="button" class="bbs-menu-item new" id="btnCompanyProfile" runat="server">
                        <span class="msicon notranslate">storefront</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.CompanyProfile %></span>
                            <span class="caption" id="spnListedDate" runat="server" visible="false">
                                <span class="update">
                                    <span class="msicon notranslate">priority_high</span><asp:Literal ID="litListedDate" runat="server" />
                                </span>
                            </span>
                        </div>
                    </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlContacts" runat="server">
                        <button type="button" class="bbs-menu-item" id="btnContacts" runat="server">
                            <span class="msicon notranslate">person_search</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.Contacts %></span>
                            </div>
                        </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlARReports" runat="server">
                        <button type="button" class="bbs-menu-item" id="btnARReports" runat="server">
                            <span class="msicon notranslate">request_quote</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.ARReports %></span>
                            </div>
                        </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlClaimsActivityReport" runat="server">
                    <button type="button" class="bbs-menu-item" id="btnClaimsActivity" runat="server">
                        <span class="msicon notranslate">account_balance</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.ClaimsActivityTable %></span>
                            <span class="caption" id="spnNewClaim" runat="server" visible="false">
                                <span class="update">
                                    <span class="msicon notranslate">priority_high</span><asp:Literal ID="litNewClaim" runat="server" />
                                </span>
                            </span>
                        </div>
                    </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlBranchesAffiliations" runat="server">
                        <button type="button" class="bbs-menu-item" id="btnBranches" runat="server">
                            <span class="msicon notranslate">account_tree</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.BranchesAndAffiliations %></span>
                            </div>
                        </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlNewsArticles" runat="server" >
                        <button type="button" class="bbs-menu-item" id="btnNews" runat="server">
                            <span class="msicon notranslate">newsmode</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.NewsAndArticles%></span>
                            </div>
                        </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlCompanyUpdates" runat="server">
                    <button type="button" class="bbs-menu-item" id="btnUpdates" runat="server">
                        <span class="msicon notranslate">campaign</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.CompanyUpdatesSearch %></span>
                            <span class="caption" id="spnLastUpdated" runat="server" visible="false">
                                <span class="update">
                                    <span class="msicon notranslate -tw-ml-1">priority_high</span><asp:Literal ID="litLastUpdated" runat="server" /></span>
                            </span>
                        </div>
                    </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlNotes" runat="server">
                    <button type="button" class="bbs-menu-item" id="btnNotes" runat="server">
                        <span class="msicon notranslate">note_stack</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.Notes %></span>
                        </div>
                        <span class="bbsBadge" id="spnNotesBadge" runat="server" visible="false">
                            <asp:Literal ID="litNotesBadge" runat="server" />
                        </span>
                    </button>
                </asp:HyperLink>

                <asp:HyperLink ID="hlChainStoreGuide" runat="server" Visible="false">
                        <button type="button" class="bbs-menu-item" id="btnCSG" runat="server">
                            <span class="msicon notranslate">local_grocery_store</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.ChainStoreGuide%></span>
                            </div>
                        </button>
                </asp:HyperLink>
            </div>
        </div>

        <div class="accordion-item">
            <div class="accordion-header">
                <button class="accordion-button " type="button" data-bs-toggle="collapse" data-bs-target="#<%=menu_Services.ClientID%>" aria-expanded="false" aria-controls="<%=menu_Services.ClientID%>">
                    <span class="group-label"><%=Resources.Global.Services %></span>
                </button>
            </div>
            <div id="menu_Services" runat="server" class="accordion-collapse show">
                <button type="button" class="bbs-menu-item" id="btnRequestTradingAssistance" runat="server" onserverclick="btnRequestTradingAssistance_ServerClick">
                    <span class="msicon notranslate">gavel</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.RequestTradingAssistanceOpenCollection %></span>
                    </div>
                </button>
            </div>
        </div>
        <div class="accordion-item">
            <div class="accordion-header">
                <button type="button" class="accordion-button" data-bs-toggle="collapse" data-bs-target="#<%=menuDownloads.ClientID%>" aria-expanded="false" aria-controls="<%=menuDownloads.ClientID%>">
                    <span class="group-label"><%=Resources.Global.BusinessReports %></span>
                </button>
            </div>
            <div id="menuDownloads" runat="server" class="accordion-collapse show" >
                <button type="button" class="bbs-menu-item" id="btnBusinessReportFree" runat="server" onserverclick="btnBusinessReportFree_ServerClick">
                    <span class="msicon notranslate">picture_as_pdf</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.BlueBookBusinessReportFree %></span>
                    </div>
                </button>

                <button type="button" class="bbs-menu-item new" id="btnBusinessReportExperian" runat="server" onserverclick="btnBusinessReportExperian_ServerClick" >
                    <span class="msicon notranslate">picture_as_pdf</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.BusinessReportPlusExperianSupplement %></span>
                    </div>
                </button>

                <button type="button" class="bbs-menu-item new" id="btnBusinessReportPR" runat="server" >
                    <span class="msicon notranslate">picture_as_pdf</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.BusinessReportPlusPublicRecordsSupplement %></span>
                    </div>
                </button>
            </div>
        </div>
        <div class="accordion-item">
            <div class="accordion-header">
                <button type="button" class="accordion-button" data-bs-toggle="collapse" data-bs-target="#<%=menu_Actions.ClientID%>" aria-expanded="true" aria-controls="<%=menu_Actions.ClientID%>">
                    <span class="group-label"><%=Resources.Global.Actions %></span>
                </button>
            </div>
            <div id="menu_Actions" runat="server" class="accordion-collapse show">
                <button type="button" class="bbs-menu-item" id="btnRateCompany" runat="server" onclick="return ShowRateModalPopup()">
                    <span class="msicon notranslate">thumb_up_off_alt</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.RateCompany %></span>
                    </div>
                </button>

                <button id="btnAddToConnectionList" type="button" class="bbs-menu-item" runat="server" onserverclick="btnAddToConnectionList_ServerClick" >
                    <span class="msicon notranslate">shield_with_heart</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.AddToMyReferenceList %> </span>
                    </div>
                </button>

                <button type="button" class="bbs-menu-item" id="btnAlertAdd" runat="server" onserverclick="btnAlertAdd_ServerClick" >
                    <span class="msicon notranslate">notification_add</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.SubscribeToAlerts %></span>
                        <span class="caption"><%=Resources.Global.CurrentlyNotSubscribed  %></span>
                    </div>
                </button>
                <button type="button" class="bbs-menu-item" id="btnAlertRemove" runat="server" onserverclick="btnAlertRemove_ServerClick" >
                    <span class="msicon notranslate">notification_add</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.UnsubscribeFromAlerts %></span>
                        <span class="caption"><%=Resources.Global.CurrentlySubscribed  %></span>
                    </div>
                </button>

                <button id="btnAddToWatchdog" type="button" class="bbs-menu-item" runat="server" onserverclick="btnAddToWatchdog_ServerClick">
                    <span class="msicon notranslate">playlist_add</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.AddToWatchdogs %></span>
                    </div>
                </button>

                <span style="display: none;">
                    <asp:LinkButton ID="btnRemoveFromWatchdog" Text="<%$ Resources:Global, RemoveFromWatchdogGroup %>" runat="server" /></span>

                <button id="btnRemoveFromWatchdog2" type="button" class="bbs-menu-item" runat="server" onserverclick="btnRemoveFromWatchdog2_ServerClick">
                    <span class="msicon notranslate">playlist_remove</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.RemoveFromWatchdogGroup %></span>
                    </div>
                </button>

                <button type="button" class="bbs-menu-item" id="btnUpdateCustomData" runat="server" onserverclick="btnUpdateCustomData_ServerClick" >
                    <span class="msicon notranslate">dashboard_customize</span>
                    <div class="text-content">
                        <span class="label"><%=Resources.Global.UpdateCustomData %></span>
                    </div>
                </button>
            </div>
        </div>

        <!-- End of Accrodions -->
    </div>

    <br>
    <br>
    <br>
    <br>
</aside>

<bbos:TESLongForm ID="ucTESLongForm" runat="server" />
<asp:Panel ID="pnlRemoveFromWatchdog" runat="server" CssClass="Popup p-0 m-0 border-0" align="center" Style="display: none">
    <iframe id="ifrmRemoveFromWatchdog" frameborder="0" style="border-radius:8px; max-width:100%; max-height:100%; width: 600px; height: 500px; overflow-y: hidden;" scrolling="yes" runat="server"></iframe>
</asp:Panel>

<cc1:ModalPopupExtender ID="mdeRemoveFromWatchdog" runat="server"
    TargetControlID="btnRemoveFromWatchdog"
    PopupControlID="pnlRemoveFromWatchdog"
    BackgroundCssClass="modalBackground"
  />

<%--Custom Data--%>
<bbos:CustomData ID="ucCustomData" runat="server" Visible="false" Format="2" />
<asp:Panel ID="pnlCustomFieldEdit" runat="server" CssClass="Popup p-0 m-0 border-0" align="center" Style="display: none">
    <iframe id="ifrmCustomFieldEdit" frameborder="0" style="border-radius:8px; max-width:100%; max-height:100%; width: 700px; height: 400px; overflow-y: hidden;" scrolling="yes" runat="server"></iframe>
</asp:Panel>
<span style="display: none;">
    <asp:Button ID="btnCustomFieldEdit" runat="server" />
</span>
<cc1:ModalPopupExtender ID="ModalPopupExtender2" runat="server"
    TargetControlID="btnCustomFieldEdit"
    PopupControlID="pnlCustomFieldEdit"
    BackgroundCssClass="modalBackground" />

<%--Business Reports--%>
<div class="modal fade" id="pnlFreeBR" role="dialog">
    <div class="modal-dialog">
        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-body">
                <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                <div class="row">
                    <div class="col-md-12">
                        <asp:Literal ID="litFreeMsg" runat="server" Text="<%$Resources:Global, FreeConfMsg %>" />
                        <br /><br />
                    </div>

                    <div class="col-md-12">
                        <asp:LinkButton ID="btnFreeBRDownload" runat="server" CssClass="btn gray_btn" Width="150px" OnClick="btnFreeBRDownload_Click" OnClientClick="return disableFreeBRPopup();">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Download %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnFreeBREmail" runat="server" CssClass="btn gray_btn" Width="150px" OnClick="btnFreeBREmail_Click" OnClientClick="return disableFreeBRPopup();" Visible="false">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Email_Cap %>" />
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnFreeBRCancel" runat="server" CssClass="btn gray_btn" Width="150px" data-bs-dismiss="modal">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                        </asp:LinkButton>
                    </div>

                    <div class="col-md-12 mar_top">
                        <asp:CheckBox ID="chkDontShowAgain2" runat="server" Text="<%$ Resources:Global, DontShowMsgAgain %>" CssClass="norm_lbl" Visible="false" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="pnlPurchBR" role="dialog">
    <div class="modal-dialog">
        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-body">
                <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                <div class="row">
                    <div class="col-md-12">
                        <asp:Literal ID="litPurchConfMsg" runat="server" />
                        <br /><br />
                    </div>

                    <div class="col-md-12">
                        <asp:LinkButton ID="btnPurchConfDownload" runat="server" CssClass="btn gray_btn" Width="150px" OnClick="btnPurchConfDownload_Click" OnClientClick="return disablePurchBRPopup();">
		                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Download %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnPurchConfEmail" runat="server" CssClass="btn gray_btn" Width="150px" OnClick="btnPurchConfEmail_Click" OnClientClick="return disablePurchBRPopup();" Visible="false">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Email_Cap %>" />
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnPurchConfCancel" runat="server" CssClass="btn gray_btn" Width="150px" data-bs-dismiss="modal">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                        </asp:LinkButton>
                    </div>

                    <div class="col-md-12 mar_top">
                        <asp:CheckBox ID="chkDontShowAgain" runat="server" Text="<%$ Resources:Global, DontShowMsgAgain %>" CssClass="norm_lbl" Visible="false" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="pnlPRBR" role="dialog">
    <div class="modal-dialog">
        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-body">
                <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                <div class="row">
                    <div class="col-md-12">
                        <asp:Literal ID="litPRConfMsg" runat="server" />
                        <br /><br />
                    </div>

                    <div class="col-md-12">
                        <asp:LinkButton ID="btnPRConfEmail" runat="server" CssClass="btn gray_btn" Width="150px" OnClick="btnPRConfEmail_Click" OnClientClick="return disablePRBRPopup();">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Email_Cap %>" />
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnPRConfCancel" runat="server" CssClass="btn gray_btn" Width="150px" data-bs-dismiss="modal">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function disableFreeBRPopup() {
        $('#pnlFreeBR').removeClass('modal-open');
        $('.modal-backdrop').remove();

        $('#<%=btnBusinessReportFree.ClientID%>').attr('onClick', 'return true;').attr('data-bs-toggle', '');
        $('#pnlFreeBR').hide();
        return true;
    }

    function disablePurchBRPopup() {
        $('#pnlPurchBR').removeClass('modal-open');
        $('.modal-backdrop').remove();

        $('#<%=btnBusinessReportExperian.ClientID%>').attr('onClick', 'return true;').attr('data-bs-toggle', '');
        $('#pnlPurchBR').hide();
        return true;
    }

    function disablePRBRPopup() {
        $('#pnlPRBR').removeClass('modal-open');
        $('.modal-backdrop').remove();

        $('#<%=btnBusinessReportExperian.ClientID%>').attr('onClick', 'return true;').attr('data-bs-toggle', '');
        $('#pnlPRBR').hide();
        return true;
    }

    function ShowRateModalPopup() {
        $find("mpeTESSurvey").show();
        return false;
    }
    function HideRateModalPopup() {
        $find("mpeTESSurvey").hide();
        return false;
    }
</script>