<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="MembershipUsers.aspx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipUsers" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="MembershipSelected" Src="~/UserControls/MembershipSelected.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="text-left">
        <bbos:MembershipSelected ID="ucMembershipSelected" runat="server" />

        <div class="row nomargin_lr mar_bot">
            <div class="col-md-12">
                <% =Resources.Global.MembershipAdditionalUserMsg %>
            </div>
        </div>

        <div class="row nomargin bold" id="tblMembershipUsers">
            <div class="col-md-1"></div>
            <div class="col-md-1"><% =Resources.Global.AccessLevel %></div>
            <div class="col-md-2"><% =Resources.Global.Title %></div>
            <div class="col-md-2"><% =Resources.Global.FirstName %></div>
            <div class="col-md-2"><% =Resources.Global.LastName %></div>
            <div class="col-md-4"><% =Resources.Global.EmailAddress%></div>
        </div>
        <div class="row nomargin">
            <asp:Repeater ID="repMembershipUsers" runat="server">
                <ItemTemplate>
                    <div class="row nomargin">
                        <%# IncrementRepeaterCount() %>

                        <div class="col-md-1 text-right"><%# _iRepeaterCount%></div>
                        <div class="col-md-1"><%# GetReferenceValue("prwu_AccessLevel", Eval("AccessLevel2"))%></div>
                        <div class="col-md-2">
                            <input name="txtTitle<%# _iRepeaterCount %>" value="<%# Eval("Title2") %>" maxlength="30" class="form-control"></div>
                        <div class="col-md-2">
                            <input name="txtFirstName<%# _iRepeaterCount %>" value="<%# Eval("FirstName2") %>" maxlength="30" class="form-control"></div>
                        <div class="col-md-2">
                            <input name="txtLastName<%# _iRepeaterCount %>" value="<%# Eval("LastName2") %>" maxlength="30" class="form-control"></div>
                        <div class="col-md-4">
                            <input name="txtEmail<%# _iRepeaterCount %>" value="<%# Eval("Email2") %>" tsidisplayname="<%# Resources.Global.EmailAddress %> <%# _iRepeaterCount%>" tsiemail="true" maxlength="255" class="form-control"></div>
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
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
