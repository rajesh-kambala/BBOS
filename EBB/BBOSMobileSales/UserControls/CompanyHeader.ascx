<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanyHeader.ascx.cs" Inherits="BBOSMobileSales.UserControls.CompanyHeader" %>
<h5 class="card-title mt-2 mb-0">
    <asp:Literal ID="litCompanyName" runat="server" /></h5>
<asp:Literal ID="litCityState" runat="server" /><br />
BB #<asp:Literal ID="litBBID" runat="server" /><br />
<asp:Literal ID="litListingStatus" runat="server" />

<asp:HiddenField ID="hidCompanyID" runat="server" />

<div class="mb-2">
    <div class="owl-carousel owl-theme submenu">
        <div data-hash="sum"><asp:HyperLink ID="hlSummary" runat="server">Summary</asp:HyperLink></div>
        <div data-hash="svs"><asp:HyperLink ID="hlServices" runat="server">Services</asp:HyperLink></div>
        <div data-hash="per"><asp:HyperLink ID="hlPersonnel" runat="server">Personnel</asp:HyperLink></div>
        <div data-hash="di"><asp:HyperLink ID="hlDeliveryInfo" runat="server">Delivery Info</asp:HyperLink></div>
        <div data-hash="ads"><asp:HyperLink ID="hlAdvertising" runat="server">Advertising</asp:HyperLink></div>
        <div data-hash="intr"><asp:HyperLink ID="hlInteractions" runat="server">Interactions</asp:HyperLink></div>
        <div data-hash="clm"><asp:HyperLink ID="hlClaims" runat="server">Claims</asp:HyperLink></div>
        <div data-hash="oppo"><asp:HyperLink ID="hlOpportunities" runat="server">Opportunities</asp:HyperLink></div>
        <div data-hash="lst"><asp:HyperLink ID="hlListing" runat="server">Listing</asp:HyperLink></div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        $(".owl-carousel").owlCarousel(
            {
                responsiveClass: true,
                autoWidth: true,
                dots: false,
                URLhashListener: true,
                startPosition: 'URLHash'
            }
        );
    });
</script>