<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PersonDetailsUserEdit.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonDetailsUserEdit" 
    MaintainScrollPositionOnPostback="true" ValidateRequest="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit.HtmlEditor" TagPrefix="HTMLEditor" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidPersonID" Visible="false" runat="server" />
    <asp:Label ID="hidPrivateNoteID" Visible="false" runat="server" />
    <asp:Label Width="100%" runat="server" ID="lblPersonName" CssClass="bbos_blue_title mar_bot" />

    <div class="row">
        <div class="col-md-2">
            <label class="bbos_blue" for='<%=txtPrivateNotes.ClientID %>'>
                 <%=Resources.Global.PrivateNotes %>
            </label>
            <br />
            <span class="annotation">Only I can view/edit this note.</span>
        </div>
        <div class="col-md-6">
            <asp:TextBox ID="txtPrivateNotes" Rows="8" Columns="75" TextMode="MultiLine" runat="server" CssClass="form-control" />
        </div>
    </div>

    <%--Buttons--%>
    <div class="row nomargin_lr text-left mar_top20">
        <div class="col-md-10 offset-md-2">
            <asp:LinkButton ID="btnSave" runat="server" CssClass="btn gray_btn" OnClick="btnSaveOnClick">
	        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnSave %>" />
            </asp:LinkButton>

            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
	        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnCancel %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>