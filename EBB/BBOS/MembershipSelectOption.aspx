<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="MembershipSelectOption.aspx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipSelectOption" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="MembershipSelected" Src="~/UserControls/MembershipSelected.ascx" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function preStdValidation(form) {
            txtCompanyUpdateFaxNumber.removeAttribute("tsiRequired");
            txtCompanyUpdateEmail.removeAttribute("tsiRequired");

            if (cbCompanyUpdates.checked) {
                if (rbCompanyUpdateTypeFax.checked) {
                    txtCompanyUpdateFaxNumber.setAttribute("tsiRequired", "true");
                } else {
                    txtCompanyUpdateEmail.setAttribute("tsiRequired", "true");
                }
            }

            return true;
        }

        function toggleLSS(cbLSS) {
            document.getElementById("<% =txtLSSAdditional.ClientID %>").disabled = true;

            if (cbLSS.checked) {
                document.getElementById("<% =txtLSSAdditional.ClientID %>").disabled = false;
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="text-left">
        <bbos:membershipselected id="ucMembershipSelected" runat="server" />

        <div class="row nomargin_lr mar_bot" id="lblSeries100msg" runat="server" visible="false">
            <div class="col-md-12">
                <span class="bold"><%= Resources.Global.Series100Msg %></span>
            </div>
        </div>

        <div class="row nomargin_lr">
            <div class="col-md-12">
                <%= Resources.Global.MembershipIncludesOneSubscriptionToBPQuarterlyJournal %>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-12">
                <% = Resources.Global.MembershipSelectOptionsMsg %>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-1 text-center">
                <asp:CheckBox ID="cbLSS" onclick="toggleLSS(this);" runat="server" />
                <asp:HiddenField ID="hidLSSTaxClass" runat="server" />
            </div>
            <div class="col-md-11">
                <span class="bold"><%=Resources.Global.LocalSourceLicense %>: <asp:Literal ID="litLSSPrice" runat="server" /></span>. 
                <%=Resources.Global.LocalSourceLicense_Desc1 %>
            </div>
        </div>
        <div class="row nomargin_lr" id="trLSSOptions">
            <div class="col-md-1 text-center">
                <asp:TextBox ID="txtLSSAdditional" MaxLength="3" runat="server" CssClass="form-control" />
                <cc1:FilteredTextBoxExtender TargetControlID="txtLSSAdditional" FilterType="Numbers" runat="server" />
                <asp:HiddenField ID="hidLSSAdditionalTaxClass" runat="server" />
            </div>
            <div class="col-md-11">
                <span class="bold"><asp:Literal ID="litLSSAddtionalPrice" runat="server" /></span>:
                <%=Resources.Global.LocalSourceLicense_Desc2 %>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-1 text-center">
                <asp:TextBox ID="txtAdditionalBlueBook" CssClass="form-control" MaxLength="3" runat="server" tsiInteger="true" tsiMin="0" />
            </div>
            <div class="col-md-11">
                <span class="bold"><asp:Literal ID="lblAdditionalBlueBook" runat="server" />: <asp:Literal ID="lblAdditionalBlueBookPrice" runat="server" /></span>
                <asp:Literal ID="lblAdditionalBlueBookDesc" runat="server" />
                <asp:HiddenField ID="hidAdditionalBlueBookTaxClass" runat="server" />
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-1 text-center">
                <asp:CheckBox ID="cbCompanyUpdates" runat="server" />
            </div>
            <div class="col-md-11">
                <span class="bold"><asp:Literal ID="lblCompanyUpdates" runat="server" />: <asp:Literal ID="lblCompanyUpdatesPrice" runat="server" />.</span>
                <asp:Literal ID="lblCompanyUpdatesDesc" runat="server" />
                <asp:HiddenField ID="hidCompanyUpdatesTaxClass" runat="server" />
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-1 text-center">
                <asp:TextBox ID="txtBlueprints" CssClass="form-control" Columns="3" MaxLength="3" runat="server" tsiInteger="true" tsiMin="0" />
            </div>
            <div class="col-md-11">
                <span class="bold"><asp:Literal ID="lblBlueprints" runat="server" />: <asp:Literal ID="lblBlueprintsPrice" runat="server" />.</span>
                <asp:Literal ID="lblBlueprintsDesc" runat="server" />
                <asp:HiddenField ID="hidBlueprintsTaxClass" runat="server" />
            </div>
        </div>
        
        <div class="row nomargin_lr mar_top">
            <div class="col-md-12 text-center">
                <asp:Label CssClass="explicitlink" ID="lblShippingRates" runat="server" Text="<%$ Resources:Global, ShippingChargesMayApply %>" />
                <cc1:PopupControlExtender ID="pceShippingRates" runat="server" TargetControlID="lblShippingRates" PopupControlID="pnlShippingRates" Position="top" OffsetY="-200" />

                <asp:Panel ID="pnlShippingRates" Style="display: none;" CssClass="Popup" Width="400px" Height="400px" runat="server">
                    <div class="popup_header">
                        <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('contentMain_pnlShippingRates').style.display='none';">&times;</button>
                    </div>
                    <div class="popup_content">
                        <asp:Literal ID="litShippingRates" runat="server" />
                    </div>
                </asp:Panel>
            </div>
        </div>

        <div class="row nomargin_lr">
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
    </div>
</asp:Content>
