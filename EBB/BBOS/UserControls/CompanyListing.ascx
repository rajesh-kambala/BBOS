<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanyListing.ascx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyListing" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<script type="text/javascript">
    function downloadReport() {
        var blnBranches = $("#" + "<%= cbBranches.ClientID%>").is(':checked');
        var blnAffiliations = $("#" + "<%= cbAffiliations.ClientID%>").is(':checked');

        if (blnBranches) { szValue = "true"; } else { szValue = "false"; };
        document.getElementById("<%= hidIncludeBranches.ClientID%>").value = szValue;

        if (blnAffiliations) { szValue = "true"; } else { szValue = "false"; };
        document.getElementById("<%= hidIncludeAffiliations.ClientID%>").value = szValue;
        imgPrintOnClick();
    }
</script>

<input type="hidden" id="hidIncludeBranches" value="false" name="hidIncludeBranches" runat="server" />
<input type="hidden" id="hidIncludeAffiliations" value="false" name="hidIncludeAffiliations" runat="server" />

<div id="pCompanyListing" runat="server" class="col-md-4 col-12" style="min-width:375px;">
    <div class="cmp_nme">
<h4 class="blu_tab">
            <%=Resources.Global.CompanyListingTitle %>
            <asp:ImageButton ID="imgPrint" runat="server" CssClass="flt_right" ImageUrl="../images/print.png" OnClick="imgPrint_Click" />
            <asp:ImageButton ID="imgPrintBasic" runat="server" CssClass="flt_right" ImageUrl="../images/print.png" OnClick="imgPrintBasic_Click" Visible="false"/>
        </h4>
    </div>
    <div class="tab_bdy pad10">
        <div class="row nomargin">
            <div class="col-md-12 nopadding">
                <div class="text-center" id="pnlImage" runat="server">
                    <asp:HyperLink ID="hlLogo" Visible="false" Target="_blank" alt="Logo" runat="server" />
                </div>
            </div>
            <div class="col-md-12 nopadding ListingDetails">
                <asp:Literal ID="litListing" runat="server" />
            </div>
        </div>
    </div>
</div>

<div class="bbs-card" id="pCompanyListing2" runat="server" visible="false">
    <div class="bbs-card-body tw-flex tw-flex-col tw-gap-y-4">
        <!-- Premium Listing Info -->
        <div class="tw-flex tw-flex-col tw-gap-y-2">
            <div class="tw-flex tw-justify-end">
                <h5 class="tw-flex-grow">
                    <span class="msicon notranslate">workspace_premium</span>
                    <%=Resources.Global.PremiumListingInformation %>
                </h5>
                <button id="imgPrint2" runat="server" class="bbsButton bbsButton-secondary small" type="button" OnClick="imgPrint_Click">
                    <span class="msicon notranslate">print</span>
                </button>
                <button id="imgPrintBasic2" runat="server" class="bbsButton bbsButton-secondary small" type="button" OnClick="imgPrintBasic_Click" Visible="false">
                    <span class="msicon notranslate">print</span>
                </button>
            </div>
            <div class="partial collapsed tw-text-sm" id="premium_listing_info">
                <asp:Literal ID="litListing2" runat="server"></asp:Literal>
            </div>
            <div class="tw-flex tw-items-center">
                <hr class="tw-flex-grow" />
                <button type="button"
                    class="bbsButton bbsButton-secondary small pill"
                    onclick="togglePartialExpandCollapse(this, 'premium_listing_info')">
                    <span class="text-label"><%=Resources.Global.ShowMore %></span>
                    <span class="msicon notranslate">expand_more</span>
                </button>
                <hr class="tw-flex-grow" />
            </div>
        </div>
    </div>
</div>

<asp:Panel ID="pnlListingReport" Style="display: none" CssClass="Popup" Width="325px" runat="server">
    <h4 class="blu_tab"><% =Resources.Global.ListingReport %></h4>
    <div class="row mar_top">
        <div class="col-md-12">
            <% =Resources.Global.ChooseListingReportOptions %>
        </div>
        <div class="col-md-12 mar_top">
            <asp:CheckBox ID="cbBranches" runat="server" Text="<%$Resources:Global, Branches %>" CssClass="space" /><br />
            <asp:CheckBox ID="cbAffiliations" runat="server" Text="<%$Resources:Global, Affiliations %>" CssClass="space" />
        </div>
    </div>

    
    <div class="tw-flex tw-gap-4 tw-justify-end tw-mt-4">
        <asp:LinkButton ID="btnCancel" runat="server" CssClass="bbsButton bbsButton-secondary small" >
            <span class="msicon notranslate">close</span>
            <span class="text-label"><asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" /></span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnPrint" runat="server" CssClass="bbsButton bbsButton-primary small">
            <span class="msicon notranslate">print</span>
                <span class="text-label"><asp:Literal runat="server" Text="<%$Resources:Global, Print %>" /></span>
        </asp:LinkButton>
    </div>
    
</asp:Panel>

<cc1:ModalPopupExtender ID="ModalPopupExtender1" runat="server" OnOkScript="downloadReport()"
    TargetControlID="imgPrint2" BehaviorID="mpeListingReport"
    PopupControlID="pnlListingReport" OkControlID="btnPrint" CancelControlID="btnCancel" />
