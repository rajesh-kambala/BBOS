<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="LocalSourceMarketing.aspx.cs" Inherits="PRCo.BBOS.UI.Web.LocalSourceMarketing" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><%= Resources.Global.LocalSourceMarketing %></h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <asp:Literal ID="litLocalSourceMarketing" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
