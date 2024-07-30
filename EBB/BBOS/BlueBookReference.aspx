<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="BlueBookReference.aspx.cs" Inherits="PRCo.BBOS.UI.Web.BlueBookReference" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PublicationArticles" Src="UserControls/PublicationArticles.ascx" %>

<%@ Import Namespace="TSI.Utils" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="contentHead" ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function pushImageDown() {
            var m1 = 0;
            if ($(window).width() > 767) {

                if ($("#m0").length > 0 && $("#m1").length > 0)
                {
                    m1 = $('#m1').offset().top - $('#m0').offset().top;
                    $('#<%=pnlSearch.ClientID %>').css('margin-top', m1);
                }
            }

            if ($(window).width() > 767) {

                if ($("#m1").length > 0 && $("#m2").length > 0)
                {
                    var offset = $('#m2').offset().top - $('#m1').offset().top;
                    var h = $('#<%=pnlSearch.ClientID %>')[0].scrollHeight;

                    $('#<%=pnlTTGFP.ClientID %>').css('margin-top', offset-h);
                }
            }
        }

        $(window).bind("load", function () {
            pushImageDown();
        });
    </script>
</asp:Content>


<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="col-lg-10 col-md-9 col-sm-7 col-xs-12">
            <div class="row nomargin_lr">
                <%= Resources.Global.ReferenceGuideText %>
            </div>

            <div class="col-lg-3 col-md-3 col-sm-4 col-xs-12 mob_nopadding">
                <div class="row nomargin">
                    <asp:Panel ID="pnlSearch" runat="server">
                        <a href='<%= PageConstants.LEARNING_CENTER %>'>
                            <h4 class="blu_tab text-center fontsize13 mar_bot15">
                                <%= Resources.Global.LearningCenter %>
                            </h4>
                        </a>
                    </asp:Panel>
                </div>

                <div class="row nomargin">
                    <asp:Panel ID="pnlTTGFP" runat="server">
                        <div class="tab_bdy">
                            <div class="add_img">
                                <asp:HyperLink ID="aTTG" runat="server" Target="_blank">
                                    <asp:Image ID="imgTTG" runat="server" CssClass="vertical-align-middle smallpadding_lr smallpadding_tb " />
                                </asp:HyperLink>
                            </div>
                        </div>
                    </asp:Panel>
                </div>
            </div>

            <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12"  id="m0">
                <div class="row mar_top" id="rowArticles" runat="server" visible="false">
                    <div class="col-md-12">
                        <bbos:PublicationArticles ID="ucPublicationArticles" runat="server" />
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-lg-2 col-md-3 col-sm-4 col-xs-12 nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="BlueBookReference" MaxAdCount="17" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>

        <div class="clearfix"></div>
    </div>
</asp:Content>
