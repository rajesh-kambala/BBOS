<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PurchaseMembership.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PurchaseMembership" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><%= Resources.Global.PurchaseMembership %></h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <asp:Literal ID="litMembershipSelect" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row nomargin_lr mar_top">
        <div class="col-md-12">
            <asp:LinkButton ID="btnPurchase" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseOnClick">
				<i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Purchase %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
