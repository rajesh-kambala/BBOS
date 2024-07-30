<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="KnowYourCommodityView.aspx.cs" Inherits="PRCo.BBOS.UI.Web.KnowYourCommodityView" %>
<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="WordPressArticle" Src="UserControls/WordPressArticle.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style type="text/css">
        .kyc {
            text-align: center;
            padding: 10pt;
        }
        #contentMain_ucWordPressArticle_divPagination {
            display: none;
        }
        #kycd1, #kycd2 {
            display: inline-block;
            width: 100%;
        }
        #kycd1 a, #kycd2 a {
            display: block;
            width: 100%;
            text-align: center;
        }
        img {
            display: block;
            margin: 0 auto;
            margin-bottom: 10px;
        }
    </style>
    
    <link rel="stylesheet" href="Content/style_wp.min.css" />
    
    <script type="text/javascript" id="bbsiGetAdsWidget" src="<asp:Literal ID="litAdWidget" runat="server" />"></script>   
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <input id="_bbosUserID" name="_bbosUserID" type="hidden" value="<%=_oUser.prwu_WebUserID.ToString() %>" />

    <div class="row nomargin panels_box">
        <div class="col-lg-2 col-md-2 col-sm-3 col-xs-12 mob_nopadding">
            <div class="row nomargin">
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
            <bbos:WordPressArticle ID="ucWordPressArticle" runat="server" ShowDate="false" IsKYC="true" />
        </div>

        <div class="col-lg-2        col-md-3        col-sm-6        col-xs-12 
                    offset-lg-0 offset-md-0 offset-sm-3 offset-xs-0
                    nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="KnowYourCommodity" MaxAdCount="9" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>
</asp:Content>
