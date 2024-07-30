<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="MembershipAdditionalLicenses.aspx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipAdditionalLicenses" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register TagPrefix="bbos" TagName="MembershipSelected" Src="~/UserControls/MembershipSelected.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="text-left">
        <bbos:MembershipSelected ID="ucMembershipSelected" runat="server" />

        <div class="row nomargin_lr mar_bot">
            <div class="col-md-12">
                <asp:Literal ID="litAdditionalLicenseAccessLevelMsg" runat="server" Text="<%$ Resources:Global, AdditionalLicensesAccessLevelMsg1 %>"></asp:Literal>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <asp:Repeater ID="repMemberships" runat="server">
                    <ItemTemplate>
                        <div class="row nomargin_lr mar_bot" <%# GetDisabled((int)Eval("prod_PRWebAccessLevel")) %>>
                            <div class="col-md-1 vertical-align-top">
                                <input type="text" maxlength="3" class="form-control" name="txtProductID<%# Eval("prod_ProductID") %>" value="<%# GetProductQuantity((int)Eval("prod_ProductID")) %>" tsiinteger="true" tsimin="true" tsidisplayname="<%# Eval("prod_Name")%>" <%# GetDisabled((int)Eval("prod_PRWebAccessLevel")) %> />
                            </div>
                            <div class="col-md-11 vertical-align-top">
                                <span class="bold">
                                    <%# Eval("prod_Name")%>: <%# UIUtils.GetFormattedCurrency((decimal)Eval("StandardUnitPrice"))%>
                                </span> - <%# Eval("prod_PRDescription")%>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-12">
                <asp:LinkButton ID="btnPrevious" runat="server" CssClass="btn gray_btn" OnClick="btnPrevious_Click">
				<i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Previous %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnNext" runat="server" CssClass="btn gray_btn" OnClick="btnNext_Click">
				    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Next %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
				    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                </asp:LinkButton>
            </div>
        </div>
    </div>

</asp:Content>
