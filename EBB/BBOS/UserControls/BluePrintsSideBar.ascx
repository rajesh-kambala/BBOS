<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="BluePrintsSideBar.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.BluePrintsSideBar" %>

<div class="col-lg-2 col-md-2 col-sm-3 col-xs-12 mob_nopadding">
    <div class="row nomargin">

        <div class="cmp_nme ">
            <a href='<%= PageConstants.LEARNING_CENTER %>'>
                <h4 class="blu_tab text-center fontsize14 mar_bot15">
                    <%= Resources.Global.LearningCenter %>
                </h4>
            </a>
        </div>

        <div class="tab_bdy" id="tdFlipBook1" runat="server">
            <div class="add_img">
                <asp:HyperLink ID="hlFlipBookCover" runat="server" Target="_blank">
                    <asp:Image ID="imgFlipBookCover" runat="server" CssClass="vertical-align-middle smallpadding_lr smallpadding_tb" />
                </asp:HyperLink>
            </div>
        </div>

        <div class="cmp_nme" id="tdFlipBook2" runat="server">
            <asp:HyperLink ID="hlFlipBookTitle" runat="server" Target="_blank" CssClass="vertical-align-middle">
                <h4 class="blu_tab text-center fontsize14 nomargin_lr mar_top_1_imp mar_bot_imp">
                    <asp:Label ID="lblFlipBookTitle" runat="server" />
                </h4>
            </asp:HyperLink>
        </div>

        <asp:Repeater ID="repFlipBookSupplements" runat="server" OnItemDataBound="repFlipBookSupplements_ItemDataBound">
            <ItemTemplate>
                <div class="tab_bdy">
                    <div class="add_img">
                        <asp:HyperLink ID="hlFlipBookCover" runat="server" Target="_blank">
                            <asp:Image ID="imgFlipBookCover" runat="server" CssClass="vertical-align-middle smallpadding_lr smallpadding_tb" />
                        </asp:HyperLink>
                    </div>
                </div>

                <div class="cmp_nme">
                    <asp:HyperLink ID="hlFPButton" runat="server" Target="_blank">
                        <h4 class="blu_tab text-center fontsize14 nomargin_lr mar_top_1_imp mar_bot_imp"><%# Eval("prpbar_Name")  %></h4>
                    </asp:HyperLink>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <div class="cmp_nme">
            <asp:HyperLink ID="hlBluePrintsFlipbookArchive" runat="server">
                <h4 class="blu_tab text-center fontsize14"><%=Resources.Global.View %>&nbsp;<em><%= Resources.Global.BlueprintsFlipbookArchive%></em></h4>
            </asp:HyperLink>
        </div>

        <div class="cmp_nme">
            <asp:HyperLink Target="_blank" runat="server" ID="hlAdvertise">
                <h4 class="blu_tab text-center fontsize14"><%= Resources.Global.AdvertiseInBlueprints%></h4>
            </asp:HyperLink>
        </div>
    </div>
</div>
