<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="ContactTradingAssistance.aspx.cs" Inherits="PRCo.BBOS.UI.Web.ContactTradingAssistance" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="text-left">
        <asp:Label ID="ReturnURL" Visible="false" runat="server" />

        <div class="row Title">
            <div class="col-md-12">
                <%=Resources.Global.ExpectResponseWithinOneDay2%> 
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-9 nopadding ind_typ gray_bg mar_top">
                <div class="row nomargin">
                    <div class="col-md-2 clr_blu">
                        <% =Resources.Global.WhatIsTheIssueQuestion %>:
                    </div>
                    <div class="col-md-10">
                        <asp:TextBox ID="txtIssueQuestion" runat="server" Rows="5" MaxLength="500" Width="100%" CssClass="blacktext"
                            tsiRequired="true" tsiDisplayName="<%$ Resources:Global, WhatIsTheIssueQuestion %>" TextMode="MultiLine" onkeypress="ValidateTextAreaLength(this, 500);"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>

        <div class="row nomargin_lr text-left">
            <div class="col-md-12 mar_top">
                <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn gray_btn" OnClick="btnSubmitOnClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSubmit%>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick" OnClientClick="DisableValidation();">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
                </asp:LinkButton>
            </div>
        </div>
    </div>
</asp:Content>
