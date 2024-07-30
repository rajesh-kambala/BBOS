<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="News.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.News" %>
<div class="tw-h-full portlet-grid panel-primary">
    <div class="home-info-blocks block-2">
        <div class="home-info-blocks-header">
            <span class="msicon notranslate filled">newsmode</span><%=Resources.Global.News %>
        </div>
        <div class="home-info-blocks-content">
            <ul class="tw-list-disc tw-px-4">
                <li>
                    <asp:HyperLink ID="newsArticle1" runat="server" Target="_blank" Visible="false" />
                </li>

                <li>
                    <asp:HyperLink ID="newsArticle2" runat="server" Target="_blank" Visible="false" />
                </li>

                <li><a id="hlNews3" runat="server" target="_blank"><%=Resources.Global.ViewAll %><asp:Literal ID="newsCount" runat="server" />&nbsp;<%=Resources.Global.Articles %>.</a></li>
            </ul>
        </div>
    </div>
</div>
