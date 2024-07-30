<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="BlueprintsFlipBookArchive.aspx.cs" Inherits="PRCo.BBOS.UI.Web.BlueprintsFlipBookArchive" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="col-lg-10 col-md-9 col-sm-12 col-xs-12">
            <div class="row">
                <div class="col-md-12">
                    <img src="<% =UIUtils.GetImageURL("BlueprintsLogo-news.jpg") %>" alt="Blueprints" />
                </div>
            </div>
            <div class="row mar_top">
                <div class="col-md-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><%= Resources.Global.BlueprintsFlipbookArchive %></h4>
                        </div>
                        <div class="panel-body nomargin pad10">
                            <div class='row'>
                                <asp:Repeater ID="repBPFPA" runat="server">
                                    <ItemTemplate>
                                        <div class="col-lg-2 col-md-3 col-sm-3 col-xs-4 vertical-align-top text-center" style="height:200px;">
                                            <a href="<%# PageControlBaseCommon.GetFileDownloadURL((int)Eval("prpbar_PublicationArticleID"), (string)Eval("prpbar_PublicationCode")) %>" target="_blank">
                                                <img src="<%# PublishingBase.GetImageURL(Eval("prpbar_CoverArtFileName")) %>" border="0" width="100" style="margin-left:auto; margin-right:auto;"><br />
                                                <%# Eval("prpbar_Name")%>
                                            </a>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-12 col-xs-12 nopadding">
            <div class="row nomargin_lr">
                <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="Blueprints.aspx" MaxAdCount="4" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
            </div>
        </div>
    </div>


</asp:Content>
