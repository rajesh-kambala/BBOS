<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="EMCW_Logo.aspx.cs" Inherits="PRCo.BBOS.UI.Web.EMCW_Logo" EnableEventValidation="false" %>

<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function cbIAgree_Click() {
            if (true == cbIAgree.checked) {
                <%=btnSave.ClientID%>.disabled = false;
                <%=btnSave.ClientID%>.href = "javascript:" + PostBackURL.value;
                <%=btnSave.ClientID%>.className = "btn gray_btn"
            }
            else {
                <%=btnSave.ClientID%>.disabled = true;
                <%=btnSave.ClientID%>.href = "";
                <%=btnSave.ClientID%>.className = "aspNetDisabled btn gray_btn"
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin_lr">
        <div class="col-md-3 nomargin nopadding">
            <bbos:EMCW_CompanyHeader ID="ucCompanyDetailsHeader" runat="server" />
            <asp:HiddenField ID="hidCompanyID" runat="server" />
            <asp:HiddenField ID="PostBackURL" runat="server" />
        </div>
        <div class="col-md-9 nomargin nopadding">
            <span class="clr_blu"><%= Resources.Global.PublishingLogoWithComanyInfoAvailable %></span>
        </div>
    </div>

    <div class="text-left">
        <div class="row notice nomargin_lr">
            <div class="col-md-12 text-center">
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-2">
                <div class="clr_blu"><%= Resources.Global.CurrentLogo %>:</div>
            </div>
            <div class="col-md-3 label_top form-inline">
                <asp:Image ID="imgLogo" Visible="false" alt="Logo" runat="server" />
                <asp:Literal ID="litLogo" Visible="false" runat="server" />
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-2">
                <div class="clr_blu"><%= Resources.Global.LogoFile %>:</div>
            </div>
            <div class="col-md-3 label_top form-inline">
                <asp:FileUpload ID="fileLogo" runat="server" Width="500px" tsiRequired="true" tsiDisplayName="Logo File" />
            </div>
        </div>

        <div class="row nomargin panels_box">
            <div class="row nomargin">
                <div class="col-md-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><%= Resources.Global.TermsAndConditions2 %></h4>
                        </div>
                        <div class="panel-body nomargin pad10 gray_bg" style="height:200px; overflow-y: auto;">
                            <% =Resources.Global.LogoAgreementMsg %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-12 form-inline bold">
                <asp:CheckBox ID="cbIAgree" runat="server" CssClass="space "/>
                <%=Resources.Global.PleaseEnterOrderForLogoDisplay %>
            </div>
            <br /><br />
            <div class="col-md-12 form-inline bold">
                <span class="clr_blu"><%= Resources.Global.CustomerSuccessContactInfo%></span>
            </div>
        </div>
    </div>

    <div class="row mar_top nomargin_lr">
        <div class="col-md-12">
            <asp:LinkButton ID="btnSave" runat="server" CssClass="btn gray_btn" OnClick="btnSave_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Save %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
