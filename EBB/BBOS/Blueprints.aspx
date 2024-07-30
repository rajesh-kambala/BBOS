<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Blueprints.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Blueprints" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PublicationArticles" Src="UserControls/PublicationArticles.ascx" %>
<%@ Register TagPrefix="bbos" TagName="BluePrintsSideBar" Src="UserControls/BluePrintsSideBar.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
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
            <div class="row mar_top">
                <div class="col-md-12">
                    <bbos:PublicationArticles ID="ucPublicationArticles" runat="server" DisplayReadMore="false" HideDate="true" />
                </div>
            </div>
            
            <div class="row mar_bot20">
                <div class="col-sm-6 text-left">
                    <asp:HyperLink ID="hlViewOlderArticles" runat="server" Text='<% $Resources:Global, ViewOlderArticles %>' CssClass="explicitlink"/>
                </div>
                <div class="col-sm-6 text-right">
                    <asp:HyperLink ID="hlViewNewerArticles" runat="server" Text='<% $Resources:Global, ViewNewerArticles %>' CssClass="explicitlink"/>
                </div>
            </div>
        </div>

        <div class="col-lg-2 col-md-3 col-sm-6 col-xs-12 
                    offset-lg-0 offset-md-0 offset-sm-3 offset-xs-0
                    nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="Blueprints.aspx" MaxAdCount="4" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>
</asp:Content>
