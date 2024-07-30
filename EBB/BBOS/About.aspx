<%@ Page MasterPageFile="~/BBOS.Master" Language="c#" CodeBehind="About.aspx.cs" AutoEventWireup="True" Inherits="PRCo.BBOS.UI.Web.About" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin">
        <div class="col-xs-6 offset-xs-3 text-nowrap">
            &copy;&nbsp;<% =DateTime.Now.Year.ToString() %> <% =PageBase.GetCompanyName() %> <% =Resources.Global.AllRightsReserved %>
        </div>
    </div>

    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-6 offset-md-3 col-xs-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><% =Resources.Global.BBOSInformation %></h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="form-group">
                            <div class="col-md-4 col-xs-6 text-nowrap">
                                <div class="clr_blu"><asp:Literal ID="litAppVersion" runat="server" />:</div>
                            </div>
                            <div class="col-md-8 col-xs-6">
                                <asp:Label ID="lblAppVersion" runat="server" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-4 col-xs-6 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.FrameworkVersion %>:</div>
                            </div>
                            <div class="col-md-8 col-xs-6">
                                <asp:Label ID="lblFrameworkVersion" runat="server" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-4 col-xs-6 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.TSIVersion %>:</div>
                            </div>
                            <div class="col-md-8 col-xs-6">
                                <asp:Label ID="lblTSIVersion" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-6 offset-md-3 col-xs-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><% =Resources.Global.UserInformation %></h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="form-group">
                            <div class="col-md-3 col-xs-6 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.UserID %>:</div>
                            </div>
                            <div class="col-md-9 col-xs-6">
                                <asp:Label ID="lblUIUserID" runat="server" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3 col-xs-6 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.CultureLabel %>:</div>
                            </div>
                            <div class="col-md-9 col-xs-6">
                                <asp:Label ID="lblCulture" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-6 offset-md-3 col-xs-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><% =Resources.Global.ClientBrowserInfo %></h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="form-group">
                            <div class="col-md-3 col-xs-6 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.UserAgent %>:</div>
                            </div>
                            <div class="col-md-9 col-xs-6">
                                <asp:Label ID="lblUserAgent" runat="server" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3 col-xs-6 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.Browser %>:</div>
                            </div>
                            <div class="col-md-9">
                                <asp:Label ID="lblBrowser" runat="server" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3 col-xs-6 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.Version %>:</div>
                            </div>
                            <div class="col-md-9 col-xs-6">
                                <asp:Label ID="lblBrowserVersion" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="NoticeBox" style="margin-left: auto; margin-right: auto; width: 650px; margin-top: 20px;">
        <div style="text-align: center;">
            <asp:Literal runat="server" Text="<%$ Resources:Global, BBOSBestExperiencedWith%>" />
        </div>

        <table style="margin-left: auto; margin-right: auto; margin-top: 20px;">
            <tr>
                <td class="label clr_blu">Apple Safari:</td>
                <td style="width: 200px"><a href="http://www.apple.com/safari" target="_blank" class="explicitlink">www.apple.com/safari</a></td>
            </tr>
            <tr>
                <td class="label clr_blu">Google Chrome:</td>
                <td><a href="http://www.google.com/chrome" target="_blank" class="explicitlink">www.google.com/chrome</a></td>
            </tr>
            <tr>
                <td class="label clr_blu">Microsoft Internet Explorer:</td>
                <td><a href="http://www.microsoft.com/ie" target="_blank" class="explicitlink">www.microsoft.com/ie</a></td>
            </tr>
            <tr>
                <td class="label clr_blu">Mozilla Firefox:</td>
                <td><a href="http://www.firefox.com" target="_blank" class="explicitlink">www.firefox.com</a></td>
            </tr>
            <tr>
                <td class="label clr_blu">Opera:</td>
                <td><a href="http://www.opera.com" target="_blank" class="explicitlink">www.opera.com</a></td>
            </tr>
        </table>
    </div>
</asp:Content>
