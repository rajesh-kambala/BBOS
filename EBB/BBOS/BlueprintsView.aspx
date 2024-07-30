<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="BlueprintsView.aspx.cs" Inherits="PRCo.BBOS.UI.Web.BlueprintsView" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PublicationArticles" Src="UserControls/PublicationArticles.ascx" %>
<%@ Register TagPrefix="bbos" TagName="BluePrintsSideBar" Src="UserControls/BluePrintsSideBar.ascx" %>
<%@ Register TagPrefix="bbos" TagName="WordPressArticle" Src="UserControls/WordPressArticle.ascx" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style type="text/css">
        blockquote, q {
            quotes: none;
            font-size: 83%;
            background-color: #e4eaf4;
            padding: 10px;
            margin-top: 10px;
            margin-bottom: 10px;
        }
    </style>

    <link rel="stylesheet" href="Content/style_wp.min.css" />
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <bbos:BluePrintsSideBar ID="ucBluePrintsSideBar" runat="server" />

        <div class="col-lg-8 col-md-7 col-sm-9 col-xs-10">
            <div class="row">
                <div class="col-md-12">
                    <img src="<% =UIUtils.GetImageURL("BlueprintsLogo-news.jpg") %>" alt="Blueprints" />
                </div>
            </div>
            <bbos:WordPressArticle ID="ucWordPressArticle" runat="server" ShowDate="true" />

            <asp:Panel ID="pnlNewsLink" runat="server" Visible="false">
                <br />
                <div class="row nomargin text-left mar_top">
                    <asp:LinkButton ID="btnNews" runat="server" CssClass="btn gray_btn" OnClick="btnNews_Click">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, News %>" />
                    </asp:LinkButton>
                </div>
            </asp:Panel>
        </div>

        <div class="col-lg-2        col-md-3        col-sm-6        col-xs-12 
                    offset-lg-0 offset-md-0 offset-sm-3 offset-xs-0
                    nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="Blueprints.aspx" MaxAdCount="4" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>
</asp:Content>
