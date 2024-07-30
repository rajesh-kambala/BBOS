<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" AutoEventWireup="true" CodeBehind="CompanyProfile.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.CompanyProfile" EnableViewState="false" %>

<%@ OutputCache Duration="14400" Location="Server" VaryByParam="CompanyID" %>
<%@ Register TagPrefix="bbos" TagName="Advertisement" Src="Advertisement.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">


    <style>
        .cat-sidebar2 {
            padding: 15px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            *border: 1px solid #000;
            margin-right: 25px;
            box-shadow: 0 0 1px 1px rgba(0, 0, 0, 0.1);
        }
    </style>
    <script type="text/javascript">

        function openWindow(url) {
            parent.window.open(url, '_blank');
        }

        function openDirectory() {
            window.location.href = "<% =GetMarketingSiteURL() %>/find-companies/company-directory/";
        }
    </script>

    <link rel='stylesheet' id='jquery.prettyphoto-css' href='<% =GetMarketingSiteURL() %>/wp-content/plugins/wp-video-lightbox/css/prettyPhoto.css?ver=3.8.3' type='text/css' media='all' />
    <link rel='stylesheet' id='video-lightbox-css' href='<% =GetMarketingSiteURL() %>/wp-content/plugins/wp-video-lightbox/wp-video-lightbox.css?ver=3.8.3' type='text/css' media='all' />
    <script type='text/javascript' src='<% =GetMarketingSiteURL() %>/wp-content/plugins/wp-video-lightbox/js/jquery.prettyPhoto.js?ver=3.1.5'></script>
    <script type='text/javascript'>
        /* <![CDATA[ */
        var vlpp_vars = { "prettyPhoto_rel": "wp-video-lightbox", "animation_speed": "fast", "slideshow": "5000", "autoplay_slideshow": "false", "opacity": "0.80", "show_title": "true", "allow_resize": "true", "allow_expand": "true", "default_width": "640", "default_height": "480", "counter_separator_label": "\/", "theme": "pp_default", "horizontal_padding": "20", "hideflash": "false", "wmode": "opaque", "autoplay": "false", "modal": "false", "deeplinking": "false", "overlay_gallery": "true", "overlay_gallery_max": "30", "keyboard_shortcuts": "true", "ie6_fallback": "true" };
        /* ]]> */
    </script>
    <script type='text/javascript' src='<% =GetMarketingSiteURL() %>/wp-content/plugins/wp-video-lightbox/js/video-lightbox.js?ver=3.1.5'></script>
    <script type="text/javascript" src="javascript/BootStrap.min.js" ></script> 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <div class="row">

        <h2>Company Profile</h2>

        <div class="cat-sidebar2 mar_top_7 mar_bot_25 col-sm-4 col-xs-12">

            <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
                <p style="text-align: center; font-size: 11pt;">The specified company was not found.</p>
                <a href="<% =GetMarketingSiteURL() %>/services/find-companies/" target="_top" class="button" style="font-size: 90%">Find Companies</a>
            </asp:Panel>

            <!-- company info start -->
            <table class="smalltable" id="tblListing" runat="server">
                <tr>
                    <td colspan="2" class="listing">
                        <asp:Panel ID="pnlLogo" runat="server" Style="margin-bottom: 15px;" Visible="false">
                            <asp:HyperLink ID="hlLogo" alt="Logo" runat="server" />
                        </asp:Panel>
                        BB #<asp:Literal ID="litBBID" runat="server" />
                        <br />
                        <asp:Literal ID="litCompanyName" runat="server" /><br />
                        <asp:Literal ID="litLegalName" Text="Legal Name: {0}<br/>" Visible="false" runat="server" />
                        <asp:Literal ID="litLocation" runat="server" />

                        <asp:Label ID="lblNotListed" runat="server" Visible="false"><p style="text-align:center;font-size:11pt;">This company is no longer included in our directory.</p></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td class="column1">Industry:</td>
                    <td>
                        <asp:Literal ID="litIndustry" runat="server" /></td>
                </tr>
                <tr>
                    <td class="column1">Type:</td>
                    <td>
                        <asp:Literal ID="litType" runat="server" /></td>
                </tr>
                <tr>
                    <td class="column1">Phone:</td>
                    <td>
                        <asp:Literal ID="litPrimaryPhone" runat="server" /></td>
                </tr>
                <tr>
                    <td class="column1">Fax:</td>
                    <td>
                        <asp:Literal ID="litPrimaryFax" runat="server" /></td>
                </tr>
                <tr>
                    <td class="column1">Toll Free:</td>
                    <td>
                        <asp:Literal ID="litTollFree" runat="server" /></td>
                </tr>
                <tr id="trSocialMedia" runat="server">
                    <td class="column1">Social Media:</td>
                    <td>
                        <asp:Literal ID="litSocialMedia" runat="server" /></td>
                </tr>

                <tr id="trListingInfo" runat="server">
                    <td colspan="2" style="text-align: left; padding-top: 15px;">
                        <asp:Literal ID="litRated" runat="server">This company is Blue Book Services rated. (Blue Book Ratings include one or more of the following: pay description, moral responsibility indicator and credit worth estimate.)</asp:Literal>

                        <p>
                            <asp:Literal ID="litClassCommodCount" runat="server" />
                            <asp:Literal ID="ListingMsgProduce" Visible="False" runat="server">Full listings are available to Blue Book members and can include contact names, emails, websites, brand names, specialties, and more.</asp:Literal>
                            <asp:Literal ID="ListingMsgLumber" Visible="False" runat="server">Full listings are available to Blue Book members and can include contact names, emails, websites, business function, products & species handled, industry-specific pay trends, and more.</asp:Literal>
                        </p>
                    </td>
                </tr>
            </table>

            <a href="<% =GetMarketingSiteURL() %>/services/find-companies/" class="button" style="font-size: 90%" target="_top">Find Another Company</a>

            <div style="height: 1px;"></div>
        </div>

        <div class="entry col-sm-7 col-xs-12">
            <!-- Listing start-->
            <h2 style="font-size: 1.2em;">
                <asp:Literal ID="HeadingProduce" runat="server" Visible="false">The Advantage of Blue Book Services Business Reports</asp:Literal><asp:Literal ID="HeadingLumber" runat="server" Visible="false">Join Today to Access In-Depth Business Reports</asp:Literal></h2>
            <hr />
            <div id="imgProduce" runat="server" visible="false"><a rel="wp-video-lightbox" href="https://youtu.be/NwFC1mEnjFY&amp;width=853&amp;height=480">
                <img class="video_lightbox_anchor_image" src="<% =GetMarketingSiteURL() %>/wp-content/themes/blue-book/imgs/BB_advantage.jpg" /></a></div>
            <div id="imgLumber" runat="server" visible="false">
                <img src="<% =GetMarketingSiteURL() %>/wp-content/themes/bbos-lumber-theme/imgs/Business-Report.jpg" /></div>

            <div>
                <asp:PlaceHolder ID="PromoLumber" runat="server" Visible="false">
                    <p>Looking for information on a particular business? For the industry's most comprehensive credit and marketing information on companies in the wholesale lumber & forest products industry, become a member and check out a Business Report. </p>
                </asp:PlaceHolder>

                <asp:PlaceHolder ID="PromoProduce" runat="server" Visible="false">
                    <p>Looking for information on a particular business? For the industry's most comprehensive credit and marketing information on companies in the wholesale fruit & vegetable industry, check out a Business Report.  We offer the opportunity to purchase Business Reports to nonmembers.</p>
                    <p>To take advantage of more services at an economical rate, <a href="<% =GetMarketingSiteURL() %>/join-today/" target="_top">become a Blue Book member</a>.</p>
                </asp:PlaceHolder>

                <asp:Panel ID="pnlButtonsProduce" runat="server">
                    <asp:HyperLink ID="hlGetBR"  Text="Get Business Report" Target="_top" CssClass="button" Style="font-size: 90%" runat="server" /><br />
                    <asp:HyperLink ID="hlBRPricingChart" Text="View Pricing Chart" CssClass="button" Style="font-size: 90%" runat="server" NavigateUrl="#" /><br />
                    <asp:HyperLink ID="hlBRSample" Text="View Business Report Sample" CssClass="button" Style="font-size: 90%" runat="server" NavigateUrl="#" />
                </asp:Panel>

                <asp:Panel ID="pnlButtonsLumber" runat="server" Visible="false">
                    <a href="<% =GetMarketingSiteURL() %>/join-today/" class="button" style="font-size: 90%" target="_top">Join Today</a>
                    <asp:HyperLink ID="hlBRSampleLumber" Text="View Business Report Sample" CssClass="button" Style="font-size: 90%" runat="server" NavigateUrl="#" />
                </asp:Panel>

            </div>

            <!-- listing end-->
        </div>
    </div>

    <div class="clearfix"></div>
</asp:Content>