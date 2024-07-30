<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchEdit.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SearchEdit" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="col-md-12">
        <div class="row">
            <div class="col-md-2">
                <asp:Label CssClass="bbos_blue_title" for="<%= txtSearchName.ClientID%>" runat="server"><%= Resources.Global.SearchName %>:</asp:Label>
            </div>
            <div class="col-md-8">
                <asp:TextBox ID="txtSearchName" runat="server" Columns="50" MaxLength="50" CssClass="form-control" tsiDisplayName="<%$ Resources:Global, SearchName%>" tsiRequired="true" />
            </div>
        </div>

        <div class="row mar_top_5">
            <div class="col-md-2">
                <asp:Label CssClass="bbos_blue_title" for="<%= chkPrivate.ClientID%>" runat="server"><%= Resources.Global.Private %>:</asp:Label>
            </div>
            <div class="col-md-10 form-inline">
                <asp:CheckBox ID="chkPrivate" runat="server" Checked="true" />
                <asp:Label runat="server" Text="<%$ Resources:Global, OnlyICanEditThisSearch %>" />
            </div>
        </div>

<%--        <div class="row">
            <div class="col-md-2">
                <asp:Label CssClass="bbos_blue_title" for="<%= lblSearchType.ClientID%>" runat="server"><%= Resources.Global.Type %>:</asp:Label>
            </div>
            <div class="col-md-10">
                <asp:Label ID="lblSearchType" runat="server" />
            </div>
        </div>--%>

        <br />

        <%--Buttons--%>
        <div class="row nomargin_lr text-left mar_top20">
            <asp:LinkButton ID="btnSave" runat="server" CssClass="btn gray_btn" OnClick="btnSave_Click">
	            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Save %>" />
            </asp:LinkButton>

            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
	            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Cancel %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
