<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyAuthorization.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyAuthorization" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">


    <div class="row">
        <div class="col-sm-8 offset-sm-2 Seal text-center">
            <div class="row mar_top_5 mar_bot_5">
                <asp:Label ID="lblCompanyName" runat="server" />&nbsp;<%=Resources.Global.IsCertifiedBy %><br />
                Blue Book Services, Inc. <%=Resources.Global.AsBeingA %><br />
                <asp:Label ID="lblMemberType" runat="server" />
                <%=Resources.Global.Membersince %>
                <asp:Label ID="lblMemberYear" runat="server" />.
            </div>
        </div>
    </div>

    <div class="row mar_top">
        <div class="col-sm-8 offset-sm-2">
            <div class="row">
                <label runat="server" class="clr_blu col-sm-3 nopadding_tb" for="<%= lblSource.ClientID%>"><%= Resources.Global.Source%>:</label>
                <asp:Label ID="lblSource" runat="server" CssClass="col-sm-9 text-center" />
            </div>
            <div class="row">
                <label runat="server" class="clr_blu col-sm-3 nopadding_tb" for="<%= lblDateTime.ClientID%>"><%= Resources.Global.Date%>:</label>
                <asp:Label ID="lblDateTime" runat="server" CssClass="col-sm-9 text-center" />
            </div>
            <div class="row">
                <label runat="server" class="clr_blu col-sm-3 nopadding_tb" for="<%= hlFullCompanyName.ClientID%>"><%= Resources.Global.Company%>:</label>
                <div class="col-sm-9 text-center">
                    <asp:HyperLink ID="hlFullCompanyName" runat="server" CssClass="explicitlink" />
                </div>
            </div>
            <div class="row">
                <div class="col-sm-3 text-nowrap vertical-align-top">
                    <label runat="server" class="clr_blu nopadding_tb"><%= Resources.Global.WhatIsATradingOrTransportationMember%>:</label>
                </div>
                <div class="col-sm-9 text-center vertical-align-top">
                    <%=Resources.Global.WhatIsTradingOrTransportationMember %>
                </div>
            </div>
        </div>
    </div>

    <div class="row mar_top">
        <div class="col-sm-8 offset-sm-2">
            <div class="row">
                <div class="col-sm-5 vertical-align-top text-right">
                    <asp:HyperLink ID="hlLearnMore" runat="server" CssClass="btn gray_btn" Target="_blank">
                        <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, LearnMore %>" />
                    </asp:HyperLink>
                    <asp:HyperLink ID="hlSealMisuse" runat="server" CssClass="btn gray_btn">
                        <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ReportSealMisuse %>" />
                    </asp:HyperLink>
                </div>
                <div class="col-sm-7 vertical-align-top">
                    <%=Resources.Global.VerifySeal1%> <% =GetURLProtocol() %><% =Request.ServerVariables.Get("SERVER_NAME")%>.
                </div>
            </div>
            <div class="row mar_top">
                <div class="col-sm-12">
                    <%=Resources.Global.VerifySeal2%>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
