<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="MembershipComplete.aspx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipComplete" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="text-left">
        <div class="row nomargin">
            <div class="col-md-12">
                <asp:Literal ID="litMembershipCompleteMsg" runat="server" />
            </div>
        </div>
    </div>

    <div class="row nomargin_lr mar_top">
        <div class="col-md-12">
            <asp:LinkButton ID="btnHome" runat="server" CssClass="btn gray_btn" OnClick="btnHomeOnClick">
				<i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, MyHome %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
