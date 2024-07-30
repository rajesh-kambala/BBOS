<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NewsArticles.ascx.cs" Inherits="PRCo.BBOS.UI.Web.NewsArticles" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<%--This goes in the News and Article page --%>
<div class="col4_box news_box tw-pb-2" id="pNews1" runat="server">
  <div class="bbs-card-bordered">
    <div class="bbs-card-header d-flex justify-content-between align-items-center">
      <asp:Literal ID="litTitle" runat="server" />
      <div id="divRecordCounts" class="tag" runat="server" visible="false">
          <span><asp:Label ID="lblInternalNewsRecordCount" runat="server" /></span>
      </div>
    </div>
    <div class="bbs-card-body no-padding">
        <ul class="list-group list-group-flush">
            <asp:Repeater ID="repNews" runat="server" OnItemDataBound="repNews_ItemDataBound">
                <ItemTemplate>
                    <li class="list-group-item">
                        <h4 class="mar_bot_5 mar_top_5 tw-flex tw-gap-2 tw-items-center">
                            <asp:Image ID="imgRead" runat="server" />
                            <asp:HyperLink ID="lnkArticleName1" runat="server" ForeColor="#2a6496" />
                            <asp:Label ID="lblArticleName1" CssClass="articleName" Visible="false" runat="server" />
                        </h4>
                        <div  id="rowPublishDate" runat="server">
                            <span style="text-transform: capitalize; white-space: nowrap"><asp:Literal ID="litPublishDate1" runat="server"/></span>
                            <asp:Literal ID="litHyphens" runat="server" Visible="true">&nbsp;-&nbsp;</asp:Literal>
                            <asp:Label ID="lblPublishDate" runat="server" /><asp:Label ID="lblPublicationName" runat="server" />
                            <asp:LinkButton ID="lnkCategory" runat="server" />
                            <asp:Label ID="lblCategory" runat="server" />
                            <asp:Literal ID="litSourceName" runat="server" />
                            <asp:Label ID="lblSourceCodeText" Visible="false" runat="server" />
                            <asp:Image ID="imgSourceCodeLogo" Visible="false" runat="server" />
                        </div>
                        <asp:Panel ID="panelAbstract" runat="server" class="mar_top_5">
                            <asp:Label runat="server" ID="lblAbstract1" CssClass="mediumText" />
                            <hr id="hrDivider" runat="server" class="mar_top_5 mar_bot_5" />
                        </asp:Panel>
                    </li>
                </ItemTemplate>
            </asp:Repeater>
        </ul>
        <div class="row pad10 bb_service" id="divViewAll" runat="server" visible="true">
            <div class="col-md-6 col-sm-12 search_crit">
                <asp:LinkButton ID="lnkViewAll" runat="server" CssClass="btn MediumButton gray_btn">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal ID="litViewAll" runat="server">View All</asp:Literal>
                </asp:LinkButton>
            </div>
        </div>
    </div>
  </div>

</div>

<%--BBOS9 Style This goes in the company profile page --%>
<div class="list-group" id="pNews2" runat="server">
    <asp:Repeater ID="repNews2" runat="server" OnItemDataBound="repNews_ItemDataBound">
        <ItemTemplate>
            <a href="#" class="list-group-item list-group-item-action" aria-current="true" id="lnkArticleName2" runat="server">
                <div class="d-flex w-100 justify-content-between">
                    <h5 class="mb-1">
                        <asp:Literal ID="litArticleName2" runat="server" />
                    </h5>
                    <small style="text-transform: capitalize; white-space: nowrap">
                        <asp:Literal ID="litPublishDate2" runat="server" /></small>
                </div>
                <p class="mb-1">
                    <asp:Literal ID="litCategory2" runat="server" />
                </p>
                <small>
                    <asp:Literal ID="litAuthor2" runat="server" /></small>
            </a>
        </ItemTemplate>
    </asp:Repeater>

    <a href="#" class="list-group-item list-group-item-action" id="lnkViewAll2" runat="server" visible="false">
        <div class="tw-flex tw-grow tw-justify-center tw-gap-1">
            <span><%=Resources.Global.SeeAllNews %></span>
            <span class="msicon notranslate">arrow_outward</span>
        </div>
    </a>
</div>
