<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="404NotFound.aspx.cs" Inherits="PRCo.BBOS.UI.Web._04NotFound" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="panel panel-primary col-xs-12">
            <div class="panel-heading">
                <h4 class="blu_tab"><% =Resources.Global.AccessLevel%></h4>
            </div>
            <div class="row panel-body nomargin pad10">
                <div class="col-md-12">
                    <asp:Literal ID="litNotFound" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
