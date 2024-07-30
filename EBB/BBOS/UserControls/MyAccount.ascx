<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MyAccount.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.MyAccount" %>
<div class="tw-h-full portlet-grid panel-primary" id="pnlPrimary" runat="server">
    <div class="home-info-blocks block-3">
        <div class="home-info-blocks-header">
            <span class="msicon notranslate filled">account_circle</span><%= Resources.Global.MyAccount %>
        </div>
        <div class="home-info-blocks-content">
            <ul class="tw-list-disc tw-px-4">
                <li id="hlCompanyProfileViewsli" runat="server" Visible="true">
                    <asp:HyperLink ID="hlCompanyProfileViews" runat="server"><%= Resources.Global.WhoViewedMyProfile %></asp:HyperLink>
                </li>
                <li>
                    <%= Resources.Global.View %> <asp:HyperLink ID="hlMyCompanyProfile" runat="server"><%= Resources.Global.ViewMyCompanyProfile %></asp:HyperLink>
                </li>
                <li><%= Resources.Global.Manage %> <a href="<%=PageConstants.USER_PROFILE %>"><%= Resources.Global.MyAccount %></a></li>
                <li id="liRequestBusinessValuation" runat="server"><%=Resources.Global.RequestMy%> <a href="<%=PageConstants.BUSINESS_VALUATION %>"> <%= Resources.Global.BusinessValuation2%></a> ** <%=Resources.Global.New2 %></li>
                <li id="liDownloadBusinessValuation" runat="server" visible="false"><%=Resources.Global.DownloadMy%> <a href="<%=PageConstants.MEMBERSHIP_SUMMARY %>"> <%= Resources.Global.BusinessValuation3%></a></li>
            </ul>
        </div>
    </div>
</div>
