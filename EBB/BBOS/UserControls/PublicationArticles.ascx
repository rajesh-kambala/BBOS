<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PublicationArticles.ascx.cs" Inherits="PRCo.BBOS.UI.Web.PublicationArticles" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<div class="row">
    <asp:Repeater ID="repSearchResults" runat="server" OnItemDataBound="repSearchResults_ItemDataBound">
        <ItemTemplate>
            <div class="col-md-12" id="m<%#Container.ItemIndex + 1 %>">
                <h3 class="mar_bot_5">
                    <asp:HyperLink ID="hlCover" runat="server" Target="_blank" CssClass="vertical-align-middle" Visible="false" ImageHeight="130" />
                    <asp:Image ID="imgRead" runat="server" Visible="false" />
                    <asp:Label ID="lblArticleName" runat="server" />
                </h3>
            </div>

            <div class="col-md-12" id="rowPublishDate" runat="server">
                <asp:Label ID="lblPublishDate" runat="server" /><asp:Label ID="lblPublicationName" runat="server" />
            </div>
            
            <div class="col-md-12 mar_top_10">
                <asp:Label ID="lblAbstract" runat="server" />
                <asp:HyperLink CssClass="explicitlink" ID="aReadMore" runat="server" Target="_blank" Text="<%$ Resources:Global,ReadMore2 %>" Visible='<%# DisplayReadMore %>' />
                <hr id="hrDivider" runat="server" />
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>