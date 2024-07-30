<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="KnowYourCommodity.aspx.cs" Inherits="PRCo.BBOS.UI.Web.KnowYourCommodity" %>

<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style type="text/css">
        .KYC {
            text-align: center;
            padding: 10pt;
        }
        .KYC a {
            display: inline-block;
        }
        .KYC a img {
            margin: 0 auto !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="col-lg-2 col-md-2 col-sm-3 col-xs-12 mob_nopadding">
            <div class="row nomargin">
                <div class="cmp_nme ">
                    <a href='<%= PageConstants.LEARNING_CENTER %>'>
                        <h4 class="blu_tab text-center fontsize13 mar_bot15">
                            <%= Resources.Global.LearningCenter %>
                        </h4>
                    </a>
                </div>

                <asp:Panel ID="pnlKYCFP" runat="server">
                    <div class="tab_bdy">
                        <div class="add_img">
                            <asp:HyperLink ID="aKYC" runat="server" Target="_blank">
                                <asp:Image ID="imgKYC" runat="server" CssClass="vertical-align-middle smallpadding_lr smallpadding_tb " />
                            </asp:HyperLink>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
        <div class="col-lg-8 col-md-7 col-sm-9 col-xs-12">
            <div class="row mar_top">
                <div class="col-md-12">
                    <%= Resources.Global.AccessCommodityInfo %>
                </div>
            </div>

            <div class="row mar_top">
                <div class="col-md-12">
                    <%= Resources.Global.ReviewInDepthCommodityReferenceInfo %>:
                </div>
            </div>

            <div class="row vertical-align-top">
                <div class="col-md-10 offset-md-1 col-sm-12">
                    <div class="row">
                        <div class="col-md-6 col-sm-12">
                            •&nbsp;<%= Resources.Global.ProductAvailability %><br />
                            •&nbsp;<%= Resources.Global.CommonShippingContainers %><br />
                            •&nbsp;<%= Resources.Global.FOBGoodDeliveryGuidelines %>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            •&nbsp;<%= Resources.Global.ProductTypes %><br />
                            •&nbsp;<%= Resources.Global.USGrades %><br />
                            •&nbsp;<%= Resources.Global.VarietiesAndMore %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mar_top">
                <div class="col-md-12 text-center">
                    <a href="https://play.google.com/store/apps/details?id=com.bluebookkyc.android" target="_blank" style="display: inline-block; overflow: hidden">
                        <img alt="Get it on Google Play" width="135" height="40" src="https://www.producebluebook.com/wp-content/uploads/2015/09/Google-Play-Icon.jpg" />
                    </a>
                    <a href="https://apps.apple.com/us/app/blue-book-kyc/id1437766181?itsct=apps_box_badge&amp;itscg=30200" target="_blank" style="display: inline-block; overflow: hidden; border-radius: 13px; height: 40px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1539216000&h=eccc2f8066b06cfd750b9ee4176b1df5" alt="Download on the App Store" style="border-radius: 13px; height: 40px;"></a>
                </div>
            </div>

            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.KnowYourCommodity %></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <div class="row">
                        <asp:Repeater ID="repKYC" runat="server">
                            <ItemTemplate>
                                <div class="col-xs-3 col-sm-3 col-md-5ths vertical-align-top text-center KYC" >
                                    <a href="<%# String.Format(PageConstants.KNOW_YOUR_COMMODITY_VIEW, Eval("ID")) %>">
                                        <img src="<%# PublishingBase.GetWordPressImageURL_By_KYCThumbnailImage(Eval("KYCThumbnailImage")) %>" style="height:75px; width:75px; border:solid; border-width:1px">
                                        <%# Eval("post_title")%>
                                    </a>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-2        col-md-3        col-sm-6        col-xs-12 
                    offset-lg-0 offset-md-0 offset-sm-3 offset-xs-0
                    nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="KnowYourCommodity" MaxAdCount="9" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <!--script type="text/javascript">
        $(document).ready(function () {
            setHeight();

            $(window).on('resize', function () {
                setHeight();
            });

            function setHeight() {
                var maxHeight = 0;
                $(".KYC").each(function () {
                    if ($(this).prop('scrollHeight') > maxHeight) { maxHeight = $(this).prop('scrollHeight'); }
                });
                $(".KYC").height(maxHeight);
            }
        });
    </script-->
</asp:Content>