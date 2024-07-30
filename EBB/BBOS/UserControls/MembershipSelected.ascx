<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MembershipSelected.ascx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipSelected" %>

<!-- Begin MemershipSelected -->
<div class="row nomargin">
    <div class="col-md-12">
        <asp:Literal ID="litCurrentProduct" runat="server" />
    </div>
</div>

<div class="row nomargin">
    <div class="col-md-6">
        <div class="row nomargin">
            <div class="col-md-5">
                <asp:Label for="<%= lblMembershipLevel.ClientID%>" runat="server" CssClass="bbos_blue"><%= Resources.Global.Membership %>:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lblMembershipLevel" runat="server" />
            </div>
        </div>
        <div class="row nomargin">
            <div class="col-md-5">
                <asp:Label for="<%= lblMembershipFee.ClientID%>" runat="server" CssClass="bbos_blue"><%= Resources.Global.MembershipFee %>:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lblMembershipFee" runat="server" />
            </div>
        </div>
        <div class="row nomargin">
            <div class="col-md-5">
                <asp:Label for="<%= lblNumberofUsers.ClientID%>" runat="server" CssClass="bbos_blue"><%= Resources.Global.MembershipLicenses %>:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lblNumberofUsers" runat="server" />
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="row nomargin">
            <div class="col-md-5">
                <asp:Label for="<%= lbBusinessReports.ClientID%>" runat="server" CssClass="bbos_blue"><%= Resources.Global.BusinessReports %>:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lbBusinessReports" runat="server" />
            </div>
        </div>
        <div class="row nomargin" id="trExpressUpdate" runat="server" visible="false">
            <div class="col-md-5">
                <asp:Label for="<%= lblExpressUpdate.ClientID%>" runat="server" CssClass="bbos_blue" ><em>Express Update</em> reports:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lblExpressUpdate" runat="server" />
            </div>
        </div>
        <div class="row nomargin" id="trBlueBook" runat="server" visible="false">
            <div class="col-md-5">
                <asp:Label for="<%= lblBlueBook.ClientID%>" runat="server" CssClass="bbos_blue" ><%= Resources.Global.AdditionalBlueBook %>:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lblBlueBook" runat="server" />
            </div>
        </div>
        <div class="row nomargin" id="trBlueprints" runat="server" visible="false">
            <div class="col-md-5">
                <asp:Label for="<%= lbBlueprints.ClientID%>" runat="server" CssClass="bbos_blue" ><%= Resources.Global.AdditionalBlueprintsSubscription %>:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lbBlueprints" runat="server" />
            </div>
        </div>
        <div class="row nomargin" id="trLSS" runat="server" visible="false">
            <div class="col-md-5">
                <asp:Label for="<%= lbLSS.ClientID%>" runat="server" CssClass="bbos_blue" ><%= Resources.Global.LocalSourceLicenses %>:</asp:Label>
            </div>
            <div class="col-md-7">
                <asp:Label ID="lbLSS" runat="server" />
            </div>
        </div>
    </div>
</div>

<asp:Panel ID="pnlUpgradeMsgs" runat="server">
    <div class="row nomargin_lr mar_top">
        <div class="col-md-12">
            <asp:Literal ID="litUpgradeMsg1" Text="<%$ Resources:Global, MembershipUgradeMsg1 %>" runat="server" />
            <asp:Literal ID="litUpgradeMsg2" Text="<%$ Resources:Global, MembershipUgradeMsg2 %>" runat="server" />
        </div>
    </div>
</asp:Panel>

<div class="row nomargin_lr">
    <div class="col-md-12">
        <hr />
    </div>
</div>

<!-- End MemershipSelected -->
