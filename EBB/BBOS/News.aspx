<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="News.aspx.cs" Inherits="PRCo.BBOS.UI.Web.News" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PublicationArticles" Src="UserControls/PublicationArticles.ascx" %>

<%@ Import Namespace="TSI.Utils" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        var imgRead = '<% =UIUtils.GetImageURL("read.png") %>';
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="col-lg-10 col-md-9 col-sm-8 col-xs-12">
<%--            <div class="row nomargin_lr">
                <asp:LinkButton ID="btnBankruptcyReport" runat="server" CssClass="btn gray_btn" OnClick="btnBankruptcyReportOnClick">
		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, GetBankruptcyReport %>" />
                </asp:LinkButton>
            </div>--%>

            <%--Record Count--%>
            <div class="col4_box news_box">
                <div class="cmp_nme">
                    <h4 class="blu_tab">
                        <asp:Literal ID="litTitle" runat="server" Text='<%$ Resources:Global, News %>' />
<%--                        <span id="divRecordCounts" runat="server" visible="false">
                            <asp:Label ID="lblRecordCount" runat="server" CssClass="RecordCnt" />
                        </span>--%>
                    </h4>
                </div>

                <div class="tab_bdy pad5">
                    <div class="row nomargin">
                        <div class="col-md-12">
                            <bbos:PublicationArticles ID="ucPublicationArticles" runat="server" DisplayReadMore="false" HideDate="false" DisplayReadIcon="true" />

                            <div class="row mar_bot20">
                                <div class="col-sm-6 text-left">
                                    <asp:HyperLink ID="hlViewOlderArticles" runat="server" Text='<% $Resources:Global, ViewOlderArticles %>' CssClass="explicitlink" />
                                </div>
                                <div class="col-sm-6 text-right">
                                    <asp:HyperLink ID="hlViewNewerArticles" runat="server" Text='<% $Resources:Global, ViewNewerArticles %>' CssClass="explicitlink" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4 col-xs-12 nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Sponsorship %>" PageName="News" MaxAdCount="2" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>