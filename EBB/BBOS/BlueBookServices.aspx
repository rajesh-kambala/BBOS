<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="BlueBookServices.aspx.cs" Inherits="PRCo.BBOS.UI.Web.BlueBookServices" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PublicationArticles" Src="UserControls/PublicationArticles.ascx" %>

<%@ Import Namespace="TSI.Utils" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="col-lg-10 col-md-9 col-sm-8 col-xs-12">
            <div class="row">
                <div class="col-md-12">
                    <%= Resources.Global.BlueBookServicesText %>
                </div>
            </div>

            <div class="row" id="LearningCenter" runat="server">
                <div class="col-lg-3 col-md-4 col-sm-5 col-xs-6">
                    <div class="cmp_nme">
                        <a href='<%= PageConstants.LEARNING_CENTER %>'>
                            <h4 class="blu_tab text-center fontsize13 mar_bot15">
                                <%= Resources.Global.LearningCenter %>
                            </h4>
                        </a>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12 text-center">
                    <%= Resources.Global.BlueBookServicesText2 %>
                </div>

            </div>

            <div class="row nomargin_lr text-center" id="pnlSubmenu" runat="server">
                <div class="col-md-12 mar_top_10">
                    <a class="btn gray_btn" href="#Spanish" id="aSpanish" runat="server" style="width:150px;">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Spanish %>" />
                    </a>

                    <a class="btn gray_btn" href="#English" style="width:150px;">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, English %>" />
                    </a>
                </div>
            </div>

            <asp:Panel ID="fsSpanish" runat="server">
                <a name="Spanish" class="anchor"></a>
                <div class="row nomargin">
                    <div class="col-md-12 nopadding">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h4 class="blu_tab"><%= Resources.Global.Spanish %></h4>
                            </div>
                            <div class="panel-body nomargin pad10">
                                <div class="row">
                                    <div class="col-md-12">
                                        <asp:Repeater ID="repReferencesS" runat="server" OnItemDataBound="repReferencesS_ItemDataBound">
                                            <ItemTemplate>
                                                <h2><div class="TitleMedium"><%# GetCategory(Eval("Category"))%></div></h2>
                                                <bbos:PublicationArticles ID="ucPublicationArticles" runat="server" OnItemDataBound="repReferencesS_ItemDataBound"/>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <a name="English" class="anchor"></a>
            <div class="row nomargin">
                <div class="col-md-12 nopadding">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><%= Resources.Global.English %></h4>
                        </div>
                        <div class="panel-body nomargin pad10">
                            <div class="row">
                                <div class="col-md-12">
                                    <asp:Repeater ID="repReferencesE" runat="server" OnItemDataBound="repReferencesE_ItemDataBound">
                                        <ItemTemplate>
                                            <h2><div class="TitleMedium"><%# GetCategory(Eval("Category"))%></div></h2>
                                            <bbos:PublicationArticles ID="ucPublicationArticles" runat="server" />
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4 col-xs-12 nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="BlueBookServices" MaxAdCount="7" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>
</asp:Content>
