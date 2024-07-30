<%@ Page Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:HiddenField ID="lblLoginCount" runat="server" />
    <div class="card my-3">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">BBSI Mobile Sales Login</h5>

            <div class="row">
                <div class="col-12 mb-2">
                    <asp:TextBox ID="txtUserID" CssClass="form-control form-control-sm" placeholder="email@bluebookservices.com" runat="server" />
                </div>
            </div>

            <div class="row">
                <div class="col-12 mb-2">
                    <asp:TextBox ID="txtPassword" CssClass="form-control form-control-sm" placeholder="Password" TextMode="Password" runat="server" />
                </div>
            </div>

            <div class="row my-3">
                <div class="col-6 text-center">
                    <asp:LinkButton ID="btnLogin" runat="server" CssClass="btn btn-sm btn-bbsi" OnClick="btnLoginOnClick" Width="100%">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Login %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>
</asp:Content>